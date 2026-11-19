import '../content/cognitive_task.dart';
import '../content/task_archetype.dart';
import '../content/task_pack.dart';
import '../determinism/mulberry32.dart';
import '../profile/category_filter.dart';
import 'answer_matching.dart';
import 'self_rating.dart';
import 'task_provider.dart';

/// Провайдер задач поверх пака данных. Единственная реализация контракта в
/// ядре: любой домен (Java, такмед, латынь) — это пак, а не подкласс.
final class PackTaskProvider implements CognitiveTaskProvider {
  /// Пул — задачи пака в порядке файла, чьи категории не отключены
  /// ([disabledCategories], правило сегмента — `isCategoryEnabled`).
  ///
  /// Результат [generate] стабилен для фиксированных содержимого пака и
  /// набора отключённых категорий: изменение любого из них меняет пул, а
  /// значит и выбор по тому же сиду. Для воспроизведения сессии ключ —
  /// `(seed, payloadHash)` записи `TaskAttempt`.
  PackTaskProvider(this.pack, {Iterable<String> disabledCategories = const []})
    : _pool = List.unmodifiable([
        for (final t in pack.items)
          if (isCategoryEnabled(t.domain, disabledCategories)) t,
      ]);

  final TaskPack pack;
  final List<CognitiveTask> _pool;

  /// Задачи, доступные для выбора.
  List<CognitiveTask> get pool => _pool;

  @override
  String get id => pack.pack;

  @override
  Set<TaskArchetype> get archetypes => {for (final t in _pool) t.archetype};

  @override
  Set<String> get domains => {for (final t in _pool) t.domain};

  @override
  DifficultyBand get band => DifficultyBand(Set.of(pack.levels));

  @override
  Set<String> get locales => {pack.locale};

  @override
  // Из архетипа, а не из поля `verifiable`: пак в обход валидатора не должен
  // пометить `verbal` проверяемой задачей (инвариант 7).
  bool get isMachineVerifiable =>
      _pool.every((t) => t.archetype.isMachineVerifiable);

  @override
  Duration get estimatedTime {
    if (_pool.isEmpty) return Duration.zero;
    final total = _pool.fold<int>(0, (sum, t) => sum + t.timeSec);
    return Duration(seconds: (total / _pool.length).round());
  }

  /// Выбирает задачу из пула по сиду: `Mulberry32` с солью — id провайдера,
  /// индекс — первое целое из `[0, pool.length − 1]`. `Random()` не
  /// используется. Моменты `cues` выбранной задачи считаются отдельно
  /// (`cueMoments`) от её собственного `id`.
  ///
  /// Пустой пул — [StateError]: «пул не бывает пустым» гарантируется при записи
  /// профиля, а не здесь.
  @override
  CognitiveTask generate(TaskSeed seed) {
    if (_pool.isEmpty) {
      throw StateError('Пул задач пака "${pack.pack}" пуст');
    }
    final rng = Mulberry32.forTask(seed: seed.value, taskId: pack.pack);
    return _pool[rng.nextIntInRange(0, _pool.length - 1)];
  }

  /// Проверка по `response` в каноническом виде. `verbal` — вердикт «не
  /// проверяется машиной» (`isCorrect == null`) и, если передан
  /// `selfCheckYes`, самооценка. `stream`: формат ответа — v0.2, поэтому
  /// [UnsupportedError].
  @override
  TaskVerdict verify(CognitiveTask task, TaskAnswer answer) {
    final response = answer.response;
    switch (task) {
      case RecallTask():
        return TaskVerdict(
          isCorrect:
              response != null &&
              matchesRecall(response, task.answer, task.accept),
        );
      case DelayedRecallTask():
        return TaskVerdict(
          isCorrect:
              response != null &&
              matchesRecall(response, task.answer, task.accept),
        );
      case ChoiceTask():
        return TaskVerdict(
          isCorrect: response != null && int.tryParse(response) == task.answer,
        );
      case OrderingTask():
        return TaskVerdict(isCorrect: _isCorrectOrder(response, task));
      case SpatialTask():
        return TaskVerdict(
          isCorrect: response == '${task.answer.row},${task.answer.col}',
        );
      case StreamTask():
        throw UnsupportedError(
          'Проверка stream: формат ответа определяется в v0.2',
        );
      case VerbalTask():
        final yes = answer.selfCheckYes;
        return TaskVerdict.notMachineVerifiable(
          selfRating: yes == null
              ? null
              : selfRating(yes: yes, n: task.selfCheck.length),
        );
    }
  }

  /// Верно, если индексы — ровно `0,1,…,n−1` (исходный порядок `items` —
  /// и есть верный).
  static bool _isCorrectOrder(String? response, OrderingTask task) {
    if (response == null) return false;
    final parts = response.split(',');
    if (parts.length != task.items.length) return false;
    for (var i = 0; i < parts.length; i++) {
      if (int.tryParse(parts[i]) != i) return false;
    }
    return true;
  }
}
