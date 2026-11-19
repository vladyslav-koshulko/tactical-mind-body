import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

Map<String, Object?> _clone(Map<String, Object?> m) =>
    jsonDecode(jsonEncode(m)) as Map<String, Object?>;

Matcher _formatError(String pathPart) => throwsA(
  isA<FormatException>().having(
    (e) => e.message,
    'message',
    contains(pathPart),
  ),
);

void main() {
  final demo = jsonDecode(
    File('test/demo.pack.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final sample = jsonDecode(
    File('test/events_export.sample.json').readAsStringSync(),
  ) as Map<String, Object?>;

  group('пак задач', () {
    test('нет обязательного поля заголовка → путь в сообщении', () {
      final json = _clone(demo)..remove('license');
      expect(() => TaskPack.fromJson(json), _formatError('/license'));
    });

    test('нет обязательного поля задачи → путь с индексом', () {
      final json = _clone(demo);
      ((json['items']! as List)[1] as Map<String, Object?>).remove('options');
      expect(() => TaskPack.fromJson(json), _formatError('/items/1/options'));
    });

    test('нет поля, обязательного именно для архетипа', () {
      final json = _clone(demo);
      ((json['items']! as List)[7] as Map<String, Object?>).remove('selfCheck');
      expect(() => TaskPack.fromJson(json), _formatError('/items/7/selfCheck'));
    });

    test('не тот тип', () {
      final json = _clone(demo);
      ((json['items']! as List)[0] as Map<String, Object?>)['timeSec'] = '30';
      expect(() => TaskPack.fromJson(json), _formatError('/items/0/timeSec'));
    });

    test('null там, где null: нет', () {
      final json = _clone(demo)..['title'] = null;
      expect(() => TaskPack.fromJson(json), _formatError('/title'));
    });

    test('null в необязательном поле не равен отсутствию', () {
      final json = _clone(demo);
      ((json['items']! as List)[0] as Map<String, Object?>)['reveal'] = null;
      expect(() => TaskPack.fromJson(json), _formatError('/items/0/reveal'));
    });

    test('неизвестный архетип и перечисление', () {
      final bad = _clone(demo);
      ((bad['items']! as List)[0] as Map<String, Object?>)['archetype'] =
          'java';
      expect(() => TaskPack.fromJson(bad), _formatError('/items/0/archetype'));
      final bad2 = _clone(demo)..['status'] = 'final';
      expect(() => TaskPack.fromJson(bad2), _formatError('/status'));
    });

    test('kind другого документа', () {
      final json = _clone(demo)..['kind'] = 'exercise_pack';
      expect(() => TaskPack.fromJson(json), _formatError('/kind'));
    });

    test('вложенная ошибка: grid без cols', () {
      final json = _clone(demo);
      final spatial = (json['items']! as List)[5] as Map<String, Object?>;
      (spatial['grid']! as Map<String, Object?>).remove('cols');
      expect(() => TaskPack.fromJson(json), _formatError('/items/5/grid/cols'));
    });

    test('неверная форма accept', () {
      final json = _clone(demo);
      ((json['items']! as List)[0] as Map<String, Object?>)['accept'] = 5;
      expect(() => TaskPack.fromJson(json), _formatError('/items/0/accept'));
    });

    test('комбинируемые знаки в строке пака → FormatException с путём', () {
      final json = _clone(demo)..['title'] = 'é';
      expect(() => TaskPack.fromJson(json), _formatError('/title'));
    });

    test('неизвестные поля игнорируются', () {
      final json = _clone(demo)..['somethingNew'] = {'a': 1};
      expect(
        TaskPack.fromJson(json).toJson().containsKey('somethingNew'),
        isFalse,
      );
    });
  });

  group('события', () {
    test('round-trip образца §3.6', () {
      final export = EventsExport.fromJson(sample);
      expect(export.toJson(), sample);
      expect(export.attempts, hasLength(2));
      final verbal = export.attempts[1];
      expect(verbal.isCorrect, isNull);
      expect(verbal.selfRating, 2);
      expect(verbal.response, isNull);
      expect(
        export.attempts[0].toJson(),
        containsPair('encodedRoundIndex', null),
      );
    });

    test(
      'nullable-поля обязаны присутствовать (null: да ≠ можно опустить)',
      () {
        final json = _clone(sample);
        ((json['attempts']! as List)[0] as Map<String, Object?>).remove(
          'latencyMs',
        );
        expect(
          () => EventsExport.fromJson(json),
          _formatError('/attempts/0/latencyMs'),
        );
      },
    );

    test('нет roundIndex у попытки — ошибка записи, а не пустое значение', () {
      final json = _clone(sample);
      ((json['attempts']! as List)[0] as Map<String, Object?>).remove(
        'roundIndex',
      );
      expect(
        () => EventsExport.fromJson(json),
        _formatError('/attempts/0/roundIndex'),
      );
    });

    test('нет payloadHash', () {
      final json = _clone(sample);
      ((json['attempts']! as List)[1] as Map<String, Object?>).remove(
        'payloadHash',
      );
      expect(
        () => EventsExport.fromJson(json),
        _formatError('/attempts/1/payloadHash'),
      );
    });

    test('Session: нет startedAt / неверный enum', () {
      final s = _clone(
        (sample['sessions']! as List)[0] as Map<String, Object?>,
      );
      expect(
        () => Session.fromJson(_clone(s)..remove('startedAt')),
        _formatError('/startedAt'),
      );
      expect(
        () => Session.fromJson(_clone(s)..['location'] = 'MARS'),
        _formatError('/location'),
      );
      final open = Session.fromJson(_clone(s)..['endedAt'] = null);
      expect(open.endedAt, isNull);
    });

    test('RoundLog: rpe null допустим, отсутствие — нет', () {
      final r = _clone((sample['rounds']! as List)[0] as Map<String, Object?>);
      expect(RoundLog.fromJson(_clone(r)..['rpe'] = null).rpe, isNull);
      expect(
        () => RoundLog.fromJson(_clone(r)..remove('rpe')),
        _formatError('/rpe'),
      );
    });

    test('ExerciseSet: тип поля', () {
      final s = _clone((sample['sets']! as List)[0] as Map<String, Object?>);
      expect(
        () => ExerciseSet.fromJson(_clone(s)..['done'] = 'много'),
        _formatError('/done'),
      );
      expect(ExerciseSet.fromJson(s).unit, ExerciseUnit.reps);
    });

    test('EventsExport: нет массива', () {
      final json = _clone(sample)..remove('sets');
      expect(() => EventsExport.fromJson(json), _formatError('/sets'));
    });
  });

  group('профиль', () {
    test('round-trip образца §4', () {
      final json = jsonDecode(
        File('test/profile.sample.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final profile = ProfileSettings.fromJson(json);
      expect(profile.toJson(), json);
      expect(profile.isEnabled('cog.uncertainty.premortem'), isFalse);
      expect(profile.isEnabled('it.java'), isFalse);
      expect(profile.isEnabled('cog.uncertainty.estimation'), isTrue);
      expect(profile.exerciseTargets.single.lockedByUser, isTrue);
    });

    test('нет defaultTargets.seconds', () {
      final json = {
        'schemaVersion': 1,
        'disabledCategories': <String>[],
        'defaultTargets': {
          'reps': {'min': 1, 'max': 2},
        },
        'exerciseTargets': <Object?>[],
        'progression': {'enabled': true},
      };
      expect(
        () => ProfileSettings.fromJson(json),
        _formatError('/defaultTargets/seconds'),
      );
    });
  });
}
