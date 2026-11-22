import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_ui/tmb_ui.dart' show TmbEffort;

import '../../data/content_loader.dart';
import '../../data/providers.dart';
import 'session_services.dart';
import 'session_state.dart';

/// Период тика движка. Движок сам времени не меряет: тик только зовёт
/// `engine.tick(now)` с временем из `clockProvider`.
const sessionTickPeriod = Duration(milliseconds: 250);

/// Сколько мс после завершения задачи показывается её итог (баннер).
const kOutcomeVisibleMs = 4000;

/// Контроллер сессии: связывает движок (чистая машина состояний), БД и UI.
///
///  * план строится здесь — сид криптослучайный, из `sessionSeedProvider`;
///  * время — только из `clockProvider`, чтобы тесты управляли им;
///  * события пишутся по ходу сессии (ARCHITECTURE D9): попытки сразу, а круг
///    с его подходами — когда закрыто окно оценки круга (у `RoundLog` нет
///    обновления `rpe`, поэтому круг пишется один раз и уже с оценкой);
///  * клиент ничего не считает и не отправляет (инвариант 8): только сырые
///    события в локальную БД.
final sessionControllerProvider =
    AsyncNotifierProvider.autoDispose<SessionController, SessionState>(
      SessionController.new,
      // Ошибка плана детерминирована (нет упражнений, пустой пул): повтор в
      // Riverpod 3 по умолчанию включён и оставил бы экран в «загрузке».
      retry: (retryCount, error) => null,
    );

class SessionController extends AsyncNotifier<SessionState> {
  late SessionEngine _engine;
  late SessionPlan _plan;
  late SessionRepository _repo;
  late int Function() _now;
  late SessionHaptics _haptics;
  late SessionWakelock _wakelock;
  late String _sessionId;

  Timer? _timer;
  var _ready = false;
  var _finalizing = false;

  // Что уже ушло в БД (или стоит в очереди на запись).
  final _writtenRounds = <String>{};
  final _writtenSets = <String>{};
  final _writtenAttempts = <String>{};
  Future<void> _writing = Future.value();

  // Оценка круга.
  TmbEffort? _rating;
  String? _ratingRoundId;

  // Итог последней задачи для баннера.
  String? _outcomeAttemptId;
  int _outcomeAt = 0;

  // Для вибро.
  int? _lastBlockIndex;
  int _lastCueCount = 0;

  @override
  Future<SessionState> build() async {
    _ready = false;
    _finalizing = false;
    _writtenRounds.clear();
    _writtenSets.clear();
    _writtenAttempts.clear();
    _writing = Future.value();
    _rating = null;
    _ratingRoundId = null;
    _outcomeAttemptId = null;
    _outcomeAt = 0;
    _lastDisplayKey = null;
    _lastBlockIndex = null;
    _lastCueCount = 0;
    _repo = ref.read(sessionRepositoryProvider);
    _now = ref.read(clockProvider);
    _haptics = ref.read(sessionHapticsProvider);
    _wakelock = ref.read(sessionWakelockProvider);
    ref.onDispose(_dispose);

    final profileRepo = ref.read(profileRepositoryProvider);
    final prefs = await profileRepo.loadSessionPreferences();
    final profile = await profileRepo.loadProfile();
    final exercises = await ref.read(exercisesProvider.future);
    final sources = await ref.read(taskSourcesProvider.future);

    final planner = SessionPlanner(
      exercises: exercises,
      sources: sources,
      profile: profile,
    );
    _plan = planner.plan(
      template: _templateOf(prefs),
      seed: ref.read(sessionSeedProvider)(),
      location: prefs.location,
      difficulty: prefs.difficulty,
    );

    final startMs = _now();
    _engine = SessionEngine(
      plan: _plan,
      ids: ref.read(idSourceProvider),
      utcOffsetMin: DateTime.fromMillisecondsSinceEpoch(
        startMs,
        isUtc: true,
      ).toLocal().timeZoneOffset.inMinutes,
    );
    _engine.start(startMs);
    _sessionId = _engine.state.sessionId!;
    await _repo.saveSession(SessionBundle(session: _engine.events.sessions[0]));

    if (!ref.mounted) {
      // Экран закрыли, пока строился план: пустую сессию не оставляем.
      await _repo.deleteSession(_sessionId);
      return SessionEnded(sessionId: _sessionId, aborted: true);
    }
    unawaited(_wakelock.enable().catchError((_) {}));
    _ready = true;
    final running = _compose(_engine.state);
    _flush();
    _timer = Timer.periodic(sessionTickPeriod, (_) => _onTick());
    return running;
  }

  static SessionTemplate _templateOf(
    SessionPreferences p,
  ) => switch (p.template) {
    SessionTemplateKind.physicalOnly => SessionTemplate.physicalOnly(
      rounds: p.rounds,
      restSec: p.restSec,
    ),
    SessionTemplateKind.cognitiveOnly => SessionTemplate.cognitiveOnly(
      windows: p.rounds,
      cognitiveSec: p.cognitiveSec,
    ),
    // Кастомные блоки в v0.1 не сохраняются (SessionPreferences): как обычный.
    SessionTemplateKind.dualTask || SessionTemplateKind.custom =>
      SessionTemplate.dualTask(rounds: p.rounds, cognitiveSec: p.cognitiveSec),
  };

  void _dispose() {
    _timer?.cancel();
    if (_ready) unawaited(_wakelock.disable().catchError((_) {}));
  }

  // --- действия UI ---------------------------------------------------------

  /// «Подход выполнен»: [done] — фактически сделанное; `null` — столько,
  /// сколько предписано.
  void completeSet([int? done]) => _act(() {
    final ex = _engine.state.exercise;
    if (ex == null) return;
    _engine.completeSet(done ?? ex.prescribed, _now());
  });

  void skipExercise() => _act(() => _engine.skipExercise(_now()));

  void endStudy() => _act(() => _engine.endStudy(_now()));

  void submitAnswer(TaskAnswer answer) =>
      _act(() => _engine.submitAnswer(answer, _now()));

  void skipTask() => _act(() => _engine.skipTask(_now()));

  /// Оценка последнего круга. Повторный вызов заменяет оценку.
  void rate(TmbEffort effort) => _act(() {
    _engine.rateRound(switch (effort) {
      TmbEffort.hard => RoundRating.heavy,
      TmbEffort.normal => RoundRating.normal,
      TmbEffort.easy => RoundRating.easy,
    });
    _rating = effort;
  });

  /// «Эвакуация»: прерывает сессию (`Session.endedAt` остаётся `null`).
  Future<void> evacuate() async {
    if (!_canAct) return;
    _engine.abort(_now());
    if (_engine.state.status == EngineStatus.aborted) {
      await _finalize(aborted: true);
    } else {
      // Срок успел завершить сессию раньше нажатия: это уже не эвакуация.
      _afterEngineCall();
    }
  }

  /// «К итогам» с экрана оценки последнего круга.
  Future<void> finish() async {
    if (!_canAct || !_engine.state.isFinished) return;
    await _finalize(aborted: false);
  }

  // --- внутреннее ----------------------------------------------------------

  bool get _canAct => _ready && !_finalizing;

  void _act(void Function() action) {
    if (!_canAct) return;
    try {
      action();
    } on StateError {
      // Срок истёк между нажатием и обработкой (движок сам завершил блок или
      // сессию): состояние всё равно надо опубликовать.
    }
    _afterEngineCall();
  }

  void _onTick() {
    if (!_canAct || !_engine.state.isRunning) return;
    _engine.tick(_now());
    final st = _engine.state;
    // Движок тикает 4 раза в секунду ради точности сроков, а экран меняется
    // раз в секунду (цифры таймеров) или при смене состояния — лишние
    // перерисовки только греют телефон.
    final key = _displayKey(st);
    if (key == _lastDisplayKey) {
      _flush();
      return;
    }
    _afterEngineCall();
  }

  String? _lastDisplayKey;

  /// Всё, от чего зависит картинка, с таймерами в целых секундах.
  String _displayKey(EngineState st) {
    int sec(int? ms) => ms == null ? -1 : (ms <= 0 ? 0 : (ms + 999) ~/ 1000);
    return [
      st.status.name,
      st.blockIndex,
      st.exerciseIndex,
      st.taskIndex,
      st.stage?.name,
      st.dueCues.length,
      sec(st.stageRemainingMs),
      sec(st.blockRemainingMs),
      (st.blockElapsedMs ?? 0) ~/ 1000,
      st.lastOutcome?.attempt.id,
      _outcomeVisible(st.nowMs),
    ].join('|');
  }

  bool _outcomeVisible(int now) =>
      _outcomeAttemptId != null && now - _outcomeAt < kOutcomeVisibleMs;

  /// Публикует снимок, пишет события, при конце сессии идёт на итоги.
  void _afterEngineCall() {
    final st = _engine.state;
    if (st.status == EngineStatus.aborted) {
      unawaited(_finalize(aborted: true));
      return;
    }
    if (st.isFinished && !_hasClosedRound) {
      // Оценивать нечего (нет физики): сразу к итогам.
      _flush();
      unawaited(_finalize(aborted: false));
      return;
    }
    state = AsyncData(_compose(st));
    _flush();
  }

  bool get _hasClosedRound => _closedRounds(_engine.events).isNotEmpty;

  /// Окно оценки круга: есть закрытый круг, и движок ещё допускает `rateRound`
  /// (следующий круг не завершил ни одного подхода). После конца сессии окно
  /// держится, пока пользователь не нажмёт «К итогам».
  bool _windowOpen(EngineState st) {
    if (!_hasClosedRound) return false;
    if (st.isFinished) return !_finalizing;
    if (!st.isRunning) return false;
    return !(st.phase == Phase.physical && (st.exerciseIndex ?? 0) > 0);
  }

  /// Круги, закрытые движком (без «предварительного» круга в процессе).
  List<RoundLog> _closedRounds(EventsExport events) {
    final st = _engine.state;
    final provisional =
        st.isRunning &&
        st.phase == Phase.physical &&
        (st.exerciseIndex ?? 0) > 0;
    final rounds = events.rounds;
    return provisional ? rounds.sublist(0, rounds.length - 1) : rounds;
  }

  SessionRunning _compose(EngineState st) {
    final now = st.nowMs;
    final closed = _closedRounds(_engine.events);

    // Новый закрытый круг — новое окно оценки, прошлая оценка не относится.
    final lastRoundId = closed.isEmpty ? null : closed.last.id;
    if (lastRoundId != _ratingRoundId) {
      _ratingRoundId = lastRoundId;
      _rating = null;
    }

    // Баннер итога задачи.
    final outcome = st.lastOutcome;
    if (outcome != null && outcome.attempt.id != _outcomeAttemptId) {
      _outcomeAttemptId = outcome.attempt.id;
      _outcomeAt = now;
    }
    final showOutcome = outcome != null && now - _outcomeAt < kOutcomeVisibleMs;

    // Вибро: смена фазы/блока и новая подсказка `cues`.
    if (st.isRunning) {
      if (_lastBlockIndex != null && _lastBlockIndex != st.blockIndex) {
        unawaited(_haptics.phaseChanged());
      }
      _lastBlockIndex = st.blockIndex;
      if (st.dueCues.length > _lastCueCount) {
        unawaited(_haptics.cueAppeared());
      }
      _lastCueCount = st.dueCues.length;
    }

    _lastDisplayKey = _displayKey(st);
    return SessionRunning(
      engine: st,
      plan: _plan,
      ratingOpen: _windowOpen(st),
      rating: _rating,
      outcome: showOutcome ? outcome : null,
      awaitingFinish: st.isFinished,
    );
  }

  /// Дописывает в БД то, что созрело. Круг с подходами держится, пока открыто
  /// окно его оценки: `appendEvents` только вставляет, а `RoundLog.rpe`
  /// после записи не обновить.
  void _flush() {
    final st = _engine.state;
    final events = _engine.events;
    final closed = _closedRounds(events);
    final hold = _windowOpen(st) && closed.isNotEmpty ? closed.last.id : null;

    final rounds = <RoundLog>[];
    for (final r in closed) {
      if (r.id != hold && _writtenRounds.add(r.id)) rounds.add(r);
    }
    final sets = <ExerciseSet>[];
    for (final s in events.sets) {
      if (_writtenRounds.contains(s.roundId) && _writtenSets.add(s.id)) {
        sets.add(s);
      }
    }
    final attempts = <TaskAttempt>[];
    for (final a in events.attempts) {
      if (_writtenAttempts.add(a.id)) attempts.add(a);
    }
    if (rounds.isEmpty && sets.isEmpty && attempts.isEmpty) return;

    _writing = _writing.then((_) async {
      try {
        await _repo.appendEvents(
          _sessionId,
          rounds: rounds,
          sets: sets,
          attempts: attempts,
        );
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'tmb session',
            context: ErrorDescription('запись событий сессии'),
          ),
        );
      }
    });
  }

  Future<void> _finalize({required bool aborted}) async {
    if (_finalizing) return;
    _finalizing = true;
    _timer?.cancel();
    _flush();
    await _writing;
    final endedAt = _engine.state.endedAt;
    if (!aborted && endedAt != null) {
      try {
        await _repo.finishSession(_sessionId, endedAt: endedAt);
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'tmb session',
            context: ErrorDescription('закрытие сессии'),
          ),
        );
      }
    }
    unawaited(_wakelock.disable().catchError((_) {}));
    if (ref.mounted) {
      state = AsyncData(SessionEnded(sessionId: _sessionId, aborted: aborted));
    }
  }
}
