#!/usr/bin/env bash
# Скриншот-тесты экранов (apps/mobile/test/golden).
#   scripts/golden.sh            сверить с эталонами
#   scripts/golden.sh --update   перезаписать эталоны (после осознанной правки вёрстки)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"
cd "$TMB_REPO/apps/mobile"
if [ "${1:-}" = "--update" ]; then
  flutter test --tags golden --update-goldens test/golden
else
  flutter test --tags golden test/golden
fi
