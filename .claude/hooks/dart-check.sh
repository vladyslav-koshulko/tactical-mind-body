#!/usr/bin/env bash
# PostToolUse hook: форматирует и анализирует Dart-файл сразу после правки.
#
# Смысл: ошибки компиляции и стиля ловятся без участия модели и без расхода токенов.
# Молча выходит, если Dart SDK ещё не установлен или правился не .dart файл, —
# чтобы хук не мешал работе над HTML-прототипом до миграции на Flutter.
set -uo pipefail

command -v dart >/dev/null 2>&1 || exit 0

# Путь к отредактированному файлу приходит в JSON на stdin.
file=$(python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print(d.get("tool_input", {}).get("file_path", ""))
' 2>/dev/null) || exit 0

[[ "$file" == *.dart ]] || exit 0
[[ -f "$file" ]] || exit 0

dart format --output=write "$file" >/dev/null 2>&1

out=$(dart analyze --fatal-infos "$file" 2>&1) || {
    # Код 2 возвращает stderr модели как обратную связь — она исправит сразу,
    # не дожидаясь отдельного прогона анализатора.
    echo "dart analyze нашёл проблемы в $file:" >&2
    echo "$out" >&2
    exit 2
}
exit 0
