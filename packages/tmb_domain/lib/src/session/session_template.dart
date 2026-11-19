import '../common/enums.dart';
import '../common/json_reader.dart';
import 'session_block.dart';

/// Шаблон сессии — произвольная последовательность блоков (инвариант 5).
///
/// «Dual-task», «только физика», «только когниция» — не режимы в коде, а
/// фабрики, которые просто раскладывают разные списки блоков.
final class SessionTemplate {
  SessionTemplate({required this.kind, required List<SessionBlock> blocks})
    : blocks = List.unmodifiable(blocks);

  /// Классический dual-task: круг, когнитивное окно, круг, окно… Заканчивается
  /// физическим кругом: после последнего круга сессия завершается, пауза
  /// после него не нужна. Окно после круга `k` получает `roundIndex = k`.
  factory SessionTemplate.dualTask({
    required int rounds,
    required int cognitiveSec,
  }) {
    _requirePositive(rounds, 'rounds');
    return SessionTemplate(
      kind: SessionTemplateKind.dualTask,
      blocks: [
        for (var i = 0; i < rounds; i++) ...[
          const PhysicalBlock(),
          if (i < rounds - 1) CognitiveBlock(durationSec: cognitiveSec),
        ],
      ],
    );
  }

  /// Только физика: круги, между ними пассивный отдых [restSec].
  /// `restSec == 0` — круги подряд, без блоков отдыха.
  factory SessionTemplate.physicalOnly({required int rounds, int restSec = 0}) {
    _requirePositive(rounds, 'rounds');
    return SessionTemplate(
      kind: SessionTemplateKind.physicalOnly,
      blocks: [
        for (var i = 0; i < rounds; i++) ...[
          const PhysicalBlock(),
          if (i < rounds - 1 && restSec > 0) RestBlock(durationSec: restSec),
        ],
      ],
    );
  }

  /// Только когниция («тренировка в транспорте»): [windows] окон подряд.
  factory SessionTemplate.cognitiveOnly({
    required int windows,
    required int cognitiveSec,
  }) {
    _requirePositive(windows, 'windows');
    return SessionTemplate(
      kind: SessionTemplateKind.cognitiveOnly,
      blocks: [
        for (var i = 0; i < windows; i++)
          CognitiveBlock(durationSec: cognitiveSec),
      ],
    );
  }

  /// Пользовательская последовательность.
  factory SessionTemplate.custom(List<SessionBlock> blocks) =>
      SessionTemplate(kind: SessionTemplateKind.custom, blocks: blocks);

  factory SessionTemplate.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    return SessionTemplate(
      kind: o.enumValue('kind', SessionTemplateKind.values),
      blocks: o.req(
        'blocks',
        listOf((v, p) => SessionBlock.fromJson(convObject(v, p).map)),
      ),
    );
  }

  final SessionTemplateKind kind;
  final List<SessionBlock> blocks;

  int get physicalBlockCount => blocks.whereType<PhysicalBlock>().length;
  int get cognitiveBlockCount => blocks.whereType<CognitiveBlock>().length;

  /// `RoundLog.roundIndex` для физического блока на позиции [blockIndex]:
  /// сколько `PhysicalBlock` стоит раньше.
  int physicalRoundIndex(int blockIndex) {
    _requirePosition(blockIndex, PhysicalBlock);
    return blocks.take(blockIndex).whereType<PhysicalBlock>().length;
  }

  /// `TaskAttempt.roundIndex` для когнитивного блока на позиции [blockIndex]:
  /// сколько `CognitiveBlock` начато раньше (SCHEMAS §3.4).
  int cognitiveRoundIndex(int blockIndex) {
    _requirePosition(blockIndex, CognitiveBlock);
    return blocks.take(blockIndex).whereType<CognitiveBlock>().length;
  }

  void _requirePosition(int blockIndex, Type expected) {
    if (blockIndex < 0 || blockIndex >= blocks.length) {
      throw RangeError.index(blockIndex, blocks, 'blockIndex');
    }
    if (blocks[blockIndex].runtimeType != expected) {
      throw ArgumentError.value(
        blockIndex,
        'blockIndex',
        'блок на этой позиции не $expected',
      );
    }
  }

  Map<String, Object?> toJson() => {
    'kind': kind.wire,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };
}

void _requirePositive(int value, String name) {
  if (value < 1) throw ArgumentError.value(value, name, 'должно быть ≥ 1');
}
