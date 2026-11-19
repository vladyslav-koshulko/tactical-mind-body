import '../common/json_reader.dart';

/// Допуск ответа (`accept`, SCHEMAS §1.4): массив значений либо диапазон.
sealed class Accept {
  const Accept();

  /// Читает `accept`: массив → [AcceptList], объект `{min,max}` → [AcceptRange].
  static Accept read(Object value, String path) {
    if (value is List) return AcceptList.read(value, path);
    if (value is Map) return AcceptRange.read(convObject(value, path));
    throw FormatException('$path: accept — массив или {min,max}');
  }

  Object toJson();
}

/// Допустимые значения: строки или числа, тип совпадает с `answer`.
final class AcceptList extends Accept {
  const AcceptList(this.values);

  factory AcceptList.read(List<Object?> raw, String path) {
    final out = <Object>[];
    for (var i = 0; i < raw.length; i++) {
      final v = raw[i];
      if (v is String) {
        out.add(convText(v, '$path/$i'));
      } else if (v is num) {
        out.add(v);
      } else {
        throw FormatException('$path/$i: ожидалась строка или число');
      }
    }
    return AcceptList(List.unmodifiable(out));
  }

  /// Каждый элемент — `String` или `num`.
  final List<Object> values;

  @override
  List<Object> toJson() => values;
}

/// Числовой допуск, границы включительно.
final class AcceptRange extends Accept {
  const AcceptRange({required this.min, required this.max});

  factory AcceptRange.read(JsonObj o) =>
      AcceptRange(min: o.number('min'), max: o.number('max'));

  final num min;
  final num max;

  bool contains(num x) => x >= min && x <= max;

  @override
  Map<String, Object> toJson() => {'min': min, 'max': max};
}

/// Значение `answer` у recall/delayed_recall: строка или число.
Object convAnswerValue(Object value, String path) {
  if (value is String) return convText(value, path);
  if (value is num) return value;
  throw FormatException('$path: ожидалась строка или число');
}
