/// Структурное чтение JSON с путём поля в сообщении об ошибке.
///
/// Это НЕ валидатор правил SCHEMAS §6 (диапазоны, паттерны, лимиты): здесь
/// проверяется только то, без чего Dart-объект построить нельзя — наличие
/// обязательного поля и JSON-тип значения. Неизвестные поля игнорируются.
library;

import 'text.dart';
import 'wire_enum.dart';

/// Преобразует JSON-значение в `T`; `path` — JSON Pointer значения.
typedef JsonConv<T> = T Function(Object value, String path);

Never _typeError(String path, String expected, Object value) {
  throw FormatException(
    '${_shown(path)}: ожидалось $expected, получено ${_typeName(value)}',
  );
}

String _typeName(Object value) => switch (value) {
  String() => 'строка',
  bool() => 'bool',
  int() => 'целое',
  num() => 'дробное число',
  List() => 'массив',
  Map() => 'объект',
  _ => value.runtimeType.toString(),
};

String _shown(String path) => path.isEmpty ? '/' : path;

/// Строка как есть (идентификаторы, UUID, ответ пользователя).
String convString(Object value, String path) =>
    value is String ? value : _typeError(path, 'строка', value);

/// Строка контента: `\r\n` → `\n`, NFC (SCHEMAS §0).
///
/// Строка с комбинируемыми знаками (см. [nfc]) даёт `FormatException`, а не
/// `UnsupportedError`: для вызывающего это та же «нечитаемая строка пака».
String convText(Object value, String path) {
  final s = convString(value, path);
  try {
    return normalizeText(s);
  } on UnsupportedError catch (e) {
    throw FormatException('${_shown(path)}: ${e.message}');
  }
}

int convInt(Object value, String path) =>
    value is int ? value : _typeError(path, 'целое', value);

/// Любое число; целое остаётся `int`, дробное — `double` (важно для хеша).
num convNum(Object value, String path) =>
    value is num ? value : _typeError(path, 'число', value);

double convDouble(Object value, String path) => convNum(value, path).toDouble();

bool convBool(Object value, String path) =>
    value is bool ? value : _typeError(path, 'bool', value);

JsonObj convObject(Object value, String path) {
  if (value is Map) {
    for (final k in value.keys) {
      if (k is! String) _typeError(path, 'объект со строковыми ключами', value);
    }
    return JsonObj(value.cast<String, Object?>(), path);
  }
  return _typeError(path, 'объект', value);
}

/// Конвертер массива; ошибка элемента несёт его индекс в пути.
JsonConv<List<T>> listOf<T>(JsonConv<T> conv) => (value, path) {
  if (value is! List) _typeError(path, 'массив', value);
  final out = <T>[];
  for (var i = 0; i < value.length; i++) {
    final Object? item = value[i];
    if (item == null) {
      throw FormatException('${_shown('$path/$i')}: null недопустим');
    }
    out.add(conv(item, '$path/$i'));
  }
  return List.unmodifiable(out);
};

/// Конвертер перечисления по проводному имени.
JsonConv<T> enumOf<T extends WireEnum>(List<T> values) =>
    (value, path) => parseWire(values, convString(value, path), path);

/// Объект JSON вместе с путём к нему.
///
/// Три режима чтения поля (SCHEMAS §0):
///  * `req*` — поле обязательно, `null` недопустим;
///  * `reqNullable*`/`…N` — поле обязательно, `null` допустим (`null: да`);
///  * `opt*` — поле можно опустить, `null` недопустим (равносилен ошибке типа).
final class JsonObj {
  JsonObj(this.map, this.path);

  final Map<String, Object?> map;

  /// JSON Pointer этого объекта; у корня — пустая строка.
  final String path;

  String pathOf(String key) => '$path/$key';

  bool has(String key) => map.containsKey(key);

  // --- общие режимы ---------------------------------------------------------

  T req<T>(String key, JsonConv<T> conv) {
    if (!map.containsKey(key)) {
      throw FormatException(
        '${_shown(pathOf(key))}: обязательное поле отсутствует',
      );
    }
    final v = map[key];
    if (v == null) {
      throw FormatException('${_shown(pathOf(key))}: null недопустим');
    }
    return conv(v, pathOf(key));
  }

  T? reqNullable<T>(String key, JsonConv<T> conv) {
    if (!map.containsKey(key)) {
      throw FormatException(
        '${_shown(pathOf(key))}: обязательное поле отсутствует',
      );
    }
    final v = map[key];
    return v == null ? null : conv(v, pathOf(key));
  }

  T? opt<T>(String key, JsonConv<T> conv) {
    if (!map.containsKey(key)) return null;
    final v = map[key];
    if (v == null) {
      throw FormatException('${_shown(pathOf(key))}: null недопустим');
    }
    return conv(v, pathOf(key));
  }

  // --- сокращения ------------------------------------------------------------

  /// Строка без нормализации.
  String string(String key) => req(key, convString);
  String? stringN(String key) => reqNullable(key, convString);
  String? stringOpt(String key) => opt(key, convString);

  /// Строка контента (NFC, `\n`).
  String text(String key) => req(key, convText);
  String? textOpt(String key) => opt(key, convText);

  int integer(String key) => req(key, convInt);
  int? integerN(String key) => reqNullable(key, convInt);
  int? integerOpt(String key) => opt(key, convInt);

  num number(String key) => req(key, convNum);
  double dbl(String key) => req(key, convDouble);

  bool boolean(String key) => req(key, convBool);
  bool? booleanOpt(String key) => opt(key, convBool);

  JsonObj object(String key) => req(key, convObject);

  List<JsonObj> objects(String key) => req(key, listOf(convObject));

  T enumValue<T extends WireEnum>(String key, List<T> values) =>
      req(key, enumOf(values));
}

/// Корень документа: проверяет, что это объект.
JsonObj readRoot(Map<String, Object?> json) => JsonObj(json, '');

/// Проверяет поле `kind` документа. Расхождение — структурная ошибка: файл
/// другого вида не может быть прочитан этой моделью.
void expectKind(JsonObj o, String expected) {
  final kind = o.string('kind');
  if (kind != expected) {
    throw FormatException(
      '${o.pathOf('kind')}: ожидалось "$expected", получено "$kind"',
    );
  }
}
