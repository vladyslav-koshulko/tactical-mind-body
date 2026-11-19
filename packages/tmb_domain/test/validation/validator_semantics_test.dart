import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tmb_domain/src/validation/issues.dart';
import 'package:tmb_domain/src/validation/pack_common.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'fixtures.dart';

const _tp = DocumentKind.taskPack;

Uint8List _utf8(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  group('реальные паки из assets/content/ru', () {
    const base = '../../assets/content/ru';

    test('пак задач — без единого замечания, как встроенный', () {
      final result = validate(
        File('$base/uncertainty.pack.json').readAsBytesSync(),
        const ValidationContext(
          expectedKind: _tp,
          directoryLocale: 'ru',
          assignedPackSource: PackSource.builtin,
        ),
      );
      expect(result.issues, isEmpty);
      expect(result.isDocumentRejected, isFalse);
      expect(result.acceptedTasks, hasLength(17));
      expect(result.taskPack, isNotNull);
    });

    test('пак упражнений — без единого замечания, как встроенный', () {
      final result = validate(
        File('$base/exercises.base.pack.json').readAsBytesSync(),
        const ValidationContext(
          expectedKind: DocumentKind.exercisePack,
          assignedPackSource: PackSource.builtin,
        ),
      );
      expect(result.issues, isEmpty);
      expect(result.acceptedExercises, hasLength(15));
      expect(result.exercisePack, isNotNull);
    });
  });

  group('семантика: элемент или документ', () {
    test('ошибка задачи исключает задачу, остальные приняты', () {
      final doc = loadSample(_tp);
      task(doc, recallTask)['timeSec'] = 4;
      final r = check(doc, _tp);
      expect(r.isDocumentRejected, isFalse);
      expect(r.acceptedTasks, hasLength(7));
      expect(r.taskPack!.items, hasLength(7));
      expect(r.excluded, hasLength(1));
      expect(r.excluded.single.path, 'items[0]');
      expect(r.excluded.single.id, 'demo.java.001');
      expect(r.excluded.single.codes, [ValidationCode.packBadTime]);
      expect(r.errorCount, 1);
    });

    test('ошибка документа отклоняет файл: принятых нет', () {
      final doc = loadSample(_tp)..remove('license');
      final r = check(doc, _tp);
      expect(r.isDocumentRejected, isTrue);
      expect(r.has(ValidationCode.packMissingField), isTrue);
      expect(r.acceptedTasks, isEmpty);
      expect(r.taskPack, isNull);
    });

    test('неизвестное поле — предупреждение, остальное принято', () {
      final doc = loadSample(_tp);
      doc['extra'] = 1;
      task(doc, choiceTask)['hint'] = 'x';
      final r = check(doc, _tp);
      expect(r.isDocumentRejected, isFalse);
      expect(r.errorCount, 0);
      expect(r.warningCount, 2);
      expect(r.acceptedTasks, hasLength(8));
      expect(
        r.issues.map((i) => i.path),
        containsAll(['extra', 'items[1].hint']),
      );
      expect(r.excluded, isEmpty);
    });

    test('verbal с reveal: предупреждение, поле отброшено', () {
      final doc = loadSample(_tp);
      task(doc, verbalTask)['reveal'] = 'Как надо';
      final r = check(doc, _tp);
      expect(r.has(ValidationCode.packFieldNotAllowed), isTrue);
      expect(r.errorCount, 0);
      expect(r.acceptedTasks, hasLength(8));
    });

    test('дубликат id и prompt: остаётся первая задача', () {
      final doc = loadSample(_tp);
      task(doc, choiceTask)['id'] = task(doc, recallTask)['id'];
      task(doc, orderingTask)['prompt'] = task(doc, recallTask)['prompt'];
      final r = check(doc, _tp);
      expect(r.acceptedTasks.first.id, 'demo.java.001');
      expect(r.excluded.map((e) => e.path), ['items[1]', 'items[2]']);
      expect(r.has(ValidationCode.packDupId), isTrue);
      expect(r.has(ValidationCode.packDupPrompt), isTrue);
    });

    test('payloadHash принятых задач совпадает с вектором SCHEMAS §3.5', () {
      final r = check(loadSample(_tp), _tp);
      expect(
        r.payloadHashes['demo.java.002'],
        '0301b322e4db5a224c9262ad495394182698d55b6a82ac005e992529b93a4833',
      );
    });

    test('assignedPackSource подменяет заявленный файлом источник', () {
      final r = check(
        loadSample(_tp),
        _tp,
        context: const ValidationContext(
          expectedKind: _tp,
          assignedPackSource: PackSource.imported,
        ),
      );
      expect(r.has(ValidationCode.packSourceOverridden), isTrue);
      expect(r.isDocumentRejected, isFalse);
      expect(r.taskPack!.packSource, PackSource.imported);
    });

    test('исключённая запись события делает зависимые сиротами', () {
      final doc = loadSample(DocumentKind.eventsExport);
      record(doc, 'sessions', 0)['id'] = 'не-uuid';
      final r = check(doc, DocumentKind.eventsExport);
      expect(r.eventsExport!.sessions, isEmpty);
      expect(r.eventsExport!.rounds, isEmpty);
      expect(r.has(ValidationCode.evtOrphan), isTrue);
    });

    test('профиль с ошибкой отклоняется целиком', () {
      final doc = loadSample(DocumentKind.profile);
      doc['disabledCategories'] = ['Плохо'];
      final r = check(doc, DocumentKind.profile);
      expect(r.isDocumentRejected, isTrue);
      expect(r.profile, isNull);
    });

    test('корневой раздел в disabledCategories допустим («it»)', () {
      final r = check(loadSample(DocumentKind.profile), DocumentKind.profile);
      expect(r.isClean, isTrue);
      expect(r.profile!.disabledCategories, contains('it'));
    });
  });

  group('до разбора JSON', () {
    test(
      'неизвестный schemaVersion — отказ целиком, без чтения остального',
      () {
        final doc = loadSample(_tp)..['schemaVersion'] = 7;
        task(doc, recallTask)['timeSec'] = 4;
        final r = check(doc, _tp);
        expect(r.isDocumentRejected, isTrue);
        expect(r.issues.map((i) => i.code), [
          ValidationCode.packSchemaUnsupported,
        ]);
        expect(r.issues.single.message, contains('обновите приложение'));
      },
    );

    test('версия ниже минимальной без миграции — PACK_SCHEMA_UNSUPPORTED', () {
      final r = check(
        loadSample(_tp),
        _tp,
        context: const ValidationContext(
          expectedKind: _tp,
          supportedVersions: SupportedVersions(min: 2, max: 3),
        ),
      );
      expect(r.has(ValidationCode.packSchemaUnsupported), isTrue);
    });

    test(
      'слишком большой файл отвергается до разбора (мусор — не NOT_JSON)',
      () {
        final r = validate(
          _utf8('я' * 600000),
          const ValidationContext(expectedKind: _tp),
        );
        expect(r.issues.single.code, ValidationCode.packTooLarge);
        expect(r.isDocumentRejected, isTrue);
      },
    );

    test('лимит размера берётся из контекста', () {
      final r = validate(
        _utf8('{"a":1}'),
        const ValidationContext(
          expectedKind: _tp,
          limits: ImportLimits(maxBytes: 3),
        ),
      );
      expect(r.issues.single.code, ValidationCode.packTooLarge);
    });

    test('слишком глубокая вложенность — до разбора, без падения', () {
      final r = validate(
        _utf8('[' * 200000),
        const ValidationContext(expectedKind: _tp),
      );
      expect(r.issues.single.code, ValidationCode.packTooDeep);
    });

    test('скобки внутри строк не считаются вложенностью', () {
      final doc = loadSample(_tp);
      task(doc, recallTask)['reveal'] = '[[[[[[[[[[[[[[[[ {{{{{{{{{{ \\" [[[[[';
      final r = check(doc, _tp);
      expect(r.has(ValidationCode.packTooDeep), isFalse);
      expect(r.errorCount, 0);
    });

    test('UTF-8 BOM отбрасывается', () {
      final bytes = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...encode(loadSample(_tp)),
      ]);
      final r = validate(bytes, const ValidationContext(expectedKind: _tp));
      expect(r.issues, isEmpty);
    });

    test('не UTF-8 и не объект — PACK_NOT_JSON', () {
      for (final bytes in [
        Uint8List.fromList([0xFF, 0xFE, 0x7B, 0x7D]),
        _utf8('[1, 2]'),
        _utf8('"строка"'),
        _utf8(''),
      ]) {
        final r = validate(bytes, const ValidationContext(expectedKind: _tp));
        expect(r.issues.single.code, ValidationCode.packNotJson);
      }
    });

    test('пак другого вида — PACK_BAD_KIND; нет kind — PACK_MISSING_FIELD', () {
      final r = check(loadSample(_tp), DocumentKind.exercisePack);
      expect(r.has(ValidationCode.packBadKind), isTrue);
      final doc = loadSample(_tp)..remove('kind');
      expect(check(doc, _tp).has(ValidationCode.packMissingField), isTrue);
    });
  });

  group('строки и числа', () {
    String promptIssueFor(String prompt) {
      final doc = loadSample(_tp);
      task(doc, recallTask)['prompt'] = prompt;
      final r = check(doc, _tp);
      return r.issues.isEmpty ? '' : r.issues.first.code.code;
    }

    test('разметка — по регулярке с закрывающей «>», а не по любому «<»', () {
      expect(promptIssueFor('Если a < b и x<y, то что больше?'), '');
      expect(promptIssueFor('Сравните 3 < 5 > 2'), '');
      expect(promptIssueFor('Вставьте <script>'), 'PACK_MARKUP');
      expect(promptIssueFor('Текст <!-- скрыто'), 'PACK_MARKUP');
      expect(promptIssueFor('Пустой <br/> тег'), 'PACK_MARKUP');
      expect(promptIssueFor('Ссылка <a href="x">тут</a>'), 'PACK_MARKUP');
    });

    test('перевод строки: можно в prompt, нельзя в вариантах', () {
      expect(promptIssueFor('Строка 1\nСтрока 2'), '');
      final doc = loadSample(_tp);
      (task(doc, choiceTask)['options']! as List<Object?>)[0] = 'а\nб';
      expect(check(doc, _tp).has(ValidationCode.packBadChars), isTrue);
    });

    test('bidi-управление и комбинируемые знаки — PACK_BAD_CHARS', () {
      expect(
        promptIssueFor('текст${String.fromCharCode(0x202E)}текст'),
        'PACK_BAD_CHARS',
      );
      expect(
        promptIssueFor('е${String.fromCharCode(0x0301)}'),
        'PACK_BAD_CHARS',
      );
      expect(
        promptIssueFor('a${String.fromCharCode(0x2028)}b'),
        'PACK_BAD_CHARS',
      );
      expect(promptIssueFor('a\u0085b'), 'PACK_BAD_CHARS');
    });

    test('украинские буквы и ё проходят', () {
      expect(promptIssueFor('Чи є їжак у ґанку? Ё-моё.'), '');
    });

    test('длина считается в кодовых точках, а не в UTF-16', () {
      expect(promptIssueFor('😀' * 1000), '');
      expect(promptIssueFor('😀' * 1001), 'PACK_STRING_TOO_LONG');
    });

    test('числа: 6 знаков можно, 7 нельзя; 1e15 нельзя', () {
      Json withDifficulty(Object v) {
        final d = loadSample(_tp);
        task(d, recallTask)['difficulty'] = v;
        return d;
      }

      expect(check(withDifficulty(0.123456), _tp).errorCount, 0);
      expect(
        check(
          withDifficulty(0.1234567),
          _tp,
        ).has(ValidationCode.packNumberRange),
        isTrue,
      );
      final doc = loadSample(_tp);
      task(doc, numericRecallTask)['answer'] = 1000000000000000;
      expect(check(doc, _tp).has(ValidationCode.packNumberRange), isTrue);
    });

    test('null в поле, где он не разрешён, — PACK_BAD_TYPE', () {
      final doc = loadSample(_tp);
      task(doc, recallTask)['reveal'] = null;
      expect(check(doc, _tp).has(ValidationCode.packBadType), isTrue);
    });
  });

  group('правила архетипов', () {
    test('accept-диапазон: граница включительно, min > max — ошибка формы', () {
      final doc = loadSample(_tp);
      task(doc, numericRecallTask)['accept'] = {'min': 86400, 'max': 90000};
      expect(check(doc, _tp).errorCount, 0);
      task(doc, numericRecallTask)['accept'] = {'min': 90000, 'max': 80000};
      expect(check(doc, _tp).has(ValidationCode.packAcceptInvalid), isTrue);
    });

    test('accept-массив чисел при строковом answer — ошибка формы', () {
      final doc = loadSample(_tp);
      task(doc, recallTask)['accept'] = [1, 2];
      expect(check(doc, _tp).has(ValidationCode.packAcceptInvalid), isTrue);
    });

    test('цели stream должны встречаться в stimuli', () {
      final doc = loadSample(_tp);
      task(doc, streamTask)['targets'] = ['КРАСНЫЙ', 'ФИОЛЕТОВЫЙ'];
      expect(check(doc, _tp).has(ValidationCode.packStreamTargets), isTrue);
    });

    test(
      'verbal без cues допустим; cues вплотную (b < a следующего) — тоже',
      () {
        final doc = loadSample(_tp);
        task(doc, verbalTask).remove('cues');
        expect(check(doc, _tp).issues, isEmpty);
        task(doc, verbalTask)['cues'] = [
          {
            'atSec': [5, 10],
            'text': 'Первое.',
          },
          {
            'atSec': [11, 20],
            'text': 'Второе.',
          },
        ];
        expect(check(doc, _tp).issues, isEmpty);
      },
    );
  });

  group('события и профиль', () {
    test('известные ids из БД снимают EVT_ORPHAN', () {
      final doc = loadSample(DocumentKind.eventsExport);
      (doc['sessions']! as List<Object?>).clear();
      final r = check(
        doc,
        DocumentKind.eventsExport,
        context: const ValidationContext(
          expectedKind: DocumentKind.eventsExport,
          knownSessionIds: {'62ed4258-a855-4484-9598-d5cc938f60f0'},
          knownRoundIds: {'5004e0ab-d425-48a0-bf87-766cf1c3cc8b'},
        ),
      );
      expect(r.issues, isEmpty);
    });

    test('PROF_EMPTY_POOL: в пуле остаётся задача — ошибки нет', () {
      final r = check(
        loadSample(DocumentKind.profile),
        DocumentKind.profile,
        context: const ValidationContext(
          expectedKind: DocumentKind.profile,
          installedTaskDomains: {'it.java', 'cog.memory'},
        ),
      );
      expect(r.has(ValidationCode.profEmptyPool), isFalse);
    });
  });

  group('FormatException из fromJson → замечание', () {
    test('buildModel не роняет вызов', () {
      final local = Issues();
      final model = buildModel<TaskCategory>(
        () => TaskCategory.fromJson(<String, Object?>{'domain': 1}),
        'categories[0]',
        local,
      );
      expect(model, isNull);
      expect(local.list.single.code, ValidationCode.packBadType);
      expect(local.list.single.path, 'categories[0]');
    });
  });
}
