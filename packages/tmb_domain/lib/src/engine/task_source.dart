import '../cognitive/pack_task_provider.dart';
import '../cognitive/task_provider.dart';
import '../common/enums.dart';

/// Провайдер задач вместе с тем, что о нём не говорит контракт: откуда пак.
///
/// `TaskAttempt.packSource` обязателен (D4: `imported`/`user` не идут в Индекс),
/// а `CognitiveTaskProvider` его не раскрывает.
final class TaskSource {
  const TaskSource({required this.provider, required this.packSource});

  /// Источник для пака: `packSource` берётся у пака (его присвоил читатель,
  /// решение 10).
  factory TaskSource.pack(PackTaskProvider provider) =>
      TaskSource(provider: provider, packSource: provider.pack.packSource);

  final CognitiveTaskProvider provider;
  final PackSource packSource;
}
