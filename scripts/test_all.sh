#!/usr/bin/env bash
# Run all available checks from the repository root.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Admin panel =="
(cd admin-panel && npm test && npm run build)

echo "== Mobile =="
(cd mobile && flutter analyze --no-fatal-infos --no-fatal-warnings && flutter test)

if command -v docker >/dev/null 2>&1; then
  echo "== Backend =="
  ./scripts/test_backend.sh
else
  echo "== Backend: skipped (docker not installed) =="
fi

if [ "${SKIP_SMOKE:-0}" != "1" ]; then
  echo "== Live smoke test =="
  python3 scripts/smoke_test.py
fi
