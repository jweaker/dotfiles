# A1 workstation status — 2026-07-21

## Verified working

- Ubuntu 24.04 ARM64, 4 OCPUs, 23 GiB RAM visible, 193 GiB root filesystem, 8 GiB swap.
- Root/password/keyboard-interactive SSH disabled; public-key forwarding allowed only for development ports; agent and X11 forwarding disabled.
- `ssh a1` uses `a1.tail70e8a6.ts.net`; `ssh a1-public` retains the Oracle public-IP recovery path.
- Tailscale direct path measured at 47 ms. Tailscale SSH and Mosh both passed live connection tests.
- Tailnet-only T3 URLs: short `http://a1` and secure `https://a1.tail70e8a6.ts.net/`.
- T3 `0.0.29-nightly.20260720.859` runs as `t3-a1.service` on loopback port 3773.
- Atomic T3 install/activation, idle deferral, health rollback, daily SQLite snapshots, and retention timers are enabled.
- Mac T3 Nightly changes trigger exact-version A1 installation through `xyz.jweaker.a1-t3-sync`.
- Mac helpers: `a1-code`, `a1-port`, and `a1-pair`.
- A1 persistent dev-server helper: `devrun`. Headless Chromium screenshot helper: `a1-screenshot`.
- Node 24, Bun, uv, Rust, Tauri/Electron Linux dependencies, Wrangler, Codex, Claude Code, Neovim, Git LFS, GitHub CLI, Playwright Chromium, Xvfb, Mosh, tmux, and YADM installed.
- GitHub machine SSH key registered and verified. Private key remains only on A1.
- GitHub CLI and Wrangler OAuth sessions are installed on A1 and verified against the intended accounts.
- Codex profiles `amore`, `main`, and `new` imported mode 0600. Each now has an isolated `CODEX_HOME`; `main` is the default, switching no longer waits for running processes, and the Mac-to-A1 label sync is one-way.
- The official standalone Codex build, Bubblewrap AppArmor profile, and Remote Control daemon are working. A fresh phone pairing code can be generated on demand.
- Powerlevel10k prompt selection is deterministic across embedded and normal terminals; Starship is no longer a conditional fallback.
- Portable shell/dotfile changes, Mac helper LaunchAgents, and the non-secret workstation provisioning assets are committed to `jweaker/dotfiles`.
- Cloudflare Tunnel `a1-code` routes `code.jweaker.xyz` through Cloudflare Access to the JWT-validating T3 pairing bridge. The public hostname redirects to Access and the origin rejects requests without a valid assertion.
- The accidental `code.jweaker.xyz.itsocr.com` DNS record was deleted; the existing DigitalOcean/itsocr tunnels were not modified.

## Intentionally waiting on the owner

- T3 Connect headless authorization code, then service restart/verification.
- A fresh Claude Code login; the Mac Keychain entry contained no active tokens and was not usable.
- Change the password disclosed in chat on both macOS and A1. SSH password authentication is already disabled.
- Enter the Raspberry Pi sudo password once to install its staged quality-of-life packages; SSH key access now works.

## Design decisions

- New conversations and agent processes live on A1; clients reconnect to that single state instead of syncing live databases.
- The existing Mac T3 database (310 threads / 8,844 messages when inspected) remains untouched because merging or concurrently syncing T3 SQLite databases is unsupported and path-sensitive.
- iOS Simulator, macOS signing, and native Mac GUI inspection stay on the Mac. A1 handles web/backends, Metro, headless browser QA, Linux Electron/Tauri builds, and Cloudflare work.
- `devrun` is optional and independent of `a1-port`: it adds persistence/logging only. Direct Tailnet development access uses `http://a1:PORT` with the server bound specifically to the Tailscale address.
