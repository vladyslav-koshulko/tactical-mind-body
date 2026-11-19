import '../common/enums.dart';
import 'import_limits.dart';

/// Вид проверяемого документа.
enum DocumentKind {
  taskPack('task_pack'),
  exercisePack('exercise_pack'),
  eventsExport('events_export'),

  /// Фрагмент профиля (SCHEMAS §4): поля `kind` в нём нет.
  profile(null);

  const DocumentKind(this.wire);

  /// Значение поля `kind` в файле; у профиля — `null`.
  final String? wire;
}

/// Диапазон поддерживаемых `schemaVersion` (SCHEMAS §5).
///
/// Цепочек миграции пока нет: версия внутри диапазона читается по текущим
/// правилам как есть.
final class SupportedVersions {
  const SupportedVersions({required this.min, required this.max});

  /// Только версия 1.
  static const v1 = SupportedVersions(min: 1, max: 1);

  final int min;
  final int max;

  bool contains(int version) => version >= min && version <= max;
}

/// Контекст проверки (SCHEMAS §8): что ожидаем и по каким лимитам.
///
/// Необязательные поля включают правила, которым нужны сведения извне
/// документа (каталог, установленные паки, БД). Если поле не задано, правило
/// не применяется — валидатор остаётся чистой функцией от байтов и контекста.
final class ValidationContext {
  const ValidationContext({
    required this.expectedKind,
    this.directoryLocale,
    this.supportedVersions = SupportedVersions.v1,
    this.limits = const ImportLimits(),
    this.assignedPackSource,
    this.knownExerciseIds,
    this.installedTaskDomains,
    this.knownSessionIds,
    this.knownRoundIds,
  });

  final DocumentKind expectedKind;

  /// Локаль каталога `assets/content/<locale>/`; для встроенных паков задач.
  final String? directoryLocale;
  final SupportedVersions supportedVersions;
  final ImportLimits limits;

  /// `packSource`, который присвоил читатель (решение 10). Если файл заявил
  /// другое — `PACK_SOURCE_OVERRIDDEN`, а в результате используется присвоенное.
  final PackSource? assignedPackSource;

  /// Идентификаторы упражнений установленных паков (`PROF_UNKNOWN_EXERCISE`).
  final Set<String>? knownExerciseIds;

  /// `domain` всех задач установленных паков (`PROF_EMPTY_POOL`).
  final Set<String>? installedTaskDomains;

  /// Сессии/круги, уже лежащие в БД (для `EVT_ORPHAN` у частичных экспортов).
  final Set<String>? knownSessionIds;
  final Set<String>? knownRoundIds;
}
