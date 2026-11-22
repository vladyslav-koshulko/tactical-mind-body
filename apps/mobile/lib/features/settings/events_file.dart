import 'dart:convert';
import 'dart:typed_data';

import 'package:tmb_domain/tmb_domain.dart';

/// MIME-тип файла экспорта.
const eventsFileMimeType = 'application/json';

/// Готовый файл экспорта событий (`events_export`, SCHEMAS §3).
final class EventsFile {
  const EventsFile({required this.fileName, required this.bytes});

  /// Собирает файл из документа. Имя — `tactical-mind-body-events-<дата>.json`,
  /// дата — локальная для [nowMs] (мс эпохи UTC; часы приходят снаружи).
  factory EventsFile.from(EventsExport export, {required int nowMs}) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      nowMs,
      isUtc: true,
    ).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return EventsFile(
      fileName:
          'tactical-mind-body-events-${date.year}-${two(date.month)}-'
          '${two(date.day)}.json',
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(export.toJson()))),
    );
  }

  final String fileName;
  final Uint8List bytes;
}

/// В документе нет ни одной сессии: делиться нечем.
bool isEventsExportEmpty(EventsExport export) => export.sessions.isEmpty;
