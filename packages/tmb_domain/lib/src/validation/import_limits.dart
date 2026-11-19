/// Лимиты импорта — SCHEMAS §7. Все значения — предложение владельца схемы и
/// меняются здесь, без смены формата.
final class ImportLimits {
  const ImportLimits({
    this.maxBytes = 1048576,
    this.maxDepth = 8,
    this.maxTasks = 2000,
    this.maxExercises = 500,
    this.maxCategories = 100,
    this.maxEventRecords = 5000,
    this.maxPacksPerUser = 50,
    this.maxTasksPerUser = 20000,
    this.promptLength = 1000,
    this.revealLength = 600,
    this.memorizeLength = 500,
    this.questionLength = 300,
    this.answerLength = 200,
    this.optionLength = 120,
    this.orderingItemLength = 120,
    this.selfCheckLength = 160,
    this.cueTextLength = 200,
    this.objectLabelLength = 40,
    this.stimulusLength = 20,
    this.packTitleLength = 80,
    this.categoryTitleLength = 60,
    this.descriptionLength = 200,
    this.exerciseNameLength = 60,
    this.exerciseNameLocales = 8,
  });

  /// Размер файла в байтах UTF-8; проверяется до разбора.
  final int maxBytes;

  /// Глубина вложенности JSON (корень = 1); проверяется до разбора.
  final int maxDepth;

  /// Задач в одном паке.
  final int maxTasks;

  /// Упражнений в одном паке.
  final int maxExercises;

  /// Категорий в одном паке.
  final int maxCategories;

  /// Записей в каждом массиве экспорта событий.
  final int maxEventRecords;

  /// Паков на пользователя (`imported` + `user`). Проверяется при установке,
  /// не валидатором документа; значение лежит здесь ради единого места.
  final int maxPacksPerUser;

  /// Задач на пользователя суммарно (при установке).
  final int maxTasksPerUser;

  final int promptLength;
  final int revealLength;
  final int memorizeLength;
  final int questionLength;

  /// `answer` (строка) и элемент `accept`.
  final int answerLength;
  final int optionLength;
  final int orderingItemLength;
  final int selfCheckLength;
  final int cueTextLength;
  final int objectLabelLength;

  /// Элемент `stimuli` и `targets`.
  final int stimulusLength;
  final int packTitleLength;
  final int categoryTitleLength;
  final int descriptionLength;

  /// Название упражнения на одну локаль.
  final int exerciseNameLength;

  /// Локалей в `name` упражнения.
  final int exerciseNameLocales;
}
