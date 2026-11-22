import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';

import 'providers.dart';

/// Каталог встроенных паков в бандле. В репозитории это корневой
/// `assets/content/`, в `apps/mobile/assets/content` лежит симлинк на него
/// (Flutter не умеет ассеты вне каталога пакета).
const builtinContentRoot = 'assets/content/';

const _packSuffix = '.pack.json';

/// Встроенное содержимое: уже провалидированные паки.
final class BuiltinContent {
  const BuiltinContent({required this.taskPacks, required this.exercisePacks});

  final List<TaskPack> taskPacks;
  final List<ExercisePack> exercisePacks;

  /// Все упражнения встроенных паков в порядке паков.
  List<Exercise> get exercises => [
    for (final p in exercisePacks) ...p.exercises,
  ];

  int get taskCount => taskPacks.fold(0, (n, p) => n + p.items.length);
}

/// Встроенный пак не прошёл валидацию или бандл неполон. Это дефект сборки,
/// а не ситуация пользователя: ловим громко, а не пропускаем пак молча.
final class ContentLoadException implements Exception {
  const ContentLoadException(this.message);

  final String message;

  @override
  String toString() => 'ContentLoadException: $message';
}

/// Читает `assets/content/<locale>/*.pack.json` из [AssetBundle], гоняет
/// каждый файл через доменный валидатор и собирает [BuiltinContent].
///
/// Строгость: любое замечание уровня error или отклонённый документ —
/// [ContentLoadException]. Предупреждения не фатальны для рантайма: их
/// блокирует CI-шаг `validate_packs.dart` (строгий режим, SCHEMAS §9).
final class ContentLoader {
  const ContentLoader(this._bundle);

  final AssetBundle _bundle;

  Future<BuiltinContent> load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    final paths =
        manifest
            .listAssets()
            .where((a) => a.startsWith(builtinContentRoot))
            .where((a) => a.endsWith(_packSuffix))
            .toList()
          ..sort();
    if (paths.isEmpty) {
      throw const ContentLoadException(
        'в бандле нет ни одного $builtinContentRoot*$_packSuffix',
      );
    }

    final taskPacks = <TaskPack>[];
    final exercisePacks = <ExercisePack>[];
    for (final path in paths) {
      final data = await _bundle.load(path);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final kind = _kindOf(bytes);
      final result = validate(
        bytes,
        ValidationContext(
          expectedKind: kind,
          directoryLocale: kind == DocumentKind.taskPack
              ? _localeOf(path)
              : null,
          assignedPackSource: PackSource.builtin,
        ),
      );
      final taskPack = result.taskPack;
      final exercisePack = result.exercisePack;
      if (result.isDocumentRejected ||
          result.errorCount > 0 ||
          (taskPack == null && exercisePack == null)) {
        throw ContentLoadException(
          '$path: ${result.errorCount} ошибок валидации'
          '${result.isDocumentRejected ? ' (файл отклонён)' : ''}\n'
          '${result.errors.join('\n')}',
        );
      }
      if (taskPack != null) taskPacks.add(taskPack);
      if (exercisePack != null) exercisePacks.add(exercisePack);
    }
    return BuiltinContent(
      taskPacks: List.unmodifiable(taskPacks),
      exercisePacks: List.unmodifiable(exercisePacks),
    );
  }

  /// Вид пака по полю `kind`; нечитаемое — как пак задач, чтобы валидатор
  /// сам назвал причину (`PACK_NOT_JSON`/`PACK_BAD_KIND`).
  static DocumentKind _kindOf(Uint8List bytes) {
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

  /// `assets/content/<locale>/x.pack.json` → `<locale>`.
  static String? _localeOf(String path) {
    final rest = path.substring(builtinContentRoot.length).split('/');
    return rest.length > 1 ? rest.first : null;
  }
}

/// Откуда читать ассеты. В тестах подменяется на свой [AssetBundle].
final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

/// Встроенные паки. Ошибка здесь — дефект сборки, поэтому без авто-повтора
/// (в Riverpod 3 он включён по умолчанию): экран старта покажет ошибку сразу.
final contentProvider = FutureProvider<BuiltinContent>(
  (ref) => ContentLoader(ref.watch(assetBundleProvider)).load(),
  retry: (retryCount, error) => null,
);

/// Установленные пользователем паки (метаданные). Поток нужен, чтобы
/// [taskSourcesProvider] и [exercisesProvider] пересобирались после
/// установки/удаления пака.
final installedPacksProvider = StreamProvider<List<InstalledPack>>(
  (ref) => ref.watch(contentRepositoryProvider).watchPacks(),
);

/// Источники задач для `SessionPlanner`: встроенные паки + установленные
/// пользователем (`packSource` у них проставил репозиторий: `imported`/`user`).
/// Отключённые категории здесь НЕ применяются — их учитывает планировщик
/// по профилю.
final taskSourcesProvider = FutureProvider<List<TaskSource>>((ref) async {
  final builtin = await ref.watch(contentProvider.future);
  await ref.watch(installedPacksProvider.future);
  final installed = await ref.read(contentRepositoryProvider).taskPacks();
  return [
    for (final pack in [...builtin.taskPacks, ...installed])
      TaskSource.pack(PackTaskProvider(pack)),
  ];
});

/// База упражнений для `SessionPlanner`: встроенные + установленные паки.
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final builtin = await ref.watch(contentProvider.future);
  await ref.watch(installedPacksProvider.future);
  final installed = await ref.read(contentRepositoryProvider).exercisePacks();
  return [
    ...builtin.exercises,
    for (final pack in installed) ...pack.exercises,
  ];
});
