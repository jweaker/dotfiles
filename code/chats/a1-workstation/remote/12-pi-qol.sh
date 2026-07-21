#!/usr/bin/env bash
set -euo pipefail

user_name="jweaker"
home_dir="/home/${user_name}"
[[ ${EUID} -eq 0 ]] || { printf 'Run with sudo.\n' >&2; exit 1; }
id "$user_name" >/dev/null

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
  bash-completion bat ca-certificates curl fd-find fzf git git-lfs jq less mosh \
  neovim ripgrep rsync tmux unzip yadm zsh

usermod -s /usr/bin/zsh "$user_name"
loginctl enable-linger "$user_name"
install -d -m 700 -o "$user_name" -g "$user_name" \
  "$home_dir/.config" "$home_dir/.local/bin" "$home_dir/.local/state"

if command -v batcat >/dev/null 2>&1 && [[ ! -e /usr/local/bin/bat ]]; then
  ln -s /usr/bin/batcat /usr/local/bin/bat
fi
if command -v fdfind >/dev/null 2>&1 && [[ ! -e /usr/local/bin/fd ]]; then
  ln -s /usr/bin/fdfind /usr/local/bin/fd
fi

printf '%s\n' 'Pi base quality-of-life packages installed. Run 03-dotfiles.sh as jweaker next.'
