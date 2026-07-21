# A1 workstation setup

This directory contains the reproducible provisioning and integration assets for the Oracle A1 coding workstation. Secrets, OAuth credentials, Tailscale state, Cloudflare tunnel credentials, and SSH private keys must never be stored here.

## Installed layout

- `t3-a1.service` runs the exact T3 Code Nightly version selected by `~/.local/share/t3/current` on loopback port 3773.
- `t3-sync` installs versions atomically, queues activation while Codex or Claude is active, health-checks the new version, and rolls back on failure.
- `t3-snapshot.timer` creates integrity-checked SQLite backups daily under `~/.local/share/t3/backups` (14 daily and 10 weekly weeks).
- `ai-account` gives each Codex profile an isolated `CODEX_HOME`; changing the default affects new processes immediately without interrupting running sessions.
- `devrun` is an optional convenience for development servers that should survive SSH disconnects and gain service-style logs/restarts.
- `a1-screenshot` provides a headless Chromium screenshot smoke test for agent/browser work.
- Mac LaunchAgents mirror the installed T3 Nightly version and the selected Codex profile label to the A1.

## Everyday commands

On the Mac:

```sh
ssh a1                         # normal shell
mosh a1                        # resilient shell after Tailscale enrollment
a1-code                        # open the persistent A1 T3 workspace
a1-pair open                   # pair this Mac at the Tailnet HTTPS origin
a1-pair short                  # pair and open the short http://a1 origin
a1-pair copy                   # copy a five-minute pairing link for a phone
a1-port 3000                   # localhost:3000 -> A1 localhost:3000
a1-port 8080 8081              # A1 :8080 -> Mac :8081
```

On the A1:

```sh
t3-sync status
t3-sync rollback
ai-account list
ai-account login codex main
ai-account use codex main
ai-account run codex amore     # explicit one-off account, concurrently
ai-account login claude main
devrun start web 3000 -- bun run dev -- --hostname 127.0.0.1
devrun status web
devrun logs web
devrun stop web
a1-screenshot http://127.0.0.1:3000 /tmp/web.png
```

Use the same absolute repo path on both machines when a CLI session must be moved. Prefer starting Codex, Claude, and T3 conversations on the A1 and reconnecting to them instead of synchronizing live session databases.

The short private T3 URL is `http://a1`; Tailscale MagicDNS resolves `a1` on every signed-in Tailnet device. The secure origin remains `https://a1.tail70e8a6.ts.net/`. Both are Tailnet-only. `code.jweaker.xyz` uses a separate Cloudflare Tunnel and must remain behind an Access Allow policy for the exact owner email.

## Account profiles

The A1 currently uses independently protected files under `~/.local/share/ai-accounts`. Common operations are:

```sh
ai-account use codex main
ai-account use codex amore
ai-account use codex new
ai-account run codex main
ai-account login claude main
ai-account login claude second
ai-account use claude second
```

`ai-account use codex LABEL` changes the default for newly launched Codex processes immediately. Already-running sessions keep the account-specific home they started with. `ai-account run codex LABEL` starts an explicit concurrent terminal session without changing the default. The Mac LaunchAgent synchronizes the Codex Switcher label one-way to A1 and never logs token values. The initial Codex Switcher profiles were imported over encrypted SSH; separate device login remains the recovery path if an OAuth provider rotates or revokes a refresh token.

## Development server choices

`a1-port` and `devrun` are independent:

- Run any normal server on A1 at `127.0.0.1:3000`, then run `a1-port 3000` on the Mac. No `devrun` is required.
- Use `devrun` only when the server should outlive the SSH shell, restart automatically, or have easy `status`/`logs` commands. A normal shell, tmux, or T3 terminal is also fine.
- To reach a server directly from any Tailnet device, bind it specifically to the A1 Tailscale address (`tailscale ip -4`) and open `http://a1:PORT`. Avoid `0.0.0.0` unless you intentionally want every network interface to listen.

## Codex Remote Control

The standalone Codex build, Bubblewrap, and Ubuntu's narrow AppArmor profile are installed. A persistent Remote Control daemon is enabled for the `main` profile. Generate a fresh short-lived phone pairing code with:

```sh
ssh -t a1 'ai-account run codex main remote-control pair'
```

The phone must confirm the same ChatGPT account and workspace as that A1 profile. A different ChatGPT account cannot control the `main` host pairing. To pair through another already-enrolled profile without changing the default account:

```sh
ssh a1 'systemctl --user enable --now codex-remote-control@new.service'
ssh -t a1 'ai-account run codex new remote-control pair'
```

## Platform boundaries

- Next.js, Workers, backends, tests, and browser automation run normally on A1.
- React Native Metro can run on A1; use Expo Go/tunnel or a physical device. iOS Simulator and macOS signing remain on the Mac.
- Tauri/Electron web UI and Linux builds can run under Xvfb on A1. macOS application builds and native GUI inspection remain on the Mac.
- Default to `127.0.0.1` plus SSH forwarding. Bind explicitly to the Tailscale IP only when another Tailnet device needs direct access.

## Provisioning order

The numbered scripts are idempotent enough for repair/replay in order. `10-cloudflare-bridge.sh` intentionally installs a fail-closed bridge without enabling it; the Cloudflare Access application AUD must be written to `~/.config/t3-bridge.env` before enabling the service.

The complete non-secret provisioning directory and Mac helper scripts are tracked by YADM. For the Raspberry Pi, use only `12-pi-qol.sh` followed by `03-dotfiles.sh`; the A1 hardening and workstation packages are intentionally not applied to the home server.
