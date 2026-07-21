import http from "node:http";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import httpProxy from "http-proxy";
import { createRemoteJWKSet, jwtVerify } from "jose";

const execFileAsync = promisify(execFile);
const listenHost = "127.0.0.1";
const listenPort = Number(process.env.BRIDGE_PORT || 3774);
const target = "http://127.0.0.1:3773";
const issuer = process.env.CF_ACCESS_ISSUER;
const audience = process.env.CF_ACCESS_AUD;
const allowedEmails = new Set((process.env.ALLOWED_EMAILS || "").split(",").map((value) => value.trim().toLowerCase()).filter(Boolean));
const publicBaseUrl = process.env.PUBLIC_BASE_URL || "https://code.jweaker.xyz";

if (!issuer || !audience || audience === "CHANGE_ME" || allowedEmails.size === 0) {
  throw new Error("CF_ACCESS_ISSUER, CF_ACCESS_AUD, and ALLOWED_EMAILS must be configured");
}

const normalizedIssuer = issuer.replace(/\/$/, "");
const jwks = createRemoteJWKSet(new URL(`${normalizedIssuer}/cdn-cgi/access/certs`));
const proxy = httpProxy.createProxyServer({ target, ws: true, xfwd: true });
const lastPairByEmail = new Map();

proxy.on("error", (_error, _request, response) => {
  if (response?.writeHead) {
    response.writeHead(502, { "content-type": "text/plain; charset=utf-8" });
    response.end("A1 T3 backend unavailable\n");
  }
});

async function identity(request) {
  const assertion = request.headers["cf-access-jwt-assertion"];
  if (typeof assertion !== "string" || !assertion) throw new Error("missing Access assertion");
  const { payload } = await jwtVerify(assertion, jwks, { issuer: normalizedIssuer, audience });
  const email = String(payload.email || "").toLowerCase();
  if (!allowedEmails.has(email)) throw new Error("email is not allowed");
  return email;
}

function hasBridgeCookie(request) {
  return String(request.headers.cookie || "").split(/;\s*/).includes("a1_t3_bootstrap=1");
}

async function pairUrl(email) {
  const now = Date.now();
  const previous = lastPairByEmail.get(email) || 0;
  if (now - previous < 15_000) throw new Error("pairing is rate limited");
  lastPairByEmail.set(email, now);
  const executable = `${process.env.HOME}/.local/bin/t3-current`;
  const { stdout } = await execFileAsync(executable, [
    "auth", "pairing", "create",
    "--base-dir", `${process.env.HOME}/.local/share/t3/data`,
    "--ttl", "2m",
    "--label", `cloudflare:${email}`,
    "--base-url", publicBaseUrl,
    "--json",
  ], { timeout: 10_000, maxBuffer: 64 * 1024 });
  const parsed = JSON.parse(stdout);
  if (typeof parsed.pairUrl !== "string" || !parsed.pairUrl.startsWith(`${publicBaseUrl}/pair#`)) {
    throw new Error("unexpected pairing response");
  }
  return parsed.pairUrl;
}

const server = http.createServer(async (request, response) => {
  try {
    const email = await identity(request);
    if (!hasBridgeCookie(request) && request.url !== "/healthz") {
      const location = await pairUrl(email);
      response.writeHead(302, {
        location,
        "set-cookie": "a1_t3_bootstrap=1; Path=/; Max-Age=600; Secure; HttpOnly; SameSite=Lax",
        "cache-control": "no-store",
      });
      response.end();
      return;
    }
    if (request.url === "/healthz") {
      response.writeHead(200, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
      response.end("ok\n");
      return;
    }
    proxy.web(request, response);
  } catch {
    response.writeHead(403, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
    response.end("Cloudflare Access authorization required.\n");
  }
});

server.on("upgrade", async (request, socket, head) => {
  try {
    await identity(request);
    proxy.ws(request, socket, head);
  } catch {
    socket.write("HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n");
    socket.destroy();
  }
});

server.listen(listenPort, listenHost, () => {
  console.log(`T3 Access bridge listening on http://${listenHost}:${listenPort}`);
});
