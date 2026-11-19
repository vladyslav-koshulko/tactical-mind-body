import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tmb_domain/tmb_domain.dart';

typedef Json = Map<String, Object?>;

/// Рабочие образцы валидных документов по видам (пути — от каталога пакета,
/// как в остальных тестах).
const samplePaths = {
  DocumentKind.taskPack: 'test/demo.pack.json',
  DocumentKind.exercisePack: 'test/exercises.sample.json',
  DocumentKind.eventsExport: 'test/events_export.sample.json',
  DocumentKind.profile: 'test/profile.sample.json',
};

/// Свежая глубокая копия образца: тест может её портить.
Json loadSample(DocumentKind kind) =>
    jsonDecode(File(samplePaths[kind]!).readAsStringSync()) as Json;

Uint8List encode(Object doc) =>
    Uint8List.fromList(utf8.encode(jsonEncode(doc)));

ValidationResult check(
  Object doc,
  DocumentKind kind, {
  ValidationContext? context,
}) => validate(encode(doc), context ?? ValidationContext(expectedKind: kind));

List<Object?> list(Json doc, String key) => doc[key]! as List<Object?>;

/// `items[i]` пака задач.
Json task(Json doc, int i) => list(doc, 'items')[i]! as Json;

/// `exercises[i]` пака упражнений.
Json exercise(Json doc, int i) => list(doc, 'exercises')[i]! as Json;

/// Запись события: `sessions`, `rounds`, `sets`, `attempts`.
Json record(Json doc, String key, int i) => list(doc, key)[i]! as Json;

Json copy(Json m) => jsonDecode(jsonEncode(m)) as Json;

/// Индексы задач в `test/demo.pack.json`.
const recallTask = 0;
const choiceTask = 1;
const orderingTask = 2;
const numericRecallTask = 3;
const delayedTask = 4;
const spatialTask = 5;
const streamTask = 6;
const verbalTask = 7;
