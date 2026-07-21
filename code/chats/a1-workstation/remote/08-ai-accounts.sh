#!/usr/bin/env bash
set -euo pipefail

user_name="jweaker"
home_dir="/home/${user_name}"
user_uid="$(id -u "$user_name")"
runtime_dir="/run/user/${user_uid}"

install -m 755 -o "$user_name" -g "$user_name" /tmp/ai-account "$home_dir/.local/bin/ai-account"
install -m 755 -o "$user_name" -g "$user_name" /tmp/codex-account-wrapper "$home_dir/.local/bin/codex"
install -m 644 -o "$user_name" -g "$user_name" /tmp/codex-remote-control@.service \
  "$home_dir/.config/systemd/user/codex-remote-control@.service"
install -d -m 700 -o "$user_name" -g "$user_name" \
  "$home_dir/.local/share/ai-accounts/codex/main" \
  "$home_dir/.local/share/ai-accounts/codex/amore" \
  "$home_dir/.local/share/ai-accounts/codex/new" \
  "$home_dir/.local/share/ai-accounts/claude" \
  "$home_dir/.config/systemd/user"
chown -R "$user_name:$user_name" "$home_dir/.local/share/ai-accounts"

sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
  systemctl --user disable --now ai-account-activate.timer 2>/dev/null || true
rm -f \
  "$home_dir/.config/systemd/user/ai-account-activate.service" \
  "$home_dir/.config/systemd/user/ai-account-activate.timer"
sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
  systemctl --user daemon-reload
sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
  systemctl --user enable --now codex-remote-control@main.service
sudo -u "$user_name" env HOME="$home_dir" bash -c 'cd "$HOME" && "$HOME/.local/bin/ai-account" list'
