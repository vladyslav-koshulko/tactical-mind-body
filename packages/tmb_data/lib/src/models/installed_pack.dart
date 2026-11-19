import 'package:tmb_domain/tmb_domain.dart';

/// Вид пользовательского пака.
enum PackKind implements WireEnum {
  taskPack('task_pack'),
  exercisePack('exercise_pack');

  const PackKind(this.wire);
  @override
  final String wire;
}

/// Метаданные установленного пака — без разбора JSON-блоба (для списков в UI).
final class InstalledPack {
  const InstalledPack({
    required this.kind,
    required this.packId,
    required this.packSource,
    required this.title,
    required this.locale,
    required this.itemCount,
    required this.installedAt,
  });

  final PackKind kind;

  /// Поле `pack` документа.
  final String packId;

  /// `imported` или `user` (встроенные паки в БД не хранятся).
  final PackSource packSource;
  final String title;
  final String locale;

  /// Число задач (`items`) или упражнений (`exercises`).
  final int itemCount;

  /// Мс эпохи UTC.
  final int installedAt;
}
