# Portable environment shared by POSIX login shells and Zsh.

path_prepend() {
  [ -d "$1" ] || return 0
  case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_append() {
  [ -d "$1" ] || return 0
  case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.local/share/mise/shims"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.turso"
path_prepend "$HOME/.opencode/bin"

BUN_INSTALL="$HOME/.bun"
export BUN_INSTALL

case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    PNPM_HOME="$HOME/Library/pnpm"
    path_prepend "$PNPM_HOME"
    path_prepend "$HOME/.jenv/shims"
    path_prepend "$HOME/Library/Android/Sdk/platform-tools"
    path_prepend "/opt/homebrew/opt/postgresql@18/bin"
    path_prepend "/opt/homebrew/opt/libpq/bin"
    path_prepend "/opt/homebrew/opt/icu4c@76/bin"
    path_prepend "/opt/homebrew/opt/icu4c@76/sbin"
    path_prepend "/opt/homebrew/opt/icu4c@74/bin"
    path_prepend "/opt/homebrew/opt/icu4c@74/sbin"
    path_prepend "/Applications/Postgres.app/Contents/Versions/latest/bin"
    path_prepend "$HOME/.antigravity/antigravity/bin"
    ;;
  Linux)
    PNPM_HOME="$HOME/.local/share/pnpm"
    path_prepend "$PNPM_HOME"
    path_prepend "$HOME/Android/Sdk/platform-tools"
    path_prepend "$HOME/Android/Sdk/cmdline-tools/latest/bin"
    ;;
esac

path_append /usr/local/go/bin
path_prepend "$HOME/.local/account-bin"
export PATH PNPM_HOME

if command -v nvim >/dev/null 2>&1; then
  EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
  EDITOR=vim
else
  EDITOR=vi
fi
VISUAL="$EDITOR"
export EDITOR VISUAL

unset -f path_prepend path_append
