import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../content/accept.dart';
import '../content/cognitive_task.dart';
import 'canonical_json.dart';

/// Payload-объект задачи — SCHEMAS §3.5, пункты 1–2.
///
/// Только перечисленные поля и только присутствующие, с применёнными
/// значениями по умолчанию (`delayRounds`, `showSec`, `stimulusMs`). Не входят:
/// `id`, `domain`, `difficulty`, `verifiable`, `reveal`, `shuffle`, `gen` —
/// перекалибровка сложности и перенос в другую категорию хеш не меняют.
Map<String, Object> taskPayload(CognitiveTask task) {
  final payload = <String, Object>{
    'archetype': task.archetype.wire,
    'prompt': task.prompt,
    'timeSec': task.timeSec,
  };
  switch (task) {
    case RecallTask():
      payload['answer'] = task.answer;
      _putAccept(payload, task.accept);
    case ChoiceTask():
      payload['options'] = task.options;
      payload['answer'] = task.answer;
    case OrderingTask():
      payload['items'] = task.items;
    case DelayedRecallTask():
      payload['memorize'] = task.memorize;
      payload['question'] = task.question;
      payload['answer'] = task.answer;
      _putAccept(payload, task.accept);
      payload['delayRounds'] = task.effectiveDelayRounds;
      payload['showSec'] = task.effectiveShowSec;
    case SpatialTask():
      payload['grid'] = task.grid.toJson();
      final objects = task.objects;
      if (objects != null) {
        payload['objects'] = objects.map((o) => o.toJson()).toList();
      }
      payload['answer'] = task.answer.toJson();
      payload['showSec'] = task.effectiveShowSec;
    case StreamTask():
      payload['stimuli'] = task.stimuli;
      payload['targets'] = task.targets;
      payload['stimulusMs'] = task.effectiveStimulusMs;
    case VerbalTask():
      payload['selfCheck'] = task.selfCheck;
      final cues = task.cues;
      if (cues != null) {
        payload['cues'] = cues.map((c) => c.toJson()).toList();
      }
  }
  return payload;
}

void _putAccept(Map<String, Object> payload, Accept? accept) {
  if (accept != null) payload['accept'] = accept.toJson();
}

/// Каноническая строка payload задачи (то, что хешируется).
String canonicalPayload(CognitiveTask task) => canonicalJson(taskPayload(task));

/// `hex_lowercase(SHA-256(UTF-8(канонический_JSON)))` — SCHEMAS §3.5, п. 5.
///
/// Строки с комбинируемыми знаками дают [UnsupportedError] (см. `nfc`).
String payloadHash(CognitiveTask task) =>
    sha256.convert(utf8.encode(canonicalPayload(task))).toString();
