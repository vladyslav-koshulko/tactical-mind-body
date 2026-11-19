import '../common/enums.dart';
import '../common/json_reader.dart';
import '../content/task_archetype.dart';
import 'attempt_status.dart';

/// Одна когнитивная попытка — сырое событие, не агрегат (инвариант 2,
/// SCHEMAS §3.4).
///
/// `roundIndex`, `latencyMs`, `isCorrect`, `payloadHash` — ядро инварианта 2.
/// Клиент не вычисляет и не отправляет счёт — только эти события (инвариант 8).
final class TaskAttempt {
  const TaskAttempt({
    required this.id,
    required this.sessionId,
    required this.blockIndex,
    required this.roundIndex,
    required this.taskId,
    required this.packId,
    required this.packSource,
    required this.archetype,
    required this.domain,
    required this.difficulty,
    required this.seed,
    required this.status,
    required this.presentedAt,
    required this.answeredAt,
    required this.latencyMs,
    required this.isCorrect,
    required this.selfRating,
    required this.response,
    required this.encodedRoundIndex,
    required this.payloadHash,
  });

  factory TaskAttempt.fromJson(Map<String, Object?> json) =>
      TaskAttempt.read(readRoot(json));

  factory TaskAttempt.read(JsonObj o) => TaskAttempt(
    id: o.string('id'),
    sessionId: o.string('sessionId'),
    blockIndex: o.integer('blockIndex'),
    roundIndex: o.integer('roundIndex'),
    taskId: o.string('taskId'),
    packId: o.string('packId'),
    packSource: o.enumValue('packSource', PackSource.values),
    archetype: o.enumValue('archetype', TaskArchetype.values),
    domain: o.string('domain'),
    difficulty: o.dbl('difficulty'),
    seed: o.integer('seed'),
    status: o.enumValue('status', AttemptStatus.values),
    presentedAt: o.integer('presentedAt'),
    answeredAt: o.integerN('answeredAt'),
    latencyMs: o.integerN('latencyMs'),
    isCorrect: o.reqNullable('isCorrect', convBool),
    selfRating: o.integerN('selfRating'),
    response: o.stringN('response'),
    encodedRoundIndex: o.integerN('encodedRoundIndex'),
    payloadHash: o.string('payloadHash'),
  );

  final String id;
  final String sessionId;

  /// Позиция `CognitiveBlock` в списке блоков сессии.
  final int blockIndex;

  /// Число `CognitiveBlock`, начавшихся раньше в этой сессии (с нуля).
  final int roundIndex;

  /// Для генераторного провайдера — id шаблона.
  final String taskId;

  /// `pack` пака (для генераторного провайдера — id провайдера).
  final String packId;
  final PackSource packSource;
  final TaskArchetype archetype;
  final String domain;

  /// Копия на момент показа.
  final double difficulty;

  /// Сид, по которому задача сгенерирована/показана (инвариант 4).
  final int seed;
  final AttemptStatus status;
  final int presentedAt;

  /// `null` ⇔ `status != answered`.
  final int? answeredAt;

  /// Монотонные часы; `null` ⇔ `status != answered`.
  final int? latencyMs;

  /// `null` ⇔ задача непроверяема (`verbal`); `timeout`/`skipped` дают `false`.
  final bool? isCorrect;

  /// 0…3, только `verbal` и `answered`.
  final int? selfRating;

  /// Ответ в каноническом виде для серверной перепроверки (инвариант 8).
  final String? response;

  /// Только `delayed_recall`: `roundIndex` фазы запоминания.
  final int? encodedRoundIndex;

  /// 64 символа `[0-9a-f]`.
  final String payloadHash;

  Map<String, Object?> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'blockIndex': blockIndex,
    'roundIndex': roundIndex,
    'taskId': taskId,
    'packId': packId,
    'packSource': packSource.wire,
    'archetype': archetype.wire,
    'domain': domain,
    'difficulty': difficulty,
    'seed': seed,
    'status': status.wire,
    'presentedAt': presentedAt,
    'answeredAt': answeredAt,
    'latencyMs': latencyMs,
    'isCorrect': isCorrect,
    'selfRating': selfRating,
    'response': response,
    'encodedRoundIndex': encodedRoundIndex,
    'payloadHash': payloadHash,
  };
}
