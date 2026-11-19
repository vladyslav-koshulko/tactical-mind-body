import 'checker.dart';
import 'issues.dart';
import 'schema_constants.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_issue.dart';

/// Заголовочные поля, общие для обоих видов паков (SCHEMAS §1.1, §2.1).
///
/// Возвращает `packSource`, который нужно записать в модель: присвоенный
/// читателем, если он задан (решение 10), иначе заявленный файлом.
String? validateCommonHeader(
  Map<String, Object?> root,
  Checker h,
  ValidationContext ctx,
) {
  h.takePattern(
    root,
    '',
    'pack',
    packPattern,
    ValidationCode.packBadId,
    'Идентификатор пака',
    minLength: 3,
    maxLength: 64,
  );
  h.takeText(root, '', 'title', max: h.limits.packTitleLength);

  final licenseRaw = h.take(root, '', 'license');
  if (licenseRaw != null) {
    // Пустая/длинная лицензия — тоже «не по формату» (1…64, правило 14).
    h.pattern(
      licenseRaw,
      'license',
      licensePattern,
      ValidationCode.packBadFormat,
      'Лицензия',
      minLength: 1,
      maxLength: 64,
    );
  }

  final source = h.takeWire(
    root,
    '',
    'packSource',
    packSourceWires,
    ValidationCode.packBadEnum,
    'Источник пака «packSource»',
  );
  h.takeWire(
    root,
    '',
    'status',
    packStatusWires,
    ValidationCode.packBadEnum,
    'Статус пака «status»',
  );

  final assigned = ctx.assignedPackSource;
  if (source != null && assigned != null && source != assigned.wire) {
    h.add(
      ValidationCode.packSourceOverridden,
      'packSource',
      'Файл заявил packSource «$source», присвоено «${assigned.wire}»: '
          'источник определяет читатель, а не файл.',
    );
  }
  return assigned?.wire ?? source;
}

/// Массив элементов верхнего уровня (`items`, `exercises`, `categories`):
/// 1…[max] элементов; иначе документ отвергается (`PACK_LIMIT_ITEMS`).
List<Object?>? takeElements(
  Checker h,
  Map<String, Object?> root,
  String key,
  int max,
) {
  final raw = h.takeArray(root, '', key);
  if (raw == null) return null;
  if (raw.isEmpty || raw.length > max) {
    h.add(
      ValidationCode.packLimitItems,
      key,
      raw.isEmpty
          ? 'Массив «$key» пуст: нужен хотя бы один элемент.'
          : 'В «$key» не больше $max элементов (сейчас ${raw.length}).',
    );
    return null;
  }
  return raw;
}

/// Читает модель элемента существующим `fromJson`; `FormatException` —
/// замечание, а не падение.
T? buildModel<T>(T Function() read, String path, Issues local) {
  try {
    return read();
  } on FormatException catch (e) {
    local.add(
      ValidationCode.packBadType,
      path,
      'Элемент не удалось прочитать: ${e.message}',
    );
  } on UnsupportedError catch (e) {
    local.add(
      ValidationCode.packBadChars,
      path,
      'Элемент не удалось прочитать: ${e.message}',
    );
  }
  return null;
}

/// Коды ошибок среди замечаний.
List<ValidationCode> errorCodesOf(List<ValidationIssue> list) => [
  for (final i in list)
    if (i.isError) i.code,
];
