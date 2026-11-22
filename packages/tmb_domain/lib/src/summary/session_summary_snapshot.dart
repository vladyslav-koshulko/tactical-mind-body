import '../common/json_reader.dart';
import '../common/wire_enum.dart';
import '../events/attempt_status.dart';
import '../events/exercise_set.dart';
import '../events/round_log.dart';
import '../events/session.dart';
import '../events/task_attempt.dart';

/// Чем закончилась сессия с точки зрения сводки.
enum SessionSummaryStatus implements WireEnum {
  /// `Session.endedAt` записан — сессию довели до конца.
  completed('completed'),

  /// `endedAt == null` — прервана (эвакуация, уход, убитое приложение).
  aborted('aborted');

  const SessionSummaryStatus(this.wire);
  @override
  final String wire;
}

/// Компактная сводка последней сессии для общего хранилища — то, что позже
/// прочитает нативный виджет домашнего экрана (ARCHITECTURE «Сводка сессии
/// для виджета»).
///
/// Это **не** Индекс и не счёт (инвариант 8): клиент их не считает и не
/// отправляет. Здесь только отображаемые числа по сырым событиям.
///
/// `verbal` в сводку не попадает вовсе (инвариант 7): машина его не проверяет,
/// поэтому ни `verifiableAttempts`, ни `accuracy`, ни `averageLatencyMs` его не
/// учитывают. Самооценка `verbal` остаётся на экране итогов.
///
/// Формат версионирован ([schemaVersion]): нативный читатель обязан
/// игнорировать неизвестные поля и отвергать версию выше известной.
final class SessionSummarySnapshot {
  const SessionSummarySnapshot({
    this.schemaVersion = currentSchemaVersion,
    required this.sessionId,
    required this.startedAt,
    required this.utcOffsetMin,
    required this.durationMs,
    required this.status,
    required this.rounds,
    required this.setsTotal,
    required this.setsDone,
    required this.verifiableAttempts,
    required this.correct,
    required this.averageLatencyMs,
  });

  /// Сводка по событиям одной сессии. [rounds], [sets], [attempts] — те же
  /// сырые события, что лежат в БД; чужие `sessionId` не фильтруются (это
  /// забота репозитория, см. `InconsistentEventsException`).
  factory SessionSummarySnapshot.fromEvents({
    required Session session,
    Iterable<RoundLog> rounds = const [],
    Iterable<ExerciseSet> sets = const [],
    Iterable<TaskAttempt> attempts = const [],
  }) {
    final setList = List<ExerciseSet>.of(sets);
    final attemptList = List<TaskAttempt>.of(attempts);
    final tally = VerifiableTally.of(attemptList);
    return SessionSummarySnapshot(
      sessionId: session.id,
      startedAt: session.startedAt,
      utcOffsetMin: session.utcOffsetMin,
      durationMs: sessionDurationMs(
        session,
        sets: setList,
        attempts: attemptList,
      ),
      status: session.endedAt != null
          ? SessionSummaryStatus.completed
          : SessionSummaryStatus.aborted,
      rounds: rounds.length,
      setsTotal: setList.length,
      setsDone: setList.where((s) => s.done > 0).length,
      verifiableAttempts: tally.total,
      correct: tally.correct,
      averageLatencyMs: tally.averageLatencyMs,
    );
  }

  factory SessionSummarySnapshot.fromJson(Map<String, Object?> json) {
    final o = readRoot(json);
    expectKind(o, kind);
    final version = o.integer('schemaVersion');
    if (version < 1 || version > currentSchemaVersion) {
      throw FormatException(
        '${o.pathOf('schemaVersion')}: версия $version не поддерживается '
        '(известна до $currentSchemaVersion)',
      );
    }
    return SessionSummarySnapshot(
      schemaVersion: version,
      sessionId: o.string('sessionId'),
      startedAt: o.integer('startedAt'),
      utcOffsetMin: o.integer('utcOffsetMin'),
      durationMs: o.integer('durationMs'),
      status: o.enumValue('status', SessionSummaryStatus.values),
      rounds: o.integer('rounds'),
      setsTotal: o.integer('setsTotal'),
      setsDone: o.integer('setsDone'),
      verifiableAttempts: o.integer('verifiableAttempts'),
      correct: o.integer('correct'),
      averageLatencyMs: o.integerN('averageLatencyMs'),
    );
  }

  /// Значение поля `kind`.
  static const kind = 'session_summary';

  /// Версия формата, которую пишет этот код.
  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final String sessionId;

  /// Мс эпохи UTC.
  final int startedAt;

  /// Смещение пояса на момент старта, минуты (как `Session.utcOffsetMin`).
  final int utcOffsetMin;
  final int durationMs;
  final SessionSummaryStatus status;

  /// Закрытых кругов.
  final int rounds;
  final int setsTotal;

  /// Подходов, где сделано хоть что-то (`done > 0`).
  final int setsDone;

  /// Машинно-проверяемых попыток (все статусы, кроме `verbal`).
  final int verifiableAttempts;

  /// Из них верных ответов.
  final int correct;

  /// Средняя задержка ответа, мс; `null` — ответов не было.
  final int? averageLatencyMs;

  /// Доля верных среди проверяемых попыток (таймаут и пропуск — не верно),
  /// 0…1; `null` — проверяемых задач не было.
  double? get accuracy =>
      verifiableAttempts == 0 ? null : correct / verifiableAttempts;

  /// Локальная дата старта `YYYY-MM-DD` — по `startedAt` и `utcOffsetMin`,
  /// чтобы нативному читателю не приходилось считать пояса.
  String get localDate {
    final d = DateTime.fromMillisecondsSinceEpoch(
      startedAt + utcOffsetMin * 60000,
      isUtc: true,
    );
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
  }

  /// `accuracy` и `localDate` пишутся готовыми для нативного читателя; при
  /// чтении они игнорируются и пересчитываются из первичных полей.
  Map<String, Object?> toJson() => {
    'kind': kind,
    'schemaVersion': schemaVersion,
    'sessionId': sessionId,
    'startedAt': startedAt,
    'utcOffsetMin': utcOffsetMin,
    'localDate': localDate,
    'durationMs': durationMs,
    'status': status.wire,
    'rounds': rounds,
    'setsTotal': setsTotal,
    'setsDone': setsDone,
    'verifiableAttempts': verifiableAttempts,
    'correct': correct,
    'accuracy': accuracy,
    'averageLatencyMs': averageLatencyMs,
  };

  @override
  bool operator ==(Object other) =>
      other is SessionSummarySnapshot &&
      other.schemaVersion == schemaVersion &&
      other.sessionId == sessionId &&
      other.startedAt == startedAt &&
      other.utcOffsetMin == utcOffsetMin &&
      other.durationMs == durationMs &&
      other.status == status &&
      other.rounds == rounds &&
      other.setsTotal == setsTotal &&
      other.setsDone == setsDone &&
      other.verifiableAttempts == verifiableAttempts &&
      other.correct == correct &&
      other.averageLatencyMs == averageLatencyMs;

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    sessionId,
    startedAt,
    utcOffsetMin,
    durationMs,
    status,
    rounds,
    setsTotal,
    setsDone,
    verifiableAttempts,
    correct,
    averageLatencyMs,
  );

  @override
  String toString() => 'SessionSummarySnapshot(${toJson()})';
}

/// Подсчёт по машинно-проверяемым попыткам: `verbal` пропускается целиком
/// (инвариант 7). Общая логика для сводки и экрана итогов.
final class VerifiableTally {
  const VerifiableTally({
    required this.correct,
    required this.wrong,
    required this.timeouts,
    required this.skipped,
    required this.averageLatencyMs,
  });

  factory VerifiableTally.of(Iterable<TaskAttempt> attempts) {
    var correct = 0;
    var wrong = 0;
    var timeouts = 0;
    var skipped = 0;
    var latencySum = 0;
    var latencyCount = 0;
    for (final a in attempts) {
      if (!a.archetype.isMachineVerifiable) continue;
      switch (a.status) {
        case AttemptStatus.answered:
          if (a.isCorrect == true) {
            correct++;
          } else {
            wrong++;
          }
          final latency = a.latencyMs;
          if (latency != null) {
            latencySum += latency;
            latencyCount++;
          }
        case AttemptStatus.timeout:
          timeouts++;
        case AttemptStatus.skipped:
          skipped++;
      }
    }
    return VerifiableTally(
      correct: correct,
      wrong: wrong,
      timeouts: timeouts,
      skipped: skipped,
      averageLatencyMs: latencyCount == 0
          ? null
          : (latencySum / latencyCount).round(),
    );
  }

  final int correct;
  final int wrong;
  final int timeouts;
  final int skipped;

  /// Средняя задержка по отвеченным; `null`, если ответов нет.
  final int? averageLatencyMs;

  int get total => correct + wrong + timeouts + skipped;
}

/// Длительность сессии: у завершённой — `endedAt − startedAt`; у прерванной
/// `endedAt == null` (решение 32), конец восстанавливается по последнему
/// событию; нет событий — 0.
int sessionDurationMs(
  Session session, {
  Iterable<ExerciseSet> sets = const [],
  Iterable<TaskAttempt> attempts = const [],
}) {
  final ended = session.endedAt;
  if (ended != null) return ended - session.startedAt;
  var last = session.startedAt;
  for (final s in sets) {
    if (s.endedAt > last) last = s.endedAt;
  }
  for (final a in attempts) {
    final at = a.answeredAt ?? a.presentedAt;
    if (at > last) last = at;
  }
  return last - session.startedAt;
}
