/// Проверка встроенных паков контента (SCHEMAS §6, решение 13).
///
/// Использование (из корня репозитория):
///   dart run packages/tmb_domain/bin/validate_packs.dart [каталог]
///
/// Каталог по умолчанию — `assets/content`. Ищет `*.pack.json` рекурсивно.
/// Строгий режим: код выхода 1, если нашлась любая ошибка ИЛИ предупреждение
/// (опечатка в имени поля не должна пройти незамеченной), либо паков нет.
///
/// `dart:io` допустим только здесь: библиотека `lib/` остаётся переносимой.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tmb_domain/tmb_domain.dart';

final _localeDir = RegExp(r'^[a-z]{2}(-[A-Z]{2})?$');

Future<void> main(List<String> args) async {
  final path = args.isEmpty ? 'assets/content' : args.first;
  final root = Directory(path);
  if (!root.existsSync()) {
    stderr.writeln('Каталог не найден: $path');
    exitCode = 1;
    return;
  }

  final files =
      root
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((f) => f.path.endsWith('.pack.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    stderr.writeln('В каталоге $path не найдено ни одного файла *.pack.json.');
    exitCode = 1;
    return;
  }

  var failed = false;
  for (final file in files) {
    final bytes = file.readAsBytesSync();
    final kind = _kindOf(bytes);
    final result = validate(
      bytes,
      ValidationContext(
        expectedKind: kind,
        directoryLocale: kind == DocumentKind.taskPack
            ? _directoryLocale(root, file)
            : null,
        assignedPackSource: PackSource.builtin,
      ),
    );
    final noun = kind == DocumentKind.exercisePack ? 'упражнений' : 'задач';
    final count = kind == DocumentKind.exercisePack
        ? result.acceptedExercises.length
        : result.acceptedTasks.length;
    stdout.writeln(
      '${file.path}: $count $noun, ${result.errorCount} ошибок, '
      '${result.warningCount} предупреждений'
      '${result.isDocumentRejected ? ' (файл отклонён)' : ''}',
    );
    for (final issue in result.issues) {
      stdout.writeln('  $issue');
    }
    if (!result.isClean) failed = true;
  }
  if (failed) exitCode = 1;
}

/// Вид пака по полю `kind`; нечитаемое — как пак задач, валидатор сам
/// сообщит `PACK_NOT_JSON`/`PACK_BAD_KIND`.
DocumentKind _kindOf(Uint8List bytes) {
  try {
    final json = jsonDecode(utf8.decode(bytes, allowMalformed: true));
    if (json is Map && json['kind'] == DocumentKind.exercisePack.wire) {
      return DocumentKind.exercisePack;
    }
  } on FormatException {
    // Ниже вернём значение по умолчанию.
  }
  return DocumentKind.taskPack;
}

/// Локаль каталога `<корень>/<locale>/…`, если файл лежит в таком каталоге.
String? _directoryLocale(Directory root, File file) {
  final rootPath = root.absolute.uri.pathSegments.where((s) => s.isNotEmpty);
  final fileSegments = file.absolute.uri.pathSegments;
  final depth = rootPath.length;
  if (fileSegments.length <= depth + 1) return null;
  final candidate = fileSegments[depth];
  return _localeDir.hasMatch(candidate) ? candidate : null;
}
