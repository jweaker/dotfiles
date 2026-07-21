#!/usr/bin/env bash
set -euo pipefail

user_name="jweaker"
home_dir="/home/${user_name}"
user_uid="$(id -u "$user_name")"
runtime_dir="/run/user/${user_uid}"
bridge_dir="$home_dir/.local/share/t3-bridge"

install -d -m 700 -o "$user_name" -g "$user_name" "$bridge_dir" "$home_dir/.config/systemd/user"
install -m 600 -o "$user_name" -g "$user_name" /tmp/t3-bridge.mjs "$bridge_dir/server.mjs"
sudo -u "$user_name" env HOME="$home_dir" PATH="$home_dir/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin" \
  npm install --prefix "$bridge_dir" --omit=dev --no-audit --no-fund http-proxy jose
chown -R "$user_name:$user_name" "$bridge_dir"

cat >"$home_dir/.local/bin/t3-bridge-enable" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
audience="${1:?usage: t3-bridge-enable <Cloudflare-Access-AUD>}"
[[ "$audience" =~ ^[0-9A-Za-z_-]{20,128}$ ]] || { printf 'Unexpected Access AUD format.\n' >&2; exit 2; }
environment="${HOME}/.config/t3-bridge.env"
temporary="${environment}.tmp.$$"
awk -v value="$audience" 'BEGIN { replaced=0 } /^CF_ACCESS_AUD=/ { print "CF_ACCESS_AUD=" value; replaced=1; next } { print } END { if (!replaced) print "CF_ACCESS_AUD=" value }' "$environment" >"$temporary"
chmod 600 "$temporary"
mv -f -- "$temporary" "$environment"
systemctl --user daemon-reload
systemctl --user enable --now t3-bridge.service
sleep 1
systemctl --user is-active t3-bridge.service
code="$(curl --max-time 3 --silent --output /dev/null --write-out '%{http_code}' http://127.0.0.1:3774/ || true)"
[[ "$code" == 403 ]] || { printf 'Bridge fail-closed check returned HTTP %s, expected 403.\n' "$code" >&2; exit 1; }
printf 'Cloudflare Access bridge is active and rejects requests without a valid Access JWT.\n'
EOF
chmod 755 "$home_dir/.local/bin/t3-bridge-enable"
chown "$user_name:$user_name" "$home_dir/.local/bin/t3-bridge-enable"

if [[ ! -f "$home_dir/.config/t3-bridge.env" ]]; then
  cat >"$home_dir/.config/t3-bridge.env" <<'EOF'
CF_ACCESS_ISSUER=https://jweaker.cloudflareaccess.com
CF_ACCESS_AUD=CHANGE_ME
ALLOWED_EMAILS=jweaker.t@gmail.com
PUBLIC_BASE_URL=https://code.jweaker.xyz
BRIDGE_PORT=3774
EOF
  chmod 600 "$home_dir/.config/t3-bridge.env"
  chown "$user_name:$user_name" "$home_dir/.config/t3-bridge.env"
fi

cat >"$home_dir/.config/systemd/user/t3-bridge.service" <<'EOF'
[Unit]
Description=Cloudflare Access to T3 pairing bridge
After=network-online.target t3-a1.service
Wants=network-online.target
Requires=t3-a1.service

[Service]
Type=simple
WorkingDirectory=%h/.local/share/t3-bridge
Environment=PATH=%h/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin
EnvironmentFile=%h/.config/t3-bridge.env
ExecStart=%h/.local/share/mise/shims/node %h/.local/share/t3-bridge/server.mjs
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
chown "$user_name:$user_name" "$home_dir/.config/systemd/user/t3-bridge.service"

sudo -u "$user_name" env HOME="$home_dir" XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
  systemctl --user daemon-reload
printf '%s\n' 'Bridge installed but intentionally not enabled until the Cloudflare Access AUD is configured.'
