#!/usr/bin/env bash
# =============================================================================
# Script Name: install.sh
# Description: macOS dotfiles installer — bootstraps Homebrew, installs
#              packages via Brewfile, and symlinks dotfiles into place.
# Author: Juan Garcia (arpatek)
# Created: 2026-05-15
# Version: 1.0
# =============================================================================

# ──[ Bash Bootstrap ]──────────────────────────────────────────────────────────
# macOS ships bash 3.2 which lacks associative arrays (declare -A) required by
# this script. Re-exec with Homebrew bash 4+ if available; install it if not.
if ((BASH_VERSINFO[0] < 4)); then
  for _b in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    [[ -x "$_b" ]] && exec "$_b" "$0" "$@"
  done

  printf "bash 3.x detected — installing Homebrew and bash 4+...\n"
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  brew install bash

  for _b in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    [[ -x "$_b" ]] && exec "$_b" "$0" "$@"
  done

  printf "install.sh: could not upgrade bash — install manually: brew install bash\n" >&2
  exit 1
fi

set -eo pipefail

# ──[ Paths ]───────────────────────────────────────────────────────────────────
MAC_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ──[ Shared Utilities ]────────────────────────────────────────────────────────
source "$MAC_SETUP_DIR/lib.sh"

# ──[ Error Trap ]──────────────────────────────────────────────────────────────
trap 'printf "\n%s Installation failed. Aborting.\n" "$(FAILED)"' ERR

# ──[ Argument Parsing ]────────────────────────────────────────────────────────
SKIP_PACKAGES=false

usage() {
  printf "Usage: install.sh [OPTIONS]\n"
  printf "Options:\n"
  printf "  -h, --help            Show this help message\n"
  printf "  --skip-packages       Skip Homebrew bootstrap (symlinks only)\n"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  --skip-packages) SKIP_PACKAGES=true ;;
  *)
    printf "Unknown option: %s\n" "$1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

# ──[ Privileged Session Caching ]──────────────────────────────────────────────
cache_sudo

# ──[ Backup Function ]─────────────────────────────────────────────────────────
backup() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -r "$target" "$BACKUP_DIR/"
    printf "%s Backed up %s\n" "$(PLUS)" "$target"
  fi
}

# ──[ Symlink Function ]────────────────────────────────────────────────────────
link() {
  local src="$1"
  local dst="$2"
  backup "$dst"
  ln -sf "$src" "$dst"
  printf "%s Linked %s\n" "$(COMPLETE)" "$dst"
}

# ──[ Package Bootstrap ]───────────────────────────────────────────────────────
bootstrap_xcode() {
  if xcode-select -p &>/dev/null; then
    printf "%s Xcode Command Line Tools already installed\n" "$(COMPLETE)"
    return
  fi
  printf "%s Installing Xcode Command Line Tools...\n" "$(PLUS)"
  xcode-select --install
  # Block until the install completes
  until xcode-select -p &>/dev/null; do sleep 5; done
  printf "%s Xcode Command Line Tools installed\n" "$(COMPLETE)"
}

bootstrap_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    printf "%s Homebrew already installed\n" "$(COMPLETE)"
    return
  fi
  printf "%s Installing Homebrew...\n" "$(PLUS)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for the remainder of this script
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  printf "%s Homebrew installed\n" "$(COMPLETE)"
}

bootstrap_packages() {
  printf "%s Installing packages from Brewfile...\n" "$(PLUS)"
  brew bundle --file="$MAC_SETUP_DIR/Brewfile"
  printf "%s Brewfile packages installed\n" "$(COMPLETE)"
}

bootstrap_zinit() {
  if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    printf "%s zinit already installed\n" "$(COMPLETE)"
    return
  fi
  printf "%s Installing zinit...\n" "$(PLUS)"
  # NO_INPUT=1 suppresses the post-install prompt about annexes — they are
  # already declared in .zshrc so there is nothing extra to set up
  NO_INPUT=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
  printf "%s zinit installed\n" "$(COMPLETE)"
}

bootstrap_lazyvim() {
  if ! command -v nvim >/dev/null 2>&1; then
    printf "%s nvim not found — skipping LazyVim install\n" "$(PLUS)"
    return
  fi

  local nvim_ver nvim_minor
  nvim_ver=$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  nvim_minor=${nvim_ver##*.}

  if (( ${nvim_ver%%.*} == 0 && nvim_minor < 9 )); then
    printf "%s nvim %s < 0.9 — linking init.vim fallback\n" "$(PLUS)" "$nvim_ver"
    mkdir -p "$HOME/.config/nvim"
    link "$MAC_SETUP_DIR/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
    return
  fi

  if [[ -d "$HOME/.config/nvim" && -n "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]]; then
    printf "%s ~/.config/nvim already populated — skipping LazyVim install\n" "$(PLUS)"
    return
  fi

  printf "%s Installing LazyVim starter...\n" "$(PLUS)"
  if git clone --depth 1 https://github.com/LazyVim/starter "$HOME/.config/nvim" 2>/dev/null; then
    rm -rf "$HOME/.config/nvim/.git"
    printf "%s LazyVim installed — open nvim to complete plugin setup\n" "$(COMPLETE)"
  else
    printf "%s LazyVim clone failed — linking init.vim fallback\n" "$(PLUS)"
    link "$MAC_SETUP_DIR/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
  fi
}

# ──[ Installation ]────────────────────────────────────────────────────────────
printf "%s Starting macOS Dotfiles Installation\n" "$(BANNER)"
sleep 1

if ! $SKIP_PACKAGES; then
  printf "%s Bootstrapping Dependencies\n" "$(BANNER)"
  sleep 0.5
  bootstrap_xcode
  bootstrap_homebrew
  bootstrap_packages
  bootstrap_zinit
  bootstrap_lazyvim
  printf "\n"
fi

printf "%s Creating Directories\n" "$(BANNER)"
sleep 0.5
mkdir -p ~/.zsh/themes
mkdir -p ~/.config/lazygit
mkdir -p ~/.config/zed
mkdir -p ~/.ssh/
printf "%s Directories ready\n\n" "$(COMPLETE)"
sleep 1

printf "%s Symlinking Dotfiles\n" "$(BANNER)"
sleep 0.5

printf "%s Shell\n" "$(BANNER)"
sleep 0.2
link "$MAC_SETUP_DIR/.zshrc"                              ~/.zshrc
sleep 0.2
link "$MAC_SETUP_DIR/.zprofile"                           ~/.zprofile
sleep 0.2
link "$MAC_SETUP_DIR/.zsh_aliases"                        ~/.zsh_aliases
sleep 0.2
link "$MAC_SETUP_DIR/.zsh/themes/arpatek.zsh-theme"       ~/.zsh/themes/arpatek.zsh-theme
printf "\n"

printf "%s Terminal & Editor\n" "$(BANNER)"
sleep 0.2
link "$MAC_SETUP_DIR/.tmux.conf"                          ~/.tmux.conf
sleep 0.2
link "$MAC_SETUP_DIR/.vimrc"                              ~/.vimrc
sleep 0.2
link "$MAC_SETUP_DIR/.git-commit-template"                ~/.git-commit-template
sleep 0.2
link "$MAC_SETUP_DIR/.editorconfig"                       ~/.editorconfig
sleep 0.2
link "$MAC_SETUP_DIR/.config/zed/settings.json"           ~/.config/zed/settings.json
printf "\n"

printf "%s Tools & System\n" "$(BANNER)"
sleep 0.2
link "$MAC_SETUP_DIR/.gitconfig"                          ~/.gitconfig
sleep 0.2
link "$MAC_SETUP_DIR/.curlrc"                             ~/.curlrc
sleep 0.2
link "$MAC_SETUP_DIR/.config/lazygit/config.yml"          ~/.config/lazygit/config.yml
sleep 0.2
link "$MAC_SETUP_DIR/.aerospace.toml"                     ~/.aerospace.toml
printf "\n"

printf "%s iTerm2\n" "$(BANNER)"
sleep 0.2
# Copied rather than symlinked — iTerm2 imports colors internally
mkdir -p ~/.config/iterm2
cp "$MAC_SETUP_DIR/.config/iterm2/arpatek.itermcolors" \
   ~/.config/iterm2/arpatek.itermcolors
printf "%s Copied arpatek.itermcolors\n" "$(COMPLETE)"
printf "\n"
sleep 1

printf "%s Installing SSH Config\n" "$(BANNER)"
sleep 0.5
backup ~/.ssh/config
cp "$MAC_SETUP_DIR/.ssh/config" ~/.ssh/config
chmod 600 ~/.ssh/config
printf "%s SSH config installed\n\n" "$(COMPLETE)"
sleep 1

printf "%s Installing mpu\n" "$(BANNER)"
sleep 0.5
# Homebrew manages /usr/local/bin on Intel; /opt/homebrew/bin on Apple Silicon
MPU_DEST="$(brew --prefix)/bin/mpu"
ln -sf "$MAC_SETUP_DIR/mpu" "$MPU_DEST"
printf "%s mpu installed to %s\n\n" "$(COMPLETE)" "$MPU_DEST"
sleep 1

printf "%s Installing ipkg\n" "$(BANNER)"
sleep 0.5
IPKG_DEST="$(brew --prefix)/bin/ipkg"
ln -sf "$MAC_SETUP_DIR/ipkg" "$IPKG_DEST"
printf "%s ipkg installed to %s\n\n" "$(COMPLETE)" "$IPKG_DEST"
sleep 1

printf "%s Installation Complete\n" "$(COMPLETE)"
[[ -d "$BACKUP_DIR" ]] && printf "%s Backups saved to %s\n" "$(PLUS)" "$BACKUP_DIR"
printf "%s Deployment complete. Entering the shell.\n" "$(LAMBDA)"
exec zsh
