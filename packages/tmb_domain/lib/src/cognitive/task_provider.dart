import '../common/enums.dart';
import '../content/cognitive_task.dart';
import '../content/task_archetype.dart';

/// Наибольший допустимый сид: `2^53 − 1` (SCHEMAS §3.4) — предел точного целого
/// в вебе и в JSON на сервере.
const int maxTaskSeed = 9007199254740991;

/// Сид задачи (инвариант 4): одинаковый сид → одинаковая задача.
final class TaskSeed {
  TaskSeed(this.value) {
    if (value < 0 || value > maxTaskSeed) {
      throw RangeError.range(value, 0, maxTaskSeed, 'value');
    }
  }

  /// `0 … 2^53 − 1`.
  final int value;

  @override
  bool operator ==(Object other) => other is TaskSeed && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TaskSeed($value)';
}

/// Диапазон уровней, на который рассчитан провайдер (`recruit … spetsnaz`).
final class DifficultyBand {
  const DifficultyBand(this.levels);

  final Set<DifficultyLevel> levels;

  bool contains(DifficultyLevel level) => levels.contains(level);
}

/// Ответ пользователя в каноническом виде — тот же, что пишется в
/// `TaskAttempt.response`, чтобы сервер мог перепроверить (инвариант 8):
///  * `recall`/`delayed_recall` — введённая строка;
///  * `choice` — индекс варианта по исходному порядку;
///  * `ordering` — индексы шагов в порядке пользователя через `,`;
///  * `spatial` — `row,col`;
///  * `verbal` — ответа нет, есть число «да» в самопроверке.
final class TaskAnswer {
  const TaskAnswer({this.response, this.selfCheckYes});

  const TaskAnswer.recall(String text) : this(response: text);
  TaskAnswer.choice(int index) : this(response: '$index');
  TaskAnswer.ordering(List<int> indices) : this(response: indices.join(','));
  TaskAnswer.spatial({required int row, required int col})
    : this(response: '$row,$col');
  const TaskAnswer.selfCheck({required int yes}) : this(selfCheckYes: yes);

  final String? response;

  /// Сколько вопросов самопроверки получили «да» (только `verbal`).
  final int? selfCheckYes;
}

/// Вердикт проверки.
final class TaskVerdict {
  const TaskVerdict({this.isCorrect, this.selfRating});

  /// Задача непроверяема машиной (`verbal`): `isCorrect == null`.
  const TaskVerdict.notMachineVerifiable({this.selfRating}) : isCorrect = null;

  /// `null` ⇔ задача не проверяется машиной (инвариант 7).
  final bool? isCorrect;

  /// 0…3, только у `verbal`.
  final int? selfRating;

  bool get isMachineVerified => isCorrect != null;
}

/// Контракт провайдера задач (EXTENSIBILITY §2). Ядро не знает о Java, латыни
/// и такмеде — только об этом интерфейсе. Новый домен — новый пак данных, а не
/// правка движка.
///
/// Отличия от наброска в EXTENSIBILITY: `archetypes` (множество) вместо
/// `archetype` — пак смешивает архетипы; `locales` — строки, а не `Locale`
/// (домен не знает Flutter).
abstract interface class CognitiveTaskProvider {
  /// Для пака — его `pack`; пишется в `TaskAttempt.packId`.
  String get id;

  Set<TaskArchetype> get archetypes;
  Set<String> get domains;
  DifficultyBand get band;
  Set<String> get locales;

  /// Все ли задачи провайдера проверяются машиной.
  bool get isMachineVerifiable;
  Duration get estimatedTime;

  /// ДЕТЕРМИНИРОВАННО: одинаковый [seed] → одинаковая задача.
  CognitiveTask generate(TaskSeed seed);

  TaskVerdict verify(CognitiveTask task, TaskAnswer answer);
}
