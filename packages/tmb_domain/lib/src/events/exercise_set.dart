import '../common/enums.dart';
import '../common/json_reader.dart';

/// Одно упражнение в круге (SCHEMAS §3.3).
final class ExerciseSet {
  const ExerciseSet({
    required this.id,
    required this.sessionId,
    required this.roundId,
    required this.setIndex,
    required this.exerciseId,
    required this.unit,
    required this.prescribed,
    required this.done,
    required this.startedAt,
    required this.endedAt,
  });

  factory ExerciseSet.fromJson(Map<String, Object?> json) =>
      ExerciseSet.read(readRoot(json));

  factory ExerciseSet.read(JsonObj o) => ExerciseSet(
    id: o.string('id'),
    sessionId: o.string('sessionId'),
    roundId: o.string('roundId'),
    setIndex: o.integer('setIndex'),
    exerciseId: o.string('exerciseId'),
    unit: o.enumValue('unit', ExerciseUnit.values),
    prescribed: o.integer('prescribed'),
    done: o.integer('done'),
    startedAt: o.integer('startedAt'),
    endedAt: o.integer('endedAt'),
  );

  final String id;
  final String sessionId;
  final String roundId;

  /// Позиция упражнения в круге.
  final int setIndex;
  final String exerciseId;

  /// Копия `unit` упражнения на момент записи.
  final ExerciseUnit unit;

  /// План, зафиксированный при старте сессии.
  final int prescribed;

  /// Сколько выполнено (0 — пропущено).
  final int done;
  final int startedAt;
  final int endedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'roundId': roundId,
    'setIndex': setIndex,
    'exerciseId': exerciseId,
    'unit': unit.wire,
    'prescribed': prescribed,
    'done': done,
    'startedAt': startedAt,
    'endedAt': endedAt,
  };
}
