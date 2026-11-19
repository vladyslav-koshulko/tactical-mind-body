import '../cognitive/answer_matching.dart' show normalizeAnswer;
import 'checker.dart';
import 'schema_constants.dart';
import 'validation_code.dart';

const _commonKeys = {
  'id',
  'domain',
  'archetype',
  'verifiable',
  'timeSec',
  'difficulty',
  'prompt',
};

/// Поля по архетипам — таблица SCHEMAS §1.4.
const _archetypeKeys = <String, Set<String>>{
  'recall': {'answer', 'accept', 'reveal'},
  'choice': {'options', 'answer', 'shuffle', 'reveal'},
  'ordering': {'items', 'reveal'},
  'delayed_recall': {
    'memorize',
    'question',
    'answer',
    'accept',
    'delayRounds',
    'showSec',
    'reveal',
  },
  'spatial': {'grid', 'objects', 'answer', 'showSec', 'reveal'},
  'stream': {'stimuli', 'targets', 'stimulusMs', 'reveal'},
  'verbal': {'selfCheck', 'cues'},
};

final _allTaskKeys = {
  ..._commonKeys,
  for (final keys in _archetypeKeys.values) ...keys,
};

/// Результат проверки одной задачи: то, что нужно пакетным правилам.
final class TaskFacts {
  /// `id`, если он по паттерну; иначе `null`.
  String? id;

  /// `domain`, если он по паттерну; иначе `null`.
  String? domain;

  /// `prompt` в нормализованном для сравнения виде.
  String? promptKey;
}

/// Проверяет одну задачу `items[i]` по правилам SCHEMAS §1.3–§1.4 и §6.2.
///
/// Дубликаты `id`/`prompt` и «домен объявлен» проверяет вызывающий: для этого
/// нужен контекст всего пака.
TaskFacts validateTask(Map<String, Object?> t, String p, Checker c) {
  final facts = TaskFacts();
  final limits = c.limits;

  // id
  final idRaw = c.take(t, p, 'id');
  if (idRaw != null) {
    facts.id = c.pattern(
      idRaw,
      joinKey(p, 'id'),
      taskIdPattern,
      ValidationCode.packBadId,
      'Идентификатор задачи',
    );
  }

  // domain
  final domainRaw = c.take(t, p, 'domain');
  if (domainRaw != null) {
    facts.domain = c.pattern(
      domainRaw,
      joinKey(p, 'domain'),
      domainPattern,
      ValidationCode.packBadDomain,
      'Домен',
    );
  }

  // archetype
  String? archetype;
  final archRaw = c.take(t, p, 'archetype');
  if (archRaw != null) {
    archetype = c.wire(
      archRaw,
      joinKey(p, 'archetype'),
      archetypeWires,
      ValidationCode.packBadArchetype,
      'Архетип',
    );
  }

  // verifiable
  final verifiable = c.takeBool(t, p, 'verifiable');
  if (verifiable != null && archetype != null) {
    if (archetype == 'verbal' && verifiable) {
      c.add(
        ValidationCode.packVerbalVerifiable,
        joinKey(p, 'verifiable'),
        'У задачи verbal «verifiable» должно быть false: машина её не проверяет.',
      );
    } else if (archetype != 'verbal' && !verifiable) {
      c.add(
        ValidationCode.packNonverbalUnverifiable,
        joinKey(p, 'verifiable'),
        'Проверяемая задача ($archetype) должна иметь «verifiable»: true.',
      );
    }
  }

  // timeSec
  final timeRaw = c.take(t, p, 'timeSec');
  int? timeSec;
  if (timeRaw != null) {
    timeSec = c.intIn(
      timeRaw,
      joinKey(p, 'timeSec'),
      min: 5,
      max: 180,
      code: ValidationCode.packBadTime,
      what: 'Время на задачу «timeSec»',
    );
    if (timeSec != null && timeSec > 120) {
      c.add(
        ValidationCode.packTimeLong,
        joinKey(p, 'timeSec'),
        'Время $timeSec с больше 120 с: пауза длится 180 с, часть уходит на чтение.',
      );
    }
  }

  // difficulty
  final diffRaw = c.take(t, p, 'difficulty');
  if (diffRaw != null) {
    final n = c.number(diffRaw, joinKey(p, 'difficulty'));
    if (n != null && (n < 0 || n > 1)) {
      c.add(
        ValidationCode.packBadDifficulty,
        joinKey(p, 'difficulty'),
        'Сложность «difficulty» должна быть числом от 0 до 1.',
      );
    }
  }

  // prompt
  final prompt = c.takeText(
    t,
    p,
    'prompt',
    max: limits.promptLength,
    multiline: true,
  );
  if (prompt != null) facts.promptKey = normalizeForCompare(prompt);

  // Поля по архетипу.
  if (archetype != null) {
    switch (archetype) {
      case 'recall':
        _answerAndAccept(t, p, c);
        _reveal(t, p, c);
      case 'choice':
        _choice(t, p, c);
        _reveal(t, p, c);
      case 'ordering':
        _ordering(t, p, c);
        _reveal(t, p, c);
      case 'delayed_recall':
        c.takeText(
          t,
          p,
          'memorize',
          max: limits.memorizeLength,
          multiline: true,
        );
        c.takeText(
          t,
          p,
          'question',
          max: limits.questionLength,
          multiline: true,
        );
        _answerAndAccept(t, p, c);
        _param(t, p, c, 'delayRounds', 1, 3);
        _param(t, p, c, 'showSec', 3, 60);
        _reveal(t, p, c);
      case 'spatial':
        _spatial(t, p, c);
        _param(t, p, c, 'showSec', 3, 60);
        _reveal(t, p, c);
      case 'stream':
        _stream(t, p, c);
        _param(t, p, c, 'stimulusMs', 200, 5000);
        _reveal(t, p, c);
      case 'verbal':
        _verbal(t, p, c, timeSec);
    }
    final known = {..._commonKeys, ..._archetypeKeys[archetype]!};
    c.unknownFields(
      t,
      p,
      known,
      notAllowed: _allTaskKeys.difference(known),
      reserveGen: true,
    );
  } else {
    c.unknownFields(t, p, _allTaskKeys, reserveGen: true);
  }
  return facts;
}

// --- общие поля архетипов -----------------------------------------------------

void _reveal(Map<String, Object?> t, String p, Checker c) {
  c.takeText(
    t,
    p,
    'reveal',
    max: c.limits.revealLength,
    required: false,
    multiline: true,
  );
}

void _param(
  Map<String, Object?> t,
  String p,
  Checker c,
  String key,
  int min,
  int max,
) {
  final v = c.take(t, p, key, required: false);
  if (v == null) return;
  c.intIn(
    v,
    joinKey(p, key),
    min: min,
    max: max,
    code: ValidationCode.packParamRange,
    what: 'Параметр «$key»',
  );
}

/// Массив строк [min]…[max]: слишком мало/много — [countCode]; общий код
/// `PACK_LIMIT_ARRAY` — когда у массива нет собственного кода.
List<String>? _stringArray(
  Map<String, Object?> t,
  String p,
  Checker c,
  String key, {
  required int min,
  required int max,
  required int itemMax,
  ValidationCode countCode = ValidationCode.packLimitArray,
  bool required = true,
}) {
  final at = joinKey(p, key);
  final raw = c.takeArray(t, p, key, required: required);
  if (raw == null) return null;
  if (raw.length < min || raw.length > max) {
    c.add(
      countCode,
      at,
      'Массив «$key» должен содержать от $min до $max элементов '
      '(сейчас ${raw.length}).',
    );
    return null;
  }
  final out = <String>[];
  var ok = true;
  for (var i = 0; i < raw.length; i++) {
    final s = c.text(raw[i], joinIndex(at, i), max: itemMax);
    if (s == null) {
      ok = false;
    } else {
      out.add(s);
    }
  }
  return ok ? out : null;
}

// --- recall / delayed_recall: answer и accept -----------------------------------

void _answerAndAccept(Map<String, Object?> t, String p, Checker c) {
  final limits = c.limits;
  final at = joinKey(p, 'answer');
  final raw = c.take(t, p, 'answer');
  Object? answer;
  if (raw is String) {
    answer = c.text(raw, at, max: limits.answerLength);
  } else if (raw is num) {
    answer = c.number(raw, at);
  } else if (raw != null) {
    c.add(ValidationCode.packBadType, at, 'Ответ «answer» — строка или число.');
  }

  final acceptRaw = c.take(t, p, 'accept', required: false);
  if (acceptRaw == null || answer == null) return;
  final acceptAt = joinKey(p, 'accept');

  if (acceptRaw is List<Object?>) {
    _acceptList(acceptRaw, acceptAt, answer, c);
  } else if (acceptRaw is Map<String, Object?>) {
    _acceptRange(acceptRaw, acceptAt, answer, c);
  } else {
    c.add(
      ValidationCode.packAcceptInvalid,
      acceptAt,
      '«accept» — массив допустимых значений или объект {min, max}.',
    );
  }
}

bool _sameAnswer(Object a, Object b) {
  if (a is num && b is num) return a == b;
  if (a is String && b is String) {
    final na = normalizeAnswer(a);
    final nb = normalizeAnswer(b);
    if (na.number != null && nb.number != null) return na.number == nb.number;
    return na.text == nb.text;
  }
  return false;
}

void _acceptList(List<Object?> raw, String at, Object answer, Checker c) {
  if (raw.isEmpty) {
    c.add(
      ValidationCode.packAcceptInvalid,
      at,
      'Массив «accept» не может быть пустым.',
    );
    return;
  }
  if (raw.length > 20) {
    c.add(
      ValidationCode.packLimitArray,
      at,
      'В «accept» не больше 20 значений (сейчас ${raw.length}).',
    );
    return;
  }
  final values = <Object>[];
  var ok = true;
  for (var i = 0; i < raw.length; i++) {
    final v = raw[i];
    final itemAt = joinIndex(at, i);
    Object? parsed;
    if (answer is String) {
      if (v is String) {
        parsed = c.text(v, itemAt, max: c.limits.answerLength);
      } else {
        c.add(
          ValidationCode.packAcceptInvalid,
          itemAt,
          'Элементы «accept» должны быть строками, как и «answer».',
        );
      }
    } else {
      if (v is num) {
        parsed = c.number(v, itemAt);
      } else {
        c.add(
          ValidationCode.packAcceptInvalid,
          itemAt,
          'Элементы «accept» должны быть числами, как и «answer».',
        );
      }
    }
    if (parsed == null) {
      ok = false;
      continue;
    }
    if (values.any((x) => _sameAnswer(x, parsed!))) {
      c.add(
        ValidationCode.packAcceptInvalid,
        itemAt,
        'Значение «accept» повторяется.',
      );
      ok = false;
      continue;
    }
    values.add(parsed);
  }
  if (ok && !values.any((x) => _sameAnswer(x, answer))) {
    c.add(
      ValidationCode.packAnswerNotAccepted,
      at,
      'Ответ «answer» обязан входить в «accept».',
    );
  }
}

void _acceptRange(
  Map<String, Object?> raw,
  String at,
  Object answer,
  Checker c,
) {
  c.unknownFields(raw, at, const {'min', 'max'});
  if (answer is! num) {
    c.add(
      ValidationCode.packAcceptInvalid,
      at,
      'Диапазон {min, max} допустим только при числовом «answer».',
    );
    return;
  }
  final bounds = <num>[];
  for (final key in const ['min', 'max']) {
    final v = raw[key];
    if (!raw.containsKey(key) || v is! num) {
      c.add(
        ValidationCode.packAcceptInvalid,
        joinKey(at, key),
        'В диапазоне «accept» нужна числовая граница «$key».',
      );
      continue;
    }
    final n = c.number(v, joinKey(at, key));
    if (n != null) bounds.add(n);
  }
  if (bounds.length != 2) return;
  final lo = bounds[0];
  final hi = bounds[1];
  if (lo > hi) {
    c.add(ValidationCode.packAcceptInvalid, at, 'Граница «min» больше «max».');
    return;
  }
  if (answer < lo || answer > hi) {
    c.add(
      ValidationCode.packAnswerNotAccepted,
      at,
      'Ответ «answer» лежит вне диапазона [min, max].',
    );
  }
}

// --- choice -------------------------------------------------------------------

void _choice(Map<String, Object?> t, String p, Checker c) {
  final limits = c.limits;
  final optionsAt = joinKey(p, 'options');
  final rawOptions = c.takeArray(t, p, 'options');
  int? optionCount;
  if (rawOptions != null) {
    if (rawOptions.length < 2 || rawOptions.length > 8) {
      c.add(
        ValidationCode.packChoiceOptions,
        optionsAt,
        'Вариантов ответа должно быть от 2 до 8 (сейчас ${rawOptions.length}).',
      );
    } else {
      optionCount = rawOptions.length;
      final seen = <String>{};
      for (var i = 0; i < rawOptions.length; i++) {
        final s = c.text(
          rawOptions[i],
          joinIndex(optionsAt, i),
          max: limits.optionLength,
        );
        if (s == null) continue;
        if (!seen.add(normalizeAnswer(s).text)) {
          c.add(
            ValidationCode.packChoiceOptions,
            joinIndex(optionsAt, i),
            'Варианты ответа должны различаться после нормализации.',
          );
        }
      }
    }
  }

  final answerAt = joinKey(p, 'answer');
  final rawAnswer = c.take(t, p, 'answer');
  if (rawAnswer != null) {
    final n = c.number(rawAnswer, answerAt);
    if (n != null) {
      final upper = optionCount == null ? null : optionCount - 1;
      if (n is! int || n < 0 || (upper != null && n > upper)) {
        c.add(
          ValidationCode.packChoiceAnswerRange,
          answerAt,
          upper == null
              ? 'Ответ «answer» — индекс варианта, целое неотрицательное число.'
              : 'Ответ «answer» — индекс варианта от 0 до $upper.',
        );
      }
    }
  }
  c.takeBool(t, p, 'shuffle', required: false);
}

// --- ordering -----------------------------------------------------------------

void _ordering(Map<String, Object?> t, String p, Checker c) {
  final at = joinKey(p, 'items');
  final raw = c.takeArray(t, p, 'items');
  if (raw == null) return;
  if (raw.length < 2 || raw.length > 12) {
    c.add(
      ValidationCode.packOrderingSize,
      at,
      'Шагов должно быть от 2 до 12 (сейчас ${raw.length}).',
    );
    return;
  }
  final seen = <String>{};
  for (var i = 0; i < raw.length; i++) {
    final s = c.text(
      raw[i],
      joinIndex(at, i),
      max: c.limits.orderingItemLength,
    );
    if (s == null) continue;
    if (!seen.add(normalizeAnswer(s).text)) {
      c.add(
        ValidationCode.packOrderingDup,
        joinIndex(at, i),
        'Шаги не должны повторяться (после нормализации).',
      );
    }
  }
}

// --- spatial ------------------------------------------------------------------

void _spatial(Map<String, Object?> t, String p, Checker c) {
  final gridAt = joinKey(p, 'grid');
  final grid = c.takeObject(t, p, 'grid');
  int? rows;
  int? cols;
  if (grid != null) {
    c.unknownFields(grid, gridAt, const {'rows', 'cols'});
    rows = _dimension(grid, gridAt, c, 'rows');
    cols = _dimension(grid, gridAt, c, 'cols');
  }

  final answerAt = joinKey(p, 'answer');
  final answer = c.takeObject(t, p, 'answer');
  if (answer != null) {
    c.unknownFields(answer, answerAt, const {'row', 'col'});
    _cell(answer, answerAt, c, rows, cols, 'Ответ');
  }

  final objectsAt = joinKey(p, 'objects');
  final objects = c.takeArray(t, p, 'objects', required: false);
  if (objects == null) return;
  if (objects.length > 40) {
    c.add(
      ValidationCode.packLimitArray,
      objectsAt,
      'Объектов на сетке не больше 40 (сейчас ${objects.length}).',
    );
    return;
  }
  final occupied = <String>{};
  for (var i = 0; i < objects.length; i++) {
    final at = joinIndex(objectsAt, i);
    final o = c.object(objects[i], at);
    if (o == null) continue;
    c.unknownFields(o, at, const {'label', 'row', 'col'});
    c.takeText(o, at, 'label', max: c.limits.objectLabelLength);
    final cell = _cell(o, at, c, rows, cols, 'Объект');
    if (cell != null && !occupied.add(cell)) {
      c.add(
        ValidationCode.packSpatialOverlap,
        at,
        'Два объекта в одной клетке ($cell).',
      );
    }
  }
}

int? _dimension(Map<String, Object?> grid, String at, Checker c, String key) {
  final v = c.take(grid, at, key);
  if (v == null) return null;
  return c.intIn(
    v,
    joinKey(at, key),
    min: 2,
    max: 12,
    code: ValidationCode.packSpatialBounds,
    what: 'Размер сетки «$key»',
  );
}

/// Клетка `{row, col}`; возвращает `row,col` или `null`.
String? _cell(
  Map<String, Object?> o,
  String at,
  Checker c,
  int? rows,
  int? cols,
  String what,
) {
  final row = _coordinate(o, at, c, 'row', rows, what);
  final col = _coordinate(o, at, c, 'col', cols, what);
  return row == null || col == null ? null : '$row,$col';
}

int? _coordinate(
  Map<String, Object?> o,
  String at,
  Checker c,
  String key,
  int? size,
  String what,
) {
  final v = c.take(o, at, key);
  if (v == null) return null;
  return c.intIn(
    v,
    joinKey(at, key),
    min: 0,
    max: size == null ? 11 : size - 1,
    code: ValidationCode.packSpatialBounds,
    what: '$what: «$key» (с нуля, внутри сетки)',
  );
}

// --- stream -------------------------------------------------------------------

void _stream(Map<String, Object?> t, String p, Checker c) {
  final limits = c.limits;
  final stimuli = _stringArray(
    t,
    p,
    c,
    'stimuli',
    min: 2,
    max: 60,
    itemMax: limits.stimulusLength,
  );
  final targets = _stringArray(
    t,
    p,
    c,
    'targets',
    min: 1,
    max: 10,
    itemMax: limits.stimulusLength,
  );
  if (stimuli == null || targets == null) return;
  final shown = stimuli.toSet();
  for (var i = 0; i < targets.length; i++) {
    if (!shown.contains(targets[i])) {
      c.add(
        ValidationCode.packStreamTargets,
        joinIndex(joinKey(p, 'targets'), i),
        'Цель «${targets[i]}» не встречается в «stimuli».',
      );
    }
  }
  if (!stimuli.any(targets.contains)) {
    c.add(
      ValidationCode.packStreamTargets,
      joinKey(p, 'stimuli'),
      'В «stimuli» нет ни одной цели из «targets».',
    );
  }
}

// --- verbal -------------------------------------------------------------------

void _verbal(Map<String, Object?> t, String p, Checker c, int? timeSec) {
  final limits = c.limits;

  final selfAt = joinKey(p, 'selfCheck');
  if (!t.containsKey('selfCheck')) {
    c.add(
      ValidationCode.packNoSelfcheck,
      selfAt,
      'У задачи verbal нет «selfCheck»: без чек-листа самооценки она бесполезна.',
    );
  } else {
    final raw = c.takeArray(t, p, 'selfCheck');
    if (raw != null) {
      if (raw.length < 2 || raw.length > 3) {
        c.add(
          ValidationCode.packSelfcheckCount,
          selfAt,
          'В «selfCheck» должно быть 2–3 вопроса (сейчас ${raw.length}).',
        );
      } else {
        for (var i = 0; i < raw.length; i++) {
          c.text(raw[i], joinIndex(selfAt, i), max: limits.selfCheckLength);
        }
      }
    }
  }

  final cuesAt = joinKey(p, 'cues');
  final cues = c.takeArray(t, p, 'cues', required: false);
  if (cues == null) return;
  if (cues.length > 5) {
    c.add(
      ValidationCode.packLimitArray,
      cuesAt,
      'Подсказок «cues» не больше 5 (сейчас ${cues.length}).',
    );
    return;
  }
  int? previousEnd;
  for (var i = 0; i < cues.length; i++) {
    final at = joinIndex(cuesAt, i);
    final cue = c.object(cues[i], at);
    if (cue == null) {
      previousEnd = null;
      continue;
    }
    c.unknownFields(cue, at, const {'atSec', 'text'});
    // Пустой или слишком длинный текст подсказки — PACK_CUE_RANGE (правило 45).
    final textRaw = c.take(cue, at, 'text');
    if (textRaw != null) {
      c.text(
        textRaw,
        joinKey(at, 'text'),
        max: limits.cueTextLength,
        emptyCode: ValidationCode.packCueRange,
        longCode: ValidationCode.packCueRange,
      );
    }
    final range = _cueRange(cue, at, c, timeSec);
    if (range == null) {
      previousEnd = null;
      continue;
    }
    if (previousEnd != null && previousEnd >= range.$1) {
      c.add(
        ValidationCode.packCueOrder,
        joinKey(at, 'atSec'),
        'Диапазоны подсказок должны идти по порядку и не пересекаться.',
      );
    }
    previousEnd = range.$2;
    if (timeSec != null && range.$2 > timeSec - 10) {
      c.add(
        ValidationCode.packCueLate,
        joinKey(at, 'atSec'),
        'Подсказка может прийти позже ${timeSec - 10} с: на реакцию '
        'останется меньше 10 с.',
      );
    }
  }
}

(int, int)? _cueRange(
  Map<String, Object?> cue,
  String at,
  Checker c,
  int? timeSec,
) {
  final rangeAt = joinKey(at, 'atSec');
  final raw = c.take(cue, at, 'atSec');
  if (raw == null) return null;
  final list = c.array(raw, rangeAt);
  if (list == null) return null;
  String? fail;
  if (list.length != 2 || list[0] is! int || list[1] is! int) {
    fail = 'Диапазон «atSec» — два целых числа [a, b].';
  } else {
    final a = list[0]! as int;
    final b = list[1]! as int;
    if (a < 0 || a > b || (timeSec != null && b > timeSec)) {
      fail = timeSec == null
          ? 'Нужно 0 ≤ a ≤ b.'
          : 'Нужно 0 ≤ a ≤ b ≤ timeSec ($timeSec).';
    } else {
      return (a, b);
    }
  }
  c.add(ValidationCode.packCueRange, rangeAt, fail);
  return null;
}
