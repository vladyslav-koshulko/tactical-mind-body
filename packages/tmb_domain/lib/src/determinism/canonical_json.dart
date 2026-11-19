/// Канонический JSON — SCHEMAS §3.5, пункт 4.
///
/// Без пробелов; ключи объектов по возрастанию кодовой точки; из строк
/// экранируются только `"`, `\`, U+0000…U+001F (`\b \t \n \f \r` или `\u00xx`
/// в нижнем регистре); всё остальное — буквально (кириллица, `/`, U+007F).
/// Строки приводятся к NFC и `\r\n` → `\n`; ограничение NFC — см. `nfc`
/// (для строк с комбинируемыми знаками бросается [UnsupportedError]).
library;

import '../common/text.dart' show nfc;

/// Сериализует [value] в канонический JSON.
///
/// Допустимы `bool`, `int`, `double` (конечный), `String`, `List` и
/// `Map<String, Object?>`; значение `null` и прочие типы — [ArgumentError]
/// (ключи с `null` в payload не включаются, это забота вызывающего).
String canonicalJson(Object value) {
  final out = StringBuffer();
  _write(out, value);
  return out.toString();
}

void _write(StringBuffer out, Object? value) {
  switch (value) {
    case null:
      throw ArgumentError('null не входит в канонический JSON');
    case bool():
      out.write(value ? 'true' : 'false');
    case int():
      out.write(value.toString());
    case double():
      out.write(canonicalNumber(value));
    case String():
      _writeString(out, value);
    case List<Object?>():
      out.write('[');
      for (var i = 0; i < value.length; i++) {
        if (i > 0) out.write(',');
        _write(out, value[i]);
      }
      out.write(']');
    case Map<Object?, Object?>():
      final entries = <String, Object?>{};
      for (final e in value.entries) {
        final k = e.key;
        if (k is! String) {
          throw ArgumentError('ключ объекта должен быть строкой: $k');
        }
        entries[_normalize(k)] = e.value;
      }
      // Сортировка по кодовым единицам UTF-16; для ASCII-ключей это то же,
      // что по байтам UTF-8.
      final sorted = entries.keys.toList()..sort();
      out.write('{');
      for (var i = 0; i < sorted.length; i++) {
        if (i > 0) out.write(',');
        _writeString(out, sorted[i]);
        out.write(':');
        _write(out, entries[sorted[i]]);
      }
      out.write('}');
    default:
      throw ArgumentError('Неподдерживаемый тип ${value.runtimeType}');
  }
}

/// Каноническая запись числа (SCHEMAS §3.5).
///
/// Целое значение — десятичное целое без `.0`, `+` и экспоненты (`-0` → `0`).
/// Дробное — кратчайшая десятичная запись, возвращающая то же число, без
/// экспоненты и хвостовых нулей. Целочисленность проверяется ДО `toString()`:
/// Dart печатает `5.0`.
String canonicalNumber(num n) {
  if (n is int) return n.toString();
  final d = n.toDouble();
  if (!d.isFinite) throw ArgumentError('Число не конечное: $d');
  if (d == d.truncateToDouble()) {
    // -0.0 и 0.0 → "0". Для |d| >= 2^53 toInt() на вебе неточен, но паки
    // ограничены |x| < 1e15 (SCHEMAS §0).
    return d.toInt().toString();
  }
  return _expandExponent(d.toString());
}

/// Dart печатает `1e-7` для малых и `1e+21` для больших; разворачивает такую
/// запись в позиционную без потери цифр (кратчайшая мантисса сохраняется).
String _expandExponent(String s) {
  final e = s.indexOf('e');
  if (e < 0) return s;
  var mantissa = s.substring(0, e);
  final exp = int.parse(s.substring(e + 1));
  final negative = mantissa.startsWith('-');
  if (negative) mantissa = mantissa.substring(1);
  final dot = mantissa.indexOf('.');
  final intPart = dot < 0 ? mantissa : mantissa.substring(0, dot);
  final fracPart = dot < 0 ? '' : mantissa.substring(dot + 1);
  final digits = intPart + fracPart;
  final pointPos = intPart.length + exp;
  String result;
  if (pointPos <= 0) {
    result = '0.${'0' * -pointPos}$digits';
  } else if (pointPos >= digits.length) {
    result = digits + '0' * (pointPos - digits.length);
  } else {
    result = '${digits.substring(0, pointPos)}.${digits.substring(pointPos)}';
  }
  if (result.contains('.')) {
    result = result.replaceFirst(RegExp(r'0+$'), '');
    if (result.endsWith('.')) result = result.substring(0, result.length - 1);
  }
  return negative ? '-$result' : result;
}

/// NFC и `\r\n` → `\n` (SCHEMAS §3.5, п. 3). Одиночный `\r` не трогается и
/// будет экранирован; в паке его нет — читатель заменил его раньше (§0).
String _normalize(String s) => nfc(s.replaceAll('\r\n', '\n'));

void _writeString(StringBuffer out, String raw) {
  final s = _normalize(raw);
  out.write('"');
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    switch (c) {
      case 0x22:
        out.write(r'\"');
      case 0x5C:
        out.write(r'\\');
      case 0x08:
        out.write(r'\b');
      case 0x09:
        out.write(r'\t');
      case 0x0A:
        out.write(r'\n');
      case 0x0C:
        out.write(r'\f');
      case 0x0D:
        out.write(r'\r');
      default:
        if (c < 0x20) {
          out.write('\\u${c.toRadixString(16).padLeft(4, '0')}');
        } else {
          out.writeCharCode(c);
        }
    }
  }
  out.write('"');
}
