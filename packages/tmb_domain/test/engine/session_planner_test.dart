import 'dart:convert';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'fixtures.dart';

String _json(SessionPlan p) => jsonEncode(p.toJson());

Iterable<PlannedTask> _tasks(SessionPlan p) => [
  for (final b in p.blocks)
    if (b is PlannedCognitiveBlock) ...b.tasks,
];

void main() {
  final dual = SessionTemplate.dualTask(rounds: 4, cognitiveSec: 120);

  group('детерминизм плана (инвариант 4)', () {
    test(
      'один сид и входы → идентичный план, в том числе у нового планировщика',
      () {
        final a = planOf(plannerWith(), dual, seed: 12345);
        final b = planOf(plannerWith(), dual, seed: 12345);
        expect(_json(a), _json(b));
        expect(a.blocks, hasLength(dual.blocks.length));
      },
    );

    test('разные сиды дают разные планы', () {
      final plans = {
        for (var s = 0; s < 20; s++)
          _json(planOf(plannerWith(), dual, seed: s)),
      };
      expect(plans.length, greaterThan(15));
    });

    test('сид задачи в плане воспроизводит задачу через provider.generate', () {
      final plan = planOf(plannerWith(), dual, seed: 99);
      for (final t in _tasks(plan)) {
        expect(t.seed, inInclusiveRange(0, maxTaskSeed));
        final again = t.source.provider.generate(TaskSeed(t.seed));
        expect(again.id, t.task.id);
        expect(payloadHash(again), t.payloadHash);
      }
    });

    test('моменты cues — функция сида, а не случайности', () {
      // Пул из одной verbal-задачи с cue [15, 25].
      final planner = plannerWith(
        sources: [
          sourceOf(packOf(['demo.ver.001'])),
        ],
      );
      final moments = <int>{};
      for (var s = 0; s < 40; s++) {
        final plan = planOf(
          planner,
          SessionTemplate.cognitiveOnly(windows: 1, cognitiveSec: 120),
          seed: s,
        );
        final t = _tasks(plan).single;
        final cues = (t.task as VerbalTask).cues!;
        expect(
          t.cueMomentsSec,
          cueMoments(seed: t.seed, taskId: t.task.id, cues: cues),
        );
        expect(t.cueMomentsSec.single, inInclusiveRange(15, 25));
        moments.add(t.cueMomentsSec.single);
      }
      expect(moments.length, greaterThan(3));
    });

    test('вне диапазона сид отклоняется', () {
      expect(
        () => planOf(plannerWith(), dual, seed: -1),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => planOf(plannerWith(), dual, seed: maxTaskSeed + 1),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('физические блоки', () {
    test('круги: упражнения различны, число = exercisesPerRound', () {
      final plan = planOf(plannerWith(exercisesPerRound: 4), dual);
      final rounds = plan.blocks.whereType<PlannedPhysicalBlock>().toList();
      expect(rounds.map((r) => r.roundIndex), [0, 1, 2, 3]);
      for (final r in rounds) {
        final ids = r.exercises.map((e) => e.exerciseId).toList();
        expect(ids, hasLength(4));
        expect(ids.toSet(), hasLength(4));
      }
    });

    test('мало упражнений — берутся все', () {
      final plan = planOf(
        plannerWith(
          exercises: [exercise('ex.pushup'), exercise('ex.situp')],
          exercisesPerRound: 4,
        ),
        SessionTemplate.physicalOnly(rounds: 1),
      );
      expect(
        (plan.blocks.single as PlannedPhysicalBlock).exercises,
        hasLength(2),
      );
    });

    test('цели: дефолт по единицам, своя ExerciseTarget, диапазон', () {
      final profile = ProfileSettings(
        defaultTargets: const DefaultTargets(
          reps: TargetRange(min: 12, max: 12),
          seconds: TargetRange(min: 45, max: 45),
        ),
        exerciseTargets: const [
          ExerciseTarget(
            exerciseId: 'ex.pushup',
            min: 5,
            max: 8,
            lockedByUser: true,
          ),
        ],
      );
      final planner = plannerWith(
        exercises: [
          exercise('ex.pushup'),
          exercise('ex.situp'),
          exercise('ex.plank', unit: ExerciseUnit.seconds),
        ],
        profile: profile,
      );
      final seen = <int>{};
      for (var s = 0; s < 60; s++) {
        final plan = planOf(
          planner,
          SessionTemplate.physicalOnly(rounds: 1),
          seed: s,
        );
        for (final e
            in (plan.blocks.single as PlannedPhysicalBlock).exercises) {
          switch (e.exerciseId) {
            case 'ex.pushup':
              expect(e.prescribed, inInclusiveRange(5, 8));
              seen.add(e.prescribed);
            case 'ex.situp':
              expect(e.prescribed, 12);
            case 'ex.plank':
              expect(e.prescribed, 45);
              expect(e.unit, ExerciseUnit.seconds);
          }
        }
      }
      expect(seen.length, greaterThan(2));
    });

    test('фильтры по месту и инвентарю', () {
      final exercises = [
        exercise('ex.pushup'),
        exercise('ex.pullup', inventory: const ['pullup_bar']),
        exercise('ex.bench', locations: const [Location.gym]),
      ];
      List<String> idsFor({Set<String> inventory = const {}}) {
        final planner = SessionPlanner(
          exercises: exercises,
          availableInventory: inventory,
          exercisesPerRound: 10,
        );
        final plan = planner.plan(
          template: SessionTemplate.physicalOnly(rounds: 1),
          seed: 1,
          location: Location.home,
          difficulty: DifficultyLevel.recruit,
        );
        return [
          for (final e
              in (plan.blocks.single as PlannedPhysicalBlock).exercises)
            e.exerciseId,
        ]..sort();
      }

      expect(idsFor(), ['ex.pushup']);
      expect(idsFor(inventory: {'pullup_bar'}), ['ex.pullup', 'ex.pushup']);
    });
  });

  group('когнитивные блоки', () {
    test('roundIndex окон и число задач в окне', () {
      final plan = planOf(plannerWith(tasksPerCognitiveBlock: 2), dual);
      final windows = plan.blocks.whereType<PlannedCognitiveBlock>().toList();
      expect(windows.map((w) => w.roundIndex), [0, 1, 2]);
      expect(windows.map((w) => w.blockIndex), [1, 3, 5]);
      for (final w in windows) {
        expect(w.durationSec, 120);
        expect(w.tasks.length, greaterThanOrEqualTo(2));
      }
    });

    test('stream по умолчанию исключён, без исключения — встречается', () {
      final cog = SessionTemplate.cognitiveOnly(windows: 1, cognitiveSec: 60);
      final withDefault = {
        for (var s = 0; s < 150; s++)
          ..._tasks(planOf(plannerWith(), cog, seed: s))
              .map((t) => t.archetype),
      };
      expect(withDefault, isNot(contains(TaskArchetype.stream)));
      expect(withDefault, contains(TaskArchetype.recall));

      final without = {
        for (var s = 0; s < 150; s++)
          ..._tasks(planOf(plannerWith(excluded: const []), cog, seed: s))
              .map((t) => t.archetype),
      };
      expect(without, contains(TaskArchetype.stream));
    });

    test('packSource попадает из пака', () {
      final plan = planOf(
        plannerWith(
          sources: [
            sourceOf(packOf(['demo.java.002'], source: PackSource.user)),
          ],
        ),
        SessionTemplate.cognitiveOnly(windows: 1, cognitiveSec: 60),
      );
      expect(_tasks(plan).single.packSource, PackSource.user);
    });

    test('несколько источников: выбираются оба, детерминированно', () {
      final planner = plannerWith(
        sources: [
          sourceOf(packOf(['demo.java.002'])),
          TaskSource(
            provider: PackTaskProvider(
              TaskPack(
                pack: 'second.ru',
                title: 'Второй',
                locale: 'ru',
                license: 'CC-BY-4.0',
                packSource: PackSource.imported,
                status: PackStatus.draft,
                levels: const [DifficultyLevel.recruit],
                categories: demoPack().categories,
                items: [demoPack().items[0]],
              ),
            ),
            packSource: PackSource.imported,
          ),
        ],
      );
      final cog = SessionTemplate.cognitiveOnly(windows: 1, cognitiveSec: 60);
      final packs = {
        for (var s = 0; s < 40; s++)
          for (final t in _tasks(planOf(planner, cog, seed: s))) t.providerId,
      };
      expect(packs, {'demo.ru', 'second.ru'});
    });
  });

  group('отключённые категории и пустой пул', () {
    final cog = SessionTemplate.cognitiveOnly(windows: 1, cognitiveSec: 60);

    test('отключённые категории сужают пул (по границе сегмента)', () {
      final planner = plannerWith(
        profile: const ProfileSettings(
          disabledCategories: ['it', 'math.estimation'],
        ),
      );
      final domains = {
        for (var s = 0; s < 200; s++)
          ..._tasks(planOf(planner, cog, seed: s)).map((t) => t.task.domain),
      };
      expect(domains, isNotEmpty);
      for (final d in domains) {
        expect(d.startsWith('it'), isFalse, reason: d);
        expect(d, isNot('math.estimation'));
      }
    });

    test('остаётся одна категория — только её задачи', () {
      final planner = plannerWith(
        profile: const ProfileSettings(
          disabledCategories: [
            'it',
            'math',
            'cog.memory',
            'cog.spatial',
            'cog.attention',
          ],
        ),
      );
      for (var s = 0; s < 50; s++) {
        expect(
          _tasks(planOf(planner, cog, seed: s)).single.task.id,
          'demo.ver.001',
        );
      }
    });

    test('профиль фильтрует и провайдера, уже собранного без фильтра', () {
      final provider = PackTaskProvider(demoPack());
      expect(provider.pool, hasLength(8));
      final plan = planOf(
        plannerWith(
          sources: [TaskSource.pack(provider)],
          profile: const ProfileSettings(disabledCategories: ['it']),
        ),
        cog,
      );
      expect(_tasks(plan).single.task.domain, isNot(startsWith('it')));
    });

    test('все категории отключены → понятная ошибка, не StateError', () {
      final planner = plannerWith(
        profile: const ProfileSettings(
          disabledCategories: ['it', 'math', 'cog'],
        ),
      );
      expect(
        () => planOf(planner, cog),
        throwsA(
          isA<PlanningException>().having(
            (e) => e.reason,
            'reason',
            PlanningFailure.emptyTaskPool,
          ),
        ),
      );
    });

    test('остались только исключённые архетипы → ошибка пустого пула', () {
      final planner = plannerWith(
        sources: [
          sourceOf(packOf(['demo.str.001'])),
        ],
      );
      expect(
        () => planOf(planner, cog),
        throwsA(
          isA<PlanningException>().having(
            (e) => e.reason,
            'reason',
            PlanningFailure.emptyTaskPool,
          ),
        ),
      );
    });

    test('нет источников / уровень вне полосы пака → пустой пул', () {
      expect(
        () => planOf(plannerWith(sources: const []), cog),
        throwsA(isA<PlanningException>()),
      );
      expect(
        () => planOf(plannerWith(), cog, difficulty: DifficultyLevel.spetsnaz),
        throwsA(isA<PlanningException>()),
      );
    });

    test('сообщение об ошибке читаемо', () {
      final e = PlanningException(PlanningFailure.emptyTaskPool, 'пул пуст');
      expect(e.toString(), contains('emptyTaskPool'));
      expect(e.toString(), contains('пул пуст'));
    });

    test('физика без паков задач планируется; без упражнений — ошибка', () {
      final physical = SessionTemplate.physicalOnly(rounds: 2);
      expect(
        planOf(plannerWith(sources: const []), physical).blocks,
        hasLength(2),
      );
      expect(
        () => planOf(plannerWith(exercises: const []), physical),
        throwsA(
          isA<PlanningException>().having(
            (e) => e.reason,
            'reason',
            PlanningFailure.noExercises,
          ),
        ),
      );
      // Упражнения есть, но не для этого места.
      final planner = plannerWith(
        exercises: [
          exercise('ex.bench', locations: const [Location.gym]),
        ],
      );
      expect(
        () => planOf(planner, physical),
        throwsA(isA<PlanningException>()),
      );
    });

    test('пустой шаблон и блок нулевой длины', () {
      expect(
        () => planOf(plannerWith(), SessionTemplate.custom(const [])),
        throwsA(
          isA<PlanningException>().having(
            (e) => e.reason,
            'reason',
            PlanningFailure.emptyTemplate,
          ),
        ),
      );
      expect(
        () => planOf(
          plannerWith(),
          SessionTemplate.custom(const [RestBlock(durationSec: 0)]),
        ),
        throwsA(
          isA<PlanningException>().having(
            (e) => e.reason,
            'reason',
            PlanningFailure.invalidBlock,
          ),
        ),
      );
    });
  });

  group('delayed_recall', () {
    final cog3 = SessionTemplate.cognitiveOnly(windows: 3, cognitiveSec: 60);

    List<List<PlannedTaskRole>> roles(SessionPlan p) => [
      for (final b in p.blocks.whereType<PlannedCognitiveBlock>())
        [for (final t in b.tasks) t.role],
    ];

    test(
      'вопрос встаёт в окно через delayRounds, в конце — вырожденный случай',
      () {
        final plan = planOf(
          plannerWith(
            sources: [
              sourceOf(packOf(['demo.mem.001'])),
            ],
          ),
          cog3,
        );
        expect(roles(plan), [
          [PlannedTaskRole.memorize],
          [PlannedTaskRole.recallQuestion, PlannedTaskRole.memorize],
          [PlannedTaskRole.recallQuestion, PlannedTaskRole.standard],
        ]);
        final blocks = plan.blocks.whereType<PlannedCognitiveBlock>().toList();
        // Вопрос — та же задача и тот же сид, что и запоминание.
        expect(blocks[1].tasks[0].seed, blocks[0].tasks[0].seed);
        expect(blocks[1].tasks[0].encodedRoundIndex, 0);
        expect(blocks[2].tasks[0].encodedRoundIndex, 1);
        // Вырожденный: запоминание и вопрос в одном слоте.
        expect(blocks[2].tasks[1].encodedRoundIndex, 2);
        expect(blocks[2].tasks[1].hasStudy, isTrue);
        expect(blocks[2].tasks[1].hasAnswer, isTrue);
      },
    );

    test('если есть другие задачи, «негде спросить» перетягивается', () {
      // Единственное окно: delayed_recall нигде не может получить вопрос.
      for (var s = 0; s < 60; s++) {
        final plan = planOf(
          plannerWith(),
          SessionTemplate.cognitiveOnly(windows: 1, cognitiveSec: 60),
          seed: s,
        );
        final t = _tasks(plan).single;
        if (t.task is DelayedRecallTask) {
          fail('delayed_recall без места для вопроса при наличии других задач');
        }
      }
    });
  });
}
