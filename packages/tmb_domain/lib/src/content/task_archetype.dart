import '../common/wire_enum.dart';

/// Семь архетипов — закрытый список механик (инвариант 3, SCHEMAS §0).
///
/// Восьмое значение добавлять нельзя. Тема (Java, такмед, латынь) — это
/// данные пака, а не вариант этого перечисления.
enum TaskArchetype implements WireEnum {
  recall('recall'),
  choice('choice'),
  ordering('ordering'),
  delayedRecall('delayed_recall'),
  spatial('spatial'),
  stream('stream'),
  verbal('verbal');

  const TaskArchetype(this.wire);
  @override
  final String wire;

  /// Проверяется ли задача машиной. Только `verbal` — нет (инвариант 7).
  bool get isMachineVerifiable => this != TaskArchetype.verbal;
}
