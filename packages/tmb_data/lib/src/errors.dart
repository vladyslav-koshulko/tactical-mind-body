/// Ошибки слоя данных. Ошибки SQLite (нарушение CHECK/FK/PK) наружу не
/// оборачиваются: транзакция уже откатилась, вызывающему важен сам факт.
library;

/// База данных создана более новой версией схемы, чем знает приложение.
final class DatabaseDowngradeException implements Exception {
  const DatabaseDowngradeException({required this.from, required this.to});

  /// Версия схемы в файле БД.
  final int from;

  /// Версия схемы, которую понимает это приложение.
  final int to;

  @override
  String toString() =>
      'DatabaseDowngradeException: БД версии $from новее приложения '
      '(поддерживается $to) — обновите приложение.';
}

/// Запись события противоречит другим записям пакета (чужая `sessionId`).
final class InconsistentEventsException implements Exception {
  const InconsistentEventsException(this.message);

  final String message;

  @override
  String toString() => 'InconsistentEventsException: $message';
}

/// Изменение отключило бы все категории установленных паков
/// (SCHEMAS §6.4, `PROF_EMPTY_POOL`): запись отклонена.
final class EmptyPoolException implements Exception {
  const EmptyPoolException();

  @override
  String toString() =>
      'EmptyPoolException: пул задач не бывает пустым (PROF_EMPTY_POOL).';
}

/// Пак с таким `pack` уже установлен, а замена не запрошена.
final class PackAlreadyInstalledException implements Exception {
  const PackAlreadyInstalledException(this.packId);

  final String packId;

  @override
  String toString() => 'PackAlreadyInstalledException: пак «$packId» уже есть.';
}
