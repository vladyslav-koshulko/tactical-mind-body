/// Слой данных: Drift-схема, миграции, репозитории. Без Flutter.
///
/// БД открывает приложение и передаёт [QueryExecutor] в `TmbDatabase`
/// (см. `docs/ARCHITECTURE.md`): сюда файловый ввод-вывод и Flutter не попадают.
library;

export 'src/database/tmb_database.dart' show TmbDatabase;
export 'src/errors.dart';
export 'src/models/installed_pack.dart';
export 'src/models/session_bundle.dart';
export 'src/models/session_preferences.dart';
export 'src/repositories/content_repository.dart';
export 'src/repositories/drift_content_repository.dart';
export 'src/repositories/drift_profile_repository.dart';
export 'src/repositories/drift_session_repository.dart';
export 'src/repositories/profile_repository.dart';
export 'src/repositories/session_repository.dart';
