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

  @override
  String get dashboardSettings => 'Налаштування';

  @override
  String get appLoading => 'Завантаження контенту';

  @override
  String get appLoadErrorTitle => 'Не вдалося завантажити контент';

  @override
  String get appLoadErrorBody =>
      'Вбудовані набори завдань пошкоджені або не знайдені. Перевстановіть застосунок.';

  @override
  String appLoadErrorDetails(String details) {
    return 'Подробиці: $details';
  }

  @override
  String get appRetry => 'Повторити';

  @override
  String get appRouteNotFoundTitle => 'Екран не знайдено';

  @override
  String get appBackToDashboard => 'На дашборд';

  @override
  String get dashboardLocationHeading => 'Локація';

  @override
  String get dashboardLocationSoon => 'Скоро';

  @override
  String get dashboardDifficultyHeading => 'Складність';

  @override
  String get dashboardDifficultyRecruit => 'Рекрут';

  @override
  String get dashboardDifficultyFighter => 'Боєць';

  @override
  String get dashboardDifficultyOperator => 'Оператор';

  @override
  String get dashboardDifficultySpetsnaz => 'Спецпризначенець';

  @override
  String get dashboardLastOperationDone => 'Завершена';

  @override
  String get dashboardLastOperationInterrupted => 'Перервана';

  @override
  String dashboardLastOperationRounds(int count) {
    return 'Кіл: $count';
  }

  @override
  String dashboardLastOperationTasks(int count) {
    return 'Завдань: $count';
  }

  @override
  String get dashboardLastOperationDetails => 'Докладніше';

  @override
  String get dashboardSaveError => 'Не вдалося зберегти вибір';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsBack => 'Назад';

  @override
  String get settingsLoading => 'Завантаження налаштувань';

  @override
  String get settingsLoadError => 'Не вдалося прочитати налаштування';

  @override
  String get settingsSaveError => 'Не вдалося зберегти зміну';

  @override
  String get settingsSectionSession => 'Шаблон операції';

  @override
  String get settingsTemplateDualTask => 'Dual-Task';

  @override
  String get settingsTemplateDualTaskHint =>
      'Коло, когнітивне вікно, знову коло';

  @override
  String get settingsTemplatePhysicalOnly => 'Лише фізика';

  @override
  String get settingsTemplatePhysicalOnlyHint =>
      'Кола підряд, без когнітивних завдань';

  @override
  String get settingsTemplateCognitiveOnly => 'Лише когніція';

  @override
  String get settingsTemplateCognitiveOnlyHint => 'Лише завдання, без вправ';

  @override
  String get settingsTemplateCustom => 'Власна послідовність';

  @override
  String get settingsSectionParams => 'Параметри операції';

  @override
  String get settingsRounds => 'Кількість кіл';

  @override
  String get settingsWindows => 'Кількість когнітивних вікон';

  @override
  String get settingsCognitiveSec => 'Тривалість когнітивного вікна';

  @override
  String get settingsRestSec => 'Відпочинок між колами';

  @override
  String get settingsRestNone => 'Без відпочинку';

  @override
  String settingsSecondsValue(int value) {
    return '$value с';
  }

  @override
  String settingsStepperDecrease(String label) {
    return 'Зменшити: $label';
  }

  @override
  String settingsStepperIncrease(String label) {
    return 'Збільшити: $label';
  }

  @override
  String settingsStepperEdit(String label) {
    return 'Ввести значення: $label';
  }

  @override
  String settingsStepperRangeError(int min, int max) {
    return 'Введіть число від $min до $max';
  }

  @override
  String get settingsConfirm => 'Готово';

  @override
  String get settingsCancel => 'Скасувати';

  @override
  String get settingsSectionReps => 'Навантаження за замовчуванням';

  @override
  String get settingsRepsMode => 'Режим повторень';

  @override
  String get settingsRepsModeFixed => 'Фіксований';

  @override
  String get settingsRepsModeRange => 'Діапазон';

  @override
  String get settingsRepsHint =>
      'Ціль для вправ без власної цілі. У діапазоні число випадає випадково на кожне коло.';

  @override
  String get settingsTargetReps => 'Повторення';

  @override
  String get settingsTargetSeconds => 'Утримання, секунди';

  @override
  String get settingsTargetValue => 'Значення';

  @override
  String get settingsTargetFrom => 'Від';

  @override
  String get settingsTargetTo => 'До';

  @override
  String get settingsSectionProgression => 'Прогресія навантаження';

  @override
  String get settingsProgressionToggle =>
      'Підлаштування навантаження за історією';

  @override
  String get settingsProgressionHint =>
      'Алгоритм з’явиться у версії 0.2: поки що зберігається лише цей перемикач, навантаження не змінюється.';

  @override
  String get settingsOn => 'Увімк';

  @override
  String get settingsOff => 'Вимк';

  @override
  String get settingsSectionMore => 'Дані та застосунок';

  @override
  String get settingsLinkCategories => 'Категорії завдань';

  @override
  String settingsLinkCategoriesSummary(int enabled, int total) {
    return 'Увімкнено $enabled з $total';
  }

  @override
  String get settingsLinkTargets => 'Цілі вправ';

  @override
  String settingsLinkTargetsSummary(int count) {
    return 'Власних цілей: $count';
  }

  @override
  String get settingsLinkExport => 'Експорт даних';

  @override
  String get settingsLinkAbout => 'Про застосунок';

  @override
  String get categoriesTitle => 'Категорії завдань';

  @override
  String get categoriesLoading => 'Завантаження категорій';

  @override
  String get categoriesLoadError => 'Не вдалося зібрати список категорій';

  @override
  String get categoriesSectionVerifiable => 'Перевірювані';

  @override
  String get categoriesSectionVerifiableHint =>
      'Відповідь перевіряє застосунок: правильно чи ні.';

  @override
  String get categoriesSectionUnverifiable => 'Неперевірювані';

  @override
  String get categoriesSectionUnverifiableHint =>
      'Самооцінка за чек-листом: не впливають на Індекс і рейтинги.';

  @override
  String categoriesSectionSummary(int enabled, int total) {
    return 'Увімкнено категорій: $enabled з $total';
  }

  @override
  String get categoriesEnableAll => 'Увімкнути всі';

  @override
  String get categoriesDisableAll => 'Вимкнути всі';

  @override
  String categoriesTasksCount(int count) {
    return 'Завдань: $count';
  }

  @override
  String get categoriesEmptySection => 'У цьому розділі поки немає завдань';

  @override
  String get categoriesEmptyPool =>
      'Не можна вимкнути все: має залишитися хоча б одна увімкнена категорія.';

  @override
  String get categoriesSaveError => 'Не вдалося зберегти вибір категорій';

  @override
  String get categoriesStateOn => 'Увімкнена';

  @override
  String get categoriesStateOff => 'Вимкнена';

  @override
  String get categoriesStateMixed => 'Увімкнена частково';

  @override
  String get categoriesGroupMath => 'Математика';

  @override
  String get categoriesGroupCog => 'Когнітивні';

  @override
  String get categoriesGroupArithmetic => 'Арифметика';

  @override
  String get categoriesGroupMemory => 'Пам’ять';

  @override
  String get categoriesGroupUncertainty => 'Невизначеність';

  @override
  String get categoriesGroupVerbal => 'Вербальні';

  @override
  String get targetsTitle => 'Цілі вправ';

  @override
  String get targetsHint =>
      'Власна ціль замінює значення за замовчуванням. Задані вручну цілі прогресія не змінює.';

  @override
  String get targetsLoading => 'Завантаження вправ';

  @override
  String get targetsLoadError => 'Не вдалося завантажити вправи';

  @override
  String get targetsEmpty => 'Вправ немає';

  @override
  String get targetsCustom => 'Власна ціль';

  @override
  String get targetsDefault => 'За замовчуванням';

  @override
  String get targetsReset => 'Скинути до типових';

  @override
  String get targetsSaveError => 'Не вдалося зберегти ціль';

  @override
  String get targetsUnitReps => 'повт.';

  @override
  String get targetsUnitSeconds => 'сек';

  @override
  String get targetsRangeToggle => 'Діапазон';

  @override
  String get targetsValue => 'Значення';

  @override
  String get targetsFrom => 'Від';

  @override
  String get targetsTo => 'До';

  @override
  String targetsValueFixed(int value, String unit) {
    return '$value $unit';
  }

  @override
  String targetsValueRange(int min, int max, String unit) {
    return '$min–$max $unit';
  }

  @override
  String get exportTitle => 'Експорт даних';

  @override
  String get exportDescription =>
      'Усі записані події тренувань одним JSON-файлом: сесії, кола, підходи та спроби. Файл можна зберегти або надіслати через системне меню.';

  @override
  String get exportPrivacy =>
      'Застосунок сам нічого не надсилає: файл піде лише туди, куди ви його спрямуєте.';

  @override
  String exportCounts(int sessions, int rounds, int sets, int attempts) {
    return 'Сесій: $sessions · кіл: $rounds · підходів: $sets · спроб: $attempts';
  }

  @override
  String get exportEmpty => 'Даних поки немає. Проведіть хоча б одну операцію.';

  @override
  String get exportButton => 'Поділитися файлом';

  @override
  String get exportPreparing => 'Підготовка файлу';

  @override
  String get exportError => 'Не вдалося підготувати або надіслати файл';

  @override
  String get exportLoadError => 'Не вдалося прочитати дані';

  @override
  String get aboutTitle => 'Про застосунок';

  @override
  String aboutVersion(String version) {
    return 'Версія $version';
  }

  @override
  String get aboutDescription =>
      'Офлайн-тренажер: фізичні кола чергуються з когнітивними завданнями.';

  @override
  String get aboutLicenses => 'Ліцензії';

  @override
  String get aboutFonts =>
      'Шрифти Oswald і JetBrains Mono поширюються за ліцензією SIL Open Font License 1.1.';

  @override
  String get aboutNotMedical =>
      'Застосунок не дає медичних рекомендацій: навантаження добирайте за самопочуттям.';

  @override
  String get sessionLoading => 'Підготовка операції';

  @override
  String get sessionErrorTitle => 'Не вдалося розпочати операцію';

  @override
  String get sessionErrorNoExercises =>
      'Немає вправ для обраного місця. Змініть місце або додайте вправи.';

  @override
  String get sessionErrorEmptyTaskPool =>
      'Немає доступних когнітивних завдань: перевірте ввімкнені категорії та рівень складності.';

  @override
  String get sessionErrorGeneric => 'Не вдалося побудувати план операції.';

  @override
  String get sessionBackToDashboard => 'На дашборд';

  @override
  String sessionRoundTitle(int n, int total) {
    return 'Коло $n з $total';
  }

  @override
  String sessionTaskTitle(int n, int total) {
    return 'Завдання $n з $total';
  }

  @override
  String get sessionRestPhase => 'Відпочинок';

  @override
  String get sessionRestTitle => 'Пасивний відпочинок';

  @override
  String get sessionUnitReps => 'повт.';

  @override
  String get sessionUnitSeconds => 'с';

  @override
  String get sessionExerciseDone => 'Виконано';

  @override
  String get sessionExerciseCurrent => 'Поточна';

  @override
  String get sessionExerciseUpcoming => 'Далі';

  @override
  String sessionTimerRemaining(String time) {
    return 'Залишилось $time';
  }

  @override
  String sessionTimerElapsed(String time) {
    return 'Коло триває $time';
  }

  @override
  String get sessionSetDone => 'Підхід виконано';

  @override
  String get sessionSetCustom => 'Інше число';

  @override
  String get sessionSkipExercise => 'Пропустити';

  @override
  String get sessionEvacuate => 'Евакуація';

  @override
  String get sessionEvacuateTitle => 'Перервати операцію?';

  @override
  String get sessionEvacuateBody =>
      'Незавершена вправа не буде записана. Те, що вже виконано, збережеться в підсумках.';

  @override
  String get sessionEvacuateConfirm => 'Перервати';

  @override
  String get sessionEvacuateCancel => 'Продовжити';

  @override
  String get sessionActualTitle => 'Скільки зроблено?';

  @override
  String get sessionActualConfirm => 'Записати';

  @override
  String get sessionKeyBackspace => 'Стерти';

  @override
  String get sessionKeyMinus => 'Мінус';

  @override
  String get sessionKeyDecimal => 'Десятковий роздільник';

  @override
  String get sessionRatingTitle => 'Як минуло попереднє коло?';

  @override
  String get sessionEffortHard => 'Важко';

  @override
  String get sessionEffortNormal => 'Нормально';

  @override
  String get sessionEffortEasy => 'Легко';

  @override
  String sessionRatingSaved(String label) {
    return 'Оцінка кола: $label';
  }

  @override
  String get sessionAnswerSubmit => 'Відповісти';

  @override
  String get sessionAnswerHint => 'Ваша відповідь';

  @override
  String get sessionTaskSkip => 'Пропустити завдання';

  @override
  String get sessionStudyHint => 'Запам\'ятовуйте';

  @override
  String get sessionStudyDone => 'Запам\'ятав';

  @override
  String get sessionRecallQuestionHint => 'Запитання за запам\'ятованим';

  @override
  String get sessionSpatialStudyHint => 'Запам\'ятайте розташування';

  @override
  String get sessionSpatialAnswerHint => 'Натисніть клітинку й підтвердьте';

  @override
  String sessionSpatialCell(int row, int col) {
    return 'Рядок $row, стовпець $col';
  }

  @override
  String get sessionOrderingHint =>
      'Натискайте кроки у правильному порядку. Натискання на обраний крок знімає його та всі наступні.';

  @override
  String get sessionVerbalSpeak => 'Говоріть уголос';

  @override
  String get sessionVerbalFinish => 'Закінчив';

  @override
  String get sessionVerbalSelfCheckTitle => 'Самоперевірка';

  @override
  String get sessionVerbalSelfCheckHint =>
      'Відповідайте чесно: машина цього не перевіряє';

  @override
  String get sessionYes => 'Так';

  @override
  String get sessionNo => 'Ні';

  @override
  String get sessionCueTitle => 'Зміна умови';

  @override
  String get sessionTaskUnsupported => 'Цей тип завдання поки не підтримується';

  @override
  String get sessionOutcomeCorrect => 'Завдання: правильно';

  @override
  String get sessionOutcomeWrong => 'Завдання: неправильно';

  @override
  String get sessionOutcomeTimeout => 'Завдання: час вийшов';

  @override
  String get sessionOutcomeSkipped => 'Завдання пропущено';

  @override
  String get sessionOutcomeSelfChecked => 'Самоперевірку прийнято';

  @override
  String sessionOutcomeReveal(String text) {
    return 'Розбір: $text';
  }

  @override
  String get sessionFinishedTitle => 'Операцію завершено';

  @override
  String get sessionToSummary => 'До підсумків';

  @override
  String get sessionSummaryTitle => 'Підсумки операції';

  @override
  String get sessionSummaryStatusCompleted => 'Завершена';

  @override
  String get sessionSummaryStatusAborted => 'Перервана';

  @override
  String sessionSummaryNotFound(String id) {
    return 'Операцію $id не знайдено';
  }

  @override
  String get sessionSummaryLoadError =>
      'Не вдалося прочитати підсумки операції.';

  @override
  String get sessionSummaryGeneral => 'Загальне';

  @override
  String get sessionSummaryDuration => 'Тривалість';

  @override
  String get sessionSummaryRounds => 'Кіл';

  @override
  String get sessionSummaryPhysical => 'Фізика';

  @override
  String get sessionSummarySets => 'Підходів виконано';

  @override
  String get sessionSummaryReps => 'Повторення: факт / план';

  @override
  String get sessionSummarySeconds => 'Секунди: факт / план';

  @override
  String get sessionSummaryTasks => 'Завдання';

  @override
  String get sessionSummaryNoTasks => 'Завдань не було';

  @override
  String get sessionSummaryCorrect => 'Правильно';

  @override
  String get sessionSummaryWrong => 'Неправильно';

  @override
  String get sessionSummaryTimeout => 'Час вийшов';

  @override
  String get sessionSummarySkipped => 'Пропущено';

  @override
  String get sessionSummaryLatency => 'Середня затримка відповіді';

  @override
  String get sessionSummaryVerbal => 'Вербальні (самоперевірка)';

  @override
  String get sessionSummaryVerbalDone => 'Відповіли';

  @override
  String get sessionSummaryVerbalRating => 'Середня самооцінка';

  @override
  String get sessionSummaryToDashboard => 'На дашборд';

  @override
  String get sessionSummaryNone => '—';

  @override
  String sessionSummaryOutOf(int done, int total) {
    return '$done з $total';
  }

  @override
  String sessionSummaryFactPlan(int done, int plan) {
    return '$done / $plan';
  }

  @override
  String sessionSummarySecondsValue(String sec) {
    return '$sec с';
  }

  @override
  String sessionSummaryRatingValue(String value) {
    return '$value з 3';
  }
}
