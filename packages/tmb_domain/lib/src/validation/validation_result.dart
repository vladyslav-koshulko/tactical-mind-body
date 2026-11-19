import '../content/cognitive_task.dart';
import '../content/task_category.dart';
import '../content/task_pack.dart';
import '../events/events_export.dart';
import '../exercises/exercise.dart';
import '../exercises/exercise_pack.dart';
import '../profile/profile_settings.dart';
import 'severity.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_issue.dart';

/// Элемент документа (задача, упражнение, категория, запись события),
/// исключённый из-за ошибки (SCHEMAS §9, решение 13).
final class ExcludedElement {
  const ExcludedElement({
    required this.path,
    required this.index,
    required this.codes,
    this.id,
  });

  /// Путь элемента: `items[3]`.
  final String path;
  final int index;

  /// Идентификатор элемента, если он прочитался (`id` или `domain`).
  final String? id;

  /// Коды ошибок, из-за которых элемент исключён.
  final List<ValidationCode> codes;
}

/// Итог проверки документа.
///
/// Если [isDocumentRejected], принятых элементов и моделей нет. Иначе в
/// соответствующем виду документа лежат модели, собранные из принятых элементов
/// существующими `fromJson`.
final class ValidationResult {
  ValidationResult({
    required this.kind,
    required Iterable<ValidationIssue> issues,
    required this.isDocumentRejected,
    Iterable<ExcludedElement> excluded = const [],
    Iterable<CognitiveTask> acceptedTasks = const [],
    Iterable<TaskCategory> acceptedCategories = const [],
    Iterable<Exercise> acceptedExercises = const [],
    Map<String, String> payloadHashes = const {},
    this.taskPack,
    this.exercisePack,
    this.eventsExport,
    this.profile,
  }) : issues = List.unmodifiable(issues),
       excluded = List.unmodifiable(excluded),
       acceptedTasks = List.unmodifiable(acceptedTasks),
       acceptedCategories = List.unmodifiable(acceptedCategories),
       acceptedExercises = List.unmodifiable(acceptedExercises),
       payloadHashes = Map.unmodifiable(payloadHashes);

  final DocumentKind kind;
  final List<ValidationIssue> issues;

  /// Файл отвергнут целиком (ошибка уровня документа).
  final bool isDocumentRejected;

  /// Исключённые элементы: у каждого есть хотя бы одна ошибка.
  final List<ExcludedElement> excluded;

  /// Принятые задачи (пак задач), в порядке файла.
  final List<CognitiveTask> acceptedTasks;
  final List<TaskCategory> acceptedCategories;

  /// Принятые упражнения (пак упражнений).
  final List<Exercise> acceptedExercises;

  /// `id` принятой задачи → `payloadHash`. Дедупликация между паками при
  /// импорте (D5) идёт по нему; внутри одного пака совпадение хеша означает
  /// совпадение `prompt`, то есть уже `PACK_DUP_PROMPT`.
  final Map<String, String> payloadHashes;

  final TaskPack? taskPack;
  final ExercisePack? exercisePack;
  final EventsExport? eventsExport;
  final ProfileSettings? profile;

  Iterable<ValidationIssue> get errors =>
      issues.where((i) => i.severity == Severity.error);

  Iterable<ValidationIssue> get warnings =>
      issues.where((i) => i.severity == Severity.warning);

  int get errorCount => errors.length;
  int get warningCount => warnings.length;

  /// Ни ошибок, ни предупреждений (строгий режим встроенных паков).
  bool get isClean => issues.isEmpty;

  /// Есть ли замечание с таким кодом.
  bool has(ValidationCode code) => issues.any((i) => i.code == code);
}
