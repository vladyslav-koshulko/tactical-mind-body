/// Почему план сессии не удалось построить.
enum PlanningFailure {
  /// В шаблоне нет ни одного блока.
  emptyTemplate,

  /// У блока недопустимая длительность (< 1 с).
  invalidBlock,

  /// Нет упражнений, подходящих по месту и инвентарю.
  noExercises,

  /// Пул когнитивных задач пуст: нет паков, подходящих по уровню, либо все
  /// категории отключены в профиле, либо остались только архетипы, которые
  /// движок не умеет проводить.
  emptyTaskPool,
}

/// Понятная ошибка построения плана (а не `StateError` из глубины провайдера).
final class PlanningException implements Exception {
  const PlanningException(this.reason, this.message);

  final PlanningFailure reason;

  /// Текст для разработчика/лога; UI показывает свой по [reason] (инвариант 9).
  final String message;

  @override
  String toString() => 'PlanningException(${reason.name}): $message';
}
