#!/usr/bin/env bash
# Deploy/update the Rescue Alert stack on the k3s/kubeadm cluster.
#
#   ./deploy/deploy.sh
#
# Secrets live in deploy/.env.deploy (gitignored). The manifest pins the app
# images to the local registry on ubuntu04; rebuild/push them before running
# this if the code changed.
set -euo pipefail
cd "$(dirname "$0")/.."

ENVFILE="deploy/.env.deploy"
MANIFEST="deploy/k8s/rescue-alert.yaml"
REMOTE_ENV="/tmp/rescue-alert-env.$$"

if [ ! -f "$ENVFILE" ]; then
  echo "missing $ENVFILE; create it from deploy/.env.example first" >&2
  exit 1
fi

cleanup() { ssh ubuntu03 "rm -f $REMOTE_ENV" >/dev/null 2>&1 || true; }
trap cleanup EXIT

scp -q "$ENVFILE" "ubuntu03:$REMOTE_ENV"
ssh ubuntu03 "set -e
  kubectl create namespace rescue-alert --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n rescue-alert create secret generic rescue-alert-env \
    --from-env-file=$REMOTE_ENV --dry-run=client -o yaml | kubectl apply -f -
  # Drop the retired Firebase project key if it is still present from an
  # earlier deploy. Strategic merge keeps keys that are absent from the file.
  kubectl -n rescue-alert patch secret rescue-alert-env --type=json \
    -p='[{"op":"remove","path":"/data/GOOGLE_CLOUD_PROJECT"}]' >/dev/null 2>&1 || true
  rm -f $REMOTE_ENV
  kubectl apply -f -" < "$MANIFEST"

ssh ubuntu03 '
  set -e
  kubectl -n rescue-alert rollout status deploy/db --timeout=300s
  kubectl -n rescue-alert rollout status deploy/backend --timeout=600s
  kubectl -n rescue-alert rollout status deploy/admin --timeout=300s
  kubectl -n rescue-alert get pods -o wide
  kubectl -n rescue-alert get svc
'
