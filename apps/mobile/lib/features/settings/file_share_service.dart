import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Отдаёт файл системному «Поделиться». Абстракция нужна, чтобы тесты не
/// лезли в плагин: они подменяют [fileShareServiceProvider] фейком.
abstract interface class FileShareService {
  /// Открывает системное меню «Поделиться» с файлом [fileName].
  Future<void> shareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  });
}

/// Реализация на `share_plus`. Файл создаётся плагином во временном каталоге.
final class SharePlusFileShareService implements FileShareService {
  const SharePlusFileShareService();

  @override
  Future<void> shareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
        fileNameOverrides: [fileName],
      ),
    );
  }
}
