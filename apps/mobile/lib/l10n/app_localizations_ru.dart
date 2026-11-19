// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Tactical Mind & Body';

  @override
  String get dashboardTitle => 'Дашборд';

  @override
  String get locationHome => 'Дом';

  @override
  String get locationGym => 'Зал';

  @override
  String get locationStreet => 'Улица';

  @override
  String get locationSelected => 'Выбрано';

  @override
  String get startOperation => 'Начать операцию';

  @override
  String get lastOperationTitle => 'Последняя операция';

  @override
  String get lastOperationEmpty => 'Пока нет данных';

  @override
  String get phasePhysical => 'Физическая фаза';

  @override
  String get phaseCognitive => 'Когнитивная фаза';
}
