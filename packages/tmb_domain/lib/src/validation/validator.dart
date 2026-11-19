import 'dart:convert';
import 'dart:typed_data';

import 'events_validator.dart';
import 'exercise_pack_validator.dart';
import 'issues.dart';
import 'profile_validator.dart';
import 'task_pack_validator.dart';
import 'validation_code.dart';
import 'validation_context.dart';
import 'validation_result.dart';

/// Проверяет документ по SCHEMAS §5–§7 и возвращает все замечания, принятые
/// элементы и исключённые элементы. Чистая функция: ни I/O, ни времени.
///
/// Порядок (SCHEMAS §7): размер → глубина (оба — до разбора) → UTF-8/JSON →
/// `kind` и `schemaVersion` → правила документа → правила каждого элемента.
/// Ошибка элемента исключает элемент, ошибка документа отклоняет файл
/// (решение 13); неизвестная версия отклоняет файл целиком (решение 19).
ValidationResult validate(Uint8List bytes, ValidationContext context) {
  final limits = context.limits;
  final kind = context.expectedKind;

  ValidationResult reject(ValidationCode code, String message) {
    final issues = Issues()..add(code, '\$', message);
    return ValidationResult(
      kind: kind,
      issues: issues.list,
      isDocumentRejected: true,
    );
  }

  if (bytes.length > limits.maxBytes) {
    return reject(
      ValidationCode.packTooLarge,
      'Файл слишком большой: ${bytes.length} байт при лимите ${limits.maxBytes}.',
    );
  }
  if (!_depthWithin(bytes, limits.maxDepth)) {
    return reject(
      ValidationCode.packTooDeep,
      'Вложенность JSON больше ${limits.maxDepth} уровней.',
    );
  }

  final Object? decoded;
  try {
    var body = bytes;
    if (body.length >= 3 &&
        body[0] == 0xEF &&
        body[1] == 0xBB &&
        body[2] == 0xBF) {
      body = Uint8List.sublistView(body, 3);
    }
    decoded = jsonDecode(utf8.decode(body));
  } on FormatException catch (e) {
    return reject(
      ValidationCode.packNotJson,
      'Файл не является корректным JSON в UTF-8: ${e.message}',
    );
  }
  if (decoded is! Map<String, Object?>) {
    return reject(
      ValidationCode.packNotJson,
      'Корень документа должен быть объектом JSON.',
    );
  }
  final root = decoded;

  // kind и schemaVersion: любая ошибка здесь отвергает документ целиком.
  final head = Issues();
  final wire = kind.wire;
  if (wire != null) {
    if (!root.containsKey('kind')) {
      head.add(
        ValidationCode.packMissingField,
        'kind',
        'Обязательное поле «kind» отсутствует.',
      );
    } else if (root['kind'] is! String) {
      head.add(ValidationCode.packBadType, 'kind', 'Поле «kind» — строка.');
    } else if (root['kind'] != wire) {
      head.add(
        ValidationCode.packBadKind,
        'kind',
        'Ожидался документ вида «$wire», в файле «${root['kind']}».',
      );
    }
  }
  final version = root['schemaVersion'];
  if (version is! int || version < 1) {
    head.add(
      ValidationCode.packSchemaVersion,
      'schemaVersion',
      'Поле «schemaVersion» должно быть целым числом не меньше 1.',
    );
  } else if (!context.supportedVersions.contains(version)) {
    head.add(
      ValidationCode.packSchemaUnsupported,
      'schemaVersion',
      version > context.supportedVersions.max
          ? 'Версия формата $version новее поддерживаемой '
                '(${context.supportedVersions.max}): обновите приложение.'
          : 'Версия формата $version устарела, миграции нет '
                '(поддерживается ${context.supportedVersions.min}–'
                '${context.supportedVersions.max}).',
    );
  }
  if (head.hasErrors) {
    return ValidationResult(
      kind: kind,
      issues: head.list,
      isDocumentRejected: true,
    );
  }

  final issues = Issues();
  return switch (kind) {
    DocumentKind.taskPack => validateTaskPackDocument(root, context, issues),
    DocumentKind.exercisePack => validateExercisePackDocument(
      root,
      context,
      issues,
    ),
    DocumentKind.eventsExport => validateEventsDocument(root, context, issues),
    DocumentKind.profile => validateProfileDocument(root, context, issues),
  };
}

/// Скан скобок вне строк без разбора JSON (SCHEMAS §6, правило 3).
///
/// Работает по байтам: все байты многобайтных UTF-8-символов ≥ 0x80 и не
/// совпадают со служебными. Останавливается, как только глубина превысила
/// [maxDepth]. Корень = глубина 1.
bool _depthWithin(Uint8List bytes, int maxDepth) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (final b in bytes) {
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (b == 0x5C) {
        escaped = true;
      } else if (b == 0x22) {
        inString = false;
      }
      continue;
    }
    switch (b) {
      case 0x22:
        inString = true;
      case 0x7B || 0x5B:
        depth++;
        if (depth > maxDepth) return false;
      case 0x7D || 0x5D:
        if (depth > 0) depth--;
    }
  }
  return true;
}
