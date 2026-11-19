import 'severity.dart';
import 'validation_code.dart';

/// Одно замечание валидатора.
final class ValidationIssue {
  const ValidationIssue({
    required this.code,
    required this.path,
    required this.message,
  });

  final ValidationCode code;

  /// JSON-путь к месту замечания: `items[3].selfCheck`; `$` — корень документа.
  final String path;

  /// Сообщение по-русски, пригодное для показа в предпросмотре импорта.
  final String message;

  Severity get severity => code.severity;

  bool get isError => severity == Severity.error;

  @override
  String toString() => '$path · ${code.code} · $message';
}
