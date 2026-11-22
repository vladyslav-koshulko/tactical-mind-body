import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('uk'),
  ];

  /// Название приложения (бренд, не переводится)
  ///
  /// In ru, this message translates to:
  /// **'Tactical Mind & Body'**
  String get appName;

  /// No description provided for @dashboardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дашборд'**
  String get dashboardTitle;

  /// No description provided for @locationHome.
  ///
  /// In ru, this message translates to:
  /// **'Дом'**
  String get locationHome;

  /// No description provided for @locationGym.
  ///
  /// In ru, this message translates to:
  /// **'Зал'**
  String get locationGym;

  /// No description provided for @locationStreet.
  ///
  /// In ru, this message translates to:
  /// **'Улица'**
  String get locationStreet;

  /// Метка выбранной плитки локации (дублирует рамку нецветовым каналом)
  ///
  /// In ru, this message translates to:
  /// **'Выбрано'**
  String get locationSelected;

  /// No description provided for @startOperation.
  ///
  /// In ru, this message translates to:
  /// **'Начать операцию'**
  String get startOperation;

  /// No description provided for @lastOperationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Последняя операция'**
  String get lastOperationTitle;

  /// No description provided for @lastOperationEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет данных'**
  String get lastOperationEmpty;

  /// No description provided for @phasePhysical.
  ///
  /// In ru, this message translates to:
  /// **'Физическая фаза'**
  String get phasePhysical;

  /// No description provided for @phaseCognitive.
  ///
  /// In ru, this message translates to:
  /// **'Когнитивная фаза'**
  String get phaseCognitive;

  /// Подпись кнопки-шестерёнки на дашборде (ведёт в настройки)
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get dashboardSettings;

  /// Экран старта: идёт чтение встроенных паков
  ///
  /// In ru, this message translates to:
  /// **'Загрузка контента'**
  String get appLoading;

  /// No description provided for @appLoadErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить контент'**
  String get appLoadErrorTitle;

  /// No description provided for @appLoadErrorBody.
  ///
  /// In ru, this message translates to:
  /// **'Встроенные наборы заданий повреждены или не найдены. Переустановите приложение.'**
  String get appLoadErrorBody;

  /// Техническая причина ошибки загрузки (не переводится)
  ///
  /// In ru, this message translates to:
  /// **'Подробности: {details}'**
  String appLoadErrorDetails(String details);

  /// No description provided for @appRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get appRetry;

  /// No description provided for @appRouteNotFoundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Экран не найден'**
  String get appRouteNotFoundTitle;

  /// No description provided for @appBackToDashboard.
  ///
  /// In ru, this message translates to:
  /// **'На дашборд'**
  String get appBackToDashboard;

  /// No description provided for @dashboardLocationHeading.
  ///
  /// In ru, this message translates to:
  /// **'Локация'**
  String get dashboardLocationHeading;

  /// Метка недоступной в этой версии локации (дублирует приглушённый вид нецветовым каналом)
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get dashboardLocationSoon;

  /// No description provided for @dashboardDifficultyHeading.
  ///
  /// In ru, this message translates to:
  /// **'Сложность'**
  String get dashboardDifficultyHeading;

  /// No description provided for @dashboardDifficultyRecruit.
  ///
  /// In ru, this message translates to:
  /// **'Рекрут'**
  String get dashboardDifficultyRecruit;

  /// No description provided for @dashboardDifficultyFighter.
  ///
  /// In ru, this message translates to:
  /// **'Боец'**
  String get dashboardDifficultyFighter;

  /// No description provided for @dashboardDifficultyOperator.
  ///
  /// In ru, this message translates to:
  /// **'Оператор'**
  String get dashboardDifficultyOperator;

  /// No description provided for @dashboardDifficultySpetsnaz.
  ///
  /// In ru, this message translates to:
  /// **'Спецназ'**
  String get dashboardDifficultySpetsnaz;

  /// No description provided for @dashboardLastOperationDone.
  ///
  /// In ru, this message translates to:
  /// **'Завершена'**
  String get dashboardLastOperationDone;

  /// No description provided for @dashboardLastOperationInterrupted.
  ///
  /// In ru, this message translates to:
  /// **'Прервана'**
  String get dashboardLastOperationInterrupted;

  /// No description provided for @dashboardLastOperationRounds.
  ///
  /// In ru, this message translates to:
  /// **'Кругов: {count}'**
  String dashboardLastOperationRounds(int count);

  /// No description provided for @dashboardLastOperationTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задач: {count}'**
  String dashboardLastOperationTasks(int count);

  /// No description provided for @dashboardLastOperationDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get dashboardLastOperationDetails;

  /// No description provided for @dashboardSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить выбор'**
  String get dashboardSaveError;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get settingsBack;

  /// No description provided for @settingsLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка настроек'**
  String get settingsLoading;

  /// No description provided for @settingsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать настройки'**
  String get settingsLoadError;

  /// No description provided for @settingsSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить изменение'**
  String get settingsSaveError;

  /// No description provided for @settingsSectionSession.
  ///
  /// In ru, this message translates to:
  /// **'Шаблон операции'**
  String get settingsSectionSession;

  /// No description provided for @settingsTemplateDualTask.
  ///
  /// In ru, this message translates to:
  /// **'Dual-Task'**
  String get settingsTemplateDualTask;

  /// No description provided for @settingsTemplateDualTaskHint.
  ///
  /// In ru, this message translates to:
  /// **'Круг, когнитивное окно, снова круг'**
  String get settingsTemplateDualTaskHint;

  /// No description provided for @settingsTemplatePhysicalOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только физика'**
  String get settingsTemplatePhysicalOnly;

  /// No description provided for @settingsTemplatePhysicalOnlyHint.
  ///
  /// In ru, this message translates to:
  /// **'Круги подряд, без когнитивных задач'**
  String get settingsTemplatePhysicalOnlyHint;

  /// No description provided for @settingsTemplateCognitiveOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только когниция'**
  String get settingsTemplateCognitiveOnly;

  /// No description provided for @settingsTemplateCognitiveOnlyHint.
  ///
  /// In ru, this message translates to:
  /// **'Только задачи, без упражнений'**
  String get settingsTemplateCognitiveOnlyHint;

  /// No description provided for @settingsTemplateCustom.
  ///
  /// In ru, this message translates to:
  /// **'Своя последовательность'**
  String get settingsTemplateCustom;

  /// No description provided for @settingsSectionParams.
  ///
  /// In ru, this message translates to:
  /// **'Параметры операции'**
  String get settingsSectionParams;

  /// No description provided for @settingsRounds.
  ///
  /// In ru, this message translates to:
  /// **'Число кругов'**
  String get settingsRounds;

  /// No description provided for @settingsWindows.
  ///
  /// In ru, this message translates to:
  /// **'Число когнитивных окон'**
  String get settingsWindows;

  /// No description provided for @settingsCognitiveSec.
  ///
  /// In ru, this message translates to:
  /// **'Длительность когнитивного окна'**
  String get settingsCognitiveSec;

  /// No description provided for @settingsRestSec.
  ///
  /// In ru, this message translates to:
  /// **'Отдых между кругами'**
  String get settingsRestSec;

  /// No description provided for @settingsRestNone.
  ///
  /// In ru, this message translates to:
  /// **'Без отдыха'**
  String get settingsRestNone;

  /// Число секунд с единицей
  ///
  /// In ru, this message translates to:
  /// **'{value} с'**
  String settingsSecondsValue(int value);

  /// No description provided for @settingsStepperDecrease.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить: {label}'**
  String settingsStepperDecrease(String label);

  /// No description provided for @settingsStepperIncrease.
  ///
  /// In ru, this message translates to:
  /// **'Увеличить: {label}'**
  String settingsStepperIncrease(String label);

  /// No description provided for @settingsStepperEdit.
  ///
  /// In ru, this message translates to:
  /// **'Ввести значение: {label}'**
  String settingsStepperEdit(String label);

  /// No description provided for @settingsStepperRangeError.
  ///
  /// In ru, this message translates to:
  /// **'Введите число от {min} до {max}'**
  String settingsStepperRangeError(int min, int max);

  /// No description provided for @settingsConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get settingsConfirm;

  /// No description provided for @settingsCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get settingsCancel;

  /// No description provided for @settingsSectionReps.
  ///
  /// In ru, this message translates to:
  /// **'Нагрузка по умолчанию'**
  String get settingsSectionReps;

  /// No description provided for @settingsRepsMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим повторений'**
  String get settingsRepsMode;

  /// No description provided for @settingsRepsModeFixed.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированный'**
  String get settingsRepsModeFixed;

  /// No description provided for @settingsRepsModeRange.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон'**
  String get settingsRepsModeRange;

  /// No description provided for @settingsRepsHint.
  ///
  /// In ru, this message translates to:
  /// **'Цель для упражнений без своей цели. В диапазоне число выпадает случайно на каждый круг.'**
  String get settingsRepsHint;

  /// No description provided for @settingsTargetReps.
  ///
  /// In ru, this message translates to:
  /// **'Повторения'**
  String get settingsTargetReps;

  /// No description provided for @settingsTargetSeconds.
  ///
  /// In ru, this message translates to:
  /// **'Удержание, секунды'**
  String get settingsTargetSeconds;

  /// No description provided for @settingsTargetValue.
  ///
  /// In ru, this message translates to:
  /// **'Значение'**
  String get settingsTargetValue;

  /// No description provided for @settingsTargetFrom.
  ///
  /// In ru, this message translates to:
  /// **'От'**
  String get settingsTargetFrom;

  /// No description provided for @settingsTargetTo.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get settingsTargetTo;

  /// No description provided for @settingsSectionProgression.
  ///
  /// In ru, this message translates to:
  /// **'Прогрессия нагрузки'**
  String get settingsSectionProgression;

  /// No description provided for @settingsProgressionToggle.
  ///
  /// In ru, this message translates to:
  /// **'Подстройка нагрузки по истории'**
  String get settingsProgressionToggle;

  /// No description provided for @settingsProgressionHint.
  ///
  /// In ru, this message translates to:
  /// **'Алгоритм появится в версии 0.2: пока сохраняется только этот переключатель, нагрузка не меняется.'**
  String get settingsProgressionHint;

  /// No description provided for @settingsOn.
  ///
  /// In ru, this message translates to:
  /// **'Вкл'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In ru, this message translates to:
  /// **'Выкл'**
  String get settingsOff;

  /// No description provided for @settingsSectionMore.
  ///
  /// In ru, this message translates to:
  /// **'Данные и приложение'**
  String get settingsSectionMore;

  /// No description provided for @settingsLinkCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории задач'**
  String get settingsLinkCategories;

  /// No description provided for @settingsLinkCategoriesSummary.
  ///
  /// In ru, this message translates to:
  /// **'Включено {enabled} из {total}'**
  String settingsLinkCategoriesSummary(int enabled, int total);

  /// No description provided for @settingsLinkTargets.
  ///
  /// In ru, this message translates to:
  /// **'Цели упражнений'**
  String get settingsLinkTargets;

  /// No description provided for @settingsLinkTargetsSummary.
  ///
  /// In ru, this message translates to:
  /// **'Своих целей: {count}'**
  String settingsLinkTargetsSummary(int count);

  /// No description provided for @settingsLinkExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт данных'**
  String get settingsLinkExport;

  /// No description provided for @settingsLinkAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsLinkAbout;

  /// No description provided for @categoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категории задач'**
  String get categoriesTitle;

  /// No description provided for @categoriesLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка категорий'**
  String get categoriesLoading;

  /// No description provided for @categoriesLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось собрать список категорий'**
  String get categoriesLoadError;

  /// No description provided for @categoriesSectionVerifiable.
  ///
  /// In ru, this message translates to:
  /// **'Проверяемые'**
  String get categoriesSectionVerifiable;

  /// No description provided for @categoriesSectionVerifiableHint.
  ///
  /// In ru, this message translates to:
  /// **'Ответ проверяет приложение: верно или нет.'**
  String get categoriesSectionVerifiableHint;

  /// No description provided for @categoriesSectionUnverifiable.
  ///
  /// In ru, this message translates to:
  /// **'Непроверяемые'**
  String get categoriesSectionUnverifiable;

  /// No description provided for @categoriesSectionUnverifiableHint.
  ///
  /// In ru, this message translates to:
  /// **'Самооценка по чек-листу: не влияют на Индекс и рейтинги.'**
  String get categoriesSectionUnverifiableHint;

  /// No description provided for @categoriesSectionSummary.
  ///
  /// In ru, this message translates to:
  /// **'Включено категорий: {enabled} из {total}'**
  String categoriesSectionSummary(int enabled, int total);

  /// No description provided for @categoriesEnableAll.
  ///
  /// In ru, this message translates to:
  /// **'Включить все'**
  String get categoriesEnableAll;

  /// No description provided for @categoriesDisableAll.
  ///
  /// In ru, this message translates to:
  /// **'Выключить все'**
  String get categoriesDisableAll;

  /// No description provided for @categoriesTasksCount.
  ///
  /// In ru, this message translates to:
  /// **'Задач: {count}'**
  String categoriesTasksCount(int count);

  /// No description provided for @categoriesEmptySection.
  ///
  /// In ru, this message translates to:
  /// **'В этом разделе пока нет задач'**
  String get categoriesEmptySection;

  /// No description provided for @categoriesEmptyPool.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя отключить всё: должна остаться хотя бы одна включённая категория.'**
  String get categoriesEmptyPool;

  /// No description provided for @categoriesSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить выбор категорий'**
  String get categoriesSaveError;

  /// No description provided for @categoriesStateOn.
  ///
  /// In ru, this message translates to:
  /// **'Включена'**
  String get categoriesStateOn;

  /// No description provided for @categoriesStateOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключена'**
  String get categoriesStateOff;

  /// No description provided for @categoriesStateMixed.
  ///
  /// In ru, this message translates to:
  /// **'Включена частично'**
  String get categoriesStateMixed;

  /// No description provided for @categoriesGroupMath.
  ///
  /// In ru, this message translates to:
  /// **'Математика'**
  String get categoriesGroupMath;

  /// No description provided for @categoriesGroupCog.
  ///
  /// In ru, this message translates to:
  /// **'Когнитивные'**
  String get categoriesGroupCog;

  /// No description provided for @categoriesGroupArithmetic.
  ///
  /// In ru, this message translates to:
  /// **'Арифметика'**
  String get categoriesGroupArithmetic;

  /// No description provided for @categoriesGroupMemory.
  ///
  /// In ru, this message translates to:
  /// **'Память'**
  String get categoriesGroupMemory;

  /// No description provided for @categoriesGroupUncertainty.
  ///
  /// In ru, this message translates to:
  /// **'Неопределённость'**
  String get categoriesGroupUncertainty;

  /// No description provided for @categoriesGroupVerbal.
  ///
  /// In ru, this message translates to:
  /// **'Вербальные'**
  String get categoriesGroupVerbal;

  /// No description provided for @targetsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цели упражнений'**
  String get targetsTitle;

  /// No description provided for @targetsHint.
  ///
  /// In ru, this message translates to:
  /// **'Своя цель заменяет значение по умолчанию. Заданные вручную цели прогрессия не меняет.'**
  String get targetsHint;

  /// No description provided for @targetsLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка упражнений'**
  String get targetsLoading;

  /// No description provided for @targetsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить упражнения'**
  String get targetsLoadError;

  /// No description provided for @targetsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Упражнений нет'**
  String get targetsEmpty;

  /// No description provided for @targetsCustom.
  ///
  /// In ru, this message translates to:
  /// **'Своя цель'**
  String get targetsCustom;

  /// No description provided for @targetsDefault.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get targetsDefault;

  /// No description provided for @targetsReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить к умолчанию'**
  String get targetsReset;

  /// No description provided for @targetsSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить цель'**
  String get targetsSaveError;

  /// No description provided for @targetsUnitReps.
  ///
  /// In ru, this message translates to:
  /// **'повт.'**
  String get targetsUnitReps;

  /// No description provided for @targetsUnitSeconds.
  ///
  /// In ru, this message translates to:
  /// **'сек'**
  String get targetsUnitSeconds;

  /// No description provided for @targetsRangeToggle.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон'**
  String get targetsRangeToggle;

  /// No description provided for @targetsValue.
  ///
  /// In ru, this message translates to:
  /// **'Значение'**
  String get targetsValue;

  /// No description provided for @targetsFrom.
  ///
  /// In ru, this message translates to:
  /// **'От'**
  String get targetsFrom;

  /// No description provided for @targetsTo.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get targetsTo;

  /// No description provided for @targetsValueFixed.
  ///
  /// In ru, this message translates to:
  /// **'{value} {unit}'**
  String targetsValueFixed(int value, String unit);

  /// No description provided for @targetsValueRange.
  ///
  /// In ru, this message translates to:
  /// **'{min}–{max} {unit}'**
  String targetsValueRange(int min, int max, String unit);

  /// No description provided for @exportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт данных'**
  String get exportTitle;

  /// No description provided for @exportDescription.
  ///
  /// In ru, this message translates to:
  /// **'Все записанные события тренировок одним JSON-файлом: сессии, круги, подходы и попытки. Файл можно сохранить или отправить через системное меню.'**
  String get exportDescription;

  /// No description provided for @exportPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Приложение само ничего не отправляет: файл уйдёт только туда, куда вы его направите.'**
  String get exportPrivacy;

  /// No description provided for @exportCounts.
  ///
  /// In ru, this message translates to:
  /// **'Сессий: {sessions} · кругов: {rounds} · подходов: {sets} · попыток: {attempts}'**
  String exportCounts(int sessions, int rounds, int sets, int attempts);

  /// No description provided for @exportEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Данных пока нет. Проведите хотя бы одну операцию.'**
  String get exportEmpty;

  /// No description provided for @exportButton.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться файлом'**
  String get exportButton;

  /// No description provided for @exportPreparing.
  ///
  /// In ru, this message translates to:
  /// **'Подготовка файла'**
  String get exportPreparing;

  /// No description provided for @exportError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подготовить или отправить файл'**
  String get exportError;

  /// No description provided for @exportLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать данные'**
  String get exportLoadError;

  /// No description provided for @aboutTitle.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-тренажёр: физические круги чередуются с когнитивными задачами.'**
  String get aboutDescription;

  /// No description provided for @aboutLicenses.
  ///
  /// In ru, this message translates to:
  /// **'Лицензии'**
  String get aboutLicenses;

  /// No description provided for @aboutFonts.
  ///
  /// In ru, this message translates to:
  /// **'Шрифты Oswald и JetBrains Mono распространяются по лицензии SIL Open Font License 1.1.'**
  String get aboutFonts;

  /// No description provided for @aboutNotMedical.
  ///
  /// In ru, this message translates to:
  /// **'Приложение не даёт медицинских рекомендаций: нагрузку подбирайте по самочувствию.'**
  String get aboutNotMedical;

  /// Экран сессии: строится план
  ///
  /// In ru, this message translates to:
  /// **'Подготовка операции'**
  String get sessionLoading;

  /// No description provided for @sessionErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось начать операцию'**
  String get sessionErrorTitle;

  /// No description provided for @sessionErrorNoExercises.
  ///
  /// In ru, this message translates to:
  /// **'Нет упражнений для выбранного места. Смените место или добавьте упражнения.'**
  String get sessionErrorNoExercises;

  /// No description provided for @sessionErrorEmptyTaskPool.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных когнитивных задач: проверьте включённые категории и уровень сложности.'**
  String get sessionErrorEmptyTaskPool;

  /// No description provided for @sessionErrorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось построить план операции.'**
  String get sessionErrorGeneric;

  /// No description provided for @sessionBackToDashboard.
  ///
  /// In ru, this message translates to:
  /// **'На дашборд'**
  String get sessionBackToDashboard;

  /// Заголовок физической фазы
  ///
  /// In ru, this message translates to:
  /// **'Круг {n} из {total}'**
  String sessionRoundTitle(int n, int total);

  /// Заголовок когнитивной паузы
  ///
  /// In ru, this message translates to:
  /// **'Задача {n} из {total}'**
  String sessionTaskTitle(int n, int total);

  /// Название фазы пассивного отдыха (подпись рядом с глифом)
  ///
  /// In ru, this message translates to:
  /// **'Отдых'**
  String get sessionRestPhase;

  /// No description provided for @sessionRestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пассивный отдых'**
  String get sessionRestTitle;

  /// Единица цели упражнения: повторения
  ///
  /// In ru, this message translates to:
  /// **'повт.'**
  String get sessionUnitReps;

  /// Единица цели упражнения: секунды
  ///
  /// In ru, this message translates to:
  /// **'с'**
  String get sessionUnitSeconds;

  /// Состояние упражнения для скринридера
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get sessionExerciseDone;

  /// Состояние упражнения для скринридера
  ///
  /// In ru, this message translates to:
  /// **'Текущее'**
  String get sessionExerciseCurrent;

  /// Состояние упражнения для скринридера
  ///
  /// In ru, this message translates to:
  /// **'Впереди'**
  String get sessionExerciseUpcoming;

  /// Описание таймера для скринридера
  ///
  /// In ru, this message translates to:
  /// **'Осталось {time}'**
  String sessionTimerRemaining(String time);

  /// Описание таймера круга для скринридера
  ///
  /// In ru, this message translates to:
  /// **'Круг идёт {time}'**
  String sessionTimerElapsed(String time);

  /// Главная кнопка физической фазы
  ///
  /// In ru, this message translates to:
  /// **'Подход выполнен'**
  String get sessionSetDone;

  /// Ввести фактически сделанное
  ///
  /// In ru, this message translates to:
  /// **'Другое число'**
  String get sessionSetCustom;

  /// Пропустить упражнение
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get sessionSkipExercise;

  /// Единственная danger-кнопка: прервать операцию
  ///
  /// In ru, this message translates to:
  /// **'Эвакуация'**
  String get sessionEvacuate;

  /// No description provided for @sessionEvacuateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прервать операцию?'**
  String get sessionEvacuateTitle;

  /// No description provided for @sessionEvacuateBody.
  ///
  /// In ru, this message translates to:
  /// **'Незавершённое упражнение не будет записано. Уже выполненное сохранится в итогах.'**
  String get sessionEvacuateBody;

  /// No description provided for @sessionEvacuateConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Прервать'**
  String get sessionEvacuateConfirm;

  /// No description provided for @sessionEvacuateCancel.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get sessionEvacuateCancel;

  /// Шторка ввода фактического результата подхода
  ///
  /// In ru, this message translates to:
  /// **'Сколько сделано?'**
  String get sessionActualTitle;

  /// No description provided for @sessionActualConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Записать'**
  String get sessionActualConfirm;

  /// Клавиша цифровой клавиатуры (для скринридера)
  ///
  /// In ru, this message translates to:
  /// **'Стереть'**
  String get sessionKeyBackspace;

  /// Клавиша цифровой клавиатуры (для скринридера)
  ///
  /// In ru, this message translates to:
  /// **'Минус'**
  String get sessionKeyMinus;

  /// Клавиша цифровой клавиатуры (для скринридера)
  ///
  /// In ru, this message translates to:
  /// **'Десятичный разделитель'**
  String get sessionKeyDecimal;

  /// No description provided for @sessionRatingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как прошёл прошлый круг?'**
  String get sessionRatingTitle;

  /// No description provided for @sessionEffortHard.
  ///
  /// In ru, this message translates to:
  /// **'Тяжело'**
  String get sessionEffortHard;

  /// No description provided for @sessionEffortNormal.
  ///
  /// In ru, this message translates to:
  /// **'Нормально'**
  String get sessionEffortNormal;

  /// No description provided for @sessionEffortEasy.
  ///
  /// In ru, this message translates to:
  /// **'Легко'**
  String get sessionEffortEasy;

  /// No description provided for @sessionRatingSaved.
  ///
  /// In ru, this message translates to:
  /// **'Оценка круга: {label}'**
  String sessionRatingSaved(String label);

  /// No description provided for @sessionAnswerSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Ответить'**
  String get sessionAnswerSubmit;

  /// No description provided for @sessionAnswerHint.
  ///
  /// In ru, this message translates to:
  /// **'Ваш ответ'**
  String get sessionAnswerHint;

  /// No description provided for @sessionTaskSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить задачу'**
  String get sessionTaskSkip;

  /// Подпись над текстом, который нужно запомнить
  ///
  /// In ru, this message translates to:
  /// **'Запоминайте'**
  String get sessionStudyHint;

  /// No description provided for @sessionStudyDone.
  ///
  /// In ru, this message translates to:
  /// **'Запомнил'**
  String get sessionStudyDone;

  /// Отложенный вопрос delayed_recall
  ///
  /// In ru, this message translates to:
  /// **'Вопрос по запомненному'**
  String get sessionRecallQuestionHint;

  /// No description provided for @sessionSpatialStudyHint.
  ///
  /// In ru, this message translates to:
  /// **'Запомните расположение'**
  String get sessionSpatialStudyHint;

  /// No description provided for @sessionSpatialAnswerHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите клетку и подтвердите'**
  String get sessionSpatialAnswerHint;

  /// Клетка сетки (для скринридера)
  ///
  /// In ru, this message translates to:
  /// **'Ряд {row}, столбец {col}'**
  String sessionSpatialCell(int row, int col);

  /// No description provided for @sessionOrderingHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажимайте шаги в верном порядке. Нажатие на выбранный шаг снимает его и все следующие.'**
  String get sessionOrderingHint;

  /// No description provided for @sessionVerbalSpeak.
  ///
  /// In ru, this message translates to:
  /// **'Говорите вслух'**
  String get sessionVerbalSpeak;

  /// No description provided for @sessionVerbalFinish.
  ///
  /// In ru, this message translates to:
  /// **'Закончил'**
  String get sessionVerbalFinish;

  /// No description provided for @sessionVerbalSelfCheckTitle.
  ///
  /// In ru, this message translates to:
  /// **'Самопроверка'**
  String get sessionVerbalSelfCheckTitle;

  /// No description provided for @sessionVerbalSelfCheckHint.
  ///
  /// In ru, this message translates to:
  /// **'Отвечайте честно: машина это не проверяет'**
  String get sessionVerbalSelfCheckHint;

  /// No description provided for @sessionYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get sessionYes;

  /// No description provided for @sessionNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get sessionNo;

  /// Подсказка посреди задачи; видна и без цвета
  ///
  /// In ru, this message translates to:
  /// **'Смена условия'**
  String get sessionCueTitle;

  /// No description provided for @sessionTaskUnsupported.
  ///
  /// In ru, this message translates to:
  /// **'Этот тип задачи пока не поддерживается'**
  String get sessionTaskUnsupported;

  /// No description provided for @sessionOutcomeCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Задача: верно'**
  String get sessionOutcomeCorrect;

  /// No description provided for @sessionOutcomeWrong.
  ///
  /// In ru, this message translates to:
  /// **'Задача: неверно'**
  String get sessionOutcomeWrong;

  /// No description provided for @sessionOutcomeTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Задача: время вышло'**
  String get sessionOutcomeTimeout;

  /// No description provided for @sessionOutcomeSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Задача пропущена'**
  String get sessionOutcomeSkipped;

  /// No description provided for @sessionOutcomeSelfChecked.
  ///
  /// In ru, this message translates to:
  /// **'Самопроверка принята'**
  String get sessionOutcomeSelfChecked;

  /// No description provided for @sessionOutcomeReveal.
  ///
  /// In ru, this message translates to:
  /// **'Разбор: {text}'**
  String sessionOutcomeReveal(String text);

  /// Подпись экрана оценки последнего круга
  ///
  /// In ru, this message translates to:
  /// **'Операция завершена'**
  String get sessionFinishedTitle;

  /// No description provided for @sessionToSummary.
  ///
  /// In ru, this message translates to:
  /// **'К итогам'**
  String get sessionToSummary;

  /// No description provided for @sessionSummaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Итоги операции'**
  String get sessionSummaryTitle;

  /// No description provided for @sessionSummaryStatusCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершена'**
  String get sessionSummaryStatusCompleted;

  /// No description provided for @sessionSummaryStatusAborted.
  ///
  /// In ru, this message translates to:
  /// **'Прервана'**
  String get sessionSummaryStatusAborted;

  /// No description provided for @sessionSummaryNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Операция {id} не найдена'**
  String sessionSummaryNotFound(String id);

  /// No description provided for @sessionSummaryLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать итоги операции.'**
  String get sessionSummaryLoadError;

  /// No description provided for @sessionSummaryGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Общее'**
  String get sessionSummaryGeneral;

  /// No description provided for @sessionSummaryDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get sessionSummaryDuration;

  /// No description provided for @sessionSummaryRounds.
  ///
  /// In ru, this message translates to:
  /// **'Кругов'**
  String get sessionSummaryRounds;

  /// No description provided for @sessionSummaryPhysical.
  ///
  /// In ru, this message translates to:
  /// **'Физика'**
  String get sessionSummaryPhysical;

  /// No description provided for @sessionSummarySets.
  ///
  /// In ru, this message translates to:
  /// **'Подходов выполнено'**
  String get sessionSummarySets;

  /// No description provided for @sessionSummaryReps.
  ///
  /// In ru, this message translates to:
  /// **'Повторения: факт / план'**
  String get sessionSummaryReps;

  /// No description provided for @sessionSummarySeconds.
  ///
  /// In ru, this message translates to:
  /// **'Секунды: факт / план'**
  String get sessionSummarySeconds;

  /// No description provided for @sessionSummaryTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get sessionSummaryTasks;

  /// No description provided for @sessionSummaryNoTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задач не было'**
  String get sessionSummaryNoTasks;

  /// No description provided for @sessionSummaryCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Верно'**
  String get sessionSummaryCorrect;

  /// No description provided for @sessionSummaryWrong.
  ///
  /// In ru, this message translates to:
  /// **'Неверно'**
  String get sessionSummaryWrong;

  /// No description provided for @sessionSummaryTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Время вышло'**
  String get sessionSummaryTimeout;

  /// No description provided for @sessionSummarySkipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get sessionSummarySkipped;

  /// No description provided for @sessionSummaryLatency.
  ///
  /// In ru, this message translates to:
  /// **'Средняя задержка ответа'**
  String get sessionSummaryLatency;

  /// Машина их не проверяет; в Индекс не входят
  ///
  /// In ru, this message translates to:
  /// **'Вербальные (самопроверка)'**
  String get sessionSummaryVerbal;

  /// No description provided for @sessionSummaryVerbalDone.
  ///
  /// In ru, this message translates to:
  /// **'Отвечено'**
  String get sessionSummaryVerbalDone;

  /// No description provided for @sessionSummaryVerbalRating.
  ///
  /// In ru, this message translates to:
  /// **'Средняя самооценка'**
  String get sessionSummaryVerbalRating;

  /// No description provided for @sessionSummaryToDashboard.
  ///
  /// In ru, this message translates to:
  /// **'На дашборд'**
  String get sessionSummaryToDashboard;

  /// Нет данных
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get sessionSummaryNone;

  /// No description provided for @sessionSummaryOutOf.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total}'**
  String sessionSummaryOutOf(int done, int total);

  /// No description provided for @sessionSummaryFactPlan.
  ///
  /// In ru, this message translates to:
  /// **'{done} / {plan}'**
  String sessionSummaryFactPlan(int done, int plan);

  /// No description provided for @sessionSummarySecondsValue.
  ///
  /// In ru, this message translates to:
  /// **'{sec} с'**
  String sessionSummarySecondsValue(String sec);

  /// No description provided for @sessionSummaryRatingValue.
  ///
  /// In ru, this message translates to:
  /// **'{value} из 3'**
  String sessionSummaryRatingValue(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
