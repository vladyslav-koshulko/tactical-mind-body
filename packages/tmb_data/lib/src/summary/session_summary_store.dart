import 'package:tmb_domain/tmb_domain.dart';

import '../models/session_bundle.dart';

/// Общее хранилище последней сводки сессии — то, откуда позже прочитает
/// нативный виджет домашнего экрана (ARCHITECTURE «Сводка сессии для виджета»).
///
/// Хранится одна сводка — последней сессии. История живёт в БД; здесь только
/// «витрина». Реализация обязана быть дешёвой и не бросать на битых данных
/// ([read] возвращает `null`).
abstract interface class SessionSummaryStore {
  /// Перезаписывает сводку.
  Future<void> write(SessionSummarySnapshot snapshot);

  /// Последняя сводка; `null` — записи нет или она нечитаема (битый JSON,
  /// версия новее известной).
  Future<SessionSummarySnapshot?> read();

  /// Стирает сводку (например, при удалении той сессии, на которую она
  /// указывает).
  Future<void> clear();
}

/// Хранилище в памяти: для тестов и окружений без платформенного хранилища.
final class InMemorySessionSummaryStore implements SessionSummaryStore {
  SessionSummarySnapshot? _value;

  @override
  Future<void> write(SessionSummarySnapshot snapshot) async =>
      _value = snapshot;

  @override
  Future<SessionSummarySnapshot?> read() async => _value;

  @override
  Future<void> clear() async => _value = null;
}

/// Строит сводку по [bundle] и пишет её в [store]; возвращает записанное.
///
/// Это и есть точка вызова «сессия зафиксирована»: для завершённой её вызывает
/// `SummaryRecordingSessionRepository.finishSession`, для прерванной — тот, кто
/// знает об уходе из сессии (контроллер). Повторный вызов безвреден: запись
/// перезаписывает одно и то же значение.
Future<SessionSummarySnapshot> recordSessionSummary(
  SessionSummaryStore store,
  SessionBundle bundle,
) async {
  final snapshot = SessionSummarySnapshot.fromEvents(
    session: bundle.session,
    rounds: bundle.rounds,
    sets: bundle.sets,
    attempts: bundle.attempts,
  );
  await store.write(snapshot);
  return snapshot;
}
