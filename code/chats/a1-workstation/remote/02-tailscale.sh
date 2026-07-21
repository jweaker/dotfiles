#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

systemctl enable --now tailscaled.service

if tailscale status --json 2>/dev/null | jq -e '.BackendState == "Running"' >/dev/null; then
  tailscale set --ssh=true --accept-dns=true
  echo 'Tailscale is already connected; SSH and DNS are enabled.'
else
  echo 'Tailscale is installed but still needs interactive tailnet enrollment.'
  echo 'Run: sudo tailscale up --ssh --accept-dns=true --hostname=a1'
fi
