#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  apparmor-profiles apparmor-utils bubblewrap clang cmake fonts-dejavu-core fonts-liberation gh git-lfs libasound2t64 \
  libatk-bridge2.0-0 libatk1.0-0 libayatana-appindicator3-dev libcairo2 \
  libcups2 libdrm2 libgbm1 libgtk-3-dev libjavascriptcoregtk-4.1-dev \
  libnss3 libpango-1.0-0 librsvg2-dev libssl-dev libwebkit2gtk-4.1-dev \
  libx11-xcb1 libxcomposite1 libxdamage1 libxdo-dev libxfixes3 libxkbcommon0 \
  libxrandr2 llvm mold ninja-build python3 python3-dev python3-pip xvfb

# Ubuntu 24.04 restricts unprivileged user namespaces through AppArmor. Load
# the packaged narrow bubblewrap profile required by Codex instead of turning
# that kernel protection off globally.
if [[ -f /usr/share/apparmor/extra-profiles/bwrap-userns-restrict ]]; then
  install -m 0644 \
    /usr/share/apparmor/extra-profiles/bwrap-userns-restrict \
    /etc/apparmor.d/bwrap-userns-restrict
  apparmor_parser -r /etc/apparmor.d/bwrap-userns-restrict
fi

echo 'System development libraries are installed.'
