#!/bin/bash
set -e

cd /home/inventree

echo "[start.sh] Running invoke update (migrations + collectstatic, skip backup)..."
invoke update --skip-backup

echo "[start.sh] Starting gunicorn in background on ${INVENTREE_WEB_ADDR}:${INVENTREE_WEB_PORT}..."
gunicorn -c ./gunicorn.conf.py InvenTree.wsgi \
  -b ${INVENTREE_WEB_ADDR}:${INVENTREE_WEB_PORT} \
  --chdir ${INVENTREE_BACKEND_DIR}/InvenTree &

echo "[start.sh] Waiting for gunicorn to be ready..."
for i in $(seq 1 60); do
  if curl -sf -o /dev/null http://${INVENTREE_WEB_ADDR}:${INVENTREE_WEB_PORT}/api/ 2>&1; then
    echo "[start.sh] Gunicorn is up"
    break
  fi
  echo "[start.sh] Waiting... ($i/60)"
  sleep 2
done

echo "[start.sh] Starting nginx in foreground..."
exec nginx -g 'daemon off;'
