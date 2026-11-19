import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

void main() {
  group('SessionTemplate', () {
    test('dual_task даёт чередование круг → окно', () {
      final t = SessionTemplate.dualTask(rounds: 5, cognitiveSec: 180);
      expect(t.kind, SessionTemplateKind.dualTask);
      expect(t.blocks.map((b) => b.runtimeType), [
        PhysicalBlock,
        CognitiveBlock,
        PhysicalBlock,
        CognitiveBlock,
        PhysicalBlock,
        CognitiveBlock,
        PhysicalBlock,
        CognitiveBlock,
        PhysicalBlock,
      ]);
      expect(t.physicalBlockCount, 5);
      expect(t.cognitiveBlockCount, 4);
      expect((t.blocks[1] as CognitiveBlock).durationSec, 180);
    });

    test('dual_task из одного круга — без когнитивных окон', () {
      final t = SessionTemplate.dualTask(rounds: 1, cognitiveSec: 180);
      expect(t.blocks, hasLength(1));
    });

    test('physical_only не содержит CognitiveBlock', () {
      final t = SessionTemplate.physicalOnly(rounds: 4, restSec: 60);
      expect(t.kind, SessionTemplateKind.physicalOnly);
      expect(t.blocks.whereType<CognitiveBlock>(), isEmpty);
      expect(t.blocks.whereType<PhysicalBlock>(), hasLength(4));
      expect(t.blocks.whereType<RestBlock>(), hasLength(3));
      expect(SessionTemplate.physicalOnly(rounds: 3).blocks, hasLength(3));
    });

    test('cognitive_only не содержит PhysicalBlock', () {
      final t = SessionTemplate.cognitiveOnly(windows: 3, cognitiveSec: 120);
      expect(t.kind, SessionTemplateKind.cognitiveOnly);
      expect(t.blocks.whereType<PhysicalBlock>(), isEmpty);
      expect(t.blocks, hasLength(3));
    });

    test('custom — произвольная последовательность', () {
      final t = SessionTemplate.custom(const [
        CognitiveBlock(durationSec: 60),
        CognitiveBlock(durationSec: 60),
        PhysicalBlock(),
        RestBlock(durationSec: 30),
      ]);
      expect(t.kind, SessionTemplateKind.custom);
      expect(t.blocks, hasLength(4));
    });

    test('список блоков неизменяем', () {
      final t = SessionTemplate.dualTask(rounds: 2, cognitiveSec: 60);
      expect(() => t.blocks.add(const PhysicalBlock()), throwsUnsupportedError);
    });

    test('некорректное число кругов', () {
      expect(
        () => SessionTemplate.dualTask(rounds: 0, cognitiveSec: 60),
        throwsArgumentError,
      );
      expect(
        () => SessionTemplate.cognitiveOnly(windows: 0, cognitiveSec: 60),
        throwsArgumentError,
      );
    });

    test(
      'индексы кругов: роль blockIndex → roundIndex (SCHEMAS §3.2, §3.4)',
      () {
        final t = SessionTemplate.dualTask(rounds: 3, cognitiveSec: 180);
        // P0 C0 P1 C1 P2
        expect(
          [
            t.physicalRoundIndex(0),
            t.physicalRoundIndex(2),
            t.physicalRoundIndex(4),
          ],
          [0, 1, 2],
        );
        expect([t.cognitiveRoundIndex(1), t.cognitiveRoundIndex(3)], [0, 1]);
        expect(() => t.cognitiveRoundIndex(0), throwsArgumentError);
        expect(() => t.physicalRoundIndex(99), throwsRangeError);

        final c = SessionTemplate.cognitiveOnly(windows: 3, cognitiveSec: 60);
        expect(
          [for (var i = 0; i < 3; i++) c.cognitiveRoundIndex(i)],
          [0, 1, 2],
        );
      },
    );

    test('round-trip JSON', () {
      for (final t in [
        SessionTemplate.dualTask(rounds: 3, cognitiveSec: 180),
        SessionTemplate.physicalOnly(rounds: 3, restSec: 45),
        SessionTemplate.cognitiveOnly(windows: 2, cognitiveSec: 90),
      ]) {
        expect(SessionTemplate.fromJson(t.toJson()).toJson(), t.toJson());
      }
      expect(
        () => SessionTemplate.fromJson({
          'kind': 'custom',
          'blocks': [
            {'type': 'jumping'},
          ],
        }),
        throwsFormatException,
      );
    });
  });
}
