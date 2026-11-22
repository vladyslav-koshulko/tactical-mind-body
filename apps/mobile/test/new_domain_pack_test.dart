// Критерий «Готово, когда» v0.1 (docs/ROADMAP.md): новый когнитивный домен
// добавляется файлом пака, а не правкой кода. Доказательство — тестовый пак
// латыни (test/fixtures/packs/ru/latin.test.pack.json): в коде приложения и
// пакетов про латынь нет ни строки, но пак проходит весь путь контента.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/features/settings/category_catalog.dart';
import 'package:tmb_mobile/features/settings/settings_providers.dart';

import 'helpers.dart';

const _fixturePath = 'test/fixtures/packs/ru/latin.test.pack.json';
const _builtinDir = '../../assets/content/ru';
const _latinPackId = 'lang.latin.test.ru';

/// Бандл из памяти: ключ → байты, манифест собирается из ключей.
class _MemoryBundle extends CachingAssetBundle {
  _MemoryBundle(Map<String, List<int>> files) : _files = files;

  final Map<String, List<int>> _files;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        for (final k in _files.keys)
          k: [
            {'asset': k},
          ],
      })!;
    }
    final bytes = _files[key];
    if (bytes == null) throw ArgumentError('нет ассета $key');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

/// Боевые паки с диска — ровно то, что лежит в бандле приложения.
Map<String, List<int>> _builtinFiles() => {
  for (final f in Directory(_builtinDir).listSync().whereType<File>())
    if (f.path.endsWith('.pack.json'))
      '${builtinContentRoot}ru/${f.uri.pathSegments.last}': f.readAsBytesSync(),
};

/// Бандл, в который тестовый пак положен рядом с боевыми — как если бы
/// разработчик просто добавил файл в `assets/content/ru/`.
_MemoryBundle _bundleWithLatin() => _MemoryBundle({
  ..._builtinFiles(),
  '${builtinContentRoot}ru/latin.test.pack.json': File(_fixturePath)
      .readAsBytesSync(),
});

_MemoryBundle _bundleWithoutLatin() => _MemoryBundle(_builtinFiles());

ProviderContainer _container(AssetBundle bundle) {
  final c = ProviderContainer(
    overrides: [
      ...testOverrides(),
      assetBundleProvider.overrideWithValue(bundle),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Iterable<PlannedTask> _tasksOf(SessionPlan plan) => [
  for (final b in plan.blocks)
    if (b is PlannedCognitiveBlock) ...b.tasks,
];

SessionPlan _plan(SessionPlanner planner, int seed, {int windows = 3}) =>
    planner.plan(
      template: SessionTemplate.cognitiveOnly(
        windows: windows,
        cognitiveSec: 60,
      ),
      seed: seed,
      location: Location.home,
      difficulty: DifficultyLevel.fighter,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List fixtureBytes;
  setUpAll(() => fixtureBytes = File(_fixturePath).readAsBytesSync());

  group('валидатор', () {
    late ValidationResult result;
    setUp(() {
      result = validate(
        fixtureBytes,
        const ValidationContext(
          expectedKind: DocumentKind.taskPack,
          directoryLocale: 'ru',
          assignedPackSource: PackSource.builtin,
        ),
      );
    });

    test(
      'тестовый пак чист: ни ошибок, ни предупреждений (строгий режим CI)',
      () {
        expect(result.isDocumentRejected, isFalse);
        expect(result.issues, isEmpty);
        expect(result.isClean, isTrue);
        expect(result.taskPack, isNotNull);
        expect(result.acceptedTasks, hasLength(9));
      },
    );

    test('только архетипы recall и choice, домены — латынь', () {
      final tasks = result.acceptedTasks;
      expect(
        {for (final t in tasks) t.archetype},
        {TaskArchetype.recall, TaskArchetype.choice},
      );
      expect(
        {for (final t in tasks) t.domain},
        {'lang.latin.vocab', 'lang.latin.grammar'},
      );
    });

    test('неверный домен (нет в categories) валидатор отклоняет', () {
      // Контрольная проверка: валидатор действительно что-то проверяет.
      final json =
          jsonDecode(utf8.decode(fixtureBytes)) as Map<String, Object?>;
      final items = (json['items']! as List).cast<Map<String, Object?>>();
      items.first['domain'] = 'lang.latin.unknown';
      final broken = validate(
        Uint8List.fromList(utf8.encode(jsonEncode(json))),
        const ValidationContext(
          expectedKind: DocumentKind.taskPack,
          directoryLocale: 'ru',
          assignedPackSource: PackSource.builtin,
        ),
      );
      expect(broken.errorCount, greaterThan(0));
    });
  });

  group('загрузчик (тот же ContentLoader, что и для боевых паков)', () {
    test('пак подхватывается рядом с боевыми, остальные не меняются', () async {
      final without = await ContentLoader(_bundleWithoutLatin()).load();
      final with_ = await ContentLoader(_bundleWithLatin()).load();

      expect(with_.taskPacks.length, without.taskPacks.length + 1);
      expect(with_.exercisePacks.length, without.exercisePacks.length);
      expect(with_.taskCount, without.taskCount + 9);

      final latin = with_.taskPacks.singleWhere((p) => p.pack == _latinPackId);
      expect(latin.packSource, PackSource.builtin);
      expect(latin.items, hasLength(9));
      expect(latin.categories.map((c) => c.domain), [
        'lang.latin.vocab',
        'lang.latin.grammar',
      ]);
    });
  });

  group('провайдеры и каталог категорий', () {
    test('источник задач появляется без правок Dart-кода', () async {
      final c = _container(_bundleWithLatin());
      final sources = await c.read(taskSourcesProvider.future);
      final latin = sources.singleWhere((s) => s.provider.id == _latinPackId);

      expect(latin.provider, isA<PackTaskProvider>());
      expect(latin.provider.domains, {
        'lang.latin.vocab',
        'lang.latin.grammar',
      });
      expect(latin.provider.locales, {'ru'});
      expect(latin.provider.isMachineVerifiable, isTrue);
      expect(latin.packSource, PackSource.builtin);
    });

    test('без пака латыни в каталоге категорий её нет (контроль)', () async {
      final without = await _container(_bundleWithoutLatin())
          .read(categoryCatalogProvider.future);
      expect(without.allDomains, isNotEmpty);
      expect(without.allDomains.where((d) => d.startsWith('lang.')), isEmpty);
    });

    test('категории латыни появляются в каталоге', () async {
      final catalog = await _container(_bundleWithLatin())
          .read(categoryCatalogProvider.future);

      expect(catalog.allDomains.where((d) => d.startsWith('lang.')).toSet(), {
        'lang.latin.vocab',
        'lang.latin.grammar',
      });
      // Всё проверяемое машиной — раздел «проверяемые»; verbal тут нет.
      expect(
        catalog.domainsOf(CategorySection.verifiable),
        containsAll(['lang.latin.vocab', 'lang.latin.grammar']),
      );
      expect(
        catalog.domainsOf(CategorySection.unverifiable),
        isNot(contains('lang.latin.vocab')),
      );

      final lang = catalog
          .rootsOf(CategorySection.verifiable)
          .singleWhere((n) => n.segment == 'lang');
      final latin = lang.children.singleWhere((n) => n.segment == 'latin');
      expect(latin.path, 'lang.latin');
      expect(latin.totalCount, 9);
      final vocab = latin.children.singleWhere((n) => n.segment == 'vocab');
      final grammar = latin.children.singleWhere((n) => n.segment == 'grammar');
      expect(vocab.title, 'Латынь: лексика');
      expect(vocab.ownCount, 5);
      expect(grammar.title, 'Латынь: грамматика');
      expect(grammar.ownCount, 4);
    });

    test('отключение родителя lang.latin выключает обе категории', () async {
      final catalog = await _container(_bundleWithLatin())
          .read(categoryCatalogProvider.future);
      const disabled = ['lang.latin'];
      expect(
        stateOf(['lang.latin.vocab', 'lang.latin.grammar'], disabled),
        CategoryState.off,
      );
      expect(
        stateOf(catalog.domainsOf(CategorySection.verifiable), disabled),
        CategoryState.mixed,
      );
    });
  });

  group('генерация и проверка (инвариант 4)', () {
    late TaskPack pack;
    setUp(() async {
      final content = await ContentLoader(_bundleWithLatin()).load();
      pack = content.taskPacks.singleWhere((p) => p.pack == _latinPackId);
    });

    test('один сид → одна и та же задача, независимо от экземпляра', () {
      // Два независимых экземпляра провайдера и независимо разобранный пак.
      final other = TaskPack.fromJson(
        jsonDecode(utf8.decode(fixtureBytes)) as Map<String, Object?>,
      );
      final a = PackTaskProvider(pack);
      final b = PackTaskProvider(other);
      for (final s in [0, 1, 7, 12345, 987654321, maxTaskSeed]) {
        final ta = a.generate(TaskSeed(s));
        expect(a.generate(TaskSeed(s)), same(ta), reason: 'seed $s повторно');
        final tb = b.generate(TaskSeed(s));
        expect(tb.id, ta.id, reason: 'seed $s');
        expect(payloadHash(tb), payloadHash(ta), reason: 'seed $s');
      }
    });

    test('сиды достают весь пул, только задачи латыни', () {
      final p = PackTaskProvider(pack);
      final seen = {for (var s = 0; s < 400; s++) p.generate(TaskSeed(s)).id};
      expect(seen, {for (final t in pack.items) t.id});
    });

    test('фильтр категорий работает по новому домену', () {
      final p = PackTaskProvider(
        pack,
        disabledCategories: ['lang.latin.grammar'],
      );
      expect(p.pool, hasLength(5));
      for (var s = 0; s < 100; s++) {
        expect(p.generate(TaskSeed(s)).domain, 'lang.latin.vocab');
      }
    });

    test('проверка ответов: recall (нормализация, допуск) и choice', () {
      final p = PackTaskProvider(pack);
      CognitiveTask byId(String id) =>
          pack.items.singleWhere((t) => t.id == id);

      final water = byId('lat.vocab.001');
      expect(
        p.verify(water, const TaskAnswer.recall('  Вода ')).isCorrect,
        isTrue,
      );
      expect(
        p.verify(water, const TaskAnswer.recall('огонь')).isCorrect,
        isFalse,
      );

      final earth = byId('lat.vocab.002');
      expect(
        p.verify(earth, const TaskAnswer.recall('суша')).isCorrect,
        isTrue,
      );

      final wolf = byId('lat.vocab.004');
      expect(p.verify(wolf, TaskAnswer.choice(0)).isCorrect, isTrue);
      expect(p.verify(wolf, TaskAnswer.choice(2)).isCorrect, isFalse);
    });
  });

  group('планировщик сессии', () {
    late List<TaskSource> builtinSources;
    late List<TaskSource> allSources;
    late TaskSource latinSource;

    setUp(() async {
      final content = await ContentLoader(_bundleWithLatin()).load();
      allSources = [
        for (final p in content.taskPacks) TaskSource.pack(PackTaskProvider(p)),
      ];
      latinSource = allSources.singleWhere(
        (s) => s.provider.id == _latinPackId,
      );
      builtinSources = [
        for (final s in allSources)
          if (s != latinSource) s,
      ];
    });

    test('задачи латыни попадают в планы и несут packId нового пака', () {
      final planner = SessionPlanner(sources: allSources);
      final latinDrawn = <PlannedTask>[];
      for (var seed = 1; seed <= 60; seed++) {
        latinDrawn.addAll(
          _tasksOf(_plan(planner, seed))
              .where((t) => t.source.provider.id == _latinPackId),
        );
      }
      expect(latinDrawn, isNotEmpty);
      for (final t in latinDrawn) {
        expect(t.task.domain, startsWith('lang.latin.'));
        expect(t.payloadHash, payloadHash(t.task));
      }
      // Контроль: без пака латыни в планах её нет.
      final plain = SessionPlanner(sources: builtinSources);
      for (var seed = 1; seed <= 60; seed++) {
        expect(
          _tasksOf(_plan(plain, seed))
              .where((t) => t.task.domain.startsWith('lang.')),
          isEmpty,
        );
      }
    });

    test('план воспроизводим: одинаковый сид → одинаковый план', () {
      PlannedTask? firstLatin;
      for (final seed in [3, 42, 2026, 987654321]) {
        final a = _plan(SessionPlanner(sources: allSources), seed, windows: 6);
        final b = _plan(SessionPlanner(sources: allSources), seed, windows: 6);
        expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()), reason: '$seed');
        firstLatin ??= _tasksOf(a)
            .where((t) => t.source.provider.id == _latinPackId)
            .firstOrNull;
      }
      expect(firstLatin, isNotNull);
    });

    test('только пак латыни: все задачи — латынь', () {
      final planner = SessionPlanner(sources: [latinSource]);
      final tasks = _tasksOf(_plan(planner, 11, windows: 8));
      expect(tasks, hasLength(8));
      expect(
        tasks.every((t) => t.task.domain.startsWith('lang.latin.')),
        isTrue,
      );
    });

    test('отключённая категория исключает свои задачи из плана', () {
      final planner = SessionPlanner(
        sources: [latinSource],
        profile: const ProfileSettings(
          disabledCategories: ['lang.latin.grammar'],
        ),
      );
      for (var seed = 1; seed <= 30; seed++) {
        for (final t in _tasksOf(_plan(planner, seed))) {
          expect(t.task.domain, 'lang.latin.vocab');
        }
      }
    });

    test('отключена вся латынь, других паков нет → пустой пул', () {
      final planner = SessionPlanner(
        sources: [latinSource],
        profile: const ProfileSettings(disabledCategories: ['lang.latin']),
      );
      expect(
        () => _plan(planner, 1),
        throwsA(
          isA<PlanningException>().having(
            (e) => e.reason,
            'reason',
            PlanningFailure.emptyTaskPool,
          ),
        ),
      );
    });
  });

  group('инвариант 3: в коде нет доменных классов', () {
    final libDirs = [
      'lib',
      ...Directory('../../packages')
          .listSync()
          .whereType<Directory>()
          .map((d) => '${d.path}/lib'),
    ].where((p) => Directory(p).existsSync()).toList();

    Iterable<File> dartFiles() => [
      for (final d in libDirs)
        ...Directory(d)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
    ];

    test('исходники lib/ собраны для обхода', () {
      expect(dartFiles(), isNotEmpty);
    });

    test('нет упоминаний латыни и классов вида JavaTask/TacmedTask', () {
      final latin = RegExp('latin|латын', caseSensitive: false);
      final domainClass = RegExp(
        r'class\s+\w*(Latin|Java|Tacmed|Kotlin|Rust|Cyber)\w*',
        caseSensitive: false,
      );
      final offenders = <String>[];
      for (final f in dartFiles()) {
        // Комментарии вправе приводить Java/латынь как примеры домена
        // (см. доки `CognitiveTaskProvider`): проверяем только код.
        final text = [
          for (final line in f.readAsLinesSync())
            if (!line.trimLeft().startsWith('//')) line,
        ].join('\n');
        if (latin.hasMatch(text) || domainClass.hasMatch(text)) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
