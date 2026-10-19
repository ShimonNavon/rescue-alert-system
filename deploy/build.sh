#!/usr/bin/env bash
# Build the backend and admin images. Run on a Docker host (ubuntu02).
#
#   ./deploy/build.sh <tag>          # build only
#   PUSH=1 ./deploy/build.sh <tag>   # build, push to the ubuntu04 registry,
#                                    # and update the manifest image tags
#
# Registry tunnel defaults match the current cluster:
#   REGISTRY_USER=simon REGISTRY_HOST=ubuntu04 REGISTRY_KEY=~/.ssh/mr-registry
#   REGISTRY_LOCAL_PORT=15000
set -euo pipefail
cd "$(dirname "$0")/.."

TAG="${1:?usage: [PUSH=1] ./deploy/build.sh <tag>}"

docker build -f backend/Dockerfile -t "ral-backend:$TAG" .
docker build -f admin-panel/Dockerfile -t "ral-admin:$TAG" .
echo "Built ral-backend:$TAG and ral-admin:$TAG"

if [ "${PUSH:-0}" != "1" ]; then
  echo "Not pushing. Update deploy/k8s/rescue-alert.yaml image tags to $TAG, or rerun with PUSH=1."
  exit 0
fi

REGISTRY_USER="${REGISTRY_USER:-simon}"
REGISTRY_HOST="${REGISTRY_HOST:-ubuntu04}"
REGISTRY_KEY="${REGISTRY_KEY:-$HOME/.ssh/mr-registry}"
REGISTRY_LOCAL_PORT="${REGISTRY_LOCAL_PORT:-15000}"
SOCK="/tmp/ral-registry.sock"

rm -f "$SOCK"
ssh -i "$REGISTRY_KEY" -o IdentitiesOnly=yes -o BatchMode=yes \
  -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new \
  -M -S "$SOCK" -f -N \
  -L "$REGISTRY_LOCAL_PORT:127.0.0.1:5000" "$REGISTRY_USER@$REGISTRY_HOST"
trap 'ssh -S "$SOCK" -O exit "$REGISTRY_USER@$REGISTRY_HOST" 2>/dev/null || true' EXIT

docker tag "ral-backend:$TAG" "localhost:$REGISTRY_LOCAL_PORT/ral-backend:$TAG"
docker tag "ral-admin:$TAG" "localhost:$REGISTRY_LOCAL_PORT/ral-admin:$TAG"
docker push "localhost:$REGISTRY_LOCAL_PORT/ral-backend:$TAG"
docker push "localhost:$REGISTRY_LOCAL_PORT/ral-admin:$TAG"

python3 - "$TAG" <<'PY'
import re
import sys
from pathlib import Path

tag = sys.argv[1]
path = Path("deploy/k8s/rescue-alert.yaml")
text = path.read_text()
text = re.sub(r"localhost:5000/ral-backend:[^\s]+", f"localhost:5000/ral-backend:{tag}", text)
text = re.sub(r"localhost:5000/ral-admin:[^\s]+", f"localhost:5000/ral-admin:{tag}", text)
path.write_text(text)
print(f"Updated deploy/k8s/rescue-alert.yaml to {tag}")
PY
