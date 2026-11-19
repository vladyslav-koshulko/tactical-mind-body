import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

/// БД в памяти. `dart:io` и sqlite3 нужны только тестам (в `lib/` их нет).
TmbDatabase openMemoryDb() => TmbDatabase(NativeDatabase.memory());

/// Детерминированный UUID v4: номер [n] в последней группе.
String uuid(int n) =>
    '00000000-0000-4000-8000-${n.toRadixString(16).padLeft(12, '0')}';

String hash(int n) => n.toRadixString(16).padLeft(64, '0');

const _t0 = 1795100000000;

Session session(
  int n, {
  int startedAt = _t0,
  int? endedAt = _t0 + 1500000,
  SessionTemplateKind template = SessionTemplateKind.dualTask,
}) => Session(
  id: uuid(n),
  startedAt: startedAt,
  endedAt: endedAt,
  utcOffsetMin: 180,
  location: Location.home,
  difficulty: DifficultyLevel.fighter,
  template: template,
  appVersion: '0.1.0+1',
);

RoundLog round(
  int n,
  String sessionId, {
  int blockIndex = 0,
  int roundIndex = 0,
  int? rpe = 2,
}) => RoundLog(
  id: uuid(n),
  sessionId: sessionId,
  blockIndex: blockIndex,
  roundIndex: roundIndex,
  durationMs: 214000,
  rpe: rpe,
);

ExerciseSet exerciseSet(
  int n,
  String sessionId,
  String roundId, {
  int setIndex = 0,
  String exerciseId = 'ex.pushup',
  ExerciseUnit unit = ExerciseUnit.reps,
  int prescribed = 15,
  int done = 15,
  int startedAt = _t0 + 10000,
}) => ExerciseSet(
  id: uuid(n),
  sessionId: sessionId,
  roundId: roundId,
  setIndex: setIndex,
  exerciseId: exerciseId,
  unit: unit,
  prescribed: prescribed,
  done: done,
  startedAt: startedAt,
  endedAt: startedAt + 40000,
);

/// Решённая проверяемая попытка (`choice`).
TaskAttempt answered(
  int n,
  String sessionId, {
  int blockIndex = 1,
  int roundIndex = 0,
  int presentedAt = _t0 + 220000,
  int latencyMs = 7391,
  bool isCorrect = true,
  double difficulty = 0.3,
  int seed = 1234567890,
}) => TaskAttempt(
  id: uuid(n),
  sessionId: sessionId,
  blockIndex: blockIndex,
  roundIndex: roundIndex,
  taskId: 'demo.java.002',
  packId: 'demo.ru',
  packSource: PackSource.builtin,
  archetype: TaskArchetype.choice,
  domain: 'it.java',
  difficulty: difficulty,
  seed: seed,
  status: AttemptStatus.answered,
  presentedAt: presentedAt,
  answeredAt: presentedAt + 7400,
  latencyMs: latencyMs,
  isCorrect: isCorrect,
  selfRating: null,
  response: '2',
  encodedRoundIndex: null,
  payloadHash: hash(n),
);

TaskAttempt timedOut(
  int n,
  String sessionId, {
  int blockIndex = 1,
  int roundIndex = 0,
  int presentedAt = _t0 + 260000,
}) => TaskAttempt(
  id: uuid(n),
  sessionId: sessionId,
  blockIndex: blockIndex,
  roundIndex: roundIndex,
  taskId: 'demo.java.001',
  packId: 'demo.ru',
  packSource: PackSource.imported,
  archetype: TaskArchetype.recall,
  domain: 'it.java',
  difficulty: 0.2,
  seed: 7,
  status: AttemptStatus.timeout,
  presentedAt: presentedAt,
  answeredAt: null,
  latencyMs: null,
  isCorrect: false,
  selfRating: null,
  response: null,
  encodedRoundIndex: null,
  payloadHash: hash(n),
);

/// `verbal`: не проверяется машиной (`isCorrect == null`), есть самооценка.
TaskAttempt verbal(
  int n,
  String sessionId, {
  int blockIndex = 3,
  int roundIndex = 1,
  int presentedAt = _t0 + 500000,
}) => TaskAttempt(
  id: uuid(n),
  sessionId: sessionId,
  blockIndex: blockIndex,
  roundIndex: roundIndex,
  taskId: 'demo.ver.001',
  packId: 'demo.ru',
  packSource: PackSource.user,
  archetype: TaskArchetype.verbal,
  domain: 'cog.speech',
  difficulty: 0.45,
  seed: 123456789012345,
  status: AttemptStatus.answered,
  presentedAt: presentedAt,
  answeredAt: presentedAt + 60000,
  latencyMs: 60000,
  isCorrect: null,
  selfRating: 2,
  response: null,
  encodedRoundIndex: null,
  payloadHash: hash(n),
);

/// `delayed_recall` с фазой запоминания в круге 0, вспоминание — в круге 1.
TaskAttempt delayed(
  int n,
  String sessionId, {
  int blockIndex = 3,
  int roundIndex = 1,
  int presentedAt = _t0 + 700000,
}) => TaskAttempt(
  id: uuid(n),
  sessionId: sessionId,
  blockIndex: blockIndex,
  roundIndex: roundIndex,
  taskId: 'mem.delayed.001',
  packId: 'memory.delayed.ru',
  packSource: PackSource.builtin,
  archetype: TaskArchetype.delayedRecall,
  domain: 'cog.memory',
  difficulty: 0.6,
  seed: 42,
  status: AttemptStatus.answered,
  presentedAt: presentedAt,
  answeredAt: presentedAt + 9000,
  latencyMs: 9000,
  isCorrect: false,
  selfRating: null,
  response: 'Вольфрам',
  encodedRoundIndex: 0,
  payloadHash: hash(n),
);

TaskAttempt skipped(
  int n,
  String sessionId, {
  int blockIndex = 3,
  int roundIndex = 1,
  int presentedAt = _t0 + 800000,
}) => TaskAttempt(
  id: uuid(n),
  sessionId: sessionId,
  blockIndex: blockIndex,
  roundIndex: roundIndex,
  taskId: 'demo.java.002',
  packId: 'demo.ru',
  packSource: PackSource.builtin,
  archetype: TaskArchetype.choice,
  domain: 'it.java',
  difficulty: 0.3,
  seed: 5,
  status: AttemptStatus.skipped,
  presentedAt: presentedAt,
  answeredAt: null,
  latencyMs: null,
  isCorrect: false,
  selfRating: null,
  response: null,
  encodedRoundIndex: null,
  payloadHash: hash(n),
);

/// Полная dual-task сессия: 2 физических круга, 3 упражнения в каждом и
/// попытки всех статусов. Идентификаторы — от [base] (занимает 40 номеров).
SessionBundle fullSession(int base, {int startedAt = _t0}) {
  final s = session(base, startedAt: startedAt, endedAt: startedAt + 1500000);
  final r0 = round(base + 1, s.id, blockIndex: 0, roundIndex: 0, rpe: 3);
  final r1 = round(base + 2, s.id, blockIndex: 2, roundIndex: 1, rpe: null);
  return SessionBundle(
    session: s,
    rounds: [r0, r1],
    sets: [
      for (var i = 0; i < 3; i++)
        exerciseSet(
          base + 3 + i,
          s.id,
          r0.id,
          setIndex: i,
          exerciseId: ['ex.pushup', 'ex.plank', 'ex.squat'][i],
          unit: i == 1 ? ExerciseUnit.seconds : ExerciseUnit.reps,
          prescribed: i == 1 ? 30 : 15,
          done: i == 1 ? 30 : 12 + i,
          startedAt: startedAt + 10000 + i * 45000,
        ),
      for (var i = 0; i < 3; i++)
        exerciseSet(
          base + 6 + i,
          s.id,
          r1.id,
          setIndex: i,
          exerciseId: ['ex.pushup', 'ex.plank', 'ex.squat'][i],
          unit: i == 1 ? ExerciseUnit.seconds : ExerciseUnit.reps,
          prescribed: i == 1 ? 30 : 15,
          done: i == 1 ? 25 : 10,
          startedAt: startedAt + 400000 + i * 45000,
        ),
    ],
    attempts: [
      answered(base + 10, s.id, presentedAt: startedAt + 220000),
      timedOut(base + 11, s.id, presentedAt: startedAt + 260000),
      verbal(base + 12, s.id, presentedAt: startedAt + 500000),
      delayed(base + 13, s.id, presentedAt: startedAt + 700000),
      skipped(base + 14, s.id, presentedAt: startedAt + 800000),
    ],
  );
}

Uint8List jsonBytes(Object doc) =>
    Uint8List.fromList(utf8.encode(jsonEncode(doc)));

/// Проверка экспорта настоящим валидатором из `tmb_domain`.
ValidationResult validateExport(EventsExport export) => validate(
  jsonBytes(export.toJson()),
  const ValidationContext(expectedKind: DocumentKind.eventsExport),
);

/// У моделей событий нет `==`; сравниваем по каноническому JSON.
List<Map<String, Object?>> jsons(Iterable<Object> items) => [
  for (final e in items)
    switch (e) {
      Session() => e.toJson(),
      RoundLog() => e.toJson(),
      ExerciseSet() => e.toJson(),
      TaskAttempt() => e.toJson(),
      _ => throw ArgumentError(e),
    },
];
