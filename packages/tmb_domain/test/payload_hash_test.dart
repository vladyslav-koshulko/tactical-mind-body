import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

Map<String, Object?> _demoItem(String id) {
  final pack = jsonDecode(
    File('test/demo.pack.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final items = (pack['items']! as List).cast<Map<String, Object?>>();
  return items.firstWhere((i) => i['id'] == id);
}

CognitiveTask _task(String id) => CognitiveTask.fromJson(_demoItem(id));

void main() {
  group('payloadHash — SCHEMAS §3.5', () {
    test('вектор demo.java.002: каноническая строка и хеш', () {
      final task = _task('demo.java.002');
      expect(
        canonicalPayload(task),
        '{"answer":2,"archetype":"choice","options":["int","boolean","String","double"],'
        '"prompt":"Какой из типов Java не является примитивным?","timeSec":30}',
      );
      expect(
        payloadHash(task),
        '0301b322e4db5a224c9262ad495394182698d55b6a82ac005e992529b93a4833',
      );
    });

    test('id, domain, difficulty, reveal, shuffle хеш не меняют', () {
      final base = _demoItem('demo.java.002');
      final changed = {
        ...base,
        'id': 'other.id.999',
        'domain': 'it.other',
        'difficulty': 0.9,
        'reveal': 'что-то',
        'shuffle': false,
      };
      expect(
        payloadHash(CognitiveTask.fromJson(changed)),
        payloadHash(CognitiveTask.fromJson(base)),
      );
    });

    test('изменение условия меняет хеш', () {
      final base = _demoItem('demo.java.002');
      final changed = {...base, 'answer': 1};
      expect(
        payloadHash(CognitiveTask.fromJson(changed)),
        isNot(payloadHash(CognitiveTask.fromJson(base))),
      );
    });

    test('значения по умолчанию входят в payload', () {
      final delayed = CognitiveTask.fromJson(
        {..._demoItem('demo.mem.001')}
          ..remove('delayRounds')
          ..remove('showSec'),
      );
      final payload = taskPayload(delayed);
      expect(payload['delayRounds'], 1);
      expect(payload['showSec'], 10);

      final stream = CognitiveTask.fromJson(
        {..._demoItem('demo.str.001')}..remove('stimulusMs'),
      );
      expect(taskPayload(stream)['stimulusMs'], 1000);
    });

    test('явное значение по умолчанию = отсутствующее (тот же хеш)', () {
      final withDefault = {..._demoItem('demo.mem.001'), 'delayRounds': 1}
        ..['showSec'] = 10;
      final without = {..._demoItem('demo.mem.001')}
        ..remove('delayRounds')
        ..remove('showSec');
      expect(
        payloadHash(CognitiveTask.fromJson(withDefault)),
        payloadHash(CognitiveTask.fromJson(without)),
      );
    });

    test('набор полей по архетипам', () {
      Set<String> keys(String id) => taskPayload(_task(id)).keys.toSet();
      const common = {'archetype', 'prompt', 'timeSec'};
      expect(keys('demo.java.001'), {...common, 'answer', 'accept'});
      expect(keys('demo.java.002'), {...common, 'options', 'answer'});
      expect(keys('demo.net.001'), {...common, 'items'});
      expect(keys('demo.mem.001'), {
        ...common,
        'memorize',
        'question',
        'answer',
        'delayRounds',
        'showSec',
      });
      expect(keys('demo.spa.001'), {
        ...common,
        'grid',
        'objects',
        'answer',
        'showSec',
      });
      expect(keys('demo.str.001'), {
        ...common,
        'stimuli',
        'targets',
        'stimulusMs',
      });
      expect(keys('demo.ver.001'), {...common, 'selfCheck', 'cues'});
    });

    test('spatial и verbal: вложенные объекты сериализуются каноничнее', () {
      expect(
        canonicalPayload(_task('demo.spa.001')),
        contains('"grid":{"cols":4,"rows":4}'),
      );
      expect(
        canonicalPayload(_task('demo.ver.001')),
        contains('"cues":[{"atSec":[15,25],"text":"СМЕНА ПРАВИЛА'),
      );
    });

    test('accept-диапазон: ключи max, min по порядку', () {
      expect(
        canonicalPayload(_task('demo.est.001')),
        contains('"accept":{"max":90000,"min":80000}'),
      );
    });

    test('хеш — 64 символа [0-9a-f]', () {
      for (final id in [
        'demo.java.001',
        'demo.net.001',
        'demo.mem.001',
        'demo.spa.001',
        'demo.str.001',
        'demo.ver.001',
      ]) {
        expect(payloadHash(_task(id)), matches(RegExp(r'^[0-9a-f]{64}$')));
      }
    });
  });
}
