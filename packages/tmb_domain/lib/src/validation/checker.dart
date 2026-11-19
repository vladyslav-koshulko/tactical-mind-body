import '../common/text.dart';
import '../determinism/canonical_json.dart' show canonicalNumber;
import 'import_limits.dart';
import 'issues.dart';
import 'schema_constants.dart';
import 'validation_code.dart';

/// Путь поля внутри объекта: `items[3]` + `selfCheck` → `items[3].selfCheck`.
String joinKey(String parent, String key) =>
    parent.isEmpty ? key : '$parent.$key';

/// Путь элемента массива.
String joinIndex(String parent, int index) => '$parent[$index]';

String _typeName(Object? v) => switch (v) {
  null => 'null',
  String() => 'строка',
  bool() => 'логическое значение',
  int() => 'целое число',
  num() => 'число',
  List() => 'массив',
  Map() => 'объект',
  _ => v.runtimeType.toString(),
};

/// Нормализация для сравнения «после нормализации» (prompt, имена):
/// trim, схлопывание пробелов, нижний регистр.
String normalizeForCompare(String s) =>
    s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// Общие проверки значений: типы, строки, числа, паттерны (SCHEMAS §6.1).
///
/// Каждый метод либо возвращает корректное значение, либо добавляет замечание
/// и возвращает `null`. Так вызывающий код не дублирует сообщения.
final class Checker {
  Checker(this.issues, this.limits);

  final Issues issues;
  final ImportLimits limits;

  void add(ValidationCode code, String path, String message) =>
      issues.add(code, path, message);

  // --- наличие и тип ----------------------------------------------------------

  /// Значение обязательного/необязательного поля или `null`: нет поля (для
  /// обязательного — `PACK_MISSING_FIELD`) либо `null` в поле, где он
  /// недопустим (`PACK_BAD_TYPE`).
  Object? take(
    Map<String, Object?> m,
    String path,
    String key, {
    bool required = true,
  }) {
    final at = joinKey(path, key);
    if (!m.containsKey(key)) {
      if (required) {
        add(
          ValidationCode.packMissingField,
          at,
          'Обязательное поле «$key» отсутствует.',
        );
      }
      return null;
    }
    final v = m[key];
    if (v == null) {
      add(ValidationCode.packBadType, at, 'Поле «$key»: null недопустим.');
      return null;
    }
    return v;
  }

  Map<String, Object?>? object(Object? v, String path) {
    if (v is Map<String, Object?>) return v;
    add(
      ValidationCode.packBadType,
      path,
      'Ожидался объект, получено: ${_typeName(v)}.',
    );
    return null;
  }

  List<Object?>? array(Object? v, String path) {
    if (v is List<Object?>) return v;
    add(
      ValidationCode.packBadType,
      path,
      'Ожидался массив, получено: ${_typeName(v)}.',
    );
    return null;
  }

  bool? boolean(Object? v, String path) {
    if (v is bool) return v;
    add(
      ValidationCode.packBadType,
      path,
      'Ожидалось логическое значение, получено: ${_typeName(v)}.',
    );
    return null;
  }

  Map<String, Object?>? takeObject(
    Map<String, Object?> m,
    String path,
    String key, {
    bool required = true,
  }) {
    final v = take(m, path, key, required: required);
    return v == null ? null : object(v, joinKey(path, key));
  }

  List<Object?>? takeArray(
    Map<String, Object?> m,
    String path,
    String key, {
    bool required = true,
  }) {
    final v = take(m, path, key, required: required);
    return v == null ? null : array(v, joinKey(path, key));
  }

  bool? takeBool(
    Map<String, Object?> m,
    String path,
    String key, {
    bool required = true,
  }) {
    final v = take(m, path, key, required: required);
    return v == null ? null : boolean(v, joinKey(path, key));
  }

  // --- неизвестные поля -------------------------------------------------------

  /// Поля вне [known]: `gen` у задач — зарезервировано, поля из [notAllowed] —
  /// определены схемой, но не для этого архетипа, прочие — неизвестные.
  void unknownFields(
    Map<String, Object?> m,
    String path,
    Set<String> known, {
    Set<String> notAllowed = const {},
    bool reserveGen = false,
  }) {
    for (final key in m.keys) {
      if (known.contains(key)) continue;
      final at = joinKey(path, key);
      if (reserveGen && key == 'gen') {
        add(
          ValidationCode.packReservedField,
          at,
          'Поле «gen» зарезервировано под генераторы v0.2; значение игнорируется.',
        );
      } else if (notAllowed.contains(key)) {
        add(
          ValidationCode.packFieldNotAllowed,
          at,
          'Поле «$key» не применяется к этому архетипу; значение игнорируется.',
        );
      } else {
        add(
          ValidationCode.packUnknownField,
          at,
          'Неизвестное поле «$key»; оно игнорируется и не сохраняется.',
        );
      }
    }
  }

  // --- строки -----------------------------------------------------------------

  /// Строка контента (plain text): NFC и `\n`, символы, пустота, длина, разметка.
  ///
  /// [emptyCode]/[longCode] позволяют правилам с собственным кодом (текст
  /// подсказки, название упражнения) подменить общий.
  String? text(
    Object? v,
    String path, {
    required int max,
    int min = 1,
    bool multiline = false,
    bool checkMarkup = true,
    ValidationCode emptyCode = ValidationCode.packStringEmpty,
    ValidationCode longCode = ValidationCode.packStringTooLong,
  }) {
    if (v is! String) {
      add(
        ValidationCode.packBadType,
        path,
        'Ожидалась строка, получено: ${_typeName(v)}.',
      );
      return null;
    }
    final String s;
    try {
      s = normalizeText(v);
    } on UnsupportedError {
      add(
        ValidationCode.packBadChars,
        path,
        'Строка содержит комбинируемые знаки Unicode: используйте '
        'предкомпонованные символы (NFC).',
      );
      return null;
    }
    final bad = _firstBadChar(s, multiline: multiline);
    if (bad != null) {
      add(
        ValidationCode.packBadChars,
        path,
        'Недопустимый символ U+${bad.toRadixString(16).toUpperCase().padLeft(4, '0')}: '
        'управляющие, bidi- и разделители строк запрещены.',
      );
      return null;
    }
    if (min >= 1 && s.trim().isEmpty) {
      add(emptyCode, path, 'Строка пуста.');
      return null;
    }
    final length = s.runes.length;
    if (length > max) {
      add(longCode, path, 'Строка длиннее $max символов (сейчас $length).');
      return null;
    }
    if (checkMarkup) {
      if (markupPattern.hasMatch(s)) {
        add(
          ValidationCode.packMarkup,
          path,
          'Строка содержит HTML-подобную разметку; допускается только обычный текст.',
        );
        return null;
      }
      if (s.contains('://')) {
        add(
          ValidationCode.packUrlInText,
          path,
          'Строка содержит «://»; ссылка не будет активна.',
        );
      }
    }
    return s;
  }

  /// Поле-строка по ключу; см. [text].
  String? takeText(
    Map<String, Object?> m,
    String path,
    String key, {
    required int max,
    bool required = true,
    bool multiline = false,
    bool checkMarkup = true,
    int min = 1,
  }) {
    final v = take(m, path, key, required: required);
    return v == null
        ? null
        : text(
            v,
            joinKey(path, key),
            max: max,
            multiline: multiline,
            min: min,
            checkMarkup: checkMarkup,
          );
  }

  /// Строка, обязанная соответствовать паттерну (идентификаторы, локаль…).
  String? pattern(
    Object? v,
    String path,
    RegExp re,
    ValidationCode code,
    String what, {
    int minLength = 0,
    int maxLength = 1 << 20,
  }) {
    if (v is! String) {
      add(
        ValidationCode.packBadType,
        path,
        'Ожидалась строка, получено: ${_typeName(v)}.',
      );
      return null;
    }
    if (!re.hasMatch(v) || v.length < minLength || v.length > maxLength) {
      final shown = v.length > 40 ? '${v.substring(0, 40)}…' : v;
      add(code, path, '$what «$shown» не соответствует формату.');
      return null;
    }
    return v;
  }

  String? takePattern(
    Map<String, Object?> m,
    String path,
    String key,
    RegExp re,
    ValidationCode code,
    String what, {
    int minLength = 0,
    int maxLength = 1 << 20,
  }) {
    final v = take(m, path, key);
    return v == null
        ? null
        : pattern(
            v,
            joinKey(path, key),
            re,
            code,
            what,
            minLength: minLength,
            maxLength: maxLength,
          );
  }

  /// Значение из закрытого списка [allowed] (проводные имена).
  String? wire(
    Object? v,
    String path,
    List<String> allowed,
    ValidationCode code,
    String what,
  ) {
    if (v is! String) {
      add(
        ValidationCode.packBadType,
        path,
        'Ожидалась строка, получено: ${_typeName(v)}.',
      );
      return null;
    }
    if (!allowed.contains(v)) {
      final shown = v.length > 40 ? '${v.substring(0, 40)}…' : v;
      add(
        code,
        path,
        '$what «$shown» вне списка допустимых: ${allowed.join(', ')}.',
      );
      return null;
    }
    return v;
  }

  String? takeWire(
    Map<String, Object?> m,
    String path,
    String key,
    List<String> allowed,
    ValidationCode code,
    String what,
  ) {
    final v = take(m, path, key);
    return v == null ? null : wire(v, joinKey(path, key), allowed, code, what);
  }

  // --- числа ------------------------------------------------------------------

  /// Число: конечное, `|x| < 1e15`, не более 6 знаков после запятой.
  num? number(Object? v, String path) {
    if (v is! num) {
      add(
        ValidationCode.packBadType,
        path,
        'Ожидалось число, получено: ${_typeName(v)}.',
      );
      return null;
    }
    if (v is double) {
      if (!v.isFinite || v.abs() >= 1e15) {
        add(
          ValidationCode.packNumberRange,
          path,
          'Число не конечное или по модулю не меньше 1e15.',
        );
        return null;
      }
      if (v != v.truncateToDouble()) {
        final text = canonicalNumber(v);
        final dot = text.indexOf('.');
        if (dot >= 0 && text.length - dot - 1 > 6) {
          add(
            ValidationCode.packNumberRange,
            path,
            'Больше 6 знаков после запятой.',
          );
          return null;
        }
      }
    } else if (v.abs() >= 1000000000000000) {
      add(
        ValidationCode.packNumberRange,
        path,
        'Число по модулю не меньше 1e15.',
      );
      return null;
    }
    return v;
  }

  /// Целое в `[min, max]`; нецелое или вне диапазона — [code].
  int? intIn(
    Object? v,
    String path, {
    required int min,
    required int max,
    required ValidationCode code,
    required String what,
  }) {
    final n = number(v, path);
    if (n == null) return null;
    if (n is! int || n < min || n > max) {
      add(code, path, '$what: ожидалось целое число от $min до $max.');
      return null;
    }
    return n;
  }
}

/// Первый недопустимый символ (SCHEMAS §6, правило 20) или `null`.
///
/// Сверх списка правила отвергаются одиночные суррогаты: они не кодируются в
/// UTF-8 и ломают хеш.
int? _firstBadChar(String s, {required bool multiline}) {
  final units = s.codeUnits;
  for (var i = 0; i < units.length; i++) {
    final c = units[i];
    if (c < 0x20) {
      if (multiline && c == 0x0A) continue;
      return c;
    }
    if (c >= 0x7F && c <= 0x9F) return c;
    if (c == 0x2028 || c == 0x2029) return c;
    if (c == 0x200E || c == 0x200F) return c;
    if (c >= 0x202A && c <= 0x202E) return c;
    if (c >= 0x2066 && c <= 0x2069) return c;
    if (c >= 0xD800 && c <= 0xDBFF) {
      final paired =
          i + 1 < units.length &&
          units[i + 1] >= 0xDC00 &&
          units[i + 1] <= 0xDFFF;
      if (!paired) return c;
      i++;
    } else if (c >= 0xDC00 && c <= 0xDFFF) {
      return c;
    }
  }
  return null;
}
