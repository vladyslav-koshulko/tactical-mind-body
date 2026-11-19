import '../common/enums.dart';
import '../common/json_reader.dart';

/// Диапазон цели `{min, max}`; `min == max` — фиксированная цель.
final class TargetRange {
  const TargetRange({required this.min, required this.max});

  factory TargetRange.fromJson(Map<String, Object?> json) =>
      TargetRange.read(readRoot(json));

  factory TargetRange.read(JsonObj o) =>
      TargetRange(min: o.integer('min'), max: o.integer('max'));

  final int min;
  final int max;

  bool get isFixed => min == max;

  Map<String, Object?> toJson() => {'min': min, 'max': max};
}

/// Цель для упражнения без собственной [ExerciseTarget], по единицам.
final class DefaultTargets {
  const DefaultTargets({required this.reps, required this.seconds});

  /// Стартовые значения: 15 повторений и 30 секунд (пример SCHEMAS §4;
  /// 15 — `fixedReps` прототипа).
  static const standard = DefaultTargets(
    reps: TargetRange(min: 15, max: 15),
    seconds: TargetRange(min: 30, max: 30),
  );

  factory DefaultTargets.fromJson(Map<String, Object?> json) =>
      DefaultTargets.read(readRoot(json));

  factory DefaultTargets.read(JsonObj o) => DefaultTargets(
    reps: TargetRange.read(o.object('reps')),
    seconds: TargetRange.read(o.object('seconds')),
  );

  final TargetRange reps;
  final TargetRange seconds;

  TargetRange forUnit(ExerciseUnit unit) => switch (unit) {
    ExerciseUnit.reps => reps,
    ExerciseUnit.seconds => seconds,
  };

  Map<String, Object?> toJson() => {
    'reps': reps.toJson(),
    'seconds': seconds.toJson(),
  };
}

/// Цель для конкретного упражнения.
final class ExerciseTarget {
  const ExerciseTarget({
    required this.exerciseId,
    required this.min,
    required this.max,
    required this.lockedByUser,
  });

  factory ExerciseTarget.fromJson(Map<String, Object?> json) =>
      ExerciseTarget.read(readRoot(json));

  factory ExerciseTarget.read(JsonObj o) => ExerciseTarget(
    exerciseId: o.string('exerciseId'),
    min: o.integer('min'),
    max: o.integer('max'),
    lockedByUser: o.boolean('lockedByUser'),
  );

  final String exerciseId;
  final int min;
  final int max;

  /// `true` — правка вручную; прогрессия (v0.2) цель не меняет.
  final bool lockedByUser;

  Map<String, Object?> toJson() => {
    'exerciseId': exerciseId,
    'min': min,
    'max': max,
    'lockedByUser': lockedByUser,
  };
}

/// Настройки прогрессии нагрузки.
final class ProgressionSettings {
  const ProgressionSettings({this.enabled = true});

  factory ProgressionSettings.fromJson(Map<String, Object?> json) =>
      ProgressionSettings.read(readRoot(json));

  factory ProgressionSettings.read(JsonObj o) =>
      ProgressionSettings(enabled: o.boolean('enabled'));

  /// По умолчанию включена (рекомендация REQUIREMENTS).
  final bool enabled;

  Map<String, Object?> toJson() => {'enabled': enabled};
}
