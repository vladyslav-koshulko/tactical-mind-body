import '../common/json_reader.dart';

/// Категория пака (`categories[]`, SCHEMAS §1.2).
final class TaskCategory {
  const TaskCategory({
    required this.domain,
    required this.title,
    this.description,
  });

  factory TaskCategory.fromJson(Map<String, Object?> json) =>
      TaskCategory.read(readRoot(json));

  factory TaskCategory.read(JsonObj o) => TaskCategory(
    domain: o.string('domain'),
    title: o.text('title'),
    description: o.textOpt('description'),
  );

  /// Путь вида `cog.uncertainty.estimation`.
  final String domain;
  final String title;
  final String? description;

  Map<String, Object?> toJson() => {
    'domain': domain,
    'title': title,
    'description': ?description,
  };
}
