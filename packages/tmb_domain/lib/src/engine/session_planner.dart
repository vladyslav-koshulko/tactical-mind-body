import '../cognitive/pack_task_provider.dart';
import '../cognitive/task_provider.dart';
import '../common/enums.dart';
import '../content/cognitive_task.dart';
import '../content/cue.dart';
import '../content/task_archetype.dart';
import '../content/task_pack.dart';
import '../determinism/cue_moments.dart';
import '../determinism/mulberry32.dart';
import '../determinism/payload_hash.dart';
import '../exercises/exercise.dart';
import '../profile/profile_settings.dart';
import '../profile/targets.dart';
import '../session/session_block.dart';
import '../session/session_template.dart';
import 'planning_exception.dart';
import 'session_plan.dart';
import 'task_source.dart';

/// Сколько раз перетягивать задачу, прежде чем сдаться (см. [SessionPlanner]).
const int _maxTries = 32;

/// Строит [SessionPlan] из шаблона, паков и профиля.
///
/// Детерминизм (инвариант 4): весь выбор идёт от главного сида через
/// `Mulberry32.forTask(seed, '<соль>')`; `Random()` и часов нет. Соли
/// (часть контракта воспроизводимости — менять нельзя):
///  * `tmb.plan.phys/<blockIndex>` — выбор и цели упражнений круга;
///  * `tmb.plan.task/<blockIndex>/<slot>/<try>` — задача слота: первый вызов
///    `nextUint32()` — сид для `provider.generate`, второй — индекс источника.
///
/// Изменение входов (набор упражнений, паки, отключённые категории)
/// меняет план при том же сиде — как и для `PackTaskProvider` (решение 26).
final class SessionPlanner {
  SessionPlanner({
    Iterable<Exercise> exercises = const [],
    Iterable<TaskSource> sources = const [],
    this.profile = const ProfileSettings(),
    Iterable<String> availableInventory = const [],
    this.exercisesPerRound = 4,
    this.tasksPerCognitiveBlock = 1,
    Iterable<TaskArchetype> excludedArchetypes = const [TaskArchetype.stream],
  }) : exercises = List.unmodifiable(exercises),
       sources = List.unmodifiable(sources),
       availableInventory = Set.unmodifiable(availableInventory),
       excludedArchetypes = Set.unmodifiable(excludedArchetypes) {
    if (exercisesPerRound < 1) {
      throw ArgumentError.value(exercisesPerRound, 'exercisesPerRound', '≥ 1');
    }
    if (tasksPerCognitiveBlock < 1) {
      throw ArgumentError.value(
        tasksPerCognitiveBlock,
        'tasksPerCognitiveBlock',
        '≥ 1',
      );
    }
  }

  /// База упражнений; фильтруется по месту и инвентарю.
  final List<Exercise> exercises;

  /// Провайдеры задач (обычно по одному на пак).
  final List<TaskSource> sources;

  /// Профиль: отключённые категории (D2) и цели упражнений (§4). Для
  /// `PackTaskProvider` профиль — единственный источник фильтра категорий
  /// поверх его собственного пула.
  final ProfileSettings profile;

  /// Инвентарь пользователя: упражнение допустимо, если весь его
  /// `inventory` входит сюда. Пусто — только без инвентаря.
  final Set<String> availableInventory;

  /// Сколько упражнений в круге (в прототипе — 4).
  final int exercisesPerRound;

  /// Сколько новых задач в когнитивном окне. Отложенные вопросы
  /// `delayed_recall` идут сверх этого числа.
  final int tasksPerCognitiveBlock;

  /// Архетипы, которые не попадают в план. По умолчанию `stream`: формат
  /// ответа и проверка определяются в v0.2 (`PackTaskProvider.verify`
  /// бросает `UnsupportedError`).
  final Set<TaskArchetype> excludedArchetypes;

  /// Строит план.
  ///
  /// [seed] — `0 … 2^53 − 1`. Бросает [PlanningException] с понятной причиной,
  /// если план собрать не из чего (в том числе пустой пул задач).
  SessionPlan plan({
    required SessionTemplate template,
    required int seed,
    required Location location,
    required DifficultyLevel difficulty,
  }) {
    TaskSeed(seed); // проверка диапазона
    final blocks = template.blocks;
    if (blocks.isEmpty) {
      throw const PlanningException(
        PlanningFailure.emptyTemplate,
        'В шаблоне нет блоков',
      );
    }
    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      final sec = switch (b) {
        CognitiveBlock() => b.durationSec,
        RestBlock() => b.durationSec,
        PhysicalBlock() => 1,
      };
      if (sec < 1) {
        throw PlanningException(
          PlanningFailure.invalidBlock,
          'Блок $i: длительность должна быть не меньше 1 с (сейчас $sec)',
        );
      }
    }

    final exercisePool = template.physicalBlockCount > 0
        ? _exercisePool(location)
        : const <Exercise>[];
    final usable = template.cognitiveBlockCount > 0
        ? _usableSources(difficulty)
        : const <TaskSource>[];

    final cognitiveBlockIndices = [
      for (var i = 0; i < blocks.length; i++)
        if (blocks[i] is CognitiveBlock) i,
    ];
    // Вопросы отложенных задач, которые встанут в начало будущих окон.
    final pendingQuestions = List.generate(
      blocks.length,
      (_) => <PlannedTask>[],
    );

    final planned = <PlannedBlock>[];
    var physicalRound = 0;
    var cognitiveRound = 0;
    for (var i = 0; i < blocks.length; i++) {
      switch (blocks[i]) {
        case PhysicalBlock():
          planned.add(
            PlannedPhysicalBlock(
              blockIndex: i,
              roundIndex: physicalRound++,
              exercises: _planRound(seed, i, exercisePool),
            ),
          );
        case RestBlock(:final durationSec):
          planned.add(
            PlannedRestBlock(blockIndex: i, durationSec: durationSec),
          );
        case CognitiveBlock(:final durationSec):
          final tasks = <PlannedTask>[...pendingQuestions[i]];
          for (var slot = 0; slot < tasksPerCognitiveBlock; slot++) {
            tasks.add(
              _drawTask(
                seed: seed,
                blockIndex: i,
                slot: slot,
                round: cognitiveRound,
                sources: usable,
                cognitiveBlockIndices: cognitiveBlockIndices,
                pendingQuestions: pendingQuestions,
                difficulty: difficulty,
              ),
            );
          }
          planned.add(
            PlannedCognitiveBlock(
              blockIndex: i,
              roundIndex: cognitiveRound++,
              durationSec: durationSec,
              tasks: tasks,
            ),
          );
      }
    }

    return SessionPlan(
      seed: seed,
      template: template,
      location: location,
      difficulty: difficulty,
      blocks: planned,
    );
  }

  // --- физика ------------------------------------------------------------------

  List<Exercise> _exercisePool(Location location) {
    final pool = [
      for (final e in exercises)
        if (e.locations.contains(location) &&
            e.inventory.every(availableInventory.contains))
          e,
    ];
    if (pool.isEmpty) {
      throw PlanningException(
        PlanningFailure.noExercises,
        'Нет упражнений для места ${location.wire} с инвентарём '
        '$availableInventory (в базе ${exercises.length})',
      );
    }
    return pool;
  }

  List<PlannedExercise> _planRound(
    int seed,
    int blockIndex,
    List<Exercise> pool,
  ) {
    final rng = Mulberry32.forTask(
      seed: seed,
      taskId: 'tmb.plan.phys/$blockIndex',
    );
    final count = pool.length < exercisesPerRound
        ? pool.length
        : exercisesPerRound;
    // Частичный Фишер–Йетс: ровно `count` вызовов ГПСЧ.
    final deck = List.of(pool);
    for (var i = 0; i < count; i++) {
      final j = rng.nextIntInRange(i, deck.length - 1);
      final tmp = deck[i];
      deck[i] = deck[j];
      deck[j] = tmp;
    }
    return [
      for (final e in deck.take(count))
        PlannedExercise(exercise: e, prescribed: _prescribe(e, rng)),
    ];
  }

  /// Цель упражнения: своя `ExerciseTarget`, иначе `defaultTargets` по
  /// единице. `min == max` — фиксированная; иначе случайная в диапазоне на
  /// каждый круг. Один вызов ГПСЧ на упражнение в любом случае — чтобы
  /// смена цели одного упражнения не сдвигала остальные.
  int _prescribe(Exercise e, Mulberry32 rng) {
    ExerciseTarget? own;
    for (final t in profile.exerciseTargets) {
      if (t.exerciseId == e.id) {
        own = t;
        break;
      }
    }
    final range = own != null
        ? TargetRange(min: own.min, max: own.max)
        : profile.defaultTargets.forUnit(e.unit);
    final lo = range.min < range.max ? range.min : range.max;
    final hi = range.min < range.max ? range.max : range.min;
    return rng.nextIntInRange(lo, hi).clamp(1, 3600);
  }

  // --- когниция ----------------------------------------------------------------

  /// Источники, годные для сессии: подходят по уровню, после фильтра профиля
  /// и исключённых архетипов в них осталась хотя бы одна задача.
  List<TaskSource> _usableSources(DifficultyLevel difficulty) {
    final out = <TaskSource>[];
    for (final s in sources) {
      if (!s.provider.band.contains(difficulty)) continue;
      final narrowed = _narrow(s);
      if (narrowed != null) out.add(narrowed);
    }
    if (out.isEmpty) {
      throw PlanningException(
        PlanningFailure.emptyTaskPool,
        'Пул когнитивных задач пуст: источников ${sources.length}, '
        'отключённых категорий ${profile.disabledCategories.length}, '
        'исключённых архетипов ${excludedArchetypes.length}, '
        'уровень ${difficulty.wire}',
      );
    }
    return out;
  }

  /// Сужает пак до задач, прошедших фильтр, чтобы `generate` не приходилось
  /// перетягивать (при 1 включённой категории из 17 перетяжка не гарантирует
  /// результат). Для чужих провайдеров — только проверка пустоты; их
  /// результат фильтруется в [_drawTask].
  TaskSource? _narrow(TaskSource s) {
    final p = s.provider;
    if (p is PackTaskProvider) {
      final items = [
        for (final t in p.pool)
          if (_accepts(t)) t,
      ];
      if (items.isEmpty) return null;
      final pack = p.pack;
      return TaskSource(
        provider: PackTaskProvider(
          TaskPack(
            schemaVersion: pack.schemaVersion,
            pack: pack.pack,
            title: pack.title,
            locale: pack.locale,
            license: pack.license,
            packSource: pack.packSource,
            status: pack.status,
            levels: pack.levels,
            categories: pack.categories,
            items: items,
          ),
        ),
        packSource: s.packSource,
      );
    }
    if (!p.domains.any(profile.isEnabled)) return null;
    if (p.archetypes.isNotEmpty &&
        p.archetypes.every(excludedArchetypes.contains)) {
      return null;
    }
    return s;
  }

  bool _accepts(CognitiveTask t) =>
      profile.isEnabled(t.domain) && !excludedArchetypes.contains(t.archetype);

  PlannedTask _drawTask({
    required int seed,
    required int blockIndex,
    required int slot,
    required int round,
    required List<TaskSource> sources,
    required List<int> cognitiveBlockIndices,
    required List<List<PlannedTask>> pendingQuestions,
    required DifficultyLevel difficulty,
  }) {
    PlannedTask build(
      CognitiveTask task,
      int taskSeed,
      TaskSource source, {
      PlannedTaskRole role = PlannedTaskRole.standard,
      int? encoded,
    }) => PlannedTask(
      task: task,
      seed: taskSeed,
      source: source,
      payloadHash: payloadHash(task),
      role: role,
      encodedRoundIndex: encoded,
      cueMomentsSec: _cues(task, taskSeed),
    );

    ({CognitiveTask task, int seed, TaskSource source})? immediate;
    for (var attempt = 0; attempt < _maxTries; attempt++) {
      final rng = Mulberry32.forTask(
        seed: seed,
        taskId: 'tmb.plan.task/$blockIndex/$slot/$attempt',
      );
      final taskSeed = rng.nextUint32();
      final source = sources[rng.nextIntInRange(0, sources.length - 1)];
      final task = source.provider.generate(TaskSeed(taskSeed));
      if (!_accepts(task)) continue;

      if (task is DelayedRecallTask) {
        final target = round + task.effectiveDelayRounds;
        if (target < cognitiveBlockIndices.length) {
          final memorize = build(
            task,
            taskSeed,
            source,
            role: PlannedTaskRole.memorize,
          );
          pendingQuestions[cognitiveBlockIndices[target]].add(
            build(
              task,
              taskSeed,
              source,
              role: PlannedTaskRole.recallQuestion,
              encoded: round,
            ),
          );
          return memorize;
        }
        // Вопрос задать негде: сессия закончится раньше. Пробуем другую
        // задачу, а если пул целиком такой — запоминание и вопрос подряд.
        immediate ??= (task: task, seed: taskSeed, source: source);
        continue;
      }
      return build(task, taskSeed, source);
    }
    if (immediate != null) {
      return build(
        immediate.task,
        immediate.seed,
        immediate.source,
        encoded: round,
      );
    }
    throw PlanningException(
      PlanningFailure.emptyTaskPool,
      'Не удалось подобрать задачу для блока $blockIndex за $_maxTries '
      'попыток: провайдеры выдают только отключённые категории или '
      'исключённые архетипы',
    );
  }

  List<int> _cues(CognitiveTask task, int seed) {
    if (task is! VerbalTask) return const [];
    final List<Cue>? cues = task.cues;
    if (cues == null || cues.isEmpty) return const [];
    return cueMoments(seed: seed, taskId: task.id, cues: cues);
  }
}
