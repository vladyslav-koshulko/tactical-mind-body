import 'package:tmb_domain/tmb_domain.dart';

import '../models/session_bundle.dart';
import '../summary/session_summary_store.dart';
import 'session_repository.dart';

/// Обёртка над [SessionRepository]: после `finishSession` пишет сводку сессии
/// в [SessionSummaryStore], после `deleteSession` стирает её, если она
/// указывала на удалённую сессию.
///
/// Так контроллер сессии не знает о виджете: он и так зовёт `finishSession` при
/// завершении. Запись в хранилище идёт **в фоне** и не задерживает вызывающего:
/// платформенное хранилище (канал плагина) может отвечать долго или не
/// отвечать вовсе (виджет-тесты), а экран итогов ждать его не должен. Сбой
/// записи **не** ломает основную запись: БД — источник правды, сводка —
/// производная витрина; ошибка уходит в `onError`. Дождаться фона можно через
/// [settle] (тесты).
///
/// Прерванную сессию (`endedAt == null`) `finishSession` не фиксирует —
/// для неё вызывают `recordSessionSummary` напрямую.
final class SummaryRecordingSessionRepository implements SessionRepository {
  SummaryRecordingSessionRepository(this._inner, this._store, {this.onError});

  final SessionRepository _inner;
  final SessionSummaryStore _store;

  /// Куда уходят сбои фоновой записи сводки.
  final void Function(Object error, StackTrace stack)? onError;

  final _pending = <Future<void>>{};

  /// Завершается, когда закончились все фоновые записи сводки.
  Future<void> settle() async {
    while (_pending.isNotEmpty) {
      await Future.wait(_pending.toList());
    }
  }

  void _background(Future<void> Function() work) {
    late final Future<void> task;
    task = () async {
      try {
        await work();
      } catch (error, stack) {
        onError?.call(error, stack);
      }
    }().whenComplete(() => _pending.remove(task));
    _pending.add(task);
  }

  @override
  Future<bool> finishSession(String sessionId, {required int endedAt}) async {
    final found = await _inner.finishSession(sessionId, endedAt: endedAt);
    if (found) {
      // Чтение из БД — здесь же (быстрое и в той же очереди, что запись
      // событий), в фон уходит только обращение к хранилищу.
      SessionBundle? bundle;
      try {
        bundle = await _inner.loadSession(sessionId);
      } catch (error, stack) {
        onError?.call(error, stack);
      }
      if (bundle != null) {
        final b = bundle;
        _background(() => recordSessionSummary(_store, b));
      }
    }
    return found;
  }

  @override
  Future<bool> deleteSession(String sessionId) async {
    final found = await _inner.deleteSession(sessionId);
    if (found) {
      _background(() async {
        if ((await _store.read())?.sessionId == sessionId) {
          await _store.clear();
        }
      });
    }
    return found;
  }

  @override
  Future<void> saveSession(SessionBundle bundle) => _inner.saveSession(bundle);

  @override
  Future<void> appendEvents(
    String sessionId, {
    Iterable<RoundLog> rounds = const [],
    Iterable<ExerciseSet> sets = const [],
    Iterable<TaskAttempt> attempts = const [],
  }) => _inner.appendEvents(
    sessionId,
    rounds: rounds,
    sets: sets,
    attempts: attempts,
  );

  @override
  Future<List<Session>> listSessions({int limit = 50, int offset = 0}) =>
      _inner.listSessions(limit: limit, offset: offset);

  @override
  Stream<List<Session>> watchSessions({int limit = 50}) =>
      _inner.watchSessions(limit: limit);

  @override
  Future<Session?> getSession(String sessionId) => _inner.getSession(sessionId);

  @override
  Future<List<RoundLog>> roundsOf(String sessionId) =>
      _inner.roundsOf(sessionId);

  @override
  Future<List<ExerciseSet>> setsOf(String sessionId) =>
      _inner.setsOf(sessionId);

  @override
  Future<List<TaskAttempt>> attemptsOf(String sessionId) =>
      _inner.attemptsOf(sessionId);

  @override
  Future<SessionBundle?> loadSession(String sessionId) =>
      _inner.loadSession(sessionId);

  @override
  Future<List<ExerciseSet>> recentSets(String exerciseId, {int limit = 10}) =>
      _inner.recentSets(exerciseId, limit: limit);

  @override
  Future<EventsExport> exportEvents() => _inner.exportEvents();
}
