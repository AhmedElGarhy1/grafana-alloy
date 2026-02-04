#!/bin/sh
# Use PORT (Railway, etc.) or ALLOY_PORT or default 12345
LISTEN_PORT="${PORT:-${ALLOY_PORT:-12345}}"
exec /bin/alloy run \
  --server.http.listen-addr="0.0.0.0:${LISTEN_PORT}" \
  --storage.path=/var/lib/alloy/data \
  /etc/alloy/config.alloy
