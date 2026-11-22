import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';

import 'helpers.dart';

/// Бандл из памяти: ключ → байты. Манифест собирается из ключей.
class _MemoryBundle extends CachingAssetBundle {
  _MemoryBundle(Map<String, String> files)
    : _files = {for (final e in files.entries) e.key: utf8.encode(e.value)};

  final Map<String, List<int>> _files;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      const codec = StandardMessageCodec();
      return codec.encodeMessage({
        for (final k in _files.keys)
          k: [
            {'asset': k},
          ],
      })!;
    }
    final bytes = _files[key];
    if (bytes == null) throw ArgumentError('нет ассета $key');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('грузит все встроенные паки без ошибок', () async {
    final content = await ContentLoader(rootBundle).load();

    expect(content.taskPacks, isNotEmpty);
    expect(content.exercisePacks, isNotEmpty);
    expect(content.taskCount, greaterThan(0));
    expect(content.exercises, isNotEmpty);
    expect(
      content.taskPacks.every((p) => p.packSource == PackSource.builtin),
      isTrue,
    );
  });

  test(
    'число паков в ассетах совпадает с файлами в корне репозитория',
    () async {
      final onDisk = Directory('../../assets/content')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.pack.json'))
          .length;
      final content = await ContentLoader(rootBundle).load();
      expect(content.taskPacks.length + content.exercisePacks.length, onDisk);
    },
  );

  test('contentProvider и производные', () async {
    final container = ProviderContainer(overrides: testOverrides());
    addTearDown(container.dispose);

    final content = await container.read(contentProvider.future);
    final sources = await container.read(taskSourcesProvider.future);
    final exercises = await container.read(exercisesProvider.future);

    expect(sources, hasLength(content.taskPacks.length));
    expect(sources.every((s) => s.packSource == PackSource.builtin), isTrue);
    expect(exercises, hasLength(content.exercises.length));
  });

  test('пак с ошибкой — громкая ошибка, а не тихий пропуск', () async {
    final bundle = _MemoryBundle({
      '${builtinContentRoot}ru/broken.pack.json': '{"kind":"task_pack"}',
    });
    await expectLater(
      ContentLoader(bundle).load(),
      throwsA(isA<ContentLoadException>()),
    );
  });

  test('пустой бандл — ошибка', () async {
    await expectLater(
      ContentLoader(_MemoryBundle({})).load(),
      throwsA(isA<ContentLoadException>()),
    );
  });

  test('в бандле есть ассеты паков', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final packs = manifest
        .listAssets()
        .where((a) => a.startsWith(builtinContentRoot))
        .where((a) => a.endsWith('.pack.json'))
        .toList();
    expect(packs, isNotEmpty);
    for (final p in packs) {
      final data = await rootBundle.load(p);
      expect(data.lengthInBytes, greaterThan(0), reason: p);
    }
  });
}
