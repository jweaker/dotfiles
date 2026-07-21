#!/usr/bin/env bash
set -euo pipefail

version="${1:?Pass the exact T3 version to install}"
user_name="jweaker"
home_dir="/home/${user_name}"
user_uid="$(id -u "$user_name")"
runtime_dir="/run/user/${user_uid}"
user_path="$home_dir/.local/bin:$home_dir/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin"

install -d -m 700 -o "$user_name" -g "$user_name" \
  "$home_dir/.local/share/t3" \
  "$home_dir/.local/share/t3/data" \
  "$home_dir/.local/share/t3/backups" \
  "$home_dir/.config/systemd/user" \
  "$home_dir/code"
install -m 755 -o "$user_name" -g "$user_name" /tmp/t3-sync "$home_dir/.local/bin/t3-sync"
install -m 755 -o "$user_name" -g "$user_name" /tmp/t3-snapshot "$home_dir/.local/bin/t3-snapshot"

cat >"$home_dir/.local/bin/t3-current" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin"
binary="${HOME}/.local/share/t3/current/node_modules/.bin/t3"
[[ -x "$binary" ]] || { printf 'No active T3 version. Run t3-sync status.\n' >&2; exit 1; }
exec "$binary" "$@"
EOF
chmod 755 "$home_dir/.local/bin/t3-current"
chown "$user_name:$user_name" "$home_dir/.local/bin/t3-current"

cat >"$home_dir/.config/systemd/user/t3-a1.service" <<'EOF'
[Unit]
Description=T3 Code headless workspace
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=%h/code
Environment=PATH=%h/.local/bin:%h/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin
Environment=NODE_ENV=production
ExecStart=%h/.local/bin/t3-current serve --mode web --host 127.0.0.1 --port 3773 --base-dir %h/.local/share/t3/data --no-browser
Restart=on-failure
RestartSec=5
TimeoutStopSec=30

[Install]
WantedBy=default.target
EOF

cat >"$home_dir/.config/systemd/user/t3-snapshot.service" <<'EOF'
[Unit]
Description=Create an integrity-checked T3 Code snapshot

[Service]
Type=oneshot
ExecStart=%h/.local/bin/t3-snapshot daily
EOF

cat >"$home_dir/.config/systemd/user/t3-snapshot.timer" <<'EOF'
[Unit]
Description=Daily T3 Code snapshots

[Timer]
OnCalendar=*-*-* 03:20:00
Persistent=true
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
EOF

cat >"$home_dir/.config/systemd/user/t3-activate.service" <<'EOF'
[Unit]
Description=Activate a queued T3 Code version when providers are idle

[Service]
Type=oneshot
ExecStart=%h/.local/bin/t3-sync activate
EOF

cat >"$home_dir/.config/systemd/user/t3-activate.timer" <<'EOF'
[Unit]
Description=Check for queued T3 Code updates

[Timer]
OnBootSec=2m
OnUnitActiveSec=5m
Persistent=true

[Install]
WantedBy=timers.target
EOF

chown -R "$user_name:$user_name" "$home_dir/.config/systemd/user" "$home_dir/.local/share/t3"

sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
  systemctl --user daemon-reload
sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" PATH="$user_path" \
  "$home_dir/.local/bin/t3-sync" install "$version"
sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
  systemctl --user enable --now t3-a1.service t3-snapshot.timer t3-activate.timer
sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" PATH="$user_path" \
  "$home_dir/.local/bin/t3-sync" status
