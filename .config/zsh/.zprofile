# ┌──────────────────────────────────────────────────────────────┐
# │ arpatek - Zsh Profile (macOS)                                │
# │ Loaded for login shells, including non-interactive SSH runs. │
# └──────────────────────────────────────────────────────────────┘

# ──[ Homebrew ]────────────────────────────────────────────────────────────────
# Apple Silicon uses /opt/homebrew; Intel uses /usr/local
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ──[ PATH ]────────────────────────────────────────────────────────────────────
[ -d "$HOME/bin" ]        && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# ──[ Rust (Cargo / Rustup) ]───────────────────────────────────────────────────
export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"
[ -d "$CARGO_HOME/bin" ] && export PATH="$CARGO_HOME/bin:$PATH"

# ──[ Go ]──────────────────────────────────────────────────────────────────────
# Go installed via Homebrew — binary already in PATH via brew shellenv
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"

# ──[ Python (pyenv) ]──────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.local/share/pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# ──[ Kubernetes ]──────────────────────────────────────────────────────────────
export KUBECONFIG="$HOME/.config/kube/config"
export KUBECACHEDIR="$HOME/.cache/kube"

# ──[ npm ]─────────────────────────────────────────────────────────────────────
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export NPM_CONFIG_CACHE="$HOME/.cache/npm"
