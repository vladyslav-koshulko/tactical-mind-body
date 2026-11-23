#!/usr/bin/env bash
# Управление локальным Android-эмулятором и приложением на нём.
#
#   scripts/emu.sh start        поднять эмулятор (окно видно на экране) и дождаться загрузки
#   scripts/emu.sh stop         выключить
#   scripts/emu.sh status       запущен ли, какая сборка стоит (боевая или тестовая)
#   scripts/emu.sh build        собрать БОЕВОЙ debug-APK (lib/main.dart) → $TMB_OUT/app-main-debug.apk
#   scripts/emu.sh install      собрать боевой APK, проверить, поставить поверх и запустить
#   scripts/emu.sh launch       просто запустить приложение
#   scripts/emu.sh test         сквозные тесты (3 сценария) + скриншоты, с настоящим уходом в фон;
#                               в конце (даже при падении) возвращает боевую сборку с чистыми данными
#   scripts/emu.sh shot [имя]   скриншот экрана эмулятора в $TMB_OUT/screenshots
#   scripts/emu.sh reset        стереть данные приложения (чистый первый запуск)
#
# Эмулятор — Pixel 5 (AVD «tmb_pixel», Android 35, x86_64, 2 ГБ ОЗУ).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

SERIAL="${TMB_SERIAL:-emulator-5554}"
# БОЕВОЙ APK (lib/main.dart) лежит отдельно от build/app/outputs/flutter-apk/app-debug.apk:
# `flutter drive` пересобирает ТОТ файл с таргетом integration_test/app_flow_test.dart
# (тестовая сборка сама кликает по экранам). На эмулятор ставим только копию боевой.
APK="$TMB_OUT/app-main-debug.apk"
LOG="$TMB_OUT/emulator.log"
adb_() { adb -s "$SERIAL" "$@"; }

booted() { [ "$(adb_ shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; }

cmd_start() {
  if booted; then echo "Эмулятор уже запущен ($SERIAL)."; return 0; fi
  if ! "$ANDROID_HOME/emulator/emulator" -list-avds | grep -qx "$TMB_AVD"; then
    echo "AVD «$TMB_AVD» не найден. Создайте: scripts/emu.sh create" >&2; return 1
  fi
  mkdir -p "$TMB_OUT"
  echo "Запускаю эмулятор $TMB_AVD…"
  nohup "$ANDROID_HOME/emulator/emulator" -avd "$TMB_AVD" -gpu host \
    -no-boot-anim -no-audio -netdelay none -netspeed full >"$LOG" 2>&1 &
  adb start-server >/dev/null 2>&1 || true
  adb_ wait-for-device
  for _ in $(seq 1 120); do booted && break; sleep 2; done
  booted || { echo "Эмулятор не загрузился за 4 минуты, см. $LOG" >&2; return 1; }
  # Без анимаций тесты стабильнее и быстрее.
  for k in window_animation_scale transition_animation_scale animator_duration_scale; do
    adb_ shell settings put global "$k" 0 >/dev/null
  done
  adb_ shell input keyevent KEYCODE_WAKEUP >/dev/null || true
  adb_ shell wm dismiss-keyguard >/dev/null 2>&1 || true
  echo "Эмулятор готов: $(adb_ shell getprop ro.product.model | tr -d '\r'), Android $(adb_ shell getprop ro.build.version.release | tr -d '\r')"
}

cmd_create() {
  echo no | avdmanager create avd -n "$TMB_AVD" -d pixel_5 --force \
    -k "system-images;android-35;google_apis;x86_64"
  local ini="$HOME/.android/avd/$TMB_AVD.avd/config.ini"
  sed -i 's/^hw.ramSize=.*/hw.ramSize=2048/; s/^disk.dataPartition.size=.*/disk.dataPartition.size=6G/; s/^hw.keyboard=.*/hw.keyboard=yes/; s/^hw.gpu.enabled=.*/hw.gpu.enabled=yes/' "$ini"
}

cmd_stop() { adb_ emu kill >/dev/null 2>&1 || true; echo "Эмулятор остановлен."; }

# Тестовый таргет flutter drive зашивает путь integration_test/<имя>_test.dart в
# kernel_blob.bin; у боевой сборки таких строк нет (пакет `integration_test` как
# таковой там встречается, поэтому ищем именно путь к тестовому файлу).
apk_is_test_build() {
  local n
  n="$(unzip -p "$1" assets/flutter_assets/kernel_blob.bin 2>/dev/null |
    grep -a -c -E 'integration_test/[A-Za-z0-9_]+_test\.dart' || true)"
  [ "${n:-0}" -gt 0 ]
}

# Страховка: ставить на эмулятор можно только боевой APK.
assert_main_apk() {
  [ -f "$1" ] || { echo "Нет APK: $1" >&2; return 1; }
  if apk_is_test_build "$1"; then
    echo "ОШИБКА: $1 — ТЕСТОВАЯ сборка (внутри integration_test/). На эмулятор её ставить нельзя." >&2
    return 1
  fi
}

cmd_status() {
  if ! booted; then echo "Эмулятор: выключен"; return 0; fi
  echo "Эмулятор: работает ($SERIAL)"
  local v; v="$(adb_ shell dumpsys package "$TMB_APP_ID" 2>/dev/null | grep -m1 versionName || true)"
  echo "Приложение: ${v:-не установлено}"
  local base; base="$(adb_ shell pm path "$TMB_APP_ID" 2>/dev/null | head -n1 | sed 's/^package://' | tr -d '\r')"
  if [ -n "$base" ]; then
    local tmp; tmp="$(mktemp -d)"
    if adb_ pull "$base" "$tmp/app.apk" >/dev/null 2>&1; then
      if apk_is_test_build "$tmp/app.apk"; then
        echo "Сборка на эмуляторе: ТЕСТОВАЯ (integration_test) — не боевая! Верните: scripts/emu.sh install"
      else
        echo "Сборка на эмуляторе: боевая (lib/main.dart)"
      fi
    else
      echo "Сборка на эмуляторе: не удалось прочитать APK"
    fi
    rm -rf "$tmp"
  fi
  local top; top="$(adb_ shell dumpsys activity activities 2>/dev/null | grep -m1 -E 'topResumedActivity|mResumedActivity' | sed 's/^ *//' || true)"
  [ -n "$top" ] && echo "На экране: $top"
  [ -f "$TMB_OUT/last-verified.txt" ] && { echo "--- последняя проверка:"; cat "$TMB_OUT/last-verified.txt"; }
  return 0
}

# Боевая сборка: lib/main.dart, копия в $APK. Копия нужна, потому что общий
# app-debug.apk перезаписывает `flutter drive` (тестовым таргетом).
cmd_build() {
  (cd "$TMB_REPO/apps/mobile" && flutter build apk --debug -t lib/main.dart)
  mkdir -p "$TMB_OUT"
  cp -f "$TMB_REPO/apps/mobile/build/app/outputs/flutter-apk/app-debug.apk" "$APK"
  assert_main_apk "$APK"
  echo "Боевой APK: $APK"
}

# Собирает боевой APK, если его нет или не сказано «уже собран» (TMB_SKIP_BUILD=1).
ensure_main_apk() {
  if [ "${TMB_SKIP_BUILD:-0}" = 1 ] && [ -f "$APK" ]; then assert_main_apk "$APK"; else cmd_build; fi
}

cmd_install() {
  cmd_start
  ensure_main_apk
  assert_main_apk "$APK"
  adb_ install -r "$APK" >/dev/null
  echo "Установлено (боевая): $APK"
  cmd_launch
}

cmd_launch() {
  adb_ shell input keyevent KEYCODE_WAKEUP >/dev/null || true
  adb_ shell am force-stop "$TMB_APP_ID" >/dev/null
  adb_ shell monkey -p "$TMB_APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  echo "Приложение запущено."
}

# Если приложения нет (например, его удалил `flutter drive`), чистить нечего — это не ошибка.
cmd_reset() {
  if adb_ shell pm list packages "$TMB_APP_ID" | grep -q "$TMB_APP_ID"; then
    adb_ shell pm clear "$TMB_APP_ID" >/dev/null && echo "Данные приложения стёрты."
  else
    echo "Приложение не установлено — чистить нечего."
  fi
}

# Следящий процесс для сквозного теста: тест печатает маркер TMB_E2E_BACKGROUND
# (debugPrint → logcat, тег flutter) и ждёт заглушку паузы; здесь по маркеру
# настоящее сворачивание (HOME), скриншот лаунчера и возврат приложения через
# monkey. Так проверяется жизненный цикл на эмуляторе без правки `flutter drive`.
cmd_lifecycle_watch() {
  adb_ logcat -c
  adb_ logcat -v raw -s flutter:I | while IFS= read -r line; do
    case "$line" in
      *TMB_E2E_BACKGROUND*)
        sleep 1
        adb_ shell input keyevent KEYCODE_HOME
        sleep 3
        cmd_shot "17a_launcher_while_backgrounded" >/dev/null
        adb_ shell monkey -p "$TMB_APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
        echo "lifecycle: HOME → возврат выполнены"
        ;;
    esac
  done
}

# Убивает следящий процесс вместе со всей его группой (цикл чтения + adb logcat).
WATCHER_PID=""
stop_watcher() {
  [ -n "$WATCHER_PID" ] || return 0
  kill -TERM -- "-$WATCHER_PID" 2>/dev/null || kill -TERM "$WATCHER_PID" 2>/dev/null || true
  wait "$WATCHER_PID" 2>/dev/null || true
  WATCHER_PID=""
}

# Что бы ни случилось с тестом: убрать watcher и вернуть боевую сборку с чистыми
# данными. Иначе на эмуляторе остаётся тестовая сборка, которая сама кликает.
restore_main_build() {
  local rc=$?
  trap - EXIT INT TERM
  stop_watcher
  echo "Возвращаю на эмулятор боевую сборку (чистые данные)…"
  if assert_main_apk "$APK" && adb_ install -r "$APK" >/dev/null 2>&1; then
    cmd_reset >/dev/null 2>&1 || true
    cmd_launch >/dev/null 2>&1 || true
    echo "Боевая сборка на эмуляторе, данные чистые."
  else
    echo "ОШИБКА: не удалось вернуть боевую сборку на эмулятор!" >&2
    [ "$rc" -ne 0 ] || rc=1
  fi
  exit "$rc"
}

cmd_test() {
  cmd_start
  mkdir -p "$TMB_OUT/screenshots"
  # Боевая копия нужна до drive: он перезапишет общий app-debug.apk тестовой сборкой.
  ensure_main_apk
  trap restore_main_build EXIT INT TERM
  cmd_reset
  # Отдельная группа процессов: убить watcher = убить и logcat, без pkill -f.
  setsid "${BASH_SOURCE[0]}" lifecycle-watch &
  WATCHER_PID=$!
  (cd "$TMB_REPO/apps/mobile" && TMB_OUT="$TMB_OUT" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/app_flow_test.dart \
    --dart-define=TMB_REAL_LIFECYCLE=true -d "$SERIAL")
}

cmd_shot() {
  local name="${1:-screen-$(date +%H%M%S)}"
  mkdir -p "$TMB_OUT/screenshots"
  adb_ exec-out screencap -p >"$TMB_OUT/screenshots/$name.png"
  echo "$TMB_OUT/screenshots/$name.png"
}

case "${1:-}" in
  start) cmd_start ;; stop) cmd_stop ;; status) cmd_status ;; create) cmd_create ;;
  build) cmd_build ;; install) cmd_install ;; launch) cmd_launch ;;
  test) cmd_test ;; lifecycle-watch) cmd_lifecycle_watch ;; shot) shift; cmd_shot "${1:-}" ;; reset) cmd_reset ;;
  *) sed -n '2,17p' "$0"; exit 2 ;;
esac
