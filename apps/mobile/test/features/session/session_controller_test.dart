import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/session/session_controller.dart';
import 'package:tmb_mobile/features/session/session_services.dart';
import 'package:tmb_mobile/features/session/session_state.dart';
import 'package:tmb_ui/tmb_ui.dart' show TmbEffort;

import '../../helpers.dart';
import 'session_kit.dart';

ProviderContainer _container(
  FakeWakelock wakelock, {
  List<CognitiveTask> tasks = const [recallNumeric],
  List<Exercise> exercises = const [exerciseA, exerciseB],
  int seed = 7,
  int Function()? clock,
}) {
  final db = TmbDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: <Override>[
      databaseProvider.overrideWith((ref) {
        ref.onDispose(db.close);
        return db;
      }),
      clockProvider.overrideWithValue(clock ?? () => fakeNowMs),
      contentProvider.overrideWith(
        (ref) async => const BuiltinContent(taskPacks: [], exercisePacks: []),
      ),
      exercisesProvider.overrideWith((ref) async => exercises),
      taskSourcesProvider.overrideWith((ref) async => [sourceOf(tasks)]),
      sessionSeedProvider.overrideWithValue(() => seed),
      sessionWakelockProvider.overrideWithValue(wakelock),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Запускает контроллер, когда БД уже подготовлена. Слушатель нужен:
/// провайдер autoDispose и без него умер бы между чтениями.
Future<SessionRunning> _start(ProviderContainer c) async {
  c.listen(sessionControllerProvider, (_, _) {});
  return await c.read(sessionControllerProvider.future) as SessionRunning;
}

void main() {
  // Тесты поднимают несколько БД в памяти подряд — это намеренно.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'читает настройки сессии: шаблон, круги, окно, место, сложность',
    () async {
      final container = _container(FakeWakelock());
      await container
          .read(profileRepositoryProvider)
          .saveSessionPreferences(
            const SessionPreferences(
              rounds: 3,
              cognitiveSec: 60,
              location: Location.home,
              difficulty: DifficultyLevel.fighter,
            ),
          );
      final running = await _start(container);
      final blocks = running.plan.blocks;
      // 3 круга и 2 паузы между ними.
      expect(blocks.map((b) => b.runtimeType.toString()), [
        'PlannedPhysicalBlock',
        'PlannedCognitiveBlock',
        'PlannedPhysicalBlock',
        'PlannedCognitiveBlock',
        'PlannedPhysicalBlock',
      ]);
      expect((blocks[1] as PlannedCognitiveBlock).durationSec, 60);
      expect(running.plan.difficulty, DifficultyLevel.fighter);
      expect(running.plan.location, Location.home);

      final session =
          (await container.read(sessionRepositoryProvider).listSessions())
              .single;
      expect(session.difficulty, DifficultyLevel.fighter);
      expect(session.template, SessionTemplateKind.dualTask);
    },
  );

  test('читает профиль: отключённые категории не попадают в план', () async {
    final container = _container(
      FakeWakelock(),
      tasks: [recallNumeric, recallText, choiceTask],
    );
    await container
        .read(profileRepositoryProvider)
        .saveProfile(
          const ProfileSettings(disabledCategories: ['cog.test.recall']),
        );
    await container
        .read(profileRepositoryProvider)
        .saveSessionPreferences(const SessionPreferences(rounds: 6));
    final running = await _start(container);
    final tasks = [
      for (final b in running.plan.blocks.whereType<PlannedCognitiveBlock>())
        ...b.tasks,
    ];
    expect(tasks, hasLength(5));
    expect(tasks.map((t) => t.task.domain).toSet(), {'cog.test.choice'});
  });

  test('читает профиль: цели упражнений', () async {
    final container = _container(FakeWakelock());
    await container
        .read(profileRepositoryProvider)
        .upsertExerciseTarget(
          const ExerciseTarget(
            exerciseId: 'ex.test_a',
            min: 22,
            max: 22,
            lockedByUser: true,
          ),
        );
    final running = await _start(container);
    final first = (running.plan.blocks.first as PlannedPhysicalBlock).exercises;
    expect(first.firstWhere((e) => e.exerciseId == 'ex.test_a').prescribed, 22);
  });

  test(
    'сид приходит из sessionSeedProvider; план воспроизводим по сиду',
    () async {
      final a = await _start(_container(FakeWakelock(), seed: 42));
      final b = await _start(_container(FakeWakelock(), seed: 42));
      final c = await _start(_container(FakeWakelock(), seed: 43));
      expect(a.plan.seed, 42);
      expect(b.plan.toJson(), a.plan.toJson());
      expect(c.plan.toJson(), isNot(a.plan.toJson()));
    },
  );

  test(
    'время сессии — только из clockProvider, сессия пишется на старте',
    () async {
      final container = _container(
        FakeWakelock(),
        clock: () => fakeNowMs + 123456,
      );
      final running = await _start(container);
      expect(running.engine.startedAt, fakeNowMs + 123456);
      final session =
          (await container.read(sessionRepositoryProvider).listSessions())
              .single;
      expect(session.startedAt, fakeNowMs + 123456);
      expect(session.endedAt, isNull);
      expect(session.id, running.engine.sessionId);
    },
  );

  test(
    'экран не гаснет: wakelock включается на старте и снимается при выходе',
    () async {
      final wakelock = FakeWakelock();
      final container = _container(wakelock);
      await _start(container);
      expect(wakelock.enabled, isTrue);
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(wakelock.enabled, isFalse);
    },
  );

  test('нет упражнений — PlanningException, а не падение', () async {
    final container = _container(FakeWakelock(), exercises: const []);
    container.listen(sessionControllerProvider, (_, _) {});
    await expectLater(
      container.read(sessionControllerProvider.future),
      throwsA(
        isA<PlanningException>().having(
          (e) => e.reason,
          'reason',
          PlanningFailure.noExercises,
        ),
      ),
    );
  });

  test('все категории отключены — PlanningException(emptyTaskPool)', () async {
    final container = _container(FakeWakelock(), tasks: [recallNumeric]);
    await container
        .read(profileRepositoryProvider)
        .saveProfile(
          const ProfileSettings(disabledCategories: ['cog.test.recall']),
        );
    container.listen(sessionControllerProvider, (_, _) {});
    await expectLater(
      container.read(sessionControllerProvider.future),
      throwsA(
        isA<PlanningException>().having(
          (e) => e.reason,
          'reason',
          PlanningFailure.emptyTaskPool,
        ),
      ),
    );
  });

  test('действия до готовности и после завершения ничего не ломают', () async {
    final container = _container(FakeWakelock());
    container.listen(sessionControllerProvider, (_, _) {});
    final controller = container.read(sessionControllerProvider.notifier);
    controller.completeSet(); // до готовности — игнорируется
    await container.read(sessionControllerProvider.future);
    controller.skipTask(); // не когнитивная фаза: StateError проглочен
    controller.endStudy();
    controller.rate(TmbEffort.hard);
    final state = container.read(sessionControllerProvider).value;
    expect(state, isA<SessionRunning>());
  });
}
