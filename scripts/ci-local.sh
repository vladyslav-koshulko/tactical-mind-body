#!/usr/bin/env bash
# Локальный CI: те же проверки, что на GitHub (flutter.yml), плюс то, чего в облаке нет —
# скриншот-тесты и сквозной прогон на эмуляторе. Запускать перед каждым push.
#
#   scripts/ci-local.sh              всё
#   scripts/ci-local.sh --no-emu     без эмулятора (быстрый прогон)
#   scripts/ci-local.sh --keep-data  не стирать данные приложения после тестов
#
# В конце на эмуляторе остаётся ПОСЛЕДНЯЯ проверенная БОЕВАЯ сборка (lib/main.dart, не
# тестовая с integration_test/), запущенная с чистого состояния — именно её смотрит владелец. Отчёт: build/local-ci/report.md,
# скриншоты: build/local-ci/screenshots/, отметка: build/local-ci/last-verified.txt.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

USE_EMU=1; KEEP_DATA=0
for a in "$@"; do
  case "$a" in
    --no-emu) USE_EMU=0 ;;
    --keep-data) KEEP_DATA=1 ;;
    *) echo "Неизвестный флаг: $a" >&2; exit 2 ;;
  esac
done

mkdir -p "$TMB_OUT"
REPORT="$TMB_OUT/report.md"
SHA="$(git -C "$TMB_REPO" rev-parse --short HEAD)"
DIRTY="$(git -C "$TMB_REPO" status --porcelain | grep -q . && echo ' (+ незакоммиченные правки)' || true)"
STARTED="$(date '+%Y-%m-%d %H:%M:%S')"
FAILED=0
{
  echo "# Локальный CI"
  echo
  echo "Коммит: \`$SHA\`$DIRTY · запуск: $STARTED"
  echo
  echo "| Этап | Результат | Время |"
  echo "|---|---|---|"
} >"$REPORT"

# stage <название> <команда…>: выполняет, пишет строку в отчёт, при сбое помечает FAILED.
stage() {
  local name="$1"; shift
  local log="$TMB_OUT/$(echo "$name" | tr ' /' '__').log"
  local t0=$SECONDS
  printf '\n\033[1m▶ %s\033[0m\n' "$name"
  if "$@" >"$log" 2>&1; then
    printf '  \033[32m✓ ok\033[0m (%ss)\n' "$((SECONDS - t0))"
    echo "| $name | ✅ | $((SECONDS - t0)) с |" >>"$REPORT"
  else
    printf '  \033[31m✗ сбой\033[0m (%ss), лог: %s\n' "$((SECONDS - t0))" "$log"
    tail -n 25 "$log" | sed 's/^/    /'
    echo "| $name | ❌ [лог]($log) | $((SECONDS - t0)) с |" >>"$REPORT"
    FAILED=1
    return 1
  fi
}

in_dir() { local d="$1"; shift; (cd "$TMB_REPO/$d" && "$@"); }

# Этапы идут по цепочке: упавший не мешает увидеть остальные только там, где они независимы.
stage "pub get"        in_dir . flutter pub get
stage "format"         in_dir . dart format --output=none --set-exit-if-changed .
stage "analyze"        in_dir . flutter analyze --fatal-infos
stage "test domain"    in_dir packages/tmb_domain dart test
stage "test data"      in_dir packages/tmb_data dart test
stage "test ui"        in_dir packages/tmb_ui flutter test
stage "test mobile"    in_dir apps/mobile flutter test --exclude-tags golden
stage "golden"         in_dir apps/mobile flutter test --tags golden test/golden
stage "validate packs" in_dir . dart run packages/tmb_domain/bin/validate_packs.dart assets/content

if [ "$FAILED" -eq 0 ]; then
  # Боевой APK (lib/main.dart) → build/local-ci/app-main-debug.apk. Именно его ставим
  # на эмулятор: общий app-debug.apk затем перезапишет `flutter drive` тестовой сборкой.
  stage "build apk" "$TMB_REPO/scripts/emu.sh" build
fi
export TMB_SKIP_BUILD=1

if [ "$USE_EMU" -eq 1 ] && [ "$FAILED" -eq 0 ]; then
  stage "emulator start"  "$TMB_REPO/scripts/emu.sh" start
  stage "emulator reset"  "$TMB_REPO/scripts/emu.sh" reset
  stage "emulator e2e"    "$TMB_REPO/scripts/emu.sh" test
  # Оставляем на эмуляторе именно ту боевую сборку, что прошла проверку, — чистой.
  # (`emu.sh test` сам возвращает её в конце; install проверяет, что стоит не тестовая.)
  if [ "$FAILED" -eq 0 ]; then
    stage "emulator install" "$TMB_REPO/scripts/emu.sh" install
    stage "emulator build check" bash -c '"$0" status | tee /dev/stderr | grep -q "боевая (lib/main.dart)"' "$TMB_REPO/scripts/emu.sh"
    [ "$KEEP_DATA" -eq 1 ] || { "$TMB_REPO/scripts/emu.sh" reset >/dev/null 2>&1; "$TMB_REPO/scripts/emu.sh" launch >/dev/null 2>&1; }
    sleep 3
    "$TMB_REPO/scripts/emu.sh" shot "99_final_state" >/dev/null 2>&1 || true
  fi
elif [ "$USE_EMU" -eq 0 ]; then
  echo "| emulator | ⏭ пропущен (--no-emu) | |" >>"$REPORT"
fi

if [ "$FAILED" -eq 0 ]; then
  VERDICT="ВСЁ ЗЕЛЁНОЕ"
  [ "$USE_EMU" -eq 1 ] || VERDICT="зелёное, но без эмулятора"
else
  VERDICT="ЕСТЬ СБОИ"
fi
{
  echo
  echo "**Итог: $VERDICT**"
} >>"$REPORT"
{
  echo "коммит:  $SHA$DIRTY"
  echo "время:   $(date '+%Y-%m-%d %H:%M:%S')"
  echo "итог:    $VERDICT"
  echo "эмулятор: $([ "$USE_EMU" -eq 1 ] && echo да || echo нет)"
} >"$TMB_OUT/last-verified.txt"

printf '\n\033[1mИтог: %s\033[0m\nОтчёт: %s\n' "$VERDICT" "$REPORT"
exit "$FAILED"
