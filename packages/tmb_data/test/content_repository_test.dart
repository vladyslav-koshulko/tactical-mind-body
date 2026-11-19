import 'package:test/test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'support/fixtures.dart';

Map<String, Object?> _taskPackJson(String id, {String source = 'imported'}) => {
  'schemaVersion': 1,
  'kind': 'task_pack',
  'pack': id,
  'title': 'Мой пак',
  'locale': 'ru',
  'license': 'CC-BY-4.0',
  'packSource': source,
  'status': 'draft',
  'levels': ['recruit', 'fighter'],
  'categories': [
    {'domain': 'it.java', 'title': 'Java', 'description': 'Основы языка.'},
    {'domain': 'cog.speech', 'title': 'Речь'},
  ],
  'items': [
    {
      'id': 'demo.java.001',
      'domain': 'it.java',
      'archetype': 'recall',
      'verifiable': true,
      'timeSec': 30,
      'difficulty': 0.2,
      'prompt': 'Каким ключевым словом объявляется константа в Java?',
      'answer': 'final',
      'accept': ['final'],
      'reveal': 'final запрещает повторное присваивание.',
    },
    {
      'id': 'demo.java.002',
      'domain': 'it.java',
      'archetype': 'choice',
      'verifiable': true,
      'timeSec': 30,
      'difficulty': 0.3,
      'prompt': 'Какой из типов Java не является примитивным?',
      'options': ['int', 'boolean', 'String', 'double'],
      'answer': 2,
    },
  ],
};

Map<String, Object?> _exercisePackJson(String id, {String source = 'user'}) => {
  'schemaVersion': 1,
  'kind': 'exercise_pack',
  'pack': id,
  'title': 'Свои упражнения',
  'defaultLocale': 'ru',
  'license': 'CC-BY-4.0',
  'packSource': source,
  'status': 'draft',
  'exercises': [
    {
      'id': 'ex.plank',
      'name': {'ru': 'Планка', 'uk': 'Планка', 'en': 'Plank'},
      'unit': 'seconds',
      'muscleGroups': ['core', 'shoulders'],
      'inventory': <String>[],
      'locations': ['HOME', 'GYM', 'OUTDOOR'],
      'legacyId': null,
    },
    {
      'id': 'ex.pullup',
      'name': {'ru': 'Подтягивания'},
      'unit': 'reps',
      'muscleGroups': ['back', 'biceps'],
      'inventory': ['pullup_bar'],
      'locations': ['GYM', 'OUTDOOR'],
      'legacyId': null,
    },
  ],
};

void main() {
  late TmbDatabase db;
  late ContentRepository repo;

  setUp(() {
    db = openMemoryDb();
    repo = DriftContentRepository(db);
  });
  tearDown(() => db.close());

  test('пустая БД: паков нет', () async {
    expect(await repo.listPacks(), isEmpty);
    expect(await repo.taskPacks(), isEmpty);
    expect(await repo.exercisePacks(), isEmpty);
    expect(await repo.taskPack('nope'), isNull);
    expect(await repo.exercisePack('nope'), isNull);
  });

  test('пак задач: round-trip без потери полей', () async {
    final json = _taskPackJson('my.java');
    await repo.installTaskPack(TaskPack.fromJson(json), installedAt: 1000);

    final back = (await repo.taskPack('my.java'))!;
    expect(back.toJson(), json);
    expect(back.packSource, PackSource.imported);
    expect(back.items.map((t) => t.archetype), [
      TaskArchetype.recall,
      TaskArchetype.choice,
    ]);
  });

  test('пак упражнений: round-trip без потери полей', () async {
    final json = _exercisePackJson('my.ex');
    await repo.installExercisePack(
      ExercisePack.fromJson(json),
      installedAt: 2000,
    );
    expect((await repo.exercisePack('my.ex'))!.toJson(), json);
  });

  test('пользовательский пак проходит валидатор до и после хранения', () async {
    final json = _taskPackJson('my.java', source: 'user');
    const ctx = ValidationContext(expectedKind: DocumentKind.taskPack);
    expect(validate(jsonBytes(json), ctx).errors, isEmpty);
    await repo.installTaskPack(TaskPack.fromJson(json), installedAt: 1);
    final stored = (await repo.taskPack('my.java'))!;
    final r = validate(jsonBytes(stored.toJson()), ctx);
    expect(r.errors, isEmpty);
    expect(r.excluded, isEmpty);
  });

  test(
    'метаданные: вид, источник, число элементов, порядок установки',
    () async {
      await repo.installExercisePack(
        ExercisePack.fromJson(_exercisePackJson('b.ex')),
        installedAt: 3000,
      );
      await repo.installTaskPack(
        TaskPack.fromJson(_taskPackJson('a.java')),
        installedAt: 1000,
      );
      await repo.installTaskPack(
        TaskPack.fromJson(_taskPackJson('c.java', source: 'user')),
        installedAt: 2000,
      );

      final list = await repo.listPacks();
      expect(list.map((p) => p.packId), ['a.java', 'c.java', 'b.ex']);
      expect(list[0].kind, PackKind.taskPack);
      expect(list[0].packSource, PackSource.imported);
      expect(list[0].itemCount, 2);
      expect(list[0].title, 'Мой пак');
      expect(list[0].locale, 'ru');
      expect(list[1].packSource, PackSource.user);
      expect(list[2].kind, PackKind.exercisePack);
      expect(list[2].installedAt, 3000);

      expect((await repo.taskPacks()).map((p) => p.pack), ['a.java', 'c.java']);
      expect((await repo.exercisePacks()).map((p) => p.pack), ['b.ex']);
    },
  );

  test('один id у пака задач и упражнений не конфликтует', () async {
    await repo.installTaskPack(
      TaskPack.fromJson(_taskPackJson('same')),
      installedAt: 1,
    );
    await repo.installExercisePack(
      ExercisePack.fromJson(_exercisePackJson('same')),
      installedAt: 2,
    );
    expect(await repo.listPacks(), hasLength(2));
    expect(await repo.deletePack(PackKind.exercisePack, 'same'), isTrue);
    expect(await repo.taskPack('same'), isNotNull);
  });

  test('повторная установка: ошибка, либо замена по явному запросу', () async {
    await repo.installTaskPack(
      TaskPack.fromJson(_taskPackJson('my.java')),
      installedAt: 1,
    );
    await expectLater(
      repo.installTaskPack(
        TaskPack.fromJson(_taskPackJson('my.java')),
        installedAt: 2,
      ),
      throwsA(isA<PackAlreadyInstalledException>()),
    );
    expect((await repo.listPacks()).single.installedAt, 1);

    final changed = _taskPackJson('my.java')..['title'] = 'Новое имя';
    await repo.installTaskPack(
      TaskPack.fromJson(changed),
      installedAt: 3,
      replace: true,
    );
    final only = (await repo.listPacks()).single;
    expect(only.title, 'Новое имя');
    expect(only.installedAt, 3);
    expect((await repo.taskPack('my.java'))!.title, 'Новое имя');
  });

  test('встроенный пак в БД не кладётся', () async {
    expect(
      () => repo.installTaskPack(
        TaskPack.fromJson(_taskPackJson('x.y', source: 'builtin')),
        installedAt: 1,
      ),
      throwsArgumentError,
    );
    expect(
      () => repo.installExercisePack(
        ExercisePack.fromJson(_exercisePackJson('x.y', source: 'builtin')),
        installedAt: 1,
      ),
      throwsArgumentError,
    );
    expect(await repo.listPacks(), isEmpty);
  });

  test('deletePack откатывает пак целиком и по одному', () async {
    await repo.installTaskPack(
      TaskPack.fromJson(_taskPackJson('a.java')),
      installedAt: 1,
    );
    await repo.installTaskPack(
      TaskPack.fromJson(_taskPackJson('b.java')),
      installedAt: 2,
    );
    expect(await repo.deletePack(PackKind.taskPack, 'a.java'), isTrue);
    expect(await repo.deletePack(PackKind.taskPack, 'a.java'), isFalse);
    expect(await repo.taskPack('a.java'), isNull);
    expect(await repo.taskPack('b.java'), isNotNull);
  });

  test('watchPacks обновляется при установке и удалении', () async {
    final seen = <int>[];
    final sub = repo.watchPacks().listen((l) => seen.add(l.length));
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await repo.installTaskPack(
      TaskPack.fromJson(_taskPackJson('a.java')),
      installedAt: 1,
    );
    await pumpEventQueue();
    await repo.deletePack(PackKind.taskPack, 'a.java');
    await pumpEventQueue();
    expect(seen.first, 0);
    expect(seen, contains(1));
    expect(seen.last, 0);
  });
}
