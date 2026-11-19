import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'fixtures.dart';

/// Негативный случай: как испортить валидный образец, чтобы сработал код.
final class _Case {
  _Case(this.kind, this.mutate, {this.context});

  /// Испорченный байтовый документ целиком (для правил до разбора JSON).
  _Case.raw(this.kind, Uint8List Function() bytes)
    : mutate = null,
      _bytes = bytes,
      context = null;

  final DocumentKind kind;
  final void Function(Json doc)? mutate;
  final ValidationContext? context;
  Uint8List Function()? _bytes;

  ValidationResult run() {
    final bytes = _bytes;
    if (bytes != null) {
      return validate(bytes(), ValidationContext(expectedKind: kind));
    }
    final doc = loadSample(kind);
    mutate!(doc);
    return check(doc, kind, context: context);
  }
}

const _tp = DocumentKind.taskPack;
const _ep = DocumentKind.exercisePack;
const _ev = DocumentKind.eventsExport;
const _pf = DocumentKind.profile;

const _otherUuid = '11111111-1111-4111-8111-111111111111';

ValidationContext _ctx(
  DocumentKind kind, {
  String? directoryLocale,
  PackSource? assigned,
  Set<String>? knownExercises,
  Set<String>? domains,
}) => ValidationContext(
  expectedKind: kind,
  directoryLocale: directoryLocale,
  assignedPackSource: assigned,
  knownExerciseIds: knownExercises,
  installedTaskDomains: domains,
);

/// Таблица «код → как испортить образец». Мета-тест ниже падает, если для
/// какого-то значения [ValidationCode] записи нет.
final Map<ValidationCode, _Case> _cases = {
  // --- 6.1 Общие ---
  ValidationCode.packNotJson: _Case.raw(
    _tp,
    () => Uint8List.fromList(utf8.encode('{"не": json')),
  ),
  ValidationCode.packTooLarge: _Case.raw(
    _tp,
    () => Uint8List.fromList(utf8.encode('x' * (1048576 + 1))),
  ),
  ValidationCode.packTooDeep: _Case.raw(
    _tp,
    () => Uint8List.fromList(utf8.encode('{"a":[[[[[[[[1]]]]]]]]}')),
  ),
  ValidationCode.packSchemaVersion: _Case(
    _tp,
    (d) => d['schemaVersion'] = 'один',
  ),
  ValidationCode.packSchemaUnsupported: _Case(
    _tp,
    (d) => d['schemaVersion'] = 2,
  ),
  ValidationCode.packBadKind: _Case(_tp, (d) => d['kind'] = 'exercise_pack'),
  ValidationCode.packMissingField: _Case(
    _tp,
    (d) => task(d, recallTask).remove('timeSec'),
  ),
  ValidationCode.packBadType: _Case(
    _tp,
    (d) => task(d, recallTask)['timeSec'] = '30',
  ),
  ValidationCode.packUnknownField: _Case(
    _tp,
    (d) => task(d, recallTask)['hint'] = 'x',
  ),
  ValidationCode.packFieldNotAllowed: _Case(
    _tp,
    (d) => task(d, recallTask)['options'] = ['a', 'b'],
  ),
  ValidationCode.packReservedField: _Case(
    _tp,
    (d) => task(d, recallTask)['gen'] = <String, Object?>{},
  ),
  ValidationCode.packBadId: _Case(_tp, (d) => task(d, recallTask)['id'] = 'X'),
  ValidationCode.packDupId: _Case(
    _tp,
    (d) => task(d, choiceTask)['id'] = task(d, recallTask)['id'],
  ),
  ValidationCode.packBadFormat: _Case(_tp, (d) => d['locale'] = 'RU'),
  ValidationCode.packBadEnum: _Case(_tp, (d) => d['status'] = 'final'),
  ValidationCode.packLocaleMismatch: _Case(
    _tp,
    (_) {},
    context: _ctx(_tp, directoryLocale: 'uk'),
  ),
  ValidationCode.packSourceOverridden: _Case(
    _tp,
    (_) {},
    context: _ctx(_tp, assigned: PackSource.user),
  ),
  ValidationCode.packStringEmpty: _Case(
    _tp,
    (d) => task(d, recallTask)['prompt'] = '   ',
  ),
  ValidationCode.packStringTooLong: _Case(
    _tp,
    (d) => task(d, recallTask)['prompt'] = 'я' * 1001,
  ),
  ValidationCode.packBadChars: _Case(
    _tp,
    (d) => task(d, recallTask)['prompt'] = 'а\u0007б',
  ),
  ValidationCode.packMarkup: _Case(
    _tp,
    (d) => task(d, recallTask)['prompt'] = 'Нажмите <b>здесь</b>',
  ),
  ValidationCode.packUrlInText: _Case(
    _tp,
    (d) => task(d, recallTask)['prompt'] = 'Смотрите https://example.com/a',
  ),
  ValidationCode.packNumberRange: _Case(
    _tp,
    (d) => task(d, recallTask)['difficulty'] = 0.1234567,
  ),
  ValidationCode.packLimitItems: _Case(
    _tp,
    (d) => d['items'] = List.filled(2001, <String, Object?>{}),
  ),
  ValidationCode.packLimitArray: _Case(_tp, (d) {
    final cue = copy(list(task(d, verbalTask), 'cues').first! as Json);
    task(d, verbalTask)['cues'] = List.filled(6, cue);
  }),

  // --- 6.2 Пак задач ---
  ValidationCode.packBadDomain: _Case(
    _tp,
    (d) => task(d, recallTask)['domain'] = 'Java',
  ),
  ValidationCode.packDupCategory: _Case(
    _tp,
    (d) =>
        list(d, 'categories').add(copy(list(d, 'categories').first! as Json)),
  ),
  ValidationCode.packUndeclaredDomain: _Case(
    _tp,
    (d) => task(d, recallTask)['domain'] = 'it.unknown',
  ),
  ValidationCode.packEmptyCategory: _Case(
    _tp,
    (d) => list(d, 'categories').add({'domain': 'it.extra', 'title': 'Пусто'}),
  ),
  ValidationCode.packBadArchetype: _Case(
    _tp,
    (d) => task(d, recallTask)['archetype'] = 'quiz',
  ),
  ValidationCode.packVerbalVerifiable: _Case(
    _tp,
    (d) => task(d, verbalTask)['verifiable'] = true,
  ),
  ValidationCode.packNonverbalUnverifiable: _Case(
    _tp,
    (d) => task(d, recallTask)['verifiable'] = false,
  ),
  ValidationCode.packNoSelfcheck: _Case(
    _tp,
    (d) => task(d, verbalTask).remove('selfCheck'),
  ),
  ValidationCode.packSelfcheckCount: _Case(
    _tp,
    (d) => task(d, verbalTask)['selfCheck'] = ['Один вопрос?'],
  ),
  ValidationCode.packBadDifficulty: _Case(
    _tp,
    (d) => task(d, recallTask)['difficulty'] = 1.5,
  ),
  ValidationCode.packBadTime: _Case(
    _tp,
    (d) => task(d, recallTask)['timeSec'] = 4,
  ),
  ValidationCode.packTimeLong: _Case(
    _tp,
    (d) => task(d, recallTask)['timeSec'] = 150,
  ),
  ValidationCode.packDupPrompt: _Case(
    _tp,
    (d) => task(d, choiceTask)['prompt'] =
        '  ${(task(d, recallTask)['prompt']! as String).toUpperCase()} ',
  ),
  ValidationCode.packChoiceOptions: _Case(
    _tp,
    (d) => task(d, choiceTask)['options'] = ['единственный'],
  ),
  ValidationCode.packChoiceAnswerRange: _Case(
    _tp,
    (d) => task(d, choiceTask)['answer'] = 9,
  ),
  ValidationCode.packAcceptInvalid: _Case(
    _tp,
    (d) => task(d, recallTask)['accept'] = 'final',
  ),
  ValidationCode.packAnswerNotAccepted: _Case(
    _tp,
    (d) => task(d, recallTask)['accept'] = ['другое'],
  ),
  ValidationCode.packOrderingSize: _Case(
    _tp,
    (d) => task(d, orderingTask)['items'] = ['единственный шаг'],
  ),
  ValidationCode.packOrderingDup: _Case(
    _tp,
    (d) => task(d, orderingTask)['items'] = ['Шаг', 'шаг', 'Третий'],
  ),
  ValidationCode.packCueRange: _Case(
    _tp,
    (d) =>
        (list(task(d, verbalTask), 'cues').first! as Json)['atSec'] = [25, 15],
  ),
  ValidationCode.packCueOrder: _Case(_tp, (d) {
    final cues = list(task(d, verbalTask), 'cues');
    cues.add({
      'atSec': [20, 30],
      'text': 'Второе правило.',
    });
  }),
  ValidationCode.packCueLate: _Case(
    _tp,
    (d) =>
        (list(task(d, verbalTask), 'cues').first! as Json)['atSec'] = [15, 55],
  ),
  ValidationCode.packSpatialBounds: _Case(
    _tp,
    (d) => task(d, spatialTask)['answer'] = {'row': 9, 'col': 0},
  ),
  ValidationCode.packSpatialOverlap: _Case(_tp, (d) {
    final objects = list(task(d, spatialTask), 'objects');
    (objects[1]! as Json)
      ..['row'] = (objects[0]! as Json)['row']
      ..['col'] = (objects[0]! as Json)['col'];
  }),
  ValidationCode.packStreamTargets: _Case(
    _tp,
    (d) => task(d, streamTask)['targets'] = ['ФИОЛЕТОВЫЙ'],
  ),
  ValidationCode.packParamRange: _Case(
    _tp,
    (d) => task(d, delayedTask)['showSec'] = 1,
  ),

  // --- 6.3 Пак упражнений ---
  ValidationCode.exBadName: _Case(
    _ep,
    (d) => exercise(d, 0)['name'] = {'en': 'Plank'},
  ),
  ValidationCode.exDupName: _Case(
    _ep,
    (d) => exercise(d, 1)['name'] = copy(exercise(d, 0))['name'],
  ),
  ValidationCode.exNoMuscles: _Case(
    _ep,
    (d) => exercise(d, 0)['muscleGroups'] = <Object?>[],
  ),
  ValidationCode.exBadTag: _Case(
    _ep,
    (d) => exercise(d, 0)['muscleGroups'] = ['Core'],
  ),
  ValidationCode.exUnknownTag: _Case(
    _ep,
    (d) => exercise(d, 0)['muscleGroups'] = ['core', 'neck'],
  ),
  ValidationCode.exBadLocation: _Case(
    _ep,
    (d) => exercise(d, 0)['locations'] = ['HOME', 'HOME'],
  ),
  ValidationCode.exBadLegacyId: _Case(
    _ep,
    (d) => exercise(d, 0)['legacyId'] = 0,
  ),
  ValidationCode.exDupLegacyId: _Case(_ep, (d) {
    exercise(d, 0)['legacyId'] = 5;
    exercise(d, 1)['legacyId'] = 5;
  }),

  // --- 6.4 События и профиль ---
  ValidationCode.evtBadUuid: _Case(
    _ev,
    (d) => record(d, 'sessions', 0)['id'] = 'не-uuid',
  ),
  ValidationCode.evtDupId: _Case(
    _ev,
    (d) => list(d, 'sessions').add(copy(record(d, 'sessions', 0))),
  ),
  ValidationCode.evtOrphan: _Case(
    _ev,
    (d) => record(d, 'rounds', 0)['sessionId'] = _otherUuid,
  ),
  ValidationCode.evtBadTime: _Case(
    _ev,
    (d) => record(d, 'sessions', 0)['startedAt'] = 5000000000000,
  ),
  ValidationCode.evtTimeOrder: _Case(
    _ev,
    (d) => record(d, 'sessions', 0)['endedAt'] = 1,
  ),
  ValidationCode.evtBadEnum: _Case(
    _ev,
    (d) => record(d, 'sessions', 0)['location'] = 'MOON',
  ),
  ValidationCode.evtRange: _Case(_ev, (d) => record(d, 'rounds', 0)['rpe'] = 7),
  ValidationCode.evtVerifiableMismatch: _Case(
    _ev,
    (d) => record(d, 'attempts', 0)['isCorrect'] = null,
  ),
  ValidationCode.evtStatusMismatch: _Case(
    _ev,
    (d) => record(d, 'attempts', 0)['status'] = 'timeout',
  ),
  ValidationCode.evtBadHash: _Case(
    _ev,
    (d) => record(d, 'attempts', 0)['payloadHash'] = 'ABC',
  ),
  ValidationCode.evtLatencyMismatch: _Case(
    _ev,
    (d) => record(d, 'attempts', 0)['latencyMs'] = 1,
  ),
  ValidationCode.evtEncodedRound: _Case(
    _ev,
    (d) => record(d, 'attempts', 0)['encodedRoundIndex'] = 0,
  ),
  ValidationCode.profBadCategory: _Case(
    _pf,
    (d) => d['disabledCategories'] = ['Плохой путь'],
  ),
  ValidationCode.profTargetRange: _Case(
    _pf,
    (d) => (list(d, 'exerciseTargets').first! as Json)['min'] = 9,
  ),
  ValidationCode.profUnknownExercise: _Case(
    _pf,
    (_) {},
    context: _ctx(_pf, knownExercises: {'ex.other'}),
  ),
  ValidationCode.profEmptyPool: _Case(
    _pf,
    (_) {},
    context: _ctx(_pf, domains: {'it.java', 'it.net'}),
  ),
};

void main() {
  group('полнота правил SCHEMAS §6', () {
    test(
      'в таблице случаев есть запись для КАЖДОГО значения ValidationCode',
      () {
        final missing = [
          for (final code in ValidationCode.values)
            if (!_cases.containsKey(code)) code.code,
        ];
        expect(missing, isEmpty, reason: 'нет негативного теста для: $missing');
        expect(_cases.length, ValidationCode.values.length);
      },
    );

    for (final code in ValidationCode.values) {
      test('${code.rule}. ${code.code}', () {
        final result = _cases[code]!.run();
        expect(
          result.has(code),
          isTrue,
          reason:
              'код ${code.code} не сработал; получено: '
              '${result.issues.map((i) => i.code.code).toList()}',
        );
        final issue = result.issues.firstWhere((i) => i.code == code);
        expect(issue.severity, code.severity);
        expect(issue.message, isNotEmpty);
        expect(issue.path, isNotEmpty);
      });
    }

    test('образцы без порчи проходят без замечаний', () {
      for (final kind in DocumentKind.values) {
        final result = check(loadSample(kind), kind);
        expect(result.issues, isEmpty, reason: '$kind: ${result.issues}');
        expect(result.isDocumentRejected, isFalse);
      }
    });
  });

  group('ValidationCode совпадает с docs/SCHEMAS.md', () {
    test('номера, коды и уровни', () {
      final spec = File('../../docs/SCHEMAS.md').readAsStringSync();
      final row = RegExp(
        r'^\|\s*(\d+)\s*\|\s*`([A-Z_]+)`\s*\|\s*(error|warning)\s*\|',
        multiLine: true,
      );
      final fromSpec = [
        for (final m in row.allMatches(spec)) (int.parse(m[1]!), m[2]!, m[3]!),
      ];
      final fromEnum = [
        for (final c in ValidationCode.values)
          (c.rule, c.code, c.severity.name),
      ];
      expect(fromSpec, hasLength(75));
      expect(fromEnum, fromSpec);
    });
  });
}
