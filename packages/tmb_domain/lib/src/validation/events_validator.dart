import '../events/events_export.dart';
import '../events/exercise_set.dart';
import '../events/round_log.dart';
import '../events/session.dart';
import '../events/task_attempt.dart';
import 'checker.dart';
import 'issues.dart';
import 'pack_common.dart';
import 'schema_constants.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_result.dart';

const _rootKeys = {
  'schemaVersion',
  'kind',
  'sessions',
  'rounds',
  'sets',
  'attempts',
};

/// Проверяет экспорт событий (SCHEMAS §3, §6.1, §6.4).
///
/// Ошибка записи исключает запись; записи, ссылающиеся на исключённую,
/// становятся «сиротами» (`EVT_ORPHAN`) и исключаются следом.
ValidationResult validateEventsDocument(
  Map<String, Object?> root,
  ValidationContext ctx,
  Issues issues,
) {
  final limits = ctx.limits;
  final hdr = Issues();
  final h = Checker(hdr, limits);
  h.unknownFields(root, '', _rootKeys);

  List<Object?>? take(String key) {
    final raw = h.takeArray(root, '', key);
    if (raw != null && raw.length > limits.maxEventRecords) {
      h.add(
        ValidationCode.packLimitItems,
        key,
        'В «$key» не больше ${limits.maxEventRecords} записей '
        '(сейчас ${raw.length}).',
      );
      return null;
    }
    return raw;
  }

  final rawSessions = take('sessions');
  final rawRounds = take('rounds');
  final rawSets = take('sets');
  final rawAttempts = take('attempts');
  issues.addAll(hdr.list);
  if (hdr.hasErrors) {
    return ValidationResult(
      kind: DocumentKind.eventsExport,
      issues: issues.list,
      isDocumentRejected: true,
    );
  }

  final excluded = <ExcludedElement>[];

  /// Общий проход по массиву записей: [check] возвращает данные записи,
  /// [build] — модель; запись принимается, если нет ошибок.
  List<T> run<T, F>(
    String key,
    List<Object?> raw,
    F Function(Map<String, Object?> m, String at, Checker c, Set<String> seen)
    check,
    String? Function(F facts) idOf,
    T? Function(Map<String, Object?> m, String at, Issues local) build,
    void Function(F facts, T model) onAccept,
  ) {
    final out = <T>[];
    final seen = <String>{};
    for (var i = 0; i < raw.length; i++) {
      final at = joinIndex(key, i);
      final local = Issues();
      final c = Checker(local, limits);
      final m = c.object(raw[i], at);
      F? facts;
      T? model;
      if (m != null) {
        facts = check(m, at, c, seen);
        if (!local.hasErrors) model = build(m, at, local);
      }
      issues.addAll(local.list);
      if (model != null && facts != null && !local.hasErrors) {
        final id = idOf(facts);
        if (id != null) seen.add(id);
        onAccept(facts, model);
        out.add(model);
      } else {
        excluded.add(
          ExcludedElement(
            path: at,
            index: i,
            id: facts == null ? null : idOf(facts),
            codes: local.errorCodes,
          ),
        );
      }
    }
    return out;
  }

  // --- sessions ---
  final sessionIds = <String>{};
  final sessions = run<Session, _Facts>(
    'sessions',
    rawSessions!,
    _session,
    (f) => f.id,
    (m, at, local) => buildModel(() => Session.fromJson(m), at, local),
    (f, _) => sessionIds.add(f.id!),
  );

  bool sessionKnown(String id) =>
      sessionIds.contains(id) || (ctx.knownSessionIds?.contains(id) ?? false);

  // --- rounds ---
  final roundSession = <String, String>{};
  final rounds = run<RoundLog, _Facts>(
    'rounds',
    rawRounds!,
    (m, at, c, seen) => _round(m, at, c, seen, sessionKnown),
    (f) => f.id,
    (m, at, local) => buildModel(() => RoundLog.fromJson(m), at, local),
    (f, _) => roundSession[f.id!] = f.sessionId!,
  );

  // --- sets ---
  final sets = run<ExerciseSet, _Facts>(
    'sets',
    rawSets!,
    (m, at, c, seen) =>
        _set(m, at, c, seen, sessionKnown, (roundId, sessionId) {
          final owner = roundSession[roundId];
          if (owner != null) return owner == sessionId;
          return ctx.knownRoundIds?.contains(roundId) ?? false;
        }),
    (f) => f.id,
    (m, at, local) => buildModel(() => ExerciseSet.fromJson(m), at, local),
    (_, _) {},
  );

  // --- attempts ---
  final attempts = run<TaskAttempt, _Facts>(
    'attempts',
    rawAttempts!,
    (m, at, c, seen) => _attempt(m, at, c, seen, sessionKnown),
    (f) => f.id,
    (m, at, local) => buildModel(() => TaskAttempt.fromJson(m), at, local),
    (_, _) {},
  );

  final export = EventsExport(
    schemaVersion: root['schemaVersion']! as int,
    sessions: sessions,
    rounds: rounds,
    sets: sets,
    attempts: attempts,
  );
  return ValidationResult(
    kind: DocumentKind.eventsExport,
    issues: issues.list,
    isDocumentRejected: false,
    excluded: excluded,
    eventsExport: export,
  );
}

/// Что нужно знать о записи за пределами её самой.
final class _Facts {
  String? id;
  String? sessionId;
}

// --- примитивы ----------------------------------------------------------------

String? _uuid(Map<String, Object?> m, String at, Checker c, String key) =>
    c.takePattern(
      m,
      at,
      key,
      uuidPattern,
      ValidationCode.evtBadUuid,
      'Идентификатор «$key»',
    );

int? _time(Map<String, Object?> m, String at, Checker c, String key) {
  final v = c.take(m, at, key);
  return v == null ? null : _timeValue(v, at, c, key);
}

int? _timeValue(Object v, String at, Checker c, String key) => c.intIn(
  v,
  joinKey(at, key),
  min: 0,
  max: maxEventTimeMs,
  code: ValidationCode.evtBadTime,
  what: 'Время «$key» (мс эпохи UTC)',
);

int? _ranged(
  Map<String, Object?> m,
  String at,
  Checker c,
  String key,
  int min,
  int max,
) {
  final v = c.take(m, at, key);
  return v == null ? null : _rangedValue(v, at, c, key, min, max);
}

int? _rangedValue(
  Object v,
  String at,
  Checker c,
  String key,
  int min,
  int max,
) => c.intIn(
  v,
  joinKey(at, key),
  min: min,
  max: max,
  code: ValidationCode.evtRange,
  what: 'Поле «$key»',
);

String? _enum(
  Map<String, Object?> m,
  String at,
  Checker c,
  String key,
  List<String> allowed,
) => c.takeWire(m, at, key, allowed, ValidationCode.evtBadEnum, 'Поле «$key»');

/// Поле `null: да`: отсутствие — ошибка, `null` — допустимое значение.
/// Возвращает значение (в том числе `null`).
Object? _nullable(Map<String, Object?> m, String at, Checker c, String key) {
  if (!m.containsKey(key)) {
    c.add(
      ValidationCode.packMissingField,
      joinKey(at, key),
      'Обязательное поле «$key» отсутствует (допустим null).',
    );
    return null;
  }
  return m[key];
}

void _timeOrder(
  Checker c,
  String at,
  String laterKey,
  int? later,
  String earlierKey,
  int? earlier,
) {
  if (later != null && earlier != null && later < earlier) {
    c.add(
      ValidationCode.evtTimeOrder,
      joinKey(at, laterKey),
      '«$laterKey» раньше «$earlierKey».',
    );
  }
}

/// `id` с проверкой UUID и дубликата.
String? _recordId(
  Map<String, Object?> m,
  String at,
  Checker c,
  Set<String> seen,
) {
  final id = _uuid(m, at, c, 'id');
  if (id != null && seen.contains(id)) {
    c.add(
      ValidationCode.evtDupId,
      joinKey(at, 'id'),
      'Запись с id «$id» уже есть: остаётся первая.',
    );
  }
  return id;
}

/// `sessionId`: UUID и существование сессии.
String? _sessionRef(
  Map<String, Object?> m,
  String at,
  Checker c,
  bool Function(String) known,
) {
  final id = _uuid(m, at, c, 'sessionId');
  if (id != null && !known(id)) {
    c.add(
      ValidationCode.evtOrphan,
      joinKey(at, 'sessionId'),
      'Сессия «$id» не найдена среди принятых записей и в базе.',
    );
  }
  return id;
}

// --- записи -------------------------------------------------------------------

_Facts _session(
  Map<String, Object?> m,
  String at,
  Checker c,
  Set<String> seen,
) {
  c.unknownFields(m, at, const {
    'id',
    'startedAt',
    'endedAt',
    'utcOffsetMin',
    'location',
    'difficulty',
    'template',
    'appVersion',
  });
  final facts = _Facts()..id = _recordId(m, at, c, seen);
  final startedAt = _time(m, at, c, 'startedAt');
  final endedRaw = _nullable(m, at, c, 'endedAt');
  final endedAt = endedRaw == null
      ? null
      : _timeValue(endedRaw, at, c, 'endedAt');
  _ranged(m, at, c, 'utcOffsetMin', -720, 840);
  _enum(m, at, c, 'location', locationWires);
  _enum(m, at, c, 'difficulty', levelWires);
  _enum(m, at, c, 'template', templateWires);
  c.takeText(m, at, 'appVersion', max: 32);
  _timeOrder(c, at, 'endedAt', endedAt, 'startedAt', startedAt);
  return facts;
}

_Facts _round(
  Map<String, Object?> m,
  String at,
  Checker c,
  Set<String> seen,
  bool Function(String) sessionKnown,
) {
  c.unknownFields(m, at, const {
    'id',
    'sessionId',
    'blockIndex',
    'roundIndex',
    'durationMs',
    'rpe',
  });
  final facts = _Facts()
    ..id = _recordId(m, at, c, seen)
    ..sessionId = _sessionRef(m, at, c, sessionKnown);
  _ranged(m, at, c, 'blockIndex', 0, 1 << 31);
  _ranged(m, at, c, 'roundIndex', 0, 1 << 31);
  _ranged(m, at, c, 'durationMs', 0, 1 << 52);
  final rpe = _nullable(m, at, c, 'rpe');
  if (rpe != null) _rangedValue(rpe, at, c, 'rpe', 1, 3);
  return facts;
}

_Facts _set(
  Map<String, Object?> m,
  String at,
  Checker c,
  Set<String> seen,
  bool Function(String) sessionKnown,
  bool Function(String roundId, String sessionId) roundBelongs,
) {
  c.unknownFields(m, at, const {
    'id',
    'sessionId',
    'roundId',
    'setIndex',
    'exerciseId',
    'unit',
    'prescribed',
    'done',
    'startedAt',
    'endedAt',
  });
  final facts = _Facts()
    ..id = _recordId(m, at, c, seen)
    ..sessionId = _sessionRef(m, at, c, sessionKnown);
  final roundId = _uuid(m, at, c, 'roundId');
  if (roundId != null &&
      facts.sessionId != null &&
      !roundBelongs(roundId, facts.sessionId!)) {
    c.add(
      ValidationCode.evtOrphan,
      joinKey(at, 'roundId'),
      'Круг «$roundId» не найден среди принятых записей этой сессии и в базе.',
    );
  }
  _ranged(m, at, c, 'setIndex', 0, 1 << 31);
  c.takePattern(
    m,
    at,
    'exerciseId',
    exerciseIdPattern,
    ValidationCode.packBadId,
    'Идентификатор упражнения',
  );
  _enum(m, at, c, 'unit', unitWires);
  _ranged(m, at, c, 'prescribed', 1, 3600);
  _ranged(m, at, c, 'done', 0, 3600);
  final startedAt = _time(m, at, c, 'startedAt');
  final endedAt = _time(m, at, c, 'endedAt');
  _timeOrder(c, at, 'endedAt', endedAt, 'startedAt', startedAt);
  return facts;
}

_Facts _attempt(
  Map<String, Object?> m,
  String at,
  Checker c,
  Set<String> seen,
  bool Function(String) sessionKnown,
) {
  c.unknownFields(m, at, const {
    'id',
    'sessionId',
    'blockIndex',
    'roundIndex',
    'taskId',
    'packId',
    'packSource',
    'archetype',
    'domain',
    'difficulty',
    'seed',
    'status',
    'presentedAt',
    'answeredAt',
    'latencyMs',
    'isCorrect',
    'selfRating',
    'response',
    'encodedRoundIndex',
    'payloadHash',
  });
  final facts = _Facts()
    ..id = _recordId(m, at, c, seen)
    ..sessionId = _sessionRef(m, at, c, sessionKnown);
  _ranged(m, at, c, 'blockIndex', 0, 1 << 31);
  final roundIndex = _ranged(m, at, c, 'roundIndex', 0, 1 << 31);
  c.takeText(m, at, 'taskId', max: 64, checkMarkup: false);
  c.takeText(m, at, 'packId', max: 64, checkMarkup: false);
  _enum(m, at, c, 'packSource', packSourceWires);
  final archetype = _enum(m, at, c, 'archetype', archetypeWires);
  c.takePattern(
    m,
    at,
    'domain',
    domainPattern,
    ValidationCode.packBadDomain,
    'Домен',
  );
  final diff = c.take(m, at, 'difficulty');
  if (diff != null) {
    final n = c.number(diff, joinKey(at, 'difficulty'));
    if (n != null && (n < 0 || n > 1)) {
      c.add(
        ValidationCode.evtRange,
        joinKey(at, 'difficulty'),
        'Сложность «difficulty» должна быть от 0 до 1.',
      );
    }
  }
  _ranged(m, at, c, 'seed', 0, maxSeed);
  final status = _enum(m, at, c, 'status', attemptStatusWires);
  final presentedAt = _time(m, at, c, 'presentedAt');

  final answeredRaw = _nullable(m, at, c, 'answeredAt');
  final answeredAt = answeredRaw == null
      ? null
      : _timeValue(answeredRaw, at, c, 'answeredAt');
  final latencyRaw = _nullable(m, at, c, 'latencyMs');
  final latencyMs = latencyRaw == null
      ? null
      : _rangedValue(latencyRaw, at, c, 'latencyMs', 0, 1 << 52);

  final correctRaw = _nullable(m, at, c, 'isCorrect');
  if (correctRaw != null) c.boolean(correctRaw, joinKey(at, 'isCorrect'));

  int? selfRating;
  final ratingRaw = _nullable(m, at, c, 'selfRating');
  if (ratingRaw != null) {
    selfRating = _rangedValue(ratingRaw, at, c, 'selfRating', 0, 3);
  }

  String? response;
  final responseRaw = _nullable(m, at, c, 'response');
  if (responseRaw != null) {
    // Ответ пользователя: длина и символы, но не разметка — он может ввести что угодно.
    response = c.text(
      responseRaw,
      joinKey(at, 'response'),
      max: 200,
      checkMarkup: false,
    );
  }

  int? encoded;
  final encodedRaw = _nullable(m, at, c, 'encodedRoundIndex');
  if (encodedRaw != null) {
    encoded = _rangedValue(encodedRaw, at, c, 'encodedRoundIndex', 0, 1 << 31);
  }

  c.takePattern(
    m,
    at,
    'payloadHash',
    hashPattern,
    ValidationCode.evtBadHash,
    'Хеш «payloadHash»',
  );

  // Межполевые правила — только если сами поля прочитались.
  if (c.issues.hasErrors) return facts;
  _timeOrder(c, at, 'answeredAt', answeredAt, 'presentedAt', presentedAt);
  final verbal = archetype == 'verbal';

  if (m['isCorrect'] == null && !verbal) {
    c.add(
      ValidationCode.evtVerifiableMismatch,
      joinKey(at, 'isCorrect'),
      'У проверяемой задачи «isCorrect» не может быть null.',
    );
  } else if (m['isCorrect'] != null && verbal) {
    c.add(
      ValidationCode.evtVerifiableMismatch,
      joinKey(at, 'isCorrect'),
      'У задачи verbal «isCorrect» всегда null: машина её не проверяет.',
    );
  }
  if (selfRating != null && (!verbal || status != 'answered')) {
    c.add(
      ValidationCode.evtVerifiableMismatch,
      joinKey(at, 'selfRating'),
      '«selfRating» допустим только у verbal со статусом answered.',
    );
  }
  if (status == 'answered') {
    if (answeredAt == null || latencyMs == null) {
      c.add(
        ValidationCode.evtStatusMismatch,
        joinKey(at, 'answeredAt'),
        'При статусе answered «answeredAt» и «latencyMs» обязательны.',
      );
    }
  } else {
    if (answeredAt != null || latencyMs != null) {
      c.add(
        ValidationCode.evtStatusMismatch,
        joinKey(at, 'answeredAt'),
        'При статусе $status «answeredAt» и «latencyMs» должны быть null.',
      );
    }
    if (response != null) {
      c.add(
        ValidationCode.evtStatusMismatch,
        joinKey(at, 'response'),
        'При статусе $status «response» должен быть null.',
      );
    }
  }
  if (encoded != null &&
      (archetype != 'delayed_recall' ||
          (roundIndex != null && encoded > roundIndex))) {
    c.add(
      ValidationCode.evtEncodedRound,
      joinKey(at, 'encodedRoundIndex'),
      '«encodedRoundIndex» допустим только у delayed_recall и не больше '
      '«roundIndex».',
    );
  }
  if (answeredAt != null && presentedAt != null && latencyMs != null) {
    final delta = latencyMs - (answeredAt - presentedAt);
    if (delta.abs() > 1000) {
      c.add(
        ValidationCode.evtLatencyMismatch,
        joinKey(at, 'latencyMs'),
        '«latencyMs» отличается от answeredAt − presentedAt больше чем на 1000 мс.',
      );
    }
  }
  return facts;
}
