import 'severity.dart';
import 'validation_code.dart';
import 'validation_issue.dart';

/// Накопитель замечаний одной области (документ, элемент, запись).
final class Issues {
  final List<ValidationIssue> list = [];
  int _errors = 0;

  bool get hasErrors => _errors > 0;

  void add(ValidationCode code, String path, String message) {
    list.add(ValidationIssue(code: code, path: path, message: message));
    if (code.severity == Severity.error) _errors++;
  }

  void addAll(Iterable<ValidationIssue> issues) {
    for (final i in issues) {
      list.add(i);
      if (i.isError) _errors++;
    }
  }

  List<ValidationCode> get errorCodes => [
    for (final i in list)
      if (i.isError) i.code,
  ];
}
