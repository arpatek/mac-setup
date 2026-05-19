# mac-setup

Personal macOS dotfiles and bootstrap installer — installs all tools via Homebrew, symlinks configs, and sets up a full development environment from scratch.

> Linux dotfiles live in a separate repo: [dotfiles](https://codeberg.org/arpatek/dotfiles)

---

## Contents

| File | Description |
|---|---|
| `lib.sh` | Shared utilities — colors, decoration functions, `cache_sudo` |
| `install.sh` | Full bootstrap — Homebrew, Brewfile, zsh plugins, LazyVim, symlinks |
| `uninstall.sh` | Full cleanup — removes all packages, symlinks, and environments |
| `mpu` | Mac Package Updater — updates Homebrew formulae, casks, and cleans up |
| `ipkg` | Interactive Homebrew browser — fuzzy-find to install or remove formulae and casks |
| `Brewfile` | Declarative package list for all formulae, casks, and App Store apps |
| `.zshenv` | Sets `ZDOTDIR` so zsh finds all config under `~/.config/zsh/` |
| `.config/zsh/.zshrc` | Zsh config — plugins, fzf, zoxide, pyenv, Go, starship |
| `.config/zsh/.zprofile` | Login shell env — Homebrew PATH, pyenv, Go |
| `.config/zsh/.zsh_aliases` | Aliases for navigation, git, SSH, networking, and macOS utilities |
| `.config/starship.toml` | Starship prompt — catppuccin macchiato palette, two-line with OS icon, git, path |
| `.config/git/config` | Git config — aliases, editor, fetch prune, autosquash, colorMoved |
| `.config/git/commit-template` | Conventional commit template |
| `.config/vim/vimrc` | Minimal Vim config for CLI workflows |
| `.config/tmux/tmux.conf` | tmux — truecolor, vi copy mode with pbcopy, 50k scrollback |
| `.config/nvim/init.vim` | Neovim fallback config for nvim < 0.9 |
| `.config/curlrc` | curl defaults — follow redirects, retry, fail-fast |
| `.config/lazygit/config.yml` | lazygit catppuccin mocha theme |
| `.config/zed/settings.json` | Zed editor settings |
| `.config/iterm2/arpatek.itermcolors` | iTerm2 color scheme |
| `.aerospace.toml` | AeroSpace tiling window manager config |
| `.editorconfig` | Universal indent/charset rules for all editors |
| `.ssh/config` | SSH — global ControlMaster defaults and connection templates |
| `.gitignore` | Repo-level ignores |

---

## Installation

Clone and run the installer. It handles everything automatically.

```bash
git clone git@codeberg.org:arpatek/mac-setup.git ~/Git/mac-setup
cd ~/Git/mac-setup
./install.sh
```

The installer will:
- Auto-upgrade to bash 4+ via Homebrew if running macOS's default bash 3.2
- Install Xcode Command Line Tools if missing
- Install Homebrew if missing
- Install all packages from the Brewfile (formulae, casks, App Store apps)
- Clone zsh plugins directly — no plugin manager needed
- Clone the LazyVim starter (requires nvim ≥ 0.9; falls back to `init.vim`)
- Symlink all dotfiles into place under `~/.config/`
- Install mpu and ipkg to `$(brew --prefix)/bin`
- Launch zsh on completion

**To skip package installation** (re-link only):

```bash
./install.sh --skip-packages
```

**To uninstall:**

```bash
./uninstall.sh
```

Uninstalls all Brewfile packages, removes symlinks, plugins, pyenv, and LazyVim.

> **Note:** After install, import the iTerm2 color scheme manually:
> iTerm2 → Settings → Profiles → Colors → Color Presets → Import → `~/.config/iterm2/arpatek.itermcolors`

---

## Home Directory Layout

All shell and tool config lives under `~/.config/` (XDG-compliant). The only files
installed directly to `$HOME` are:

| File | Why it must stay in `$HOME` |
|---|---|
| `~/.zshenv` | Sets `ZDOTDIR` — zsh reads this before any other file |
| `~/.editorconfig` | EditorConfig walks up from the project root, falls back to `$HOME` |
| `~/.ssh/` | SSH has no XDG support |
| `~/.aerospace.toml` | AeroSpace requires config at `$HOME/.aerospace.toml` |

---

## mpu — Mac Package Updater

Updates Homebrew formulae, casks (including auto-updating apps with `--greedy`), runs cleanup, and checks for issues.

```
Usage: mpu [OPTIONS]
Options:
  -h, --help      Show this help message
  -V, --version   Show version
  -n, --dry-run   Print commands without executing them
```

---

## Packages

### Formulae

| Category | Packages |
|---|---|
| Shell | bash, zsh, tmux, starship |
| Core CLI | git, curl, wget, aria2, tree, nmap, make, gcc, grep |
| Modern CLI | bat, eza, fastfetch, btop, ncdu, fzf, zoxide, lazygit, yazi, lynx, shellcheck, shfmt, asciinema, asciiquarium |
| Dev | go, node, deno, pyenv, docker, neovim |
| Network | cloudflared, mole, wireguard-tools |
| Media | ffmpeg, yt-dlp |

### Casks

| Category | Apps |
|---|---|
| Terminals | iTerm2 |
| Browsers | Firefox, Zen, Helium |
| Editors | VSCode, Zed, BetterDisplay |
| AI | Claude, ChatGPT |
| Productivity | Obsidian |
| Window Management | AeroSpace |
| Media | IINA, OBS, Steam |
| Utilities | Keka, UTM |
| Fonts | JetBrains Mono Nerd Font |

### App Store (mas)

Hidden Bar · Codye · WireGuard · Wipr 2 · Amphetamine · CleanMyMac

---

## Zsh Features

| Feature | Detail |
|---|---|
| No plugin manager | Plugins cloned to `~/.config/zsh/plugins/` by the installer |
| Syntax highlighting | `fast-syntax-highlighting` — faster than zsh-syntax-highlighting |
| Autosuggestions | History-first with completion fallback, 20-char buffer cap |
| History substring search | Type any part of a past command, Up/Down cycles all matches |
| Completions | `zsh-completions` with 24-hour compinit dump cache in `~/.cache/zsh/` |
| Fuzzy finder | fzf — `Ctrl+R` history, `Ctrl+T` file picker, `Alt+C` fuzzy cd |
| Smart jump | zoxide — `z <query>` jumps to most-frecent directory, `zi` interactive |
| Prompt | Starship — catppuccin macchiato, two-line with OS icon, user@host, path, git |
| Vi mode toggle | Double `Esc` enters vi command mode, double `Esc` again returns to emacs |
| History | 50,000 entries, all-duplicates removed, timestamps, shared across sessions |
| `AUTO_CD` | Type a directory name to navigate without `cd` |
| `GLOB_DOTS` | Glob patterns include dotfiles without `.*` |
| `NO_BEEP` | Disables terminal bell |

---

## Zsh Aliases

| Alias | Command |
|---|---|
| `la` / `ll` / `lll` / `ltree` | eza file listings with icons and git status |
| `cat` | `bat --plain` — syntax-highlighted drop-in replacement |
| `bcat` | `bat` — full bat with line numbers, highlighting, and pager |
| `grep` | `ggrep --color=auto` — GNU grep with `-P` Perl regex support |
| `flushdns` | Flush macOS DNS cache |
| `showfiles` / `hidefiles` | Toggle hidden files in Finder |
| `pubkey` | Copy SSH public key to clipboard via pbcopy |
| `ipinfo` | `ipconfig getifaddr en0` |
| `ssh` | Wraps ssh with `TERM=xterm-256color` to fix Ghostty terminfo errors on remotes |
| `pi` / `rhel` / `dev` | SSH into configured hosts |
| `reload` | `exec zsh` |

---

## ipkg — Interactive Homebrew Browser

| Key | Action |
|---|---|
| `alt+f` | Install formulae (default, green markers) |
| `alt+c` | Install casks (green markers) |
| `alt+r` | Remove installed formulae (red markers) |
| `alt+x` | Remove installed casks (red markers) |
| `Tab` | Multi-select |
| `alt+p` | Toggle preview panel |
| `alt+j` / `alt+k` | Scroll preview line by line |
| `alt+d` / `alt+u` | Scroll preview half-page |

---

## AeroSpace Key Bindings

| Binding | Action |
|---|---|
| `Alt+hjkl` | Focus window left/down/up/right |
| `Alt+Shift+hjkl` | Move window left/down/up/right |
| `Alt+1-9` | Switch to workspace |
| `Alt+Shift+1-9` | Move window to workspace |
| `Alt+Tab` | Toggle previous workspace |
| `Alt+Enter` | Open iTerm2 |
| `Alt+b` | Open Zen browser |
| `Alt+c` | Open VSCode |
| `Alt+Shift+;` | Enter service mode |

---

## tmux Key Bindings

| Binding | Action |
|---|---|
| `C-a` | Prefix (replaces `C-b`) |
| `Prefix + \|` | Split vertically |
| `Prefix + -` | Split horizontally |
| `Prefix + r` | Reload config |
| `v` (copy mode) | Begin selection |
| `y` (copy mode) | Copy to clipboard via pbcopy |

---

## SSH Keys

The SSH config references key files not included in this repo. Generate them with:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/git.codeberg.key   -C "Codeberg | $(hostname)" -N ""
ssh-keygen -t ed25519 -f ~/.ssh/git.github.key     -C "GitHub | $(hostname)"   -N ""
ssh-keygen -t ed25519 -f ~/.ssh/git.gitlab.key     -C "GitLab | $(hostname)"   -N ""
ssh-keygen -t ed25519 -f ~/.ssh/netrunner-rpi.key  -C "netrunner | $(hostname)" -N ""
ssh-keygen -t ed25519 -f ~/.ssh/dev-rhel-0.key     -C "rhel-0 | $(hostname)"   -N ""
ssh-keygen -t ed25519 -f ~/.ssh/dev-ubuntu-0.key   -C "ubuntu-0 | $(hostname)" -N ""
```

Add the `.pub` files to their respective services and `authorized_keys` files.
