#!/bin/bash
# Tears down the old stack and deploys a fresh one with Docker Compose.
set -euo pipefail

# Support both Compose v2 ("docker compose") and v1 ("docker-compose")
if docker compose version > /dev/null 2>&1; then
  COMPOSE="docker compose"
else
  COMPOSE="docker-compose"
fi
echo ">> Using: ${COMPOSE}"

echo ">> Stopping old containers (database volume is kept)..."
${COMPOSE} down --remove-orphans

echo ">> Building and starting django + postgres..."
${COMPOSE} up -d --build

${COMPOSE} ps
