import '../common/json_reader.dart';

/// Один физический круг (SCHEMAS §3.2).
final class RoundLog {
  const RoundLog({
    required this.id,
    required this.sessionId,
    required this.blockIndex,
    required this.roundIndex,
    required this.durationMs,
    required this.rpe,
  });

  factory RoundLog.fromJson(Map<String, Object?> json) =>
      RoundLog.read(readRoot(json));

  factory RoundLog.read(JsonObj o) => RoundLog(
    id: o.string('id'),
    sessionId: o.string('sessionId'),
    blockIndex: o.integer('blockIndex'),
    roundIndex: o.integer('roundIndex'),
    durationMs: o.integer('durationMs'),
    rpe: o.integerN('rpe'),
  );

  final String id;
  final String sessionId;

  /// Позиция `PhysicalBlock` в списке блоков сессии.
  final int blockIndex;

  /// Порядковый номер круга среди физических блоков сессии.
  final int roundIndex;
  final int durationMs;

  /// 1 = легко, 2 = нормально, 3 = тяжело; `null` — не оценил.
  final int? rpe;

  Map<String, Object?> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'blockIndex': blockIndex,
    'roundIndex': roundIndex,
    'durationMs': durationMs,
    'rpe': rpe,
  };
}
