import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

Map<String, Object?> _load(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

const _uncertainty = '../../assets/content/ru/uncertainty.pack.json';
const _exercises = '../../assets/content/ru/exercises.base.pack.json';

void main() {
  group('пак задач: round-trip fromJson → toJson', () {
    for (final path in [_uncertainty, 'test/demo.pack.json']) {
      test(path, () {
        final json = _load(path);
        final pack = TaskPack.fromJson(json);
        expect(pack.toJson(), json);
        // Через настоящую сериализацию тоже.
        expect(jsonDecode(jsonEncode(pack.toJson())), json);
      });

      test('$path: каждая задача без потери полей', () {
        final json = _load(path);
        final items = (json['items']! as List).cast<Map<String, Object?>>();
        final pack = TaskPack.fromJson(json);
        expect(pack.items, hasLength(items.length));
        for (var i = 0; i < items.length; i++) {
          expect(
            pack.items[i].toJson(),
            items[i],
            reason: items[i]['id']! as String,
          );
        }
      });
    }

    test('demo-пак покрывает все семь архетипов — и ровно семь классов', () {
      final pack = TaskPack.fromJson(_load('test/demo.pack.json'));
      expect(
        pack.items.map((t) => t.archetype).toSet(),
        TaskArchetype.values.toSet(),
      );
      expect(TaskArchetype.values, hasLength(7));
      expect(pack.items.map((t) => t.runtimeType).toSet(), hasLength(7));
    });

    test('реальный пак: заголовок и типы', () {
      final pack = TaskPack.fromJson(_load(_uncertainty));
      expect(pack.pack, 'cog.uncertainty.ru');
      expect(pack.packSource, PackSource.builtin);
      expect(pack.levels, DifficultyLevel.values);
      expect(pack.items.whereType<VerbalTask>(), isNotEmpty);
      expect(pack.items.whereType<RecallTask>(), hasLength(3));
      final recall = pack.items.whereType<RecallTask>().first;
      expect(recall.accept, isA<AcceptRange>());
      final cued = pack.items.whereType<VerbalTask>().firstWhere(
        (t) => t.id == 'unc.rs.001',
      );
      expect(cued.cues!.single.fromSec, 18);
      expect(cued.cues!.single.toSec, 32);
    });

    test('verbal: reveal и gen игнорируются и не сохраняются', () {
      final task = CognitiveTask.fromJson({
        'id': 'x.y.z',
        'domain': 'a.b',
        'archetype': 'verbal',
        'verifiable': false,
        'timeSec': 30,
        'difficulty': 0.5,
        'prompt': 'p',
        'selfCheck': ['a', 'b'],
        'reveal': 'нельзя',
        'gen': {'k': 1},
        'unknownField': 1,
      });
      expect(task.toJson().keys, isNot(contains('reveal')));
      expect(task.toJson().keys, isNot(contains('gen')));
      expect(task.toJson().keys, isNot(contains('unknownField')));
    });

    test('CRLF и одиночный CR в строках контента → LF', () {
      final task = CognitiveTask.fromJson({
        'id': 'x.y.z',
        'domain': 'a.b',
        'archetype': 'ordering',
        'verifiable': true,
        'timeSec': 30,
        'difficulty': 0.5,
        'prompt': 'a\r\nb\rc',
        'items': ['1', '2'],
      });
      expect(task.prompt, 'a\nb\nc');
    });
  });

  group('пак упражнений', () {
    for (final path in [_exercises, 'test/exercises.sample.json']) {
      test('round-trip $path', () {
        final json = _load(path);
        final pack = ExercisePack.fromJson(json);
        expect(pack.toJson(), json);
      });
    }

    test('поля базового пака', () {
      final pack = ExercisePack.fromJson(_load(_exercises));
      expect(pack.exercises, isNotEmpty);
      final first = pack.exercises.first;
      expect(first.id, 'ex.burpee_pushup');
      expect(first.legacyId, 1);
      expect(first.unit, ExerciseUnit.reps);
      expect(first.nameFor('ru', defaultLocale: 'ru'), 'Бёрпи с отжиманием');
      expect(first.nameFor('uk', defaultLocale: 'ru'), 'Бёрпи с отжиманием');
      expect(first.nameFor('uk', defaultLocale: 'en'), isNull);
    });

    test('образец §2: legacyId = null сохраняется как null', () {
      final pack = ExercisePack.fromJson(_load('test/exercises.sample.json'));
      expect(pack.exercises.first.legacyId, isNull);
      expect(pack.exercises.first.toJson(), containsPair('legacyId', null));
      expect(pack.exercises.first.name, {
        'ru': 'Планка',
        'uk': 'Планка',
        'en': 'Plank',
      });
    });
  });
}
