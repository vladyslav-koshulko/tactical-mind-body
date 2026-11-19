import 'wire_enum.dart';

/// Источник пака (SCHEMAS §1.1). Для `imported`/`user` события не идут в Индекс.
enum PackSource implements WireEnum {
  builtin('builtin'),
  imported('imported'),
  user('user');

  const PackSource(this.wire);
  @override
  final String wire;
}

/// Статус вычитки пака. Только отображение, на логику не влияет.
enum PackStatus implements WireEnum {
  draft('draft'),
  reviewed('reviewed'),
  published('published');

  const PackStatus(this.wire);
  @override
  final String wire;
}

/// Уровень подготовки — закрытый список (SCHEMAS §0).
enum DifficultyLevel implements WireEnum {
  recruit('recruit'),
  fighter('fighter'),
  operator('operator'),
  spetsnaz('spetsnaz');

  const DifficultyLevel(this.wire);
  @override
  final String wire;
}

/// Место тренировки.
enum Location implements WireEnum {
  home('HOME'),
  gym('GYM'),
  outdoor('OUTDOOR');

  const Location(this.wire);
  @override
  final String wire;
}

/// Единица измерения упражнения.
enum ExerciseUnit implements WireEnum {
  reps('reps'),
  seconds('seconds');

  const ExerciseUnit(this.wire);
  @override
  final String wire;
}

/// Вид шаблона сессии (инвариант 5; SCHEMAS §3.1).
enum SessionTemplateKind implements WireEnum {
  dualTask('dual_task'),
  physicalOnly('physical_only'),
  cognitiveOnly('cognitive_only'),
  custom('custom');

  const SessionTemplateKind(this.wire);
  @override
  final String wire;
}
