#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

hostnamectl set-hostname a1
if grep -qE '^127\.0\.1\.1[[:space:]]+' /etc/hosts; then
  sed -i -E 's/^127\.0\.1\.1[[:space:]].*/127.0.1.1 a1/' /etc/hosts
else
  printf '%s\n' '127.0.1.1 a1' >>/etc/hosts
fi

apt-get update
apt-get install -y --no-install-recommends \
  acl bash-completion bat btop build-essential ca-certificates curl direnv dnsutils \
  fd-find file fzf git git-lfs gnupg htop jq less lsof mosh nala ncdu needrestart \
  nftables openssh-client openssh-server pkg-config ripgrep rsync shellcheck sqlite3 \
  sudo tmux tree unattended-upgrades unzip wget xz-utils yadm zip zoxide zsh

ln -sfn /usr/bin/fdfind /usr/local/bin/fd
ln -sfn /usr/bin/batcat /usr/local/bin/bat

systemctl disable --now rpcbind.service rpcbind.socket 2>/dev/null || true
systemctl enable --now unattended-upgrades.service
systemctl enable --now systemd-timesyncd.service 2>/dev/null || true

if ! swapon --show=NAME --noheadings | grep -qx '/swapfile'; then
  if [[ ! -f /swapfile ]]; then
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
  fi
  swapon /swapfile
fi
if ! grep -qE '^/swapfile[[:space:]]' /etc/fstab; then
  printf '%s\n' '/swapfile none swap sw 0 0' >>/etc/fstab
fi

install -d -m 755 /etc/sysctl.d
install -m 644 /dev/null /etc/sysctl.d/99-a1-workstation.conf
printf '%s\n' \
  'vm.swappiness = 10' \
  'fs.inotify.max_user_watches = 524288' \
  'fs.inotify.max_user_instances = 1024' \
  >/etc/sysctl.d/99-a1-workstation.conf
sysctl --system >/dev/null

install -d -m 755 /etc/systemd/journald.conf.d
install -m 644 /dev/null /etc/systemd/journald.conf.d/a1-workstation.conf
printf '%s\n' \
  '[Journal]' \
  'SystemMaxUse=500M' \
  'RuntimeMaxUse=200M' \
  'MaxRetentionSec=30day' \
  >/etc/systemd/journald.conf.d/a1-workstation.conf
systemctl restart systemd-journald.service

install -d -o jweaker -g jweaker -m 755 \
  /home/jweaker/code \
  /home/jweaker/.local/bin \
  /home/jweaker/.local/share \
  /home/jweaker/.config/systemd/user
chown jweaker:jweaker /home/jweaker/.local /home/jweaker/.config
chsh -s /usr/bin/zsh jweaker
loginctl enable-linger jweaker

install -d -m 755 /etc/ssh/sshd_config.d
install -m 644 /dev/null /etc/ssh/sshd_config.d/60-a1-workstation.conf
printf '%s\n' \
  'PermitRootLogin no' \
  'PasswordAuthentication no' \
  'KbdInteractiveAuthentication no' \
  'PubkeyAuthentication yes' \
  'X11Forwarding no' \
  'AllowAgentForwarding no' \
  'AllowTcpForwarding yes' \
  'GatewayPorts no' \
  'PermitTunnel no' \
  'ClientAliveInterval 60' \
  'ClientAliveCountMax 3' \
  'AllowUsers jweaker ubuntu' \
  >/etc/ssh/sshd_config.d/60-a1-workstation.conf
sshd -t
systemctl reload ssh.service

echo 'Base provisioning complete.'
