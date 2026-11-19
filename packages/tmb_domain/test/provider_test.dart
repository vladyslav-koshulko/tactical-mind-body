import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

TaskPack _pack(String path) => TaskPack.fromJson(
  jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>,
);

void main() {
  final uncertainty = _pack('../../assets/content/ru/uncertainty.pack.json');
  final demo = _pack('test/demo.pack.json');

  CognitiveTask byId(String id) => demo.items.firstWhere((t) => t.id == id);

  group('PackTaskProvider.generate', () {
    test('один сид → одна задача и один момент cues', () {
      final p1 = PackTaskProvider(uncertainty);
      final p2 = PackTaskProvider(uncertainty);
      for (final s in [0, 1, 12345, 987654321, maxTaskSeed]) {
        final a = p1.generate(TaskSeed(s));
        final b = p2.generate(TaskSeed(s));
        expect(a.id, b.id);
        expect(payloadHash(a), payloadHash(b));
        if (a is VerbalTask && a.cues != null) {
          expect(
            cueMoments(seed: s, taskId: a.id, cues: a.cues!),
            cueMoments(seed: s, taskId: b.id, cues: (b as VerbalTask).cues!),
          );
        }
      }
    });

    test('разные сиды дают разброс по пулу', () {
      final p = PackTaskProvider(uncertainty);
      final ids = {for (var s = 0; s < 300; s++) p.generate(TaskSeed(s)).id};
      expect(p.pool, hasLength(17));
      expect(ids.length, greaterThanOrEqualTo(14));
    });

    test('фильтр категорий: отключённые задачи не выбираются', () {
      final p = PackTaskProvider(
        uncertainty,
        disabledCategories: {
          'cog.uncertainty.rule_shift',
          'cog.uncertainty.estimation',
        },
      );
      expect(
        p.pool.map((t) => t.domain).toSet(),
        isNot(contains('cog.uncertainty.rule_shift')),
      );
      for (var s = 0; s < 200; s++) {
        final t = p.generate(TaskSeed(s));
        expect(t.domain, isNot('cog.uncertainty.rule_shift'));
        expect(t.domain, isNot('cog.uncertainty.estimation'));
      }
      expect(p.archetypes, {TaskArchetype.verbal});
    });

    test('родитель отключает дерево целиком → пул пуст → StateError', () {
      final p = PackTaskProvider(uncertainty, disabledCategories: {'cog'});
      expect(p.pool, isEmpty);
      expect(() => p.generate(TaskSeed(1)), throwsStateError);
      expect(p.estimatedTime, Duration.zero);
    });

    test('метаданные провайдера', () {
      final p = PackTaskProvider(uncertainty);
      expect(p.id, 'cog.uncertainty.ru');
      expect(p.locales, {'ru'});
      expect(p.band.contains(DifficultyLevel.spetsnaz), isTrue);
      expect(p.isMachineVerifiable, isFalse); // в пуле есть verbal
      expect(p.archetypes, {TaskArchetype.verbal, TaskArchetype.recall});
      expect(p.estimatedTime.inSeconds, greaterThan(0));
      expect(PackTaskProvider(demo).isMachineVerifiable, isFalse);
    });

    test('TaskSeed: диапазон 0…2^53-1', () {
      expect(() => TaskSeed(-1), throwsRangeError);
      expect(() => TaskSeed(maxTaskSeed + 1), throwsRangeError);
      expect(TaskSeed(5), TaskSeed(5));
    });
  });

  group('PackTaskProvider.verify', () {
    final provider = PackTaskProvider(demo);

    bool? ok(String id, TaskAnswer a) => provider.verify(byId(id), a).isCorrect;

    test('recall: строка, accept-массив, регистр, ё/е, пробелы', () {
      expect(ok('demo.java.001', const TaskAnswer.recall('final')), isTrue);
      expect(ok('demo.java.001', const TaskAnswer.recall('  FINAL  ')), isTrue);
      expect(ok('demo.java.001', const TaskAnswer.recall('static')), isFalse);
      expect(ok('demo.java.001', const TaskAnswer()), isFalse);
    });

    test('recall: ё → е и схлопывание пробелов', () {
      const t = RecallTask(
        id: 'a.b.c',
        domain: 'a.b',
        timeSec: 10,
        difficulty: 0.1,
        prompt: 'p',
        answer: 'Зелёный  свет',
      );
      expect(
        provider.verify(t, const TaskAnswer.recall(' зеленый свет ')).isCorrect,
        isTrue,
      );
    });

    test('recall: числовой допуск (accept {min,max})', () {
      expect(ok('demo.est.001', const TaskAnswer.recall('86400')), isTrue);
      expect(ok('demo.est.001', const TaskAnswer.recall('80000')), isTrue);
      expect(ok('demo.est.001', const TaskAnswer.recall('90000')), isTrue);
      expect(ok('demo.est.001', const TaskAnswer.recall('79 999')), isFalse);
      expect(ok('demo.est.001', const TaskAnswer.recall('90000,5')), isFalse);
      expect(ok('demo.est.001', const TaskAnswer.recall('85 000')), isTrue);
      expect(ok('demo.est.001', const TaskAnswer.recall('85 000')), isTrue);
      expect(
        ok('demo.est.001', const TaskAnswer.recall('около суток')),
        isFalse,
      );
    });

    test('recall: запятая как десятичный разделитель', () {
      const t = RecallTask(
        id: 'a.b.c',
        domain: 'a.b',
        timeSec: 10,
        difficulty: 0.1,
        prompt: 'p',
        answer: 2.5,
      );
      expect(
        provider.verify(t, const TaskAnswer.recall('2,5')).isCorrect,
        isTrue,
      );
      expect(
        provider.verify(t, const TaskAnswer.recall('2.50')).isCorrect,
        isTrue,
      );
      expect(
        provider.verify(t, const TaskAnswer.recall('2.6')).isCorrect,
        isFalse,
      );
    });

    test('recall: accept-массив', () {
      const t = RecallTask(
        id: 'a.b.c',
        domain: 'a.b',
        timeSec: 10,
        difficulty: 0.1,
        prompt: 'p',
        answer: 'final',
        accept: AcceptList(['final', 'константа']),
      );
      expect(
        provider.verify(t, const TaskAnswer.recall('Константа')).isCorrect,
        isTrue,
      );
      expect(
        provider.verify(t, const TaskAnswer.recall('var')).isCorrect,
        isFalse,
      );
    });

    test('delayed_recall: как recall', () {
      expect(ok('demo.mem.001', const TaskAnswer.recall('р3')), isTrue);
      expect(ok('demo.mem.001', const TaskAnswer.recall('К7')), isFalse);
    });

    test('choice: индекс по исходному порядку', () {
      expect(ok('demo.java.002', TaskAnswer.choice(2)), isTrue);
      expect(ok('demo.java.002', TaskAnswer.choice(0)), isFalse);
      expect(ok('demo.java.002', const TaskAnswer(response: 'x')), isFalse);
    });

    test('ordering: верен только исходный порядок', () {
      expect(ok('demo.net.001', TaskAnswer.ordering([0, 1, 2, 3, 4])), isTrue);
      expect(ok('demo.net.001', TaskAnswer.ordering([1, 0, 2, 3, 4])), isFalse);
      expect(ok('demo.net.001', TaskAnswer.ordering([0, 1, 2])), isFalse);
      expect(ok('demo.net.001', const TaskAnswer()), isFalse);
    });

    test('spatial: row,col', () {
      expect(ok('demo.spa.001', TaskAnswer.spatial(row: 2, col: 3)), isTrue);
      expect(ok('demo.spa.001', TaskAnswer.spatial(row: 3, col: 2)), isFalse);
    });

    test('verbal: «не проверяется машиной», isCorrect == null', () {
      final v = provider.verify(
        byId('demo.ver.001'),
        const TaskAnswer.selfCheck(yes: 2),
      );
      expect(v.isCorrect, isNull);
      expect(v.isMachineVerified, isFalse);
      expect(v.selfRating, 2); // floor(3*2/3 + 0.5) = 2
      expect(
        provider.verify(byId('demo.ver.001'), const TaskAnswer()).selfRating,
        isNull,
      );
    });

    test('stream: формат ответа — v0.2', () {
      expect(
        () => provider.verify(byId('demo.str.001'), const TaskAnswer()),
        throwsUnsupportedError,
      );
    });
  });

  group('selfRating = floor(3·yes/n + 0.5)', () {
    test('n = 3', () {
      expect(
        [for (var y = 0; y <= 3; y++) selfRating(yes: y, n: 3)],
        [0, 1, 2, 3],
      );
    });
    test('n = 2', () {
      // 0 → 0; 1 → floor(2.0) = 2 (1.5 + 0.5); 2 → 3
      expect(
        [for (var y = 0; y <= 2; y++) selfRating(yes: y, n: 2)],
        [0, 2, 3],
      );
    });
    test('совпадает с формулой через double, всегда 0…3', () {
      for (var n = 1; n <= 12; n++) {
        for (var y = 0; y <= n; y++) {
          final r = selfRating(yes: y, n: n);
          expect(r, (3 * y / n + 0.5).floor(), reason: 'yes=$y n=$n');
          expect(r, inInclusiveRange(0, 3));
        }
      }
    });
    test('недопустимые аргументы', () {
      expect(() => selfRating(yes: 0, n: 0), throwsArgumentError);
      expect(() => selfRating(yes: 4, n: 3), throwsRangeError);
      expect(() => selfRating(yes: -1, n: 3), throwsRangeError);
    });
  });
}
