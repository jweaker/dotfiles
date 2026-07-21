#!/usr/bin/env bash
set -euo pipefail

tunnel_id="${1:?Tunnel ID is required}"
hostname="${2:?Hostname is required}"
credential_source="/tmp/a1-code-tunnel.json"

[[ "$tunnel_id" =~ ^[0-9a-f-]{36}$ ]] || { printf 'Invalid tunnel ID.\n' >&2; exit 2; }
[[ "$hostname" =~ ^[0-9A-Za-z.-]+$ ]] || { printf 'Invalid hostname.\n' >&2; exit 2; }
[[ -s "$credential_source" ]] || { printf 'Tunnel credential is missing.\n' >&2; exit 1; }

if ! command -v cloudflared >/dev/null 2>&1; then
  temporary_deb="$(mktemp /tmp/cloudflared-arm64.XXXXXX.deb)"
  curl -fsSL --retry 3 \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb \
    -o "$temporary_deb"
  apt-get install -y "$temporary_deb"
  rm -f -- "$temporary_deb"
fi

install -d -m 700 -o root -g root /etc/cloudflared
install -m 600 -o root -g root "$credential_source" "/etc/cloudflared/${tunnel_id}.json"
shred -u -- "$credential_source"
cat >/etc/cloudflared/config.yml <<EOF
tunnel: ${tunnel_id}
credentials-file: /etc/cloudflared/${tunnel_id}.json

ingress:
  - hostname: ${hostname}
    service: http://127.0.0.1:3774
  - service: http_status:404
EOF
chmod 600 /etc/cloudflared/config.yml

cat >/etc/systemd/system/cloudflared-a1.service <<'EOF'
[Unit]
Description=Cloudflare Tunnel for the A1 coding workspace
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/cloudflared --no-autoupdate --config /etc/cloudflared/config.yml tunnel run
Restart=on-failure
RestartSec=5
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now cloudflared-a1.service
systemctl is-active cloudflared-a1.service
cloudflared tunnel ingress validate
