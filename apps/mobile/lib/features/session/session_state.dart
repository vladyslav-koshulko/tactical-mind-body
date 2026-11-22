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
    this.isPaused = false,
    this.hold,
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

  /// Приложение уходило в фон (или экран гас): время остановлено, экран
  /// закрыт заглушкой до «Продолжить». Пауза не пишется в события.
  final bool isPaused;

  /// Когнитивное окно закрыто досрочно (задачи кончились), но срок не вышел:
  /// держим паузу до срока (ARCHITECTURE D15). Пока не `null`, экран показывает
  /// остаток паузы вместо снимка движка (тот уже в следующем блоке).
  final SessionHold? hold;
}

/// Остаток когнитивного окна после последней задачи.
@immutable
final class SessionHold {
  const SessionHold({required this.remainingMs, required this.totalMs});

  final int remainingMs;

  /// Полная длина окна (`CognitiveBlock.durationSec`), мс.
  final int totalMs;
}

/// Сессия закончена и записана: экран уводит на итоги.
final class SessionEnded extends SessionState {
  const SessionEnded({required this.sessionId, required this.aborted});

  final String sessionId;

  /// Прервана «Эвакуацией» (`Session.endedAt` остаётся `null`).
  final bool aborted;
}
