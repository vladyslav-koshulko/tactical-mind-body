/// Перечисление с «проводным» именем — строкой, как она лежит в JSON.
///
/// Имя в Dart (`delayedRecall`) и имя в формате (`delayed_recall`) — разные вещи;
/// формат от переименования Dart-идентификаторов зависеть не должен.
abstract interface class WireEnum {
  String get wire;
}

/// Находит значение по проводному имени. Неизвестное имя — `FormatException`
/// с путём поля (структурная ошибка: Dart-значения для него не существует).
T parseWire<T extends WireEnum>(List<T> values, String raw, String path) {
  for (final v in values) {
    if (v.wire == raw) return v;
  }
  final allowed = values.map((v) => v.wire).join(', ');
  throw FormatException(
    '$path: неизвестное значение "$raw" (допустимо: $allowed)',
  );
}
