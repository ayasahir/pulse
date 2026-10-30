#!/usr/bin/env bash
# healthcheck.sh - basic Linux and network health check.
# Usage: ./healthcheck.sh [HOST] [DOMAIN] [PORT]
#   HOST    IP or name to ping          (default: 1.1.1.1)
#   DOMAIN  name to resolve and connect (default: example.com)
#   PORT    TCP port to test on DOMAIN  (default: 443)

set -euo pipefail

HOST="${1:-1.1.1.1}"
DOMAIN="${2:-example.com}"
PORT="${3:-443}"
DISK_LIMIT=80
FAILED=0

ok()   { printf '[ OK ] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; FAILED=$((FAILED + 1)); }

# --- Disk: percentage used on / ---
usage=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')
if [ "$usage" -lt "$DISK_LIMIT" ]; then
    ok "disk usage on / is ${usage}%"
else
    fail "disk usage on / is ${usage}% (limit ${DISK_LIMIT}%)"
fi

# --- Load: 1-minute load average versus number of CPU cores ---
load=$(cut -d' ' -f1 /proc/loadavg)
cores=$(nproc)
# bash cannot compare decimals, so let awk do it
if awk -v l="$load" -v c="$cores" 'BEGIN { exit !(l < c) }'; then
    ok "load average ${load} on ${cores} cores"
else
    fail "load average ${load} is high for ${cores} cores"
fi

# --- Memory: available MB from /proc/meminfo ---
mem_mb=$(awk '/MemAvailable/ { print int($2 / 1024) }' /proc/meminfo)
if [ "$mem_mb" -gt 200 ]; then
    ok "available memory ${mem_mb} MB"
else
    fail "available memory only ${mem_mb} MB"
fi

# --- Network: ping ---
if ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
    ok "ping to ${HOST}"
else
    fail "ping to ${HOST}"
fi

# --- Network: DNS ---
if getent hosts "$DOMAIN" >/dev/null 2>&1; then
    ok "DNS resolves ${DOMAIN}"
else
    fail "DNS cannot resolve ${DOMAIN}"
fi

# --- Network: TCP port (bash built-in /dev/tcp, no extra tools needed) ---
if timeout 3 bash -c "exec 3<>/dev/tcp/${DOMAIN}/${PORT}" 2>/dev/null; then
    ok "TCP ${DOMAIN}:${PORT} is reachable"
else
    fail "TCP ${DOMAIN}:${PORT} is not reachable"
fi

echo
if [ "$FAILED" -eq 0 ]; then
    echo "All checks passed."
else
    echo "${FAILED} check(s) failed."
    exit 1
fi
