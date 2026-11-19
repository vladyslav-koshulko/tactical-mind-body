import 'package:tmb_domain/tmb_domain.dart';

import '../models/session_bundle.dart';

/// История тренировок: сырые события (инвариант 2) и их чтение.
///
/// Клиент пишет только события; счёт и Индекс считает сервер (инвариант 8).
abstract interface class SessionRepository {
  /// Сохраняет сессию вместе со всеми событиями **одной транзакцией**: при
  /// любой ошибке не сохраняется ничего. `session.endedAt == null` допустим —
  /// так сохраняется прерванная сессия.
  ///
  /// Бросает [InconsistentEventsException] (событие ссылается на другую
  /// сессию) и ошибки SQLite при дубле `id`, битом `roundId` и нарушении
  /// CHECK; в любом случае транзакция откатывается.
  Future<void> saveSession(SessionBundle bundle);

  /// Дописывает события в уже существующую сессию (запись по ходу тренировки,
  /// чтобы убитое приложение не теряло попытки). Одной транзакцией.
  Future<void> appendEvents(
    String sessionId, {
    Iterable<RoundLog> rounds = const [],
    Iterable<ExerciseSet> sets = const [],
    Iterable<TaskAttempt> attempts = const [],
  });

  /// Проставляет `endedAt` прерванной сессии. `false` — сессии нет.
  Future<bool> finishSession(String sessionId, {required int endedAt});

  /// Удаляет сессию и все её события (каскадом). `false` — сессии нет.
  Future<bool> deleteSession(String sessionId);

  /// Сессии, новые первыми (`startedAt` по убыванию; при равенстве — по `id`).
  Future<List<Session>> listSessions({int limit = 50, int offset = 0});

  /// То же как поток: обновляется при любой записи в таблицу сессий.
  Stream<List<Session>> watchSessions({int limit = 50});

  Future<Session?> getSession(String sessionId);

  /// Круги сессии по возрастанию `roundIndex` (затем `blockIndex`).
  Future<List<RoundLog>> roundsOf(String sessionId);

  /// Подходы сессии: по `startedAt`, затем `setIndex`.
  Future<List<ExerciseSet>> setsOf(String sessionId);

  /// Попытки сессии: по `presentedAt`, затем `blockIndex`.
  Future<List<TaskAttempt>> attemptsOf(String sessionId);

  /// Сессия со всеми событиями, `null` — сессии нет.
  Future<SessionBundle?> loadSession(String sessionId);

  /// Последние [limit] подходов упражнения [exerciseId], новые первыми
  /// (`startedAt` по убыванию). Вход для прогрессии нагрузки (v0.2, D6).
  Future<List<ExerciseSet>> recentSets(String exerciseId, {int limit = 10});

  /// Все события пользователя одним документом `events_export` (SCHEMAS §3):
  /// сессии, круги, подходы и попытки по возрастанию времени. Без UI.
  Future<EventsExport> exportEvents();
}
