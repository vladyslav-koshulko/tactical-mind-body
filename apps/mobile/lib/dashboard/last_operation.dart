import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmb_domain/tmb_domain.dart';

import '../data/providers.dart';

/// Последняя сессия из БД и то, что видно на дашборде без подсчёта счёта
/// (Индекс считает сервер — инвариант 8, поэтому здесь только сырые числа).
final class LastOperation {
  const LastOperation({
    required this.session,
    required this.roundCount,
    required this.taskCount,
  });

  final Session session;

  /// Записанных физических кругов.
  final int roundCount;

  /// Записанных когнитивных попыток.
  final int taskCount;

  /// Сессия доведена до конца (иначе — прервана, `endedAt == null`).
  bool get isFinished => session.endedAt != null;
}

/// Последняя операция; `null` — сессий ещё не было. Обновляется, когда
/// меняется таблица сессий (старт и завершение).
final lastOperationProvider = StreamProvider<LastOperation?>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessions(limit: 1).asyncMap((sessions) async {
    if (sessions.isEmpty) return null;
    final session = sessions.first;
    final rounds = await repo.roundsOf(session.id);
    final attempts = await repo.attemptsOf(session.id);
    return LastOperation(
      session: session,
      roundCount: rounds.length,
      taskCount: attempts.length,
    );
  });
});
