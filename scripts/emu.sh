#!/usr/bin/env bash
# Управление локальным Android-эмулятором и приложением на нём.
#
#   scripts/emu.sh start        поднять эмулятор (окно видно на экране) и дождаться загрузки
#   scripts/emu.sh stop         выключить
#   scripts/emu.sh status       запущен ли, какая сборка стоит
#   scripts/emu.sh build        собрать debug-APK
#   scripts/emu.sh install      собрать (если надо), поставить поверх и запустить
#   scripts/emu.sh launch       просто запустить приложение
#   scripts/emu.sh test         сквозные тесты (3 сценария) + скриншоты, с настоящим уходом в фон
#   scripts/emu.sh shot [имя]   скриншот экрана эмулятора в $TMB_OUT/screenshots
#   scripts/emu.sh reset        стереть данные приложения (чистый первый запуск)
#
# Эмулятор — Pixel 5 (AVD «tmb_pixel», Android 35, x86_64, 2 ГБ ОЗУ).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

SERIAL="${TMB_SERIAL:-emulator-5554}"
APK="$TMB_REPO/apps/mobile/build/app/outputs/flutter-apk/app-debug.apk"
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

cmd_status() {
  if ! booted; then echo "Эмулятор: выключен"; return 0; fi
  echo "Эмулятор: работает ($SERIAL)"
  local v; v="$(adb_ shell dumpsys package "$TMB_APP_ID" 2>/dev/null | grep -m1 versionName || true)"
  echo "Приложение: ${v:-не установлено}"
  [ -f "$TMB_OUT/last-verified.txt" ] && { echo "--- последняя проверка:"; cat "$TMB_OUT/last-verified.txt"; }
  return 0
}

cmd_build() { (cd "$TMB_REPO/apps/mobile" && flutter build apk --debug); }

cmd_install() {
  cmd_start
  [ -f "$APK" ] || cmd_build
  adb_ install -r "$APK" >/dev/null
  echo "Установлено: $APK"
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

cmd_test() {
  cmd_start
  mkdir -p "$TMB_OUT/screenshots"
  cmd_lifecycle_watch &
  local watcher=$!
  local rc=0
  (cd "$TMB_REPO/apps/mobile" && TMB_OUT="$TMB_OUT" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/app_flow_test.dart \
    --dart-define=TMB_REAL_LIFECYCLE=true -d "$SERIAL") || rc=$?
  # Убираем и сам цикл чтения, и его logcat.
  pkill -P "$watcher" 2>/dev/null || true
  kill "$watcher" 2>/dev/null || true
  return "$rc"
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
  test) cmd_test ;; shot) shift; cmd_shot "${1:-}" ;; reset) cmd_reset ;;
  *) sed -n '2,15p' "$0"; exit 2 ;;
esac
