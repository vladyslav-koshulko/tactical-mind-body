import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Не даёт экрану гаснуть, пока идёт сессия. Вынесено в провайдер, потому что
/// `wakelock_plus` ходит в платформенный канал, которого нет в тестах.
abstract interface class SessionWakelock {
  Future<void> enable();
  Future<void> disable();
}

final class _PlatformWakelock implements SessionWakelock {
  const _PlatformWakelock();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

final sessionWakelockProvider = Provider<SessionWakelock>(
  (ref) => const _PlatformWakelock(),
);

/// Вибро — нецветовой канал смены фазы (инвариант 6). Звук — позже.
///
/// Любая ошибка платформы проглатывается: вибро — подсказка, а не условие
/// работы сессии (на устройстве без мотора канал просто ничего не делает).
final class SessionHaptics {
  const SessionHaptics();

  /// Смена фазы (физика ↔ пауза ↔ отдых): самый сильный отклик.
  Future<void> phaseChanged() => _safe(HapticFeedback.heavyImpact);

  /// Появилась подсказка `cues` посреди задачи.
  Future<void> cueAppeared() => _safe(HapticFeedback.mediumImpact);

  static Future<void> _safe(Future<void> Function() call) async {
    try {
      await call();
    } catch (_) {
      // см. комментарий к классу
    }
  }
}

final sessionHapticsProvider = Provider<SessionHaptics>(
  (ref) => const SessionHaptics(),
);

/// Верхняя граница сида плана: `2^53 − 1` (SCHEMAS §3.4).
const _seedHighBits = 1 << 21;
const _seedLowBits = 1 << 32;

/// Криптослучайный сид сессии `0 … 2^53 − 1`. Домену `Random` запрещён
/// (инвариант 4), поэтому сид рождается здесь, в приложении.
int generateSessionSeed(Random random) =>
    random.nextInt(_seedHighBits) * _seedLowBits + random.nextInt(_seedLowBits);

/// Источник сидов сессии. В тестах подменяется на фиксированный.
final sessionSeedProvider = Provider<int Function()>((ref) {
  final random = Random.secure();
  return () => generateSessionSeed(random);
});
