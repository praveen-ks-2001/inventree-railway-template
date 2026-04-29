#!/bin/bash
set -e

echo "[start.sh] Launching InvenTree gunicorn server in background..."
invoke server &

echo "[start.sh] Waiting for gunicorn to be ready on 127.0.0.1:8000..."
for i in $(seq 1 60); do
  if curl -sf -o /dev/null http://127.0.0.1:8000/api/ 2>&1 || \
     curl -sf -o /dev/null http://127.0.0.1:8000/ 2>&1; then
    echo "[start.sh] Gunicorn is up"
    break
  fi
  echo "[start.sh] Waiting... ($i/60)"
  sleep 2
done

echo "[start.sh] Starting nginx in foreground..."
exec nginx -g 'daemon off;'
