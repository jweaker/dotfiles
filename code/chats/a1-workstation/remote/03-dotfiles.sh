#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Run this script as the jweaker user, not root." >&2
  exit 1
fi

backup_dir="$HOME/.local/state/pre-a1-dotfiles"
install -d -m 700 "$backup_dir"

for relative_path in \
  .zshrc .zprofile .profile .p10k.zsh .tmux.conf \
  .config/starship.toml .config/shell .config/zsh .local/bin/bootstrap-shell; do
  if [[ -e "$HOME/$relative_path" && ! -e "$backup_dir/$relative_path" ]]; then
    install -d -m 700 "$backup_dir/$(dirname "$relative_path")"
    cp -a "$HOME/$relative_path" "$backup_dir/$relative_path"
  fi
done

if ! yadm rev-parse --git-dir >/dev/null 2>&1; then
  yadm init
  yadm remote add origin https://github.com/jweaker/dotfiles.git
fi

yadm fetch --depth=1 origin master
yadm sparse-checkout init --no-cone
yadm sparse-checkout set --no-cone \
  .zshrc \
  .zprofile \
  .profile \
  .p10k.zsh \
  .tmux.conf \
  .config/starship.toml \
  .config/shell/env.sh \
  .config/zsh/common.zsh \
  .config/zsh/linux.zsh \
  .config/zsh/macos.zsh \
  .config/zsh/plugins.zsh \
  .config/zsh/prompt.zsh \
  .local/bin/bootstrap-shell \
  .local/bin/ai-account \
  .local/account-bin/claude \
  code/chats/a1-workstation
yadm checkout -f -B master origin/master
yadm config branch.master.remote origin
yadm config branch.master.merge refs/heads/master
yadm perms

"$HOME/.local/bin/bootstrap-shell"

zsh -n \
  "$HOME/.zshrc" \
  "$HOME/.zprofile" \
  "$HOME/.config/zsh/"*.zsh
sh -n "$HOME/.profile" "$HOME/.config/shell/env.sh"

echo 'Sparse dotfiles deployment complete.'
