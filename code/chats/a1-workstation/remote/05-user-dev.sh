#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Run this script as the jweaker user, not root." >&2
  exit 1
fi

install -d -m 755 \
  "$HOME/.local/bin" \
  "$HOME/.local/share" \
  "$HOME/.config" \
  "$HOME/code"

if [[ ! -x "$HOME/.local/bin/mise" ]]; then
  curl -fsSL https://mise.run | sh
fi

mise_bin="$HOME/.local/bin/mise"
"$mise_bin" settings set experimental true
"$mise_bin" use --global node@24
"$mise_bin" use --global bun@latest
"$mise_bin" use --global uv@latest
"$mise_bin" reshim

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
corepack enable
npm install --global wrangler
"$mise_bin" reshim

# Remote Control requires the standalone build managed by OpenAI's installer.
curl -fsSL https://chatgpt.com/codex/install.sh | sh
# The portable dotfiles already put ~/.local/bin on PATH deterministically.
# Avoid carrying an installer-managed, host-specific PATH block in .zshrc.
sed -i '/^# >>> Codex installer >>>$/,/^# <<< Codex installer <<<$/{d;}' "$HOME/.zshrc"

if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal
fi
export PATH="$HOME/.cargo/bin:$PATH"
rustup default stable
rustup component add rustfmt clippy

if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

nvim_release=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest)
nvim_version=$(jq -r '.tag_name' <<<"$nvim_release")
nvim_url=$(jq -r '.assets[] | select(.name == "nvim-linux-arm64.tar.gz") | .browser_download_url' <<<"$nvim_release")
if [[ -z "$nvim_version" || "$nvim_version" == null || -z "$nvim_url" || "$nvim_url" == null ]]; then
  echo 'Could not resolve the current Neovim ARM64 release.' >&2
  exit 1
fi
nvim_root="$HOME/.local/share/nvim/$nvim_version"
if [[ ! -x "$nvim_root/bin/nvim" ]]; then
  archive=$(mktemp)
  trap 'rm -f "$archive"' EXIT
  curl -fsSL "$nvim_url" -o "$archive"
  install -d -m 755 "$nvim_root"
  tar -xzf "$archive" --strip-components=1 -C "$nvim_root"
  rm -f "$archive"
  trap - EXIT
fi
ln -sfn "$nvim_root/bin/nvim" "$HOME/.local/bin/nvim"

if [[ ! -e "$HOME/.config/nvim" ]]; then
  git clone https://github.com/jweaker/nvim.git "$HOME/.config/nvim"
elif [[ -d "$HOME/.config/nvim/.git" && -z $(git -C "$HOME/.config/nvim" status --porcelain) ]]; then
  git -C "$HOME/.config/nvim" pull --ff-only
fi

npx --yes playwright@latest install chromium

git lfs install --skip-repo

printf '%s\n' \
  "mise: $(mise --version)" \
  "node: $(node --version)" \
  "npm: $(npm --version)" \
  "bun: $(bun --version)" \
  "uv: $(uv --version)" \
  "rust: $(rustc --version)" \
  "nvim: $(nvim --version | head -n1)" \
  "codex: $(codex --version)" \
  "claude: $(claude --version)" \
  "wrangler: $(wrangler --version | head -n1)"
