#!/usr/bin/env bash
set -euo pipefail

user_name="jweaker"
home_dir="/home/${user_name}"

install -m 755 -o "$user_name" -g "$user_name" /tmp/devrun "$home_dir/.local/bin/devrun"
sudo -u "$user_name" env HOME="$home_dir" PATH="$home_dir/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin" \
  npm install --prefix "$home_dir/.local/share/browser-tools" --omit=dev --no-audit --no-fund playwright
chown -R "$user_name:$user_name" "$home_dir/.local/share/browser-tools"

cat >"$home_dir/.local/bin/a1-screenshot" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin"
if [[ $# -ne 2 ]]; then
  printf 'usage: a1-screenshot <url> <output.png>\n' >&2
  exit 2
fi
exec "$HOME/.local/share/browser-tools/node_modules/.bin/playwright" screenshot --full-page "$1" "$2"
EOF
chmod 755 "$home_dir/.local/bin/a1-screenshot"
chown "$user_name:$user_name" "$home_dir/.local/bin/a1-screenshot"
