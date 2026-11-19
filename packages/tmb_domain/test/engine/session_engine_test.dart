import 'dart:convert';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'fixtures.dart';

/// Движок на когнитивных окнах из одной задачи [taskId].
SessionEngine cognitiveEngine(
  String taskId, {
  int windows = 1,
  int cognitiveSec = 120,
  int tasksPerBlock = 1,
}) {
  final plan = planOf(
    plannerWith(
      sources: [
        sourceOf(packOf([taskId])),
      ],
      tasksPerCognitiveBlock: tasksPerBlock,
    ),
    SessionTemplate.cognitiveOnly(windows: windows, cognitiveSec: cognitiveSec),
  );
  return engineOf(plan);
}

PlannedTask plannedTask(SessionEngine e, {int block = 0, int index = 0}) =>
    (e.plan.blocks[block] as PlannedCognitiveBlock).tasks[index];

void main() {
  group('полный прогон: физика → когниция → физика', () {
    final plan = planOf(
      plannerWith(
        sources: [
          sourceOf(packOf(['demo.java.002'])),
        ],
      ),
      SessionTemplate.dualTask(rounds: 2, cognitiveSec: 120),
    );
    final round0 = plan.blocks[0] as PlannedPhysicalBlock;
    final round1 = plan.blocks[2] as PlannedPhysicalBlock;
    final task = (plan.blocks[1] as PlannedCognitiveBlock).tasks.single;

    /// Прогон по фиксированным моментам; возвращает движок.
    SessionEngine run() {
      final e = engineOf(plan);
      e.start(t0);
      var c = t0;
      for (final ex in round0.exercises) {
        c += 20000;
        e.completeSet(ex.prescribed, c);
      }
      e.rateRound(RoundRating.normal);
      e.submitAnswer(TaskAnswer.choice(2), c + 7391);
      c += 7391;
      for (final ex in round1.exercises) {
        c += 15000;
        e.completeSet(ex.prescribed - 1, c);
      }
      return e;
    }

    test('состояния по ходу прогона', () {
      final e = engineOf(plan);
      expect(e.state.status, EngineStatus.idle);
      var st = e.start(t0);
      expect(st.status, EngineStatus.running);
      expect(st.phase, Phase.physical);
      expect(st.blockIndex, 0);
      expect(st.roundIndex, 0);
      expect(st.exerciseIndex, 0);
      expect(st.exercise!.exerciseId, round0.exercises[0].exerciseId);
      expect(st.totalBlocks, 3);
      expect(st.stageRemainingMs, isNull); // повторения: срока нет

      var c = t0;
      for (var i = 0; i < round0.exercises.length; i++) {
        expect(st.exerciseIndex, i);
        c += 20000;
        st = e.completeSet(round0.exercises[i].prescribed, c);
      }
      // Круг закончен: началось когнитивное окно в момент последнего подхода.
      expect(st.phase, Phase.cognitive);
      expect(st.blockIndex, 1);
      expect(st.roundIndex, 0);
      expect(st.stage, TaskStage.answer);
      expect(st.task!.task.id, 'demo.java.002');
      expect(st.blockRemainingMs, 120000);
      expect(st.stageRemainingMs, 30000); // timeSec задачи меньше срока окна
      expect(st.dueCues, isEmpty);

      st = e.tick(c + 10000);
      expect(st.stageRemainingMs, 20000);
      expect(st.blockRemainingMs, 110000);
      expect(st.blockElapsedMs, 10000);

      st = e.submitAnswer(TaskAnswer.choice(2), c + 10000);
      expect(st.phase, Phase.physical);
      expect(st.blockIndex, 2);
      expect(st.roundIndex, 1);
      expect(st.lastOutcome!.attempt.isCorrect, isTrue);
      expect(st.lastOutcome!.task.id, 'demo.java.002');

      c += 10000;
      for (final ex in round1.exercises) {
        c += 15000;
        st = e.completeSet(ex.prescribed, c);
      }
      expect(st.status, EngineStatus.finished);
      expect(st.endedAt, c);
      expect(st.phase, isNull);
    });

    test('сырые события: поля, связи, времена', () {
      final e = run();
      final ev = e.events;
      expect(e.status, EngineStatus.finished);

      expect(ev.sessions, hasLength(1));
      final s = ev.sessions.single;
      expect(s.startedAt, t0);
      expect(s.endedAt, t0 + 60000 + 7391 + 45000);
      expect(s.template, SessionTemplateKind.dualTask);
      expect(s.location, Location.home);
      expect(s.difficulty, DifficultyLevel.recruit);

      expect(ev.rounds, hasLength(2));
      expect(ev.rounds[0].blockIndex, 0);
      expect(ev.rounds[0].roundIndex, 0);
      expect(ev.rounds[0].durationMs, 60000);
      expect(ev.rounds[0].rpe, 2);
      expect(ev.rounds[1].blockIndex, 2);
      expect(ev.rounds[1].roundIndex, 1);
      expect(ev.rounds[1].durationMs, 45000);
      expect(ev.rounds[1].rpe, isNull);

      expect(ev.sets, hasLength(6));
      for (var i = 0; i < 6; i++) {
        final planned = (i < 3 ? round0 : round1).exercises[i % 3];
        final set = ev.sets[i];
        expect(set.exerciseId, planned.exerciseId);
        expect(set.unit, ExerciseUnit.reps);
        expect(set.prescribed, planned.prescribed);
        expect(set.done, i < 3 ? planned.prescribed : planned.prescribed - 1);
        expect(set.setIndex, i % 3);
        expect(set.roundId, ev.rounds[i < 3 ? 0 : 1].id);
        expect(set.sessionId, s.id);
        expect(set.endedAt - set.startedAt, i < 3 ? 20000 : 15000);
      }
      // Подходы идут встык: начало следующего = конец предыдущего.
      expect(ev.sets[1].startedAt, ev.sets[0].endedAt);
      expect(ev.sets[3].startedAt, t0 + 60000 + 7391);

      expect(ev.attempts, hasLength(1));
      final a = ev.attempts.single;
      expect(a.sessionId, s.id);
      expect(a.blockIndex, 1);
      expect(a.roundIndex, 0);
      expect(a.taskId, 'demo.java.002');
      expect(a.packId, 'demo.ru');
      expect(a.packSource, PackSource.builtin);
      expect(a.archetype, TaskArchetype.choice);
      expect(a.domain, 'it.java');
      expect(a.difficulty, 0.3);
      expect(a.seed, task.seed);
      expect(a.status, AttemptStatus.answered);
      expect(a.presentedAt, t0 + 60000);
      expect(a.answeredAt, t0 + 60000 + 7391);
      expect(a.latencyMs, 7391);
      expect(a.isCorrect, isTrue);
      expect(a.selfRating, isNull);
      expect(a.response, '2');
      expect(a.encodedRoundIndex, isNull);
      // Вектор из SCHEMAS §3.5.
      expect(
        a.payloadHash,
        '0301b322e4db5a224c9262ad495394182698d55b6a82ac005e992529b93a4833',
      );
      expectValidEvents(ev);
    });

    test('повторный прогон даёт побайтно те же события', () {
      expect(
        jsonEncode(run().events.toJson()),
        jsonEncode(run().events.toJson()),
      );
    });

    test('события согласованы в любой промежуточный момент', () {
      final e = engineOf(plan);
      expectValidEvents(e.events); // до старта: пустой документ
      e.start(t0);
      expectValidEvents(e.events);
      var c = t0;
      for (final ex in round0.exercises) {
        c += 20000;
        e.completeSet(ex.prescribed, c);
        expectValidEvents(e.events);
      }
      // Круг в процессе (подходы есть, круг ещё не закрыт) уже в журнале.
      expect(e.events.rounds, hasLength(1));
      expect(e.events.rounds.single.rpe, isNull);
    });

    test('снимки иммутабельны, events — независимые копии', () {
      final e = engineOf(plan);
      final before = e.start(t0);
      final docBefore = e.events;
      e.completeSet(5, t0 + 1000);
      expect(before.exerciseIndex, 0);
      expect(before.nowMs, t0);
      expect(docBefore.sets, isEmpty);
      expect(e.events.sets, hasLength(1));
    });
  });

  group('оценка круга', () {
    test('rateRound: нет круга / идёт следующий / замена оценки', () {
      final plan = planOf(
        plannerWith(exercisesPerRound: 2),
        SessionTemplate.physicalOnly(rounds: 2),
      );
      final e = engineOf(plan)..start(t0);
      expect(() => e.rateRound(RoundRating.heavy), throwsStateError);

      e.completeSet(10, t0 + 1000);
      e.completeSet(10, t0 + 2000); // круг 0 закончен, круг 1 начался
      e.rateRound(RoundRating.heavy);
      expect(e.events.rounds.single.rpe, 3);
      e.rateRound(RoundRating.easy); // повтор заменяет
      expect(e.events.rounds.single.rpe, 1);

      e.completeSet(10, t0 + 3000); // в круге 1 появился подход
      expect(() => e.rateRound(RoundRating.heavy), throwsStateError);
      expect(e.events.rounds.first.rpe, 1);

      e.completeSet(10, t0 + 4000);
      expect(e.status, EngineStatus.finished);
      e.rateRound(RoundRating.normal); // после конца — оценка последнего круга
      expect(e.events.rounds.map((r) => r.rpe), [1, 2]);
      expectValidEvents(e.events);
    });

    test('значения RPE: легко 1, нормально 2, тяжело 3', () {
      expect(RoundRating.values.map((r) => r.rpe), [1, 2, 3]);
    });
  });

  group('только физика', () {
    final plan = planOf(
      plannerWith(
        exercises: [exercise('ex.plank', unit: ExerciseUnit.seconds)],
        sources: const [],
        exercisesPerRound: 1,
      ),
      SessionTemplate.physicalOnly(rounds: 2, restSec: 30),
    );

    test('упражнение в секундах и отдых завершаются по tick', () {
      final e = engineOf(plan);
      var st = e.start(t0);
      expect(st.exercise!.unit, ExerciseUnit.seconds);
      expect(st.exercise!.prescribed, 30);
      expect(st.stageRemainingMs, 30000);

      st = e.tick(t0 + 29999);
      expect(st.phase, Phase.physical);
      expect(st.stageRemainingMs, 1);
      expect(e.events.sets, isEmpty);

      st = e.tick(t0 + 30000);
      expect(st.phase, Phase.rest);
      expect(st.blockIndex, 1);
      expect(st.roundIndex, isNull);
      expect(st.blockRemainingMs, 30000);
      final set = e.events.sets.single;
      expect(set.done, 30);
      expect(set.startedAt, t0);
      expect(set.endedAt, t0 + 30000);

      e.rateRound(RoundRating.heavy); // окно оценки — во время отдыха
      st = e.tick(t0 + 45000);
      expect(st.blockRemainingMs, 15000);

      st = e.tick(t0 + 60000);
      expect(st.phase, Phase.physical);
      expect(st.blockIndex, 2);
      expect(st.roundIndex, 1);

      st = e.completeSet(25, t0 + 80000); // досрочно, не добрал
      expect(st.status, EngineStatus.finished);
      expect(e.events.sets.last.done, 25);
      expect(e.events.sets.last.prescribed, 30);
      expect(e.events.rounds.map((r) => r.durationMs), [30000, 20000]);
      expect(e.events.rounds.first.rpe, 3);
      expect(e.events.attempts, isEmpty);
      expect(
        e.events.sessions.single.template,
        SessionTemplateKind.physicalOnly,
      );
      expectValidEvents(e.events);
    });

    test(
      'запоздавший tick догоняет сроки и датирует их сроком, не вызовом',
      () {
        final e = engineOf(plan)..start(t0);
        final st = e.tick(t0 + 10 * 60 * 1000);
        expect(st.status, EngineStatus.finished);
        expect(st.endedAt, t0 + 90000);
        expect(e.events.sets.map((s) => s.endedAt), [t0 + 30000, t0 + 90000]);
        expect(e.events.sets.map((s) => s.startedAt), [t0, t0 + 60000]);
        expectValidEvents(e.events);
        // Дальнейшие tick — пустая операция.
        expect(e.tick(t0 + 20 * 60 * 1000).status, EngineStatus.finished);
      },
    );

    test('пропуск упражнения пишет подход с done = 0', () {
      final e = engineOf(
        planOf(
          plannerWith(exercisesPerRound: 2),
          SessionTemplate.physicalOnly(rounds: 1),
        ),
      )..start(t0);
      e.skipExercise(t0 + 500);
      e.completeSet(12, t0 + 5000);
      expect(e.events.sets.map((s) => s.done), [0, 12]);
      expect(e.status, EngineStatus.finished);
      expectValidEvents(e.events);
    });
  });

  group('только когниция', () {
    test('окна подряд, без физических событий, roundIndex = номер окна', () {
      final e = cognitiveEngine('demo.java.002', windows: 3)..start(t0);
      var st = e.state;
      expect(st.phase, Phase.cognitive);
      expect(st.roundIndex, 0);
      e.submitAnswer(TaskAnswer.choice(2), t0 + 4000);
      e.submitAnswer(TaskAnswer.choice(0), t0 + 9000);
      st = e.submitAnswer(TaskAnswer.choice(2), t0 + 15000);
      expect(st.status, EngineStatus.finished);

      final ev = e.events;
      expect(ev.rounds, isEmpty);
      expect(ev.sets, isEmpty);
      expect(ev.attempts.map((a) => a.roundIndex), [0, 1, 2]);
      expect(ev.attempts.map((a) => a.blockIndex), [0, 1, 2]);
      expect(ev.attempts.map((a) => a.isCorrect), [true, false, true]);
      expect(ev.attempts.map((a) => a.latencyMs), [4000, 5000, 6000]);
      expect(ev.sessions.single.template, SessionTemplateKind.cognitiveOnly);
      expectValidEvents(ev);
    });

    test('несколько задач в окне идут встык', () {
      final e = cognitiveEngine('demo.java.002', tasksPerBlock: 2)..start(t0);
      expect(e.state.taskIndex, 0);
      var st = e.submitAnswer(TaskAnswer.choice(2), t0 + 5000);
      expect(st.taskIndex, 1);
      expect(st.stageRemainingMs, 30000);
      st = e.tick(t0 + 5000 + 30000); // вторую не успели
      expect(st.status, EngineStatus.finished);
      final a = e.events.attempts;
      expect(a.map((x) => x.status), [
        AttemptStatus.answered,
        AttemptStatus.timeout,
      ]);
      expect(a[1].presentedAt, t0 + 5000);
      expect(a.map((x) => x.roundIndex), [0, 0]);
      expectValidEvents(e.events);
    });

    test(
      'recall: ответ нормализуется провайдером, пустой ответ отклоняется',
      () {
        final e = cognitiveEngine('demo.est.001', windows: 2)..start(t0);
        expect(
          () => e.submitAnswer(const TaskAnswer.recall('   '), t0 + 1000),
          throwsArgumentError,
        );
        expect(
          () => e.submitAnswer(const TaskAnswer(), t0 + 1000),
          throwsArgumentError,
        );
        e.submitAnswer(const TaskAnswer.recall('  85 000 '), t0 + 2000);
        e.submitAnswer(const TaskAnswer.recall('100000'), t0 + 3000);
        final a = e.events.attempts;
        expect(a[0].isCorrect, isTrue); // допуск 80000…90000
        expect(a[0].response, '85 000'); // после trim
        expect(a[1].isCorrect, isFalse);
        expectValidEvents(e.events);
      },
    );
  });

  group('таймаут и пропуск задачи', () {
    test('таймаут ровно на сроке задачи, а не раньше', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      e.tick(t0 + 29999);
      expect(e.events.attempts, isEmpty);
      expect(e.state.stageRemainingMs, 1);

      final st = e.tick(t0 + 30000);
      expect(st.status, EngineStatus.finished);
      final a = e.events.attempts.single;
      expect(a.status, AttemptStatus.timeout);
      expect(a.isCorrect, isFalse); // проверяемая: timeout даёт false
      expect(a.answeredAt, isNull);
      expect(a.latencyMs, isNull);
      expect(a.response, isNull);
      expect(a.selfRating, isNull);
      expect(a.presentedAt, t0);
      expect(st.lastOutcome!.attempt.status, AttemptStatus.timeout);
      // Окно закончилось в момент таймаута, а не в момент tick.
      expect(e.events.sessions.single.endedAt, t0 + 30000);
      expectValidEvents(e.events);
    });

    test('ответ ровно в момент срока — уже таймаут (срок включительно)', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      expect(
        () => e.submitAnswer(TaskAnswer.choice(2), t0 + 30000),
        throwsStateError,
      );
      expect(e.events.attempts.single.status, AttemptStatus.timeout);
      expect(e.status, EngineStatus.finished);
    });

    test('срок окна короче срока задачи — таймаут по окну', () {
      final e = cognitiveEngine('demo.java.002', cognitiveSec: 20)..start(t0);
      expect(e.state.stageRemainingMs, 20000);
      final st = e.tick(t0 + 20000);
      expect(st.status, EngineStatus.finished);
      expect(e.events.attempts.single.status, AttemptStatus.timeout);
      expect(e.events.sessions.single.endedAt, t0 + 20000);
    });

    test('запоздавший tick: оба окна в таймауте с честными временами', () {
      final e = cognitiveEngine('demo.java.002', windows: 2, cognitiveSec: 60)
        ..start(t0);
      final st = e.tick(t0 + 10 * 60 * 1000);
      expect(st.status, EngineStatus.finished);
      final a = e.events.attempts;
      expect(a.map((x) => x.status), [
        AttemptStatus.timeout,
        AttemptStatus.timeout,
      ]);
      expect(a.map((x) => x.presentedAt), [t0, t0 + 30000]);
      expect(a.map((x) => x.roundIndex), [0, 1]);
      expect(e.events.sessions.single.endedAt, t0 + 60000);
      expectValidEvents(e.events);
    });

    test('пропуск: skipped, isCorrect false, без ответа', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      e.skipTask(t0 + 3000);
      final a = e.events.attempts.single;
      expect(a.status, AttemptStatus.skipped);
      expect(a.isCorrect, isFalse);
      expect(a.answeredAt, isNull);
      expect(a.latencyMs, isNull);
      expect(a.response, isNull);
      expect(a.presentedAt, t0);
      expectValidEvents(e.events);
    });
  });

  group('verbal: самооценка и cues (инвариант 7)', () {
    SessionEngine verbal({int cognitiveSec = 120}) =>
        cognitiveEngine('demo.ver.001', cognitiveSec: cognitiveSec)..start(t0);

    test('самооценка по формуле, isCorrect == null, response == null', () {
      // floor(3 × yes / n + 0.5), n = 3: 0 → 0, 1 → 1, 2 → 2, 3 → 3.
      for (final yes in [0, 1, 2, 3]) {
        final e = verbal();
        e.submitAnswer(TaskAnswer.selfCheck(yes: yes), t0 + 20000);
        final a = e.events.attempts.single;
        expect(a.archetype, TaskArchetype.verbal);
        expect(a.status, AttemptStatus.answered);
        expect(a.isCorrect, isNull);
        expect(a.selfRating, yes);
        expect(a.response, isNull);
        expect(a.latencyMs, 20000); // закончил речь раньше срока
        expect(a.answeredAt, t0 + 20000);
        expectValidEvents(e.events);
      }
    });

    test(
      'речь кончилась по сроку: ждём самооценку, answeredAt — конец речи',
      () {
        final e = verbal();
        var st = e.tick(t0 + 59999);
        expect(st.stage, TaskStage.answer);
        st = e.tick(t0 + 60000);
        expect(st.stage, TaskStage.selfCheck);
        expect(st.status, EngineStatus.running);
        expect(st.stageRemainingMs, 60000); // до срока окна
        st = e.tick(t0 + 100000); // самооценка ждёт, пока не кончится окно
        expect(st.stage, TaskStage.selfCheck);

        e.submitAnswer(const TaskAnswer.selfCheck(yes: 3), t0 + 100000);
        final a = e.events.attempts.single;
        expect(a.status, AttemptStatus.answered);
        expect(a.answeredAt, t0 + 60000);
        expect(a.latencyMs, 60000);
        expect(a.selfRating, 3);
        expect(a.isCorrect, isNull);
        expectValidEvents(e.events);
      },
    );

    test('самооценку не дали до срока окна — timeout без оценки', () {
      final e = verbal(cognitiveSec: 70);
      e.tick(t0 + 60000);
      expect(e.state.stage, TaskStage.selfCheck);
      e.tick(t0 + 70000);
      final a = e.events.attempts.single;
      expect(a.status, AttemptStatus.timeout);
      expect(a.isCorrect, isNull); // verbal: null и при таймауте
      expect(a.selfRating, isNull);
      expect(a.answeredAt, isNull);
      expectValidEvents(e.events);
    });

    test('неверный вид ответа и число «да» вне диапазона', () {
      final e = verbal();
      expect(
        () => e.submitAnswer(const TaskAnswer.recall('да'), t0 + 1000),
        throwsArgumentError,
      );
      expect(
        () => e.submitAnswer(const TaskAnswer.selfCheck(yes: 4), t0 + 1000),
        throwsRangeError,
      );
      expect(e.events.attempts, isEmpty); // ошибка ничего не записала
      expect(e.state.stage, TaskStage.answer);
      e.submitAnswer(const TaskAnswer.selfCheck(yes: 1), t0 + 2000);
      expect(e.events.attempts.single.selfRating, 1);

      final c = cognitiveEngine('demo.java.002')..start(t0);
      expect(
        () => c.submitAnswer(const TaskAnswer.selfCheck(yes: 1), t0 + 1000),
        throwsArgumentError,
      );
    });

    test('cues: состояние говорит, какие подсказки уже должны были показаться', () {
      final e = verbal();
      final t = plannedTask(e);
      final m = t.cueMomentsSec.single;
      expect(m, inInclusiveRange(15, 25));
      final cueText = (t.task as VerbalTask).cues!.single.text;

      expect(e.tick(t0 + m * 1000 - 1).dueCues, isEmpty);
      final st = e.tick(t0 + m * 1000);
      expect(st.dueCues, hasLength(1));
      expect(st.dueCues.single.index, 0);
      expect(st.dueCues.single.atSec, m);
      expect(st.dueCues.single.text, cueText);
      // Остаётся «уже показанной» до конца задачи, в том числе на самопроверке.
      expect(e.tick(t0 + 40000).dueCues, hasLength(1));
      expect(e.tick(t0 + 60000).dueCues, hasLength(1));
    });

    test('cues не появляются у задач без них', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      expect(e.tick(t0 + 20000).dueCues, isEmpty);
    });
  });

  group('delayed_recall и spatial: фаза показа', () {
    test(
      'вопрос через окно, encodedRoundIndex, вырожденный случай в конце',
      () {
        final e = cognitiveEngine('demo.mem.001', windows: 3, cognitiveSec: 60)
          ..start(t0);
        var st = e.state;
        expect(st.stage, TaskStage.study);
        expect(st.task!.role, PlannedTaskRole.memorize);
        expect(st.stageRemainingMs, 8000);
        expect(
          () => e.submitAnswer(const TaskAnswer.recall('Р3'), t0 + 1000),
          throwsStateError,
        );

        e.tick(t0 + 7999);
        expect(e.events.attempts, isEmpty);
        st = e.tick(t0 + 8000); // показ кончился → окно 1, сразу вопрос
        expect(st.blockIndex, 1);
        expect(st.roundIndex, 1);
        expect(st.task!.role, PlannedTaskRole.recallQuestion);
        expect(st.stage, TaskStage.answer);
        expect(e.events.attempts, isEmpty); // запись создаётся при ответе

        e.submitAnswer(const TaskAnswer.recall('Р3'), t0 + 10000);
        expect(e.state.stage, TaskStage.study); // запоминание следующей
        e.endStudy(t0 + 13000); // «запомнил»: досрочно
        expect(e.state.blockIndex, 2);

        e.submitAnswer(const TaskAnswer.recall('К7'), t0 + 14000);
        expect(e.state.stage, TaskStage.study); // вырожденная: показ
        expect(e.state.task!.role, PlannedTaskRole.standard);
        e.tick(t0 + 14000 + 8000);
        expect(e.state.stage, TaskStage.answer);
        final st3 = e.submitAnswer(const TaskAnswer.recall('р3'), t0 + 25000);
        expect(st3.status, EngineStatus.finished);

        final a = e.events.attempts;
        expect(a, hasLength(3));
        expect(a.map((x) => x.roundIndex), [1, 2, 2]);
        expect(a.map((x) => x.blockIndex), [1, 2, 2]);
        expect(a.map((x) => x.encodedRoundIndex), [0, 1, 2]);
        expect(a.map((x) => x.isCorrect), [true, false, true]);
        expect(
          a.map((x) => x.archetype),
          everyElement(TaskArchetype.delayedRecall),
        );
        // presentedAt — когда вопрос стал виден, а не когда показали условие.
        expect(a[0].presentedAt, t0 + 8000);
        expect(a[0].latencyMs, 2000);
        expect(a[2].presentedAt, t0 + 22000);
        expect(a[2].latencyMs, 3000);
        expect(a.map((x) => x.taskId), everyElement('demo.mem.001'));
        expectValidEvents(e.events);
      },
    );

    test('срок окна во время показа попытку не пишет', () {
      final e = cognitiveEngine('demo.mem.001', windows: 1, cognitiveSec: 5)
        ..start(t0);
      expect(e.state.stage, TaskStage.study);
      expect(e.state.stageRemainingMs, 5000); // срок окна раньше конца показа
      e.tick(t0 + 5000);
      expect(e.status, EngineStatus.finished);
      expect(e.events.attempts, isEmpty);
    });

    test(
      'пропуск запоминания не пишет попытку, вопрос потом всё равно задан',
      () {
        final e = cognitiveEngine('demo.mem.001', windows: 2, cognitiveSec: 60)
          ..start(t0);
        e.skipTask(t0 + 1000);
        expect(e.events.attempts, isEmpty);
        expect(e.state.task!.role, PlannedTaskRole.recallQuestion);
      },
    );

    test('spatial: показ → ответ по клетке', () {
      final e = cognitiveEngine('demo.spa.001')..start(t0);
      expect(e.state.stage, TaskStage.study);
      expect(e.state.stageRemainingMs, 6000);
      expect(
        () => e.submitAnswer(TaskAnswer.spatial(row: 2, col: 3), t0 + 1000),
        throwsStateError,
      );
      final st = e.tick(t0 + 6000);
      expect(st.stage, TaskStage.answer);
      expect(st.stageRemainingMs, 20000);

      e.submitAnswer(TaskAnswer.spatial(row: 2, col: 3), t0 + 9000);
      final a = e.events.attempts.single;
      expect(a.isCorrect, isTrue);
      expect(a.response, '2,3');
      expect(a.presentedAt, t0 + 6000);
      expect(a.latencyMs, 3000);
      expect(a.encodedRoundIndex, isNull);
      expectValidEvents(e.events);
    });

    test('spatial: пропуск во время показа — skipped с началом показа', () {
      final e = cognitiveEngine('demo.spa.001')..start(t0);
      e.skipTask(t0 + 2000);
      final a = e.events.attempts.single;
      expect(a.status, AttemptStatus.skipped);
      expect(a.presentedAt, t0);
      expectValidEvents(e.events);
    });

    test('endStudy вне показа — ошибка', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      expect(() => e.endStudy(t0 + 100), throwsStateError);
    });
  });

  group('abort', () {
    final plan = planOf(
      plannerWith(
        sources: [
          sourceOf(packOf(['demo.java.002'])),
        ],
      ),
      SessionTemplate.dualTask(rounds: 2, cognitiveSec: 120),
    );
    final round0 = plan.blocks[0] as PlannedPhysicalBlock;

    test('посреди круга: записаны завершённые подходы и неполный круг', () {
      final e = engineOf(plan)..start(t0);
      e.completeSet(round0.exercises[0].prescribed, t0 + 20000);
      final st = e.abort(t0 + 30000);
      expect(st.status, EngineStatus.aborted);
      expect(st.endedAt, isNull);
      expect(st.phase, isNull);

      final ev = e.events;
      expect(ev.sets, hasLength(1)); // незаконченное упражнение не пишется
      expect(ev.rounds, hasLength(1));
      expect(ev.rounds.single.durationMs, 30000);
      expect(ev.rounds.single.rpe, isNull);
      expect(ev.sessions.single.endedAt, isNull); // SCHEMAS §3.1
      expectValidEvents(ev);

      // Дальше — только чтение.
      expect(() => e.completeSet(5, t0 + 40000), throwsStateError);
      expect(() => e.skipTask(t0 + 40000), throwsStateError);
      expect(e.tick(t0 + 50000).status, EngineStatus.aborted);
      expect(e.abort(t0 + 60000).status, EngineStatus.aborted);
      expect(e.events.rounds, hasLength(1));
    });

    test('в самом начале круга: ни подходов, ни круга — без сирот', () {
      final e = engineOf(plan)..start(t0);
      e.abort(t0 + 1000);
      expect(e.events.rounds, isEmpty);
      expect(e.events.sets, isEmpty);
      expect(e.events.sessions, hasLength(1));
      expectValidEvents(e.events);
    });

    test('посреди когнитивного окна: задача без ответа не пишется', () {
      final e = engineOf(plan)..start(t0);
      var c = t0;
      for (final ex in round0.exercises) {
        c += 10000;
        e.completeSet(ex.prescribed, c);
      }
      e.abort(c + 5000);
      final ev = e.events;
      expect(ev.attempts, isEmpty);
      expect(ev.rounds, hasLength(1)); // завершённый круг
      expect(ev.rounds.single.durationMs, 30000);
      expect(ev.sets, hasLength(3));
      expectValidEvents(ev);
    });

    test('abort применяет сначала истёкшие сроки', () {
      final e = cognitiveEngine('demo.java.002', windows: 2, cognitiveSec: 60)
        ..start(t0);
      e.abort(t0 + 40000); // первое окно истекло в t0+30000
      expect(e.events.attempts.single.status, AttemptStatus.timeout);
      expect(e.status, EngineStatus.aborted);
    });

    test('abort после конца сессии — пустая операция', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      e.tick(t0 + 40000);
      expect(e.abort(t0 + 50000).status, EngineStatus.finished);
      expect(e.events.sessions.single.endedAt, isNotNull);
    });
  });

  group('контракт вызовов', () {
    test('до старта и повторный старт', () {
      final e = cognitiveEngine('demo.java.002');
      expect(() => e.tick(t0), throwsStateError);
      expect(() => e.abort(t0), throwsStateError);
      expect(() => e.skipTask(t0), throwsStateError);
      expect(() => e.completeSet(1, t0), throwsStateError);
      expect(e.events.sessions, isEmpty);
      e.start(t0);
      expect(() => e.start(t0), throwsStateError);
    });

    test('время не идёт назад и укладывается в допустимый диапазон', () {
      final e = cognitiveEngine('demo.java.002');
      expect(() => e.start(-1), throwsRangeError);
      e.start(t0);
      e.tick(t0 + 1000);
      expect(() => e.tick(t0), throwsArgumentError);
      expect(() => e.skipTask(t0 + 500), throwsArgumentError);
      expect(() => e.tick(4102444800001), throwsRangeError);
    });

    test('действие не той фазы — StateError, состояние цело', () {
      final e = cognitiveEngine('demo.java.002')..start(t0);
      expect(() => e.completeSet(5, t0 + 1), throwsStateError);
      expect(e.state.phase, Phase.cognitive);

      final p = engineOf(
        planOf(plannerWith(), SessionTemplate.physicalOnly(rounds: 1)),
      )..start(t0);
      expect(
        () => p.submitAnswer(TaskAnswer.choice(0), t0 + 1),
        throwsStateError,
      );
      expect(() => p.skipTask(t0 + 1), throwsStateError);
      expect(() => p.completeSet(-1, t0 + 1), throwsRangeError);
      expect(() => p.completeSet(3601, t0 + 1), throwsRangeError);
      expect(p.state.phase, Phase.physical);
    });

    test('параметры сессии проверяются', () {
      final plan = planOf(
        plannerWith(),
        SessionTemplate.physicalOnly(rounds: 1),
      );
      expect(
        () => SessionEngine(
          plan: plan,
          ids: SeededIdSource(1),
          utcOffsetMin: 900,
        ),
        throwsRangeError,
      );
      expect(
        () => SessionEngine(plan: plan, ids: SeededIdSource(1), appVersion: ''),
        throwsArgumentError,
      );
    });

    test('utcOffsetMin и appVersion попадают в Session', () {
      final plan = planOf(
        plannerWith(),
        SessionTemplate.physicalOnly(rounds: 1),
      );
      final e = SessionEngine(
        plan: plan,
        ids: SeededIdSource(1),
        utcOffsetMin: 180,
        appVersion: '0.1.0+3',
      )..start(t0);
      final s = e.events.sessions.single;
      expect(s.utcOffsetMin, 180);
      expect(s.appVersion, '0.1.0+3');
      expectValidEvents(e.events);
    });
  });

  group('идентификаторы', () {
    test('SeededIdSource: UUID v4, воспроизводимы и различны', () {
      final a = SeededIdSource(5);
      final b = SeededIdSource(5);
      final ids = [for (var i = 0; i < 200; i++) a.nextId()];
      expect(ids, [for (var i = 0; i < 200; i++) b.nextId()]);
      expect(ids.toSet(), hasLength(200));
      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      for (final id in ids) {
        expect(id, matches(uuid));
      }
      expect(SeededIdSource(6).nextId(), isNot(ids.first));
    });
  });
}
