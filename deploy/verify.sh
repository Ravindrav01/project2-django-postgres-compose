#!/bin/bash
# Checks that Django responds and can reach Postgres.
set -euo pipefail
URL="http://localhost:8000/health"

for i in $(seq 1 20); do
  if curl -fs "${URL}" > /dev/null; then
    echo ">> Application is healthy:"
    curl -s "${URL}"; echo
    exit 0
  fi
  echo ">> Waiting for application... (${i}/20)"
  sleep 3
done

echo ">> Application failed health check. Logs:"
docker logs django-web --tail 50 || true
exit 1
