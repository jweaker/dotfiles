#!/usr/bin/env bash
set -euo pipefail

git_name="${1:?Git name is required}"
git_email="${2:?Git email is required}"
key="${HOME}/.ssh/id_ed25519_github_a1"

install -d -m 700 "${HOME}/.ssh"
if [[ ! -f "$key" ]]; then
  ssh-keygen -q -t ed25519 -a 100 -N '' -C 'jweaker@a1-oracle-dubai' -f "$key"
fi
chmod 600 "$key"
chmod 644 "${key}.pub"

touch "${HOME}/.ssh/config"
chmod 600 "${HOME}/.ssh/config"
if ! grep -q '^Host github.com$' "${HOME}/.ssh/config"; then
  cat >>"${HOME}/.ssh/config" <<'EOF'

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_a1
    IdentitiesOnly yes
EOF
fi

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global pull.ff only
git config --global core.editor nvim
git config --global gpg.format ssh

printf '%s\n' "${key}.pub"
