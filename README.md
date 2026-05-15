# mac-setup

Personal macOS dotfiles and bootstrap installer — installs all tools via Homebrew, symlinks configs, and sets up a full development environment from scratch.

> Linux dotfiles live in a separate repo: [dotfiles](https://codeberg.org/arpatek/dotfiles)

---

## Contents

| File | Description |
|---|---|
| `lib.sh` | Shared utilities — colors, decoration functions, `cache_sudo` |
| `install.sh` | Full bootstrap — Homebrew, Brewfile, zinit, LazyVim, symlinks |
| `uninstall.sh` | Full cleanup — removes all packages, symlinks, and environments |
| `mpu` | Mac Package Updater — updates Homebrew formulae, casks, and cleans up |
| `Brewfile` | Declarative package list for all formulae, casks, and App Store apps |
| `.zshrc` | Zsh config — Zinit, fzf, zoxide, pyenv, Go, plugins |
| `.zprofile` | Login shell env — Homebrew PATH, pyenv, Go |
| `.zsh_aliases` | Aliases for navigation, git, SSH, networking, and macOS utilities |
| `.zsh/themes/arpatek.zsh-theme` | Custom two-line Zsh prompt with git status |
| `.tmux.conf` | tmux — truecolor, vi copy mode with pbcopy, 50k scrollback |
| `.gitconfig` | Git config — aliases, editor, fetch prune, autosquash, colorMoved |
| `.git-commit-template` | Conventional commit template |
| `.vimrc` | Minimal Vim config for CLI workflows |
| `.config/nvim/init.vim` | Neovim fallback config for nvim < 0.9 |
| `.ssh/config` | SSH — global ControlMaster defaults and connection templates |
| `.editorconfig` | Universal indent/charset rules for all editors |
| `.curlrc` | curl defaults — follow redirects, retry, fail-fast |
| `.aerospace.toml` | AeroSpace tiling window manager config |
| `.config/lazygit/config.yml` | lazygit catppuccin mocha theme |
| `.config/zed/settings.json` | Zed editor settings |
| `.config/iterm2/arpatek.itermcolors` | iTerm2 color scheme |
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
- Bootstrap zinit and LazyVim
- Symlink all dotfiles into place
- Install mpu to `$(brew --prefix)/bin`
- Launch zsh on completion

**To skip package installation** (re-link only):

```bash
./install.sh --skip-packages
```

**To uninstall:**

```bash
./uninstall.sh
```

Uninstalls all Brewfile packages, removes symlinks, pyenv, zinit, and LazyVim.

> **Note:** After install, import the iTerm2 color scheme manually:
> iTerm2 → Settings → Profiles → Colors → Color Presets → Import → `~/.config/iterm2/arpatek.itermcolors`

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
| Shell | bash, zsh, tmux |
| Core CLI | git, curl, wget, aria2, tree, nmap, make, gcc, grep |
| Modern CLI | bat, eza, fastfetch, btop, ncdu, fzf, zoxide, lazygit, yazi, lynx, shellcheck, shfmt, asciinema, asciiquarium |
| Dev | go, node, deno, pyenv, docker, neovim, shellcheck, shfmt |
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
| Plugin manager | Zinit with lazy loading and annexes |
| Syntax highlighting | `fast-syntax-highlighting` — faster than zsh-syntax-highlighting |
| Autosuggestions | History-first with completion fallback, 20-char buffer cap |
| Completions | `zsh-completions` with 24-hour compinit dump cache |
| Fuzzy finder | fzf — `Ctrl+R` history, `Ctrl+T` file picker, `Alt+C` fuzzy cd |
| Smart jump | zoxide — `z <query>` jumps to most-frecent directory, `zi` interactive |
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
| `pi` / `rhel` / `dev` | SSH into configured hosts |
| `reload` | `exec zsh` |

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
