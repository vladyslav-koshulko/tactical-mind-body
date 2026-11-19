import 'package:test/test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'support/fixtures.dart';

void main() {
  late TmbDatabase db;
  late ProfileRepository repo;

  setUp(() {
    db = openMemoryDb();
    repo = DriftProfileRepository(db);
  });
  tearDown(() => db.close());

  Future<List<int>> counts() async => [
    (await db.select(db.profileSettingsTable).get()).length,
    (await db.select(db.disabledCategories).get()).length,
    (await db.select(db.exerciseTargets).get()).length,
  ];

  group('профиль', () {
    test('пока ничего не записано — значения по умолчанию', () async {
      final p = await repo.loadProfile();
      expect(p.toJson(), const ProfileSettings().toJson());
      expect(p.disabledCategories, isEmpty);
      expect(p.progression.enabled, isTrue);
      expect(await counts(), [0, 0, 0]);
    });

    test('saveProfile → loadProfile: round-trip всех частей', () async {
      const saved = ProfileSettings(
        disabledCategories: ['cog.uncertainty.premortem', 'it'],
        defaultTargets: DefaultTargets(
          reps: TargetRange(min: 5, max: 10),
          seconds: TargetRange(min: 20, max: 20),
        ),
        exerciseTargets: [
          ExerciseTarget(
            exerciseId: 'ex.pistol_squat',
            min: 5,
            max: 8,
            lockedByUser: true,
          ),
          ExerciseTarget(
            exerciseId: 'ex.plank',
            min: 30,
            max: 30,
            lockedByUser: false,
          ),
        ],
        progression: ProgressionSettings(enabled: false),
      );
      await repo.saveProfile(saved);

      final back = await repo.loadProfile();
      // Списки возвращаются отсортированными.
      expect(back.disabledCategories, ['cog.uncertainty.premortem', 'it']);
      expect(back.toJson(), saved.toJson());
      expect(back.isEnabled('it.java'), isFalse);
      expect(back.isEnabled('cog.uncertainty.rule_shift'), isTrue);
    });

    test('профиль из БД проходит profile_validator', () async {
      await repo.saveProfile(
        const ProfileSettings(
          disabledCategories: ['it'],
          exerciseTargets: [
            ExerciseTarget(
              exerciseId: 'ex.pushup',
              min: 10,
              max: 20,
              lockedByUser: true,
            ),
          ],
        ),
      );
      final r = validate(
        jsonBytes((await repo.loadProfile()).toJson()),
        const ValidationContext(expectedKind: DocumentKind.profile),
      );
      expect(r.errors, isEmpty);
      expect(r.issues, isEmpty);
    });

    test('повторный saveProfile заменяет, а не дополняет', () async {
      await repo.saveProfile(
        const ProfileSettings(
          disabledCategories: ['it', 'math'],
          exerciseTargets: [
            ExerciseTarget(
              exerciseId: 'ex.a_one',
              min: 1,
              max: 2,
              lockedByUser: false,
            ),
          ],
        ),
      );
      await repo.saveProfile(
        const ProfileSettings(disabledCategories: ['cog']),
      );
      final p = await repo.loadProfile();
      expect(p.disabledCategories, ['cog']);
      expect(p.exerciseTargets, isEmpty);
      expect(await counts(), [1, 1, 0]);
    });

    test(
      'setDisabledCategories: дубли схлопываются, список заменяется',
      () async {
        await repo.setDisabledCategories(['it', 'it', 'math']);
        expect((await repo.loadProfile()).disabledCategories, ['it', 'math']);
        await repo.setDisabledCategories(const []);
        expect((await repo.loadProfile()).disabledCategories, isEmpty);
      },
    );

    test('граница по сегменту: cog.unc не отключает cog.uncertainty', () async {
      await repo.setDisabledCategories(['cog.unc']);
      final p = await repo.loadProfile();
      expect(p.isEnabled('cog.uncertainty.rule_shift'), isTrue);
      expect(p.isEnabled('cog.unc.x'), isFalse);
    });

    test('точечные записи не трогают остальное', () async {
      await repo.setDisabledCategories(['it']);
      await repo.setDefaultTargets(
        const DefaultTargets(
          reps: TargetRange(min: 8, max: 12),
          seconds: TargetRange(min: 45, max: 45),
        ),
      );
      await repo.setProgressionEnabled(enabled: false);
      await repo.upsertExerciseTarget(
        const ExerciseTarget(
          exerciseId: 'ex.pushup',
          min: 10,
          max: 10,
          lockedByUser: false,
        ),
      );
      await repo.upsertExerciseTarget(
        const ExerciseTarget(
          exerciseId: 'ex.pushup',
          min: 12,
          max: 15,
          lockedByUser: true,
        ),
      );

      var p = await repo.loadProfile();
      expect(p.disabledCategories, ['it']);
      expect(p.defaultTargets.reps.min, 8);
      expect(p.defaultTargets.reps.max, 12);
      expect(p.defaultTargets.seconds.isFixed, isTrue);
      expect(p.progression.enabled, isFalse);
      expect(p.exerciseTargets, hasLength(1));
      expect(p.exerciseTargets.single.max, 15);
      expect(p.exerciseTargets.single.lockedByUser, isTrue);

      expect(await repo.removeExerciseTarget('ex.pushup'), isTrue);
      expect(await repo.removeExerciseTarget('ex.pushup'), isFalse);
      p = await repo.loadProfile();
      expect(p.exerciseTargets, isEmpty);
      // Остальное на месте.
      expect(p.disabledCategories, ['it']);
    });
  });

  group('пул не бывает пустым (PROF_EMPTY_POOL)', () {
    const domains = {'it.java', 'it.net', 'math.estimation'};

    test('отключить всё — отклонено, ничего не записано', () async {
      await repo.setDisabledCategories(['math']);
      await expectLater(
        repo.setDisabledCategories([
          'it',
          'math',
        ], installedTaskDomains: domains),
        throwsA(isA<EmptyPoolException>()),
      );
      expect((await repo.loadProfile()).disabledCategories, ['math']);

      await expectLater(
        repo.saveProfile(
          const ProfileSettings(disabledCategories: ['it', 'math']),
          installedTaskDomains: domains,
        ),
        throwsA(isA<EmptyPoolException>()),
      );
      expect((await repo.loadProfile()).disabledCategories, ['math']);
    });

    test('остаётся хотя бы одна категория — запись проходит', () async {
      await repo.setDisabledCategories(['it'], installedTaskDomains: domains);
      expect((await repo.loadProfile()).disabledCategories, ['it']);
    });

    test('набор доменов не передан — проверка не выполняется', () async {
      await repo.setDisabledCategories(['it', 'math']);
      expect((await repo.loadProfile()).disabledCategories, ['it', 'math']);
    });
  });

  group('ограничения БД', () {
    test('цель вне 1 ≤ min ≤ max ≤ 3600 не записывается', () async {
      for (final (min, max) in [(0, 5), (10, 5), (1, 3601)]) {
        await expectLater(
          repo.upsertExerciseTarget(
            ExerciseTarget(
              exerciseId: 'ex.bad',
              min: min,
              max: max,
              lockedByUser: false,
            ),
          ),
          throwsA(anything),
          reason: '$min..$max',
        );
      }
      expect(await counts(), [0, 0, 0]);
    });

    test('saveProfile с битой целью откатывается целиком', () async {
      await repo.setDisabledCategories(['it']);
      await expectLater(
        repo.saveProfile(
          const ProfileSettings(
            disabledCategories: ['math'],
            exerciseTargets: [
              ExerciseTarget(
                exerciseId: 'ex.ok_one',
                min: 1,
                max: 2,
                lockedByUser: false,
              ),
              ExerciseTarget(
                exerciseId: 'ex.bad',
                min: 9,
                max: 3,
                lockedByUser: false,
              ),
            ],
          ),
        ),
        throwsA(anything),
      );
      final p = await repo.loadProfile();
      expect(p.disabledCategories, ['it']);
      expect(p.exerciseTargets, isEmpty);
    });

    test('цели по умолчанию вне диапазона не записываются', () async {
      await expectLater(
        repo.setDefaultTargets(
          const DefaultTargets(
            reps: TargetRange(min: 20, max: 10),
            seconds: TargetRange(min: 30, max: 30),
          ),
        ),
        throwsA(anything),
      );
      expect((await repo.loadProfile()).defaultTargets.reps.min, 15);
    });
  });

  group('настройки сессии', () {
    test('по умолчанию — значения прототипа', () async {
      final p = await repo.loadSessionPreferences();
      expect(p, SessionPreferences.standard);
      expect(p.rounds, 5);
      expect(p.cognitiveSec, 180);
    });

    test('round-trip и перезапись', () async {
      const saved = SessionPreferences(
        template: SessionTemplateKind.physicalOnly,
        rounds: 8,
        cognitiveSec: 90,
        restSec: 45,
        location: Location.gym,
        difficulty: DifficultyLevel.spetsnaz,
      );
      await repo.saveSessionPreferences(saved);
      expect(await repo.loadSessionPreferences(), saved);

      await repo.saveSessionPreferences(saved.copyWith(rounds: 3));
      expect((await repo.loadSessionPreferences()).rounds, 3);
      expect(await db.select(db.sessionPreferencesTable).get(), hasLength(1));
    });

    test('rounds < 1 не записывается', () async {
      await expectLater(
        repo.saveSessionPreferences(const SessionPreferences(rounds: 0)),
        throwsA(anything),
      );
    });
  });

  group('потоки', () {
    test('watchProfile: значение сразу и после каждой записи', () async {
      final seen = <List<String>>[];
      final sub = repo.watchProfile().listen(
        (p) => seen.add(p.disabledCategories),
      );
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await repo.setDisabledCategories(['it']);
      await pumpEventQueue();
      expect(seen.first, isEmpty);
      expect(seen.last, ['it']);
    });

    test('watchSessionPreferences', () async {
      final seen = <int>[];
      final sub = repo.watchSessionPreferences().listen(
        (p) => seen.add(p.rounds),
      );
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await repo.saveSessionPreferences(const SessionPreferences(rounds: 7));
      await pumpEventQueue();
      expect(seen.first, 5);
      expect(seen.last, 7);
    });
  });
}
