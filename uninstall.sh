#!/usr/bin/env bash
# =============================================================================
# Script Name: uninstall.sh
# Description: macOS dotfiles uninstaller — removes symlinks, uninstalls
#              Homebrew packages, and restores clean system state.
# Author: Juan Garcia (arpatek)
# Created: 2026-05-15
# Version: 1.0
# =============================================================================

# ──[ Bash Version Check ]──────────────────────────────────────────────────────
if ((BASH_VERSINFO[0] < 4)); then
  printf "uninstall.sh requires bash 4 or higher (detected: %s)\n" "$BASH_VERSION" >&2
  exit 1
fi

set -o pipefail

# ──[ Paths ]───────────────────────────────────────────────────────────────────
MAC_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ──[ Shared Utilities ]────────────────────────────────────────────────────────
source "$MAC_SETUP_DIR/lib.sh"

# ──[ Privileged Session Caching ]──────────────────────────────────────────────
cache_sudo

# ──[ Helpers ]─────────────────────────────────────────────────────────────────
ERRORS=0

warn() {
  printf "%s %s\n" "$(FAILED)" "$1" >&2
  (( ERRORS++ )) || true
}

unlink_file() {
  local target="$1"
  if [[ -L "$target" ]]; then
    rm "$target" && printf "%s Removed symlink %s\n" "$(COMPLETE)" "$target" \
      || warn "Could not remove symlink $target"
  else
    printf "%s Skipped %s (not a symlink)\n" "$(PLUS)" "$target"
  fi
}

remove_dir() {
  local target="$1"
  local label="${2:-$target}"
  if [[ -d "$target" ]]; then
    rm -rf "$target" && printf "%s Removed %s\n" "$(COMPLETE)" "$label" \
      || warn "Could not fully remove $label"
  else
    printf "%s Not found, skipping: %s\n" "$(PLUS)" "$label"
  fi
}

remove_file() {
  local target="$1"
  local use_sudo="${2:-false}"
  if [[ -f "$target" || -L "$target" ]]; then
    if $use_sudo; then
      sudo rm -f "$target" && printf "%s Removed %s\n" "$(COMPLETE)" "$target" \
        || warn "Could not remove $target"
    else
      rm -f "$target" && printf "%s Removed %s\n" "$(COMPLETE)" "$target" \
        || warn "Could not remove $target"
    fi
  else
    printf "%s Not found, skipping: %s\n" "$(PLUS)" "$target"
  fi
}

confirm() {
  printf "%s %s [y/N] " "$(BANNER)" "$1"
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ──[ Restore Backups ]─────────────────────────────────────────────────────────
restore_backups() {
  local backup_base="$HOME/.dotfiles_backup"
  if [[ ! -d "$backup_base" ]]; then
    printf "%s No backup directory found\n" "$(PLUS)"
    return
  fi

  local latest
  latest=$(ls -t "$backup_base" | head -1)
  if [[ -z "$latest" ]]; then
    printf "%s No backups found\n" "$(PLUS)"
    return
  fi

  printf "%s Restoring from %s/%s\n" "$(BANNER)" "$backup_base" "$latest"
  sleep 0.5
  for file in "$backup_base/$latest"/.*  "$backup_base/$latest"/*; do
    [[ -e "$file" ]] || continue
    cp -r "$file" "$HOME/" && printf "%s Restored %s\n" "$(COMPLETE)" "$(basename "$file")" \
      || warn "Could not restore $(basename "$file")"
  done
}

# ──[ Uninstallation ]──────────────────────────────────────────────────────────
printf "%s Starting macOS Dotfiles Uninstall\n" "$(BANNER)"
sleep 1

# ── Homebrew packages ─────────────────────────────────────────────────────────
printf "%s Homebrew Package Removal\n" "$(BANNER)"
sleep 0.5
if command -v brew >/dev/null 2>&1; then
  printf "%s The following packages would be removed:\n" "$(PLUS)"
  brew bundle cleanup --file="$MAC_SETUP_DIR/Brewfile" 2>/dev/null || true
  printf "\n"
  if confirm "Remove all Brewfile packages listed above?"; then
    brew bundle cleanup --force --file="$MAC_SETUP_DIR/Brewfile" \
      && printf "%s Brewfile packages removed\n" "$(COMPLETE)" \
      || warn "brew bundle cleanup had errors"
  else
    printf "%s Skipping package removal\n" "$(PLUS)"
  fi
else
  printf "%s Homebrew not found, skipping package removal\n" "$(PLUS)"
fi
printf "\n"
sleep 1

# ── LazyVim / Neovim config ───────────────────────────────────────────────────
printf "%s Removing LazyVim / Neovim config\n" "$(BANNER)"
sleep 0.5
unlink_file "$HOME/.config/nvim/init.vim"
remove_dir "$HOME/.config/nvim"      "~/.config/nvim"
remove_dir "$HOME/.local/share/nvim" "~/.local/share/nvim (plugin data)"
remove_dir "$HOME/.local/state/nvim" "~/.local/state/nvim"
remove_dir "$HOME/.cache/nvim"       "~/.cache/nvim"
printf "\n"
sleep 1

# ── pyenv ─────────────────────────────────────────────────────────────────────
printf "%s Removing pyenv\n" "$(BANNER)"
sleep 0.5
remove_dir "$HOME/.pyenv" "~/.pyenv"
printf "\n"
sleep 1

# ── zinit ─────────────────────────────────────────────────────────────────────
printf "%s Removing zinit\n" "$(BANNER)"
sleep 0.5
# Remove both possible install locations — new installs use ~/.local/share/zinit,
# older installs may still be at ~/.zinit
remove_dir "$HOME/.local/share/zinit" "~/.local/share/zinit"
remove_dir "$HOME/.zinit"             "~/.zinit (legacy location)"
printf "\n"
sleep 1

# ── mpu ───────────────────────────────────────────────────────────────────────
printf "%s Removing mpu\n" "$(BANNER)"
sleep 0.5
if command -v brew >/dev/null 2>&1; then
  remove_file "$(brew --prefix)/bin/mpu"
fi
printf "\n"

# ── SSH Config ────────────────────────────────────────────────────────────────
printf "%s Removing SSH Config\n" "$(BANNER)"
sleep 0.5
remove_file ~/.ssh/config
printf "\n"

# ── Default shell — revert before dotfiles are removed ───────────────────────
printf "%s Reverting default shell to zsh (system)\n" "$(BANNER)"
sleep 0.5
SYSTEM_ZSH="/bin/zsh"
if [[ -n "$SYSTEM_ZSH" && "$SHELL" != "$SYSTEM_ZSH" ]]; then
  sudo chsh -s "$SYSTEM_ZSH" "$USER" \
    && printf "%s Default shell reverted to %s\n\n" "$(COMPLETE)" "$SYSTEM_ZSH" \
    || warn "chsh failed — revert shell manually: sudo chsh -s $SYSTEM_ZSH $USER"
else
  printf "%s Already using system zsh, skipping\n\n" "$(PLUS)"
fi

# ── Dotfile symlinks — last so PATH stays intact throughout ──────────────────
printf "%s Removing Dotfile Symlinks\n" "$(BANNER)"
sleep 0.5
unlink_file ~/.zsh/themes/arpatek.zsh-theme
unlink_file ~/.tmux.conf
unlink_file ~/.gitconfig
unlink_file ~/.vimrc
unlink_file ~/.editorconfig
unlink_file ~/.curlrc
unlink_file ~/.config/lazygit/config.yml
unlink_file ~/.config/zed/settings.json
unlink_file ~/.aerospace.toml
remove_file "$HOME/.config/iterm2/arpatek.itermcolors"
unlink_file ~/.zsh_aliases
unlink_file ~/.zprofile
unlink_file ~/.zshrc
remove_dir "$HOME/.zsh" "~/.zsh"
printf "\n"
sleep 1

# ── Backups ───────────────────────────────────────────────────────────────────
if confirm "Restore pre-install backups from ~/.dotfiles_backup?"; then
  printf "\n"
  restore_backups
  printf "\n"
fi

if confirm "Delete ~/.dotfiles_backup?"; then
  remove_dir "$HOME/.dotfiles_backup" "~/.dotfiles_backup"
  printf "\n"
fi

if (( ERRORS > 0 )); then
  printf "%s Uninstall finished with %d warning(s) — check output above\n" \
    "$(FAILED)" "$ERRORS"
else
  printf "%s Uninstall Complete — system restored to clean state\n" "$(COMPLETE)"
fi
