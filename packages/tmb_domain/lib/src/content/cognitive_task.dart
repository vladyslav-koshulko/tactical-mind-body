import '../common/json_reader.dart';
import 'accept.dart';
import 'cue.dart';
import 'spatial_types.dart';
import 'task_archetype.dart';

/// Задача пака — ровно семь наследников по архетипам (инвариант 3).
///
/// Классов под тему (Java, такмед, латынь…) здесь быть не должно: тема — это
/// `domain` и содержимое полей, то есть данные пака.
sealed class CognitiveTask {
  const CognitiveTask({
    required this.id,
    required this.domain,
    required this.verifiable,
    required this.timeSec,
    required this.difficulty,
    required this.prompt,
  });

  /// Читает задачу, выбирая наследника по `archetype`.
  factory CognitiveTask.fromJson(Map<String, Object?> json) =>
      CognitiveTask.read(readRoot(json));

  factory CognitiveTask.read(JsonObj o) {
    final archetype = o.enumValue('archetype', TaskArchetype.values);
    final id = o.string('id');
    final domain = o.string('domain');
    final verifiable = o.boolean('verifiable');
    final timeSec = o.integer('timeSec');
    final difficulty = o.dbl('difficulty');
    final prompt = o.text('prompt');
    return switch (archetype) {
      TaskArchetype.recall => RecallTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        answer: o.req('answer', convAnswerValue),
        accept: o.opt('accept', Accept.read),
        reveal: o.textOpt('reveal'),
      ),
      TaskArchetype.choice => ChoiceTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        options: o.req('options', listOf(convText)),
        answer: o.integer('answer'),
        shuffle: o.booleanOpt('shuffle'),
        reveal: o.textOpt('reveal'),
      ),
      TaskArchetype.ordering => OrderingTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        items: o.req('items', listOf(convText)),
        reveal: o.textOpt('reveal'),
      ),
      TaskArchetype.delayedRecall => DelayedRecallTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        memorize: o.text('memorize'),
        question: o.text('question'),
        answer: o.req('answer', convAnswerValue),
        accept: o.opt('accept', Accept.read),
        delayRounds: o.integerOpt('delayRounds'),
        showSec: o.integerOpt('showSec'),
        reveal: o.textOpt('reveal'),
      ),
      TaskArchetype.spatial => SpatialTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        grid: GridSize.read(o.object('grid')),
        answer: CellPosition.read(o.object('answer')),
        objects: o.opt(
          'objects',
          listOf((v, p) => SpatialObject.read(convObject(v, p))),
        ),
        showSec: o.integerOpt('showSec'),
        reveal: o.textOpt('reveal'),
      ),
      TaskArchetype.stream => StreamTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        stimuli: o.req('stimuli', listOf(convText)),
        targets: o.req('targets', listOf(convText)),
        stimulusMs: o.integerOpt('stimulusMs'),
        reveal: o.textOpt('reveal'),
      ),
      // У verbal нет `reveal` (решение 22): даже если он есть в файле, он
      // игнорируется — после непроверяемой задачи показывают чек-лист.
      TaskArchetype.verbal => VerbalTask(
        id: id,
        domain: domain,
        verifiable: verifiable,
        timeSec: timeSec,
        difficulty: difficulty,
        prompt: prompt,
        selfCheck: o.req('selfCheck', listOf(convText)),
        cues: o.opt('cues', listOf((v, p) => Cue.read(convObject(v, p)))),
      ),
    };
  }

  /// `id` задачи, уникален в паке.
  final String id;

  /// Путь категории, `cog.uncertainty.estimation`.
  final String domain;

  /// Хранится явно, хотя выводится из архетипа (решение 9).
  final bool verifiable;

  /// Лимит времени; для многофазных — лимит каждой фазы.
  final int timeSec;

  /// Оценка автора 0…1, не калиброванная.
  final double difficulty;
  final String prompt;

  TaskArchetype get archetype;

  Map<String, Object?> toJson() => {
    'id': id,
    'domain': domain,
    'archetype': archetype.wire,
    'verifiable': verifiable,
    'timeSec': timeSec,
    'difficulty': difficulty,
    'prompt': prompt,
  };
}

/// Ввести ответ.
final class RecallTask extends CognitiveTask {
  const RecallTask({
    required super.id,
    required super.domain,
    super.verifiable = true,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.answer,
    this.accept,
    this.reveal,
  });

  /// `String` или `num`.
  final Object answer;
  final Accept? accept;
  final String? reveal;

  @override
  TaskArchetype get archetype => TaskArchetype.recall;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'answer': answer,
    'accept': ?accept?.toJson(),
    'reveal': ?reveal,
  };
}

/// Выбрать из N вариантов.
final class ChoiceTask extends CognitiveTask {
  const ChoiceTask({
    required super.id,
    required super.domain,
    super.verifiable = true,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.options,
    required this.answer,
    this.shuffle,
    this.reveal,
  });

  final List<String> options;

  /// Индекс в [options] по исходному порядку.
  final int answer;

  /// Как записано в файле; `null` — не указано (по умолчанию `true`).
  final bool? shuffle;
  final String? reveal;

  /// Перемешивать ли варианты при показе (по умолчанию да).
  bool get shufflesOptions => shuffle ?? true;

  @override
  TaskArchetype get archetype => TaskArchetype.choice;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'options': options,
    'answer': answer,
    'shuffle': ?shuffle,
    'reveal': ?reveal,
  };
}

/// Упорядочить шаги.
final class OrderingTask extends CognitiveTask {
  const OrderingTask({
    required super.id,
    required super.domain,
    super.verifiable = true,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.items,
    this.reveal,
  });

  /// Верный порядок шагов.
  final List<String> items;
  final String? reveal;

  @override
  TaskArchetype get archetype => TaskArchetype.ordering;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'items': items,
    'reveal': ?reveal,
  };
}

/// Запомнить сейчас — ответить через [delayRounds] кругов.
final class DelayedRecallTask extends CognitiveTask {
  const DelayedRecallTask({
    required super.id,
    required super.domain,
    super.verifiable = true,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.memorize,
    required this.question,
    required this.answer,
    this.accept,
    this.delayRounds,
    this.showSec,
    this.reveal,
  });

  /// Значение по умолчанию для `delayRounds` (SCHEMAS §1.4).
  static const defaultDelayRounds = 1;

  /// Значение по умолчанию для `showSec` (SCHEMAS §1.4).
  static const defaultShowSec = 10;

  final String memorize;
  final String question;

  /// `String` или `num`.
  final Object answer;
  final Accept? accept;

  /// Как записано в файле; `null` — не указано.
  final int? delayRounds;
  final int? showSec;
  final String? reveal;

  int get effectiveDelayRounds => delayRounds ?? defaultDelayRounds;
  int get effectiveShowSec => showSec ?? defaultShowSec;

  @override
  TaskArchetype get archetype => TaskArchetype.delayedRecall;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'memorize': memorize,
    'question': question,
    'answer': answer,
    'accept': ?accept?.toJson(),
    'delayRounds': ?delayRounds,
    'showSec': ?showSec,
    'reveal': ?reveal,
  };
}

/// Работа с сеткой: статическая форма v1.
final class SpatialTask extends CognitiveTask {
  const SpatialTask({
    required super.id,
    required super.domain,
    super.verifiable = true,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.grid,
    required this.answer,
    this.objects,
    this.showSec,
    this.reveal,
  });

  /// Значение по умолчанию для `showSec` (SCHEMAS §1.4).
  static const defaultShowSec = 10;

  final GridSize grid;
  final CellPosition answer;
  final List<SpatialObject>? objects;
  final int? showSec;
  final String? reveal;

  int get effectiveShowSec => showSec ?? defaultShowSec;

  @override
  TaskArchetype get archetype => TaskArchetype.spatial;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'grid': grid.toJson(),
    'answer': answer.toJson(),
    'objects': ?objects?.map((e) => e.toJson()).toList(),
    'showSec': ?showSec,
    'reveal': ?reveal,
  };
}

/// Поток стимулов на скорость (go/no-go): статическая форма v1.
final class StreamTask extends CognitiveTask {
  const StreamTask({
    required super.id,
    required super.domain,
    super.verifiable = true,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.stimuli,
    required this.targets,
    this.stimulusMs,
    this.reveal,
  });

  /// Значение по умолчанию для `stimulusMs` (SCHEMAS §1.4).
  static const defaultStimulusMs = 1000;

  final List<String> stimuli;
  final List<String> targets;
  final int? stimulusMs;
  final String? reveal;

  int get effectiveStimulusMs => stimulusMs ?? defaultStimulusMs;

  @override
  TaskArchetype get archetype => TaskArchetype.stream;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'stimuli': stimuli,
    'targets': targets,
    'stimulusMs': ?stimulusMs,
    'reveal': ?reveal,
  };
}

/// Произнести вслух, самооценка. Не проверяется машиной (инвариант 7).
final class VerbalTask extends CognitiveTask {
  const VerbalTask({
    required super.id,
    required super.domain,
    super.verifiable = false,
    required super.timeSec,
    required super.difficulty,
    required super.prompt,
    required this.selfCheck,
    this.cues,
  });

  /// 2…3 вопроса «да/нет».
  final List<String> selfCheck;
  final List<Cue>? cues;

  @override
  TaskArchetype get archetype => TaskArchetype.verbal;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'selfCheck': selfCheck,
    'cues': ?cues?.map((e) => e.toJson()).toList(),
  };
}
