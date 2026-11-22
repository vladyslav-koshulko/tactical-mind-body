import 'package:flutter/foundation.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart' show TmbEffort;

/// Состояние экрана сессии, как его видит UI.
@immutable
sealed class SessionState {
  const SessionState();
}

/// Сессия идёт (или ждёт оценки последнего круга перед итогами).
final class SessionRunning extends SessionState {
  const SessionRunning({
    required this.engine,
    required this.plan,
    required this.ratingOpen,
    required this.rating,
    required this.outcome,
    required this.awaitingFinish,
  });

  /// Снимок движка на момент последнего вызова.
  final EngineState engine;
  final SessionPlan plan;

  /// Окно оценки прошлого круга открыто (`rateRound` сейчас допустим).
  final bool ratingOpen;

  /// Уже выбранная оценка этого окна.
  final TmbEffort? rating;

  /// Итог только что завершённой задачи; `null`, когда показывать нечего
  /// (нет итога или он «устарел», см. `kOutcomeVisibleMs`).
  final TaskOutcome? outcome;

  /// Движок завершил все блоки, но последний круг ещё не оценён: показываем
  /// экран оценки, итоги — по кнопке.
  final bool awaitingFinish;
}

/// Сессия закончена и записана: экран уводит на итоги.
final class SessionEnded extends SessionState {
  const SessionEnded({required this.sessionId, required this.aborted});

  final String sessionId;

  /// Прервана «Эвакуацией» (`Session.endedAt` остаётся `null`).
  final bool aborted;
}
