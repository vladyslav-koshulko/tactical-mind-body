#!/usr/bin/env bash
# Окружение локального тулчейна: Flutter, JDK 17, Android SDK/эмулятор.
# Подключать так:  source scripts/env.sh
# Пути переопределяются переменными окружения (TMB_FLUTTER_HOME и т.д.).

export FLUTTER_HOME="${TMB_FLUTTER_HOME:-$HOME/development/flutter}"
export JAVA_HOME="${TMB_JAVA_HOME:-$HOME/development/jdk-17}"
export ANDROID_HOME="${TMB_ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# NDK нужен build hooks пакета sqlite3; версия — та, что просит Flutter.
if [ -z "${ANDROID_NDK_HOME:-}" ]; then
  ndk="$(ls -d "$ANDROID_HOME"/ndk/* 2>/dev/null | sort -V | tail -n 1)"
  [ -n "$ndk" ] && export ANDROID_NDK_HOME="$ndk"
fi

# Свои adb/emulator первыми: в системе может лежать другой adb (конфликт версий).
export PATH="$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Эмулятор и приложение.
export TMB_AVD="${TMB_AVD:-tmb_pixel}"
export TMB_APP_ID="com.echoua.tmb_mobile"
export TMB_REPO="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export TMB_OUT="${TMB_OUT:-$TMB_REPO/build/local-ci}"
