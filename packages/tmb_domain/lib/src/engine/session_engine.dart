import '../cognitive/self_rating.dart';
import '../cognitive/task_provider.dart';
import '../common/enums.dart';
import '../content/cognitive_task.dart';
import '../events/attempt_status.dart';
import '../events/events_export.dart';
import '../events/exercise_set.dart';
import '../events/round_log.dart';
import '../events/session.dart';
import '../events/task_attempt.dart';
import 'engine_state.dart';
import 'id_source.dart';
import 'session_plan.dart';

/// Верхняя граница времени события (SCHEMAS §0): 2100-01-01.
const int _maxTimeMs = 4102444800000;

/// Максимальная длина `TaskAttempt.response` (SCHEMAS §3.4).
const int _maxResponseLength = 200;

/// Машина состояний сессии по плану ([SessionPlan]).
///
/// **Время подаёт хост**: каждый вызов принимает `nowMs` — мс эпохи UTC.
/// Ни таймеров, ни `Future`/`Stream`, ни `DateTime.now()`. Время не должно
/// идти назад (`ArgumentError`). Хост зовёт [tick] по своему таймеру (раз в
/// 100–250 мс для обратного отсчёта) и сразу после пользовательских действий
/// передаёт `now` в соответствующий метод.
///
/// **Сроки истекают по `tick`, но датируются сроком, а не моментом вызова.**
/// Если хост проснулся через минуту (приложение было в фоне), [tick]
/// «догоняет»: проходит все блоки, истёкшие к `nowMs`, каждый со своими
/// временами. Поэтому запоздавший `tick` не искажает `endedAt`, `presentedAt`
/// и круг в логе. Любое действие пользователя тоже сначала применяет
/// истёкшие к `now` сроки, и только потом сработает само: ответ ровно в
/// момент срока — уже таймаут (срок включительно).
///
/// **События** (инвариант 2) накапливаются сырыми: `Session`, `RoundLog`,
/// `ExerciseSet`, `TaskAttempt`; агрегатов нет. [events] в любой момент даёт
/// согласованный документ (круг, в котором уже есть подходы, включён в него
/// предварительно), так что хост может сохранять после каждого вызова.
///
/// Правила, о которых стоит знать:
///  * физический блок кончается, когда пройдено каждое упражнение; упражнение
///    в секундах само завершается по сроку с `done == prescribed`;
///  * когнитивный блок кончается, когда разобраны все его задачи, либо по
///    сроку `durationSec`: задача, которую не успели, пишется как `timeout`;
///  * дедлайн во время показа (запоминание/сетка) попытки не пишет — вопрос
///    так и не был задан;
///  * `abort` не пишет незаконченное упражнение и задачу без ответа;
///    `Session.endedAt` остаётся `null`.
final class SessionEngine {
  SessionEngine({
    required this.plan,
    required this.ids,
    this.utcOffsetMin = 0,
    this.appVersion = '0.1.0',
  }) {
    if (plan.blocks.isEmpty) {
      throw ArgumentError.value(plan, 'plan', 'в плане нет блоков');
    }
    if (utcOffsetMin < -720 || utcOffsetMin > 840) {
      throw RangeError.range(utcOffsetMin, -720, 840, 'utcOffsetMin');
    }
    if (appVersion.isEmpty || appVersion.length > 32) {
      throw ArgumentError.value(appVersion, 'appVersion', 'длина 1…32');
    }
  }

  final SessionPlan plan;

  /// Смещение локального пояса на момент старта (`Session.utcOffsetMin`).
  final int utcOffsetMin;
  final String appVersion;

  /// Источник идентификаторов записей.
  final IdSource ids;

  EngineStatus _status = EngineStatus.idle;
  int _now = 0;
  String? _sessionId;
  int? _startedAt;
  int? _endedAt;

  int _blockIndex = -1;
  int _blockStart = 0;

  // Физика.
  String? _roundId;
  int _exIndex = 0;
  int _exStart = 0;
  final List<ExerciseSet> _roundSets = [];

  // Когниция.
  int _taskIndex = 0;
  TaskStage _stage = TaskStage.answer;
  int _stageStart = 0;
  int _presentedAt = 0;
  int _speechEnd = 0;

  // Журнал.
  final List<RoundLog> _rounds = [];
  final List<ExerciseSet> _sets = [];
  final List<TaskAttempt> _attempts = [];
  int _lastRoundPos = -1;
  TaskOutcome? _lastOutcome;

  // --- чтение --------------------------------------------------------------

  EngineStatus get status => _status;

  /// Снимок состояния на момент последнего вызова.
  EngineState get state => _snapshot();

  /// Все накопленные сырые события в формате экспорта (SCHEMAS §3).
  /// Каждый вызов даёт новый независимый документ.
  EventsExport get events {
    final rounds = [..._rounds];
    // Круг в процессе: подходы уже ссылаются на его id — без записи круга
    // документ дал бы EVT_ORPHAN.
    if (_isPhysicalRunning && _roundSets.isNotEmpty) {
      rounds.add(_roundLog(_roundSets.last.endedAt, rpe: null));
    }
    return EventsExport(
      sessions: [
        if (_sessionId != null)
          Session(
            id: _sessionId!,
            startedAt: _startedAt!,
            endedAt: _endedAt,
            utcOffsetMin: utcOffsetMin,
            location: plan.location,
            difficulty: plan.difficulty,
            template: plan.template.kind,
            appVersion: appVersion,
          ),
      ],
      rounds: rounds,
      sets: [..._sets],
      attempts: [..._attempts],
    );
  }

  // --- управление ----------------------------------------------------------

  /// Начинает сессию: первый блок стартует в [nowMs].
  EngineState start(int nowMs) {
    if (_status != EngineStatus.idle) {
      throw StateError('Сессия уже запущена (${_status.name})');
    }
    _checkTime(nowMs);
    _now = nowMs;
    _status = EngineStatus.running;
    _sessionId = ids.nextId();
    _startedAt = nowMs;
    _beginBlock(0, nowMs);
    return _snapshot();
  }

  /// Применяет сроки, истёкшие к [nowMs]. На завершённой или прерванной
  /// сессии — пустая операция (хост может не останавливать свой таймер).
  EngineState tick(int nowMs) {
    if (_status == EngineStatus.idle) {
      throw StateError('Сессия ещё не запущена');
    }
    if (_status != EngineStatus.running) return _snapshot();
    _advance(nowMs);
    return _snapshot();
  }

  /// Завершает текущее упражнение с результатом [done] (0 — пропущено).
  EngineState completeSet(int done, int nowMs) {
    if (done < 0 || done > 3600) {
      throw RangeError.range(done, 0, 3600, 'done');
    }
    _advanceForAction(nowMs);
    if (!_isPhysicalRunning) {
      throw StateError('Сейчас не физическая фаза (${_describe()})');
    }
    _completeSetAt(done, nowMs);
    return _snapshot();
  }

  /// Пропуск упражнения: `ExerciseSet` с `done == 0`.
  EngineState skipExercise(int nowMs) => completeSet(0, nowMs);

  /// Оценка последнего завершённого круга одним нажатием.
  ///
  /// Неблокирующая: окно оценки открыто, пока следующий круг не завершил
  /// ни одного подхода. Повторный вызов заменяет оценку.
  EngineState rateRound(RoundRating rating) {
    if (_lastRoundPos < 0) {
      throw StateError('Нет завершённого круга для оценки');
    }
    if (_isPhysicalRunning && _roundSets.isNotEmpty) {
      throw StateError('Следующий круг уже идёт: оценка прошлого закрыта');
    }
    final old = _rounds[_lastRoundPos];
    _rounds[_lastRoundPos] = RoundLog(
      id: old.id,
      sessionId: old.sessionId,
      blockIndex: old.blockIndex,
      roundIndex: old.roundIndex,
      durationMs: old.durationMs,
      rpe: rating.rpe,
    );
    return _snapshot();
  }

  /// Конец фазы показа раньше срока («запомнил»).
  EngineState endStudy(int nowMs) {
    _advanceForAction(nowMs);
    _requireTask(TaskStage.study);
    if (_task.hasAnswer) {
      _toAnswer(nowMs);
    } else {
      _nextTask(nowMs);
    }
    return _snapshot();
  }

  /// Ответ на задачу.
  ///
  /// Проверяемые архетипы — [TaskAnswer.response] в каноническом виде
  /// (`recall`/`delayed_recall` — строка, `choice` — индекс по исходному
  /// порядку, `ordering` — индексы через `,`, `spatial` — `row,col`);
  /// `verbal` — [TaskAnswer.selfCheckYes]. Проверка — только через
  /// `CognitiveTaskProvider.verify`; у `verbal` `isCorrect == null`,
  /// `selfRating` считается по самопроверке (инвариант 7).
  EngineState submitAnswer(TaskAnswer answer, int nowMs) {
    _advanceForAction(nowMs);
    _requireTask(null);
    if (_stage == TaskStage.study) {
      throw StateError('Идёт показ: ответ принимается после его конца');
    }
    final pt = _task;
    final verifiable = pt.archetype.isMachineVerifiable;

    TaskAnswer normalized;
    String? recorded;
    if (verifiable) {
      final raw = answer.response?.trim();
      if (raw == null || raw.isEmpty) {
        throw ArgumentError.value(
          answer.response,
          'answer.response',
          'пустой ответ: для отказа есть skipTask',
        );
      }
      normalized = TaskAnswer(response: raw);
      recorded = _truncate(raw);
    } else {
      final yes = answer.selfCheckYes;
      if (yes == null) {
        throw ArgumentError.notNull('answer.selfCheckYes');
      }
      normalized = TaskAnswer.selfCheck(yes: yes);
    }
    final verdict = pt.source.provider.verify(pt.task, normalized);
    final answeredAt = _stage == TaskStage.selfCheck ? _speechEnd : nowMs;
    _record(
      pt,
      status: AttemptStatus.answered,
      presentedAt: _presentedAt,
      answeredAt: answeredAt,
      isCorrect: verifiable ? (verdict.isCorrect ?? false) : null,
      selfRating: verifiable ? null : _rating(pt, normalized, verdict),
      response: recorded,
    );
    _nextTask(nowMs);
    return _snapshot();
  }

  /// Пропуск задачи: `TaskAttempt` со статусом `skipped` (у проверяемой
  /// `isCorrect == false`). Пропуск запоминания `delayed_recall` попытки не
  /// пишет — вопрос позже всё равно будет задан.
  EngineState skipTask(int nowMs) {
    _advanceForAction(nowMs);
    _requireTask(null);
    final pt = _task;
    if (pt.hasAnswer) {
      _record(
        pt,
        status: AttemptStatus.skipped,
        presentedAt: _stage == TaskStage.study ? _stageStart : _presentedAt,
      );
    }
    _nextTask(nowMs);
    return _snapshot();
  }

  /// Прерывает сессию в момент [nowMs].
  ///
  /// Круг, где уже есть подходы, записывается как есть; незаконченное
  /// упражнение и задача без ответа — нет. `Session.endedAt` остаётся
  /// `null`. На завершённой/прерванной сессии — пустая операция.
  EngineState abort(int nowMs) {
    if (_status == EngineStatus.idle) {
      throw StateError('Сессия ещё не запущена');
    }
    if (_status != EngineStatus.running) return _snapshot();
    _advance(nowMs);
    if (_status != EngineStatus.running) return _snapshot();
    if (_isPhysicalRunning && _roundSets.isNotEmpty) {
      _rounds.add(_roundLog(nowMs, rpe: null));
      _roundSets.clear();
    }
    _status = EngineStatus.aborted;
    return _snapshot();
  }

  // --- время ---------------------------------------------------------------

  void _checkTime(int nowMs) {
    if (nowMs < 0 || nowMs > _maxTimeMs) {
      throw RangeError.range(nowMs, 0, _maxTimeMs, 'nowMs');
    }
    if (nowMs < _now) {
      throw ArgumentError.value(
        nowMs,
        'nowMs',
        'время не должно идти назад (последний вызов: $_now)',
      );
    }
  }

  void _advanceForAction(int nowMs) {
    if (_status != EngineStatus.running) {
      throw StateError('Сессия не идёт (${_status.name})');
    }
    _advance(nowMs);
    if (_status != EngineStatus.running) {
      throw StateError('Сессия уже завершена к моменту $nowMs');
    }
  }

  /// Проходит все сроки, истёкшие к [nowMs], в хронологическом порядке.
  void _advance(int nowMs) {
    _checkTime(nowMs);
    while (_status == EngineStatus.running) {
      final due = _nextDeadline();
      if (due == null || due > nowMs) break;
      _expire(due);
    }
    _now = nowMs;
  }

  /// Ближайший срок текущего состояния; `null` — сроков нет.
  int? _nextDeadline() {
    switch (plan.blocks[_blockIndex]) {
      case PlannedPhysicalBlock b:
        final ex = b.exercises[_exIndex];
        return ex.unit == ExerciseUnit.seconds
            ? _exStart + ex.prescribed * 1000
            : null;
      case PlannedRestBlock b:
        return _blockStart + b.durationSec * 1000;
      case PlannedCognitiveBlock b:
        final blockDl = _blockStart + b.durationSec * 1000;
        final stageDl = _stageDeadline();
        return stageDl != null && stageDl < blockDl ? stageDl : blockDl;
    }
  }

  int? _stageDeadline() {
    final pt = _task;
    return switch (_stage) {
      TaskStage.study => _stageStart + pt.studySec * 1000,
      TaskStage.answer => _stageStart + pt.task.timeSec * 1000,
      TaskStage.selfCheck => null,
    };
  }

  void _expire(int due) {
    switch (plan.blocks[_blockIndex]) {
      case PlannedPhysicalBlock b:
        _completeSetAt(b.exercises[_exIndex].prescribed, due);
      case PlannedRestBlock():
        _endBlock(due);
      case PlannedCognitiveBlock b:
        final blockDl = _blockStart + b.durationSec * 1000;
        if (due >= blockDl) {
          // Срок окна: задача, которую не успели, — таймаут.
          if (_stage != TaskStage.study) {
            _record(
              _task,
              status: AttemptStatus.timeout,
              presentedAt: _presentedAt,
            );
          }
          _endBlock(blockDl);
          return;
        }
        final pt = _task;
        switch (_stage) {
          case TaskStage.study:
            if (pt.hasAnswer) {
              _toAnswer(due);
            } else {
              _nextTask(due);
            }
          case TaskStage.answer:
            if (pt.archetype.isMachineVerifiable) {
              _record(
                pt,
                status: AttemptStatus.timeout,
                presentedAt: _presentedAt,
              );
              _nextTask(due);
            } else {
              // verbal: речь кончилась, ждём самооценку.
              _stage = TaskStage.selfCheck;
              _speechEnd = due;
            }
          case TaskStage.selfCheck:
            break; // срока нет, до сюда не доходит
        }
    }
  }

  // --- блоки ---------------------------------------------------------------

  void _beginBlock(int index, int at) {
    _blockIndex = index;
    _blockStart = at;
    switch (plan.blocks[index]) {
      case PlannedPhysicalBlock():
        _roundId = ids.nextId();
        _exIndex = 0;
        _exStart = at;
        _roundSets.clear();
      case PlannedRestBlock():
        break;
      case PlannedCognitiveBlock b:
        _taskIndex = 0;
        if (b.tasks.isEmpty) {
          _endBlock(at);
        } else {
          _beginTask(at);
        }
    }
  }

  void _endBlock(int at) {
    if (plan.blocks[_blockIndex] is PlannedPhysicalBlock) {
      _rounds.add(_roundLog(at, rpe: null));
      _lastRoundPos = _rounds.length - 1;
      _roundSets.clear();
    }
    final next = _blockIndex + 1;
    if (next < plan.blocks.length) {
      _beginBlock(next, at);
    } else {
      _status = EngineStatus.finished;
      _endedAt = at;
    }
  }

  // --- физика --------------------------------------------------------------

  bool get _isPhysicalRunning =>
      _status == EngineStatus.running &&
      plan.blocks[_blockIndex] is PlannedPhysicalBlock;

  void _completeSetAt(int done, int endedAt) {
    final block = plan.blocks[_blockIndex] as PlannedPhysicalBlock;
    final ex = block.exercises[_exIndex];
    final set = ExerciseSet(
      id: ids.nextId(),
      sessionId: _sessionId!,
      roundId: _roundId!,
      setIndex: _exIndex,
      exerciseId: ex.exerciseId,
      unit: ex.unit,
      prescribed: ex.prescribed,
      done: done,
      startedAt: _exStart,
      endedAt: endedAt,
    );
    _sets.add(set);
    _roundSets.add(set);
    _exIndex++;
    if (_exIndex < block.exercises.length) {
      _exStart = endedAt;
    } else {
      _endBlock(endedAt);
    }
  }

  RoundLog _roundLog(int endedAt, {required int? rpe}) {
    final block = plan.blocks[_blockIndex] as PlannedPhysicalBlock;
    return RoundLog(
      id: _roundId!,
      sessionId: _sessionId!,
      blockIndex: block.blockIndex,
      roundIndex: block.roundIndex,
      durationMs: endedAt - _blockStart,
      rpe: rpe,
    );
  }

  // --- когниция ------------------------------------------------------------

  PlannedCognitiveBlock get _cogBlock =>
      plan.blocks[_blockIndex] as PlannedCognitiveBlock;

  PlannedTask get _task => _cogBlock.tasks[_taskIndex];

  void _requireTask(TaskStage? expected) {
    if (_status != EngineStatus.running ||
        plan.blocks[_blockIndex] is! PlannedCognitiveBlock) {
      throw StateError('Сейчас не когнитивная фаза (${_describe()})');
    }
    if (expected != null && _stage != expected) {
      throw StateError('Стадия задачи: ${_stage.name}, нужна ${expected.name}');
    }
  }

  void _beginTask(int at) {
    _stageStart = at;
    if (_task.hasStudy) {
      _stage = TaskStage.study;
    } else {
      _stage = TaskStage.answer;
      _presentedAt = at;
    }
  }

  void _toAnswer(int at) {
    _stage = TaskStage.answer;
    _stageStart = at;
    _presentedAt = at;
  }

  void _nextTask(int at) {
    _taskIndex++;
    if (_taskIndex >= _cogBlock.tasks.length) {
      _endBlock(at);
    } else {
      _beginTask(at);
    }
  }

  int _rating(PlannedTask pt, TaskAnswer answer, TaskVerdict verdict) {
    final task = pt.task;
    if (task is! VerbalTask) {
      throw StateError('Самооценка только у verbal');
    }
    return verdict.selfRating ??
        selfRating(yes: answer.selfCheckYes!, n: task.selfCheck.length);
  }

  /// Пишет `TaskAttempt`. Для `answered` нужен [answeredAt]; иначе поля
  /// ответа — `null`, а у проверяемой задачи `isCorrect == false`.
  void _record(
    PlannedTask pt, {
    required AttemptStatus status,
    required int presentedAt,
    int? answeredAt,
    bool? isCorrect,
    int? selfRating,
    String? response,
  }) {
    final answered = status == AttemptStatus.answered;
    final verifiable = pt.archetype.isMachineVerifiable;
    final attempt = TaskAttempt(
      id: ids.nextId(),
      sessionId: _sessionId!,
      blockIndex: _blockIndex,
      roundIndex: _cogBlock.roundIndex,
      taskId: pt.task.id,
      packId: pt.providerId,
      packSource: pt.packSource,
      archetype: pt.archetype,
      domain: pt.task.domain,
      difficulty: pt.task.difficulty,
      seed: pt.seed,
      status: status,
      presentedAt: presentedAt,
      answeredAt: answered ? answeredAt : null,
      latencyMs: answered ? answeredAt! - presentedAt : null,
      isCorrect: verifiable ? (isCorrect ?? false) : null,
      selfRating: answered ? selfRating : null,
      response: answered ? response : null,
      encodedRoundIndex: pt.encodedRoundIndex,
      payloadHash: pt.payloadHash,
    );
    _attempts.add(attempt);
    _lastOutcome = TaskOutcome(attempt: attempt, task: pt.task);
  }

  static String _truncate(String s) {
    final runes = s.runes;
    if (runes.length <= _maxResponseLength) return s;
    return String.fromCharCodes(runes.take(_maxResponseLength));
  }

  // --- снимок --------------------------------------------------------------

  String _describe() => '${_status.name}, блок $_blockIndex';

  EngineState _snapshot() {
    final total = plan.blocks.length;
    if (_status == EngineStatus.idle) {
      return EngineState(status: _status, nowMs: _now, totalBlocks: total);
    }
    if (_status != EngineStatus.running) {
      return EngineState(
        status: _status,
        nowMs: _now,
        totalBlocks: total,
        sessionId: _sessionId,
        startedAt: _startedAt,
        endedAt: _endedAt,
        lastOutcome: _lastOutcome,
      );
    }
    final block = plan.blocks[_blockIndex];
    final elapsed = _now - _blockStart;
    switch (block) {
      case PlannedPhysicalBlock b:
        final ex = b.exercises[_exIndex];
        return EngineState(
          status: _status,
          nowMs: _now,
          totalBlocks: total,
          sessionId: _sessionId,
          startedAt: _startedAt,
          phase: Phase.physical,
          blockIndex: _blockIndex,
          roundIndex: b.roundIndex,
          block: b,
          blockElapsedMs: elapsed,
          exerciseIndex: _exIndex,
          exercise: ex,
          stageRemainingMs: ex.unit == ExerciseUnit.seconds
              ? _exStart + ex.prescribed * 1000 - _now
              : null,
          lastOutcome: _lastOutcome,
        );
      case PlannedRestBlock b:
        final remaining = _blockStart + b.durationSec * 1000 - _now;
        return EngineState(
          status: _status,
          nowMs: _now,
          totalBlocks: total,
          sessionId: _sessionId,
          startedAt: _startedAt,
          phase: Phase.rest,
          blockIndex: _blockIndex,
          block: b,
          blockElapsedMs: elapsed,
          blockRemainingMs: remaining,
          stageRemainingMs: remaining,
          lastOutcome: _lastOutcome,
        );
      case PlannedCognitiveBlock b:
        final blockRemaining = _blockStart + b.durationSec * 1000 - _now;
        final stageDl = _stageDeadline();
        final stageRemaining = stageDl == null
            ? blockRemaining
            : (stageDl - _now < blockRemaining
                  ? stageDl - _now
                  : blockRemaining);
        return EngineState(
          status: _status,
          nowMs: _now,
          totalBlocks: total,
          sessionId: _sessionId,
          startedAt: _startedAt,
          phase: Phase.cognitive,
          blockIndex: _blockIndex,
          roundIndex: b.roundIndex,
          block: b,
          blockElapsedMs: elapsed,
          blockRemainingMs: blockRemaining,
          taskIndex: _taskIndex,
          task: _task,
          stage: _stage,
          stageRemainingMs: stageRemaining,
          dueCues: _dueCues(),
          lastOutcome: _lastOutcome,
        );
    }
  }

  /// `cues`, чей момент наступил к [_now]. После конца речи время
  /// замораживается на её конце.
  List<DueCue> _dueCues() {
    final pt = _task;
    final task = pt.task;
    if (task is! VerbalTask || task.cues == null) return const [];
    if (_stage == TaskStage.study) return const [];
    final until = _stage == TaskStage.selfCheck ? _speechEnd : _now;
    final elapsedMs = until - _presentedAt;
    final cues = task.cues!;
    return [
      for (var i = 0; i < cues.length; i++)
        if (pt.cueMomentsSec[i] * 1000 <= elapsedMs)
          DueCue(index: i, atSec: pt.cueMomentsSec[i], text: cues[i].text),
    ];
  }
}
