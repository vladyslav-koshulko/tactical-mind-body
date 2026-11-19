import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'fixtures.dart';

/// Запускает `bin/validate_packs.dart` как отдельный процесс на временном
/// каталоге с паками: `<tmp>/ru/<имя>.pack.json`.
Future<ProcessResult> _runCli(Directory dir, Map<String, Object> packs) async {
  final ru = Directory('${dir.path}/ru')..createSync(recursive: true);
  packs.forEach((name, doc) {
    File('${ru.path}/$name.pack.json').writeAsStringSync(jsonEncode(doc));
  });
  return Process.run(Platform.resolvedExecutable, [
    'run',
    'bin/validate_packs.dart',
    dir.path,
  ], stdoutEncoding: utf8);
}

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('tmb_validate_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('валидный пак → код 0 и отчёт по-русски', () async {
    final r = await _runCli(tmp, {'demo': loadSample(DocumentKind.taskPack)});
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
    expect(r.stdout, contains('8 задач, 0 ошибок, 0 предупреждений'));
  });

  test(
    'испорченный пак → код 1, замечание выведено как «path · code · text»',
    () async {
      final doc = loadSample(DocumentKind.taskPack);
      task(doc, recallTask)['timeSec'] = 4;
      final r = await _runCli(tmp, {'demo': doc});
      expect(r.exitCode, 1);
      expect(r.stdout, contains('7 задач, 1 ошибок, 0 предупреждений'));
      expect(r.stdout, contains('items[0].timeSec · PACK_BAD_TIME · '));
    },
  );

  test('одно предупреждение — тоже сбой (строгий режим)', () async {
    final doc = loadSample(DocumentKind.taskPack)..['опечатка'] = 1;
    final r = await _runCli(tmp, {'demo': doc});
    expect(r.exitCode, 1);
    expect(r.stdout, contains('0 ошибок, 1 предупреждений'));
  });

  test('один плохой пак среди хороших → код 1', () async {
    final bad = loadSample(DocumentKind.exercisePack);
    exercise(bad, 0)['muscleGroups'] = ['core', 'neck'];
    final r = await _runCli(tmp, {
      'good': loadSample(DocumentKind.taskPack),
      'bad': bad,
    });
    expect(r.exitCode, 1);
    expect(r.stdout, contains('EX_UNKNOWN_TAG'));
  });

  test('каталог без паков → код 1 с понятным сообщением', () async {
    final r = await _runCli(tmp, {});
    expect(r.exitCode, 1);
    expect(r.stderr, contains('не найдено ни одного файла *.pack.json'));
  });

  test('несуществующий каталог → код 1', () async {
    final r = await Process.run(Platform.resolvedExecutable, [
      'run',
      'bin/validate_packs.dart',
      '${tmp.path}/нет-такого',
    ]);
    expect(r.exitCode, 1);
  });
}
