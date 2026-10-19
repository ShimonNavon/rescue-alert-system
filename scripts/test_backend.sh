#!/usr/bin/env bash
# Backend test harness: builds the image and runs it against a throwaway
# PostGIS database. Requires Docker.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v docker >/dev/null || {
  echo "docker is required for backend tests" >&2
  exit 1
}

TAG="ral-backend-test:$(date +%s)"
NETWORK="ral-test-net-$$"
DB="ral-test-db-$$"

cleanup() {
  docker rm -f "$DB" >/dev/null 2>&1 || true
  docker network rm "$NETWORK" >/dev/null 2>&1 || true
  docker rmi "$TAG" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker network create "$NETWORK" >/dev/null
docker run -d --name "$DB" --network "$NETWORK" \
  -e POSTGRES_DB=rescue_alert \
  -e POSTGRES_USER=rescue_user \
  -e POSTGRES_PASSWORD=testpass \
  postgis/postgis:17-3.5 >/dev/null

for _ in $(seq 1 60); do
  if docker exec "$DB" pg_isready -U rescue_user -d rescue_alert >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

docker build -f backend/Dockerfile -t "$TAG" . >/dev/null

docker run --rm --network "$NETWORK" \
  -e POSTGRES_DB=rescue_alert \
  -e POSTGRES_USER=rescue_user \
  -e POSTGRES_PASSWORD=testpass \
  -e POSTGRES_HOST="$DB" \
  -e POSTGRES_PORT=5432 \
  -e SECRET_KEY=test-secret-key-that-is-long-enough-for-hs256 \
  -e DEBUG=False \
  -e ALLOWED_HOSTS=localhost,127.0.0.1 \
  -e REGISTRATION_INVITE_CODE=invite-123 \
  "$TAG" sh -c 'python manage.py check && python manage.py test --verbosity 2'
