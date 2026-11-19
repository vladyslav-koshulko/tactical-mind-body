import '../common/json_reader.dart';

/// Блок сессии (инвариант 5): сессия — список блоков, а не жёсткое
/// «круг → пауза». Здесь только данные; таймеров и движка нет.
sealed class SessionBlock {
  const SessionBlock();

  factory SessionBlock.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    final type = o.string('type');
    return switch (type) {
      PhysicalBlock.type => const PhysicalBlock(),
      CognitiveBlock.type => CognitiveBlock(
        durationSec: o.integer('durationSec'),
      ),
      RestBlock.type => RestBlock(durationSec: o.integer('durationSec')),
      _ => throw FormatException(
        '${o.pathOf('type')}: неизвестный тип блока "$type"',
      ),
    };
  }

  Map<String, Object?> toJson();
}

/// Один физический круг (в истории ему соответствует один `RoundLog`).
/// Состав упражнений выбирается при старте сессии, а не хранится в блоке.
final class PhysicalBlock extends SessionBlock {
  const PhysicalBlock();

  static const type = 'physical';

  @override
  Map<String, Object?> toJson() => {'type': type};
}

/// Когнитивное окно: одна или несколько задач за [durationSec].
final class CognitiveBlock extends SessionBlock {
  const CognitiveBlock({required this.durationSec});

  static const type = 'cognitive';

  /// Длительность окна; в прототипе — `breakSeconds: 180`.
  final int durationSec;

  @override
  Map<String, Object?> toJson() => {'type': type, 'durationSec': durationSec};
}

/// Пассивный отдых без задач.
final class RestBlock extends SessionBlock {
  const RestBlock({required this.durationSec});

  static const type = 'rest';

  final int durationSec;

  @override
  Map<String, Object?> toJson() => {'type': type, 'durationSec': durationSec};
}
