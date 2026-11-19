// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Tactical Mind & Body';

  @override
  String get dashboardTitle => 'Дашборд';

  @override
  String get locationHome => 'Дім';

  @override
  String get locationGym => 'Зал';

  @override
  String get locationStreet => 'Вулиця';

  @override
  String get locationSelected => 'Обрано';

  @override
  String get startOperation => 'Розпочати операцію';

  @override
  String get lastOperationTitle => 'Остання операція';

  @override
  String get lastOperationEmpty => 'Поки немає даних';

  @override
  String get phasePhysical => 'Фізична фаза';

  @override
  String get phaseCognitive => 'Когнітивна фаза';
}
