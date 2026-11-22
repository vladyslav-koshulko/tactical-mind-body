import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/session/session_services.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';

import '../../helpers.dart';

final l10n = AppLocalizationsRu();

// --- данные ---------------------------------------------------------------------

const exerciseA = Exercise(
  id: 'ex.test_a',
  name: {'ru': 'Отжимания'},
  unit: ExerciseUnit.reps,
  muscleGroups: [],
  inventory: [],
  locations: [Location.home],
);
const exerciseB = Exercise(
  id: 'ex.test_b',
  name: {'ru': 'Приседания'},
  unit: ExerciseUnit.reps,
  muscleGroups: [],
  inventory: [],
  locations: [Location.home],
);

/// Цель по умолчанию в профиле (`DefaultTargets.standard`): 15 повторений.
const defaultReps = 15;

const recallNumeric = RecallTask(
  id: 'test.recall.num',
  domain: 'cog.test.recall',
  timeSec: 20,
  difficulty: 0.3,
  prompt: 'Сколько будет 47 + 38?',
  answer: 85,
  reveal: '47 + 38 = 85.',
);
const recallText = RecallTask(
  id: 'test.recall.text',
  domain: 'cog.test.recall',
  timeSec: 20,
  difficulty: 0.3,
  prompt: 'Назовите пароль.',
  answer: 'купол',
);
const choiceTask = ChoiceTask(
  id: 'test.choice',
  domain: 'cog.test.choice',
  timeSec: 20,
  difficulty: 0.3,
  prompt: 'Какой вариант верный?',
  options: ['Альфа', 'Браво', 'Чарли'],
  answer: 1,
);
const orderingTask = OrderingTask(
  id: 'test.ordering',
  domain: 'cog.test.ordering',
  timeSec: 30,
  difficulty: 0.3,
  prompt: 'Расставьте шаги по порядку.',
  items: ['Первый шаг', 'Второй шаг', 'Третий шаг'],
);
const spatialTask = SpatialTask(
  id: 'test.spatial',
  domain: 'cog.test.spatial',
  timeSec: 20,
  difficulty: 0.3,
  prompt: 'Где была отметка Б?',
  grid: GridSize(rows: 3, cols: 3),
  answer: CellPosition(row: 1, col: 2),
  objects: [
    SpatialObject(label: 'А', row: 0, col: 0),
    SpatialObject(label: 'Б', row: 1, col: 2),
  ],
  showSec: 5,
);
const delayedTask = DelayedRecallTask(
  id: 'test.delayed',
  domain: 'cog.test.delayed',
  timeSec: 20,
  difficulty: 0.3,
  prompt: 'Запомните пост.',
  memorize: 'Пост номер три',
  question: 'Какой был номер поста?',
  answer: 3,
  showSec: 5,
);
const verbalTask = VerbalTask(
  id: 'test.verbal',
  domain: 'cog.test.verbal',
  timeSec: 30,
  difficulty: 0.3,
  prompt: 'Опишите комнату вслух.',
  selfCheck: ['Говорил без пауз?', 'Уложился в условие?', 'Назвал предметы?'],
  cues: [Cue(fromSec: 3, toSec: 3, text: 'Теперь без слов на букву А')],
);

TaskSource sourceOf(List<CognitiveTask> tasks, {String pack = 'test.pack'}) {
  final domains = {for (final t in tasks) t.domain};
  return TaskSource.pack(
    PackTaskProvider(
      TaskPack(
        pack: pack,
        title: 'Тестовый пак',
        locale: 'ru',
        license: 'proprietary',
        packSource: PackSource.builtin,
        status: PackStatus.draft,
        levels: DifficultyLevel.values,
        categories: [
          for (final d in domains) TaskCategory(domain: d, title: d),
        ],
        items: tasks,
      ),
    ),
  );
}

// --- окружение --------------------------------------------------------------------

final class FakeWakelock implements SessionWakelock {
  var enabled = false;
  var enableCalls = 0;

  @override
  Future<void> enable() async {
    enabled = true;
    enableCalls++;
  }

  @override
  Future<void> disable() async => enabled = false;
}

/// Всё, что тест держит в руках: часы, БД, роутер, записанные вибро-вызовы.
final class SessionEnv {
  SessionEnv(this.tester, this.db);

  final WidgetTester tester;
  final TmbDatabase db;
  int now = fakeNowMs;
  late GoRouter router;
  final wakelock = FakeWakelock();

  /// Методы платформенного канала `HapticFeedback.*`, по порядку.
  final haptics = <String>[];

  SessionRepository get sessions => DriftSessionRepository(db);

  /// Двигает фейковые часы и даёт движку тикнуть.
  Future<void> advance(int ms) async {
    now += ms;
    await settle();
  }

  /// Несколько кадров без `pumpAndSettle`: идущая сессия тикает вечно.
  Future<void> settle([int frames = 4]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 260));
    }
  }

  /// Снимает дерево и даёт отработать таймерам очистки Drift (стримы
  /// дашборда), иначе тест падает на «Timer is still pending».
  Future<void> unmount() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  }

  Future<void> tapText(String text, {bool upper = true}) async {
    final finder = find.text(upper ? text.toUpperCase() : text);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await settle();
  }

  /// Нажимает клавиши собственной клавиатуры: цифры, `,` и `−`.
  Future<void> tapDigits(String keys) async {
    for (final k in keys.split('')) {
      final key = k == '-' ? '−' : k;
      final finder = find
          .descendant(of: find.byType(TextButton), matching: find.text(key))
          .first;
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }
    await settle(1);
  }

  /// Выполняет все подходы круга «по умолчанию».
  Future<void> completeRound({int sets = 2, String? label}) async {
    for (var i = 0; i < sets; i++) {
      await advance(2000);
      await tapText(label ?? l10n.sessionSetDone);
    }
  }

  String get currentSessionId {
    final uri = router.state.uri.path;
    return Uri.decodeComponent(uri.split('/').last);
  }
}

/// Поднимает приложение на маршруте сессии с управляемыми часами и БД в памяти.
Future<SessionEnv> pumpSession(
  WidgetTester tester, {
  required List<CognitiveTask> tasks,
  SessionPreferences prefs = const SessionPreferences(rounds: 2),
  ProfileSettings? profile,
  Size size = const Size(360, 800),
  double textScale = 1,
  String initialLocation = TmbRoutes.session,
  List<Exercise> exercises = const [exerciseA, exerciseB],
  Future<void> Function(TmbDatabase db)? seedDb,
  Locale locale = const Locale('ru'),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final db = TmbDatabase(NativeDatabase.memory());
  await tester.runAsync(() async {
    final repo = DriftProfileRepository(db);
    await repo.saveSessionPreferences(prefs);
    if (profile != null) await repo.saveProfile(profile);
    if (seedDb != null) await seedDb(db);
  });

  final env = SessionEnv(tester, db);
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        env.haptics.add('${call.arguments}');
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );

  env.router = createRouter(initialLocation: initialLocation);
  addTearDown(env.router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) {
          ref.onDispose(db.close);
          return db;
        }),
        clockProvider.overrideWithValue(() => env.now),
        contentProvider.overrideWith(
          (ref) async => const BuiltinContent(taskPacks: [], exercisePacks: []),
        ),
        exercisesProvider.overrideWith((ref) async => exercises),
        taskSourcesProvider.overrideWith((ref) async => [sourceOf(tasks)]),
        sessionSeedProvider.overrideWithValue(() => 7),
        sessionWakelockProvider.overrideWithValue(env.wakelock),
        routerProvider.overrideWithValue(env.router),
      ],
      child: TmbApp(locale: locale),
    ),
  );
  await env.settle(6);
  return env;
}
