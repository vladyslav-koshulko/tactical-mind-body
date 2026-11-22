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

  @override
  String get dashboardSettings => 'Настройки';

  @override
  String get appLoading => 'Загрузка контента';

  @override
  String get appLoadErrorTitle => 'Не удалось загрузить контент';

  @override
  String get appLoadErrorBody =>
      'Встроенные наборы заданий повреждены или не найдены. Переустановите приложение.';

  @override
  String appLoadErrorDetails(String details) {
    return 'Подробности: $details';
  }

  @override
  String get appRetry => 'Повторить';

  @override
  String get appRouteNotFoundTitle => 'Экран не найден';

  @override
  String get appBackToDashboard => 'На дашборд';

  @override
  String get dashboardLocationHeading => 'Локация';

  @override
  String get dashboardLocationSoon => 'Скоро';

  @override
  String get dashboardDifficultyHeading => 'Сложность';

  @override
  String get dashboardDifficultyRecruit => 'Рекрут';

  @override
  String get dashboardDifficultyFighter => 'Боец';

  @override
  String get dashboardDifficultyOperator => 'Оператор';

  @override
  String get dashboardDifficultySpetsnaz => 'Спецназ';

  @override
  String get dashboardLastOperationDone => 'Завершена';

  @override
  String get dashboardLastOperationInterrupted => 'Прервана';

  @override
  String dashboardLastOperationRounds(int count) {
    return 'Кругов: $count';
  }

  @override
  String dashboardLastOperationTasks(int count) {
    return 'Задач: $count';
  }

  @override
  String get dashboardLastOperationDetails => 'Подробнее';

  @override
  String get dashboardSaveError => 'Не удалось сохранить выбор';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsBack => 'Назад';

  @override
  String get settingsLoading => 'Загрузка настроек';

  @override
  String get settingsLoadError => 'Не удалось прочитать настройки';

  @override
  String get settingsSaveError => 'Не удалось сохранить изменение';

  @override
  String get settingsSectionSession => 'Шаблон операции';

  @override
  String get settingsTemplateDualTask => 'Dual-Task';

  @override
  String get settingsTemplateDualTaskHint =>
      'Круг, когнитивное окно, снова круг';

  @override
  String get settingsTemplatePhysicalOnly => 'Только физика';

  @override
  String get settingsTemplatePhysicalOnlyHint =>
      'Круги подряд, без когнитивных задач';

  @override
  String get settingsTemplateCognitiveOnly => 'Только когниция';

  @override
  String get settingsTemplateCognitiveOnlyHint =>
      'Только задачи, без упражнений';

  @override
  String get settingsTemplateCustom => 'Своя последовательность';

  @override
  String get settingsSectionParams => 'Параметры операции';

  @override
  String get settingsRounds => 'Число кругов';

  @override
  String get settingsWindows => 'Число когнитивных окон';

  @override
  String get settingsCognitiveSec => 'Длительность когнитивного окна';

  @override
  String get settingsRestSec => 'Отдых между кругами';

  @override
  String get settingsRestNone => 'Без отдыха';

  @override
  String settingsSecondsValue(int value) {
    return '$value с';
  }

  @override
  String settingsStepperDecrease(String label) {
    return 'Уменьшить: $label';
  }

  @override
  String settingsStepperIncrease(String label) {
    return 'Увеличить: $label';
  }

  @override
  String settingsStepperEdit(String label) {
    return 'Ввести значение: $label';
  }

  @override
  String settingsStepperRangeError(int min, int max) {
    return 'Введите число от $min до $max';
  }

  @override
  String get settingsConfirm => 'Готово';

  @override
  String get settingsCancel => 'Отмена';

  @override
  String get settingsSectionReps => 'Нагрузка по умолчанию';

  @override
  String get settingsRepsMode => 'Режим повторений';

  @override
  String get settingsRepsModeFixed => 'Фиксированный';

  @override
  String get settingsRepsModeRange => 'Диапазон';

  @override
  String get settingsRepsHint =>
      'Цель для упражнений без своей цели. В диапазоне число выпадает случайно на каждый круг.';

  @override
  String get settingsTargetReps => 'Повторения';

  @override
  String get settingsTargetSeconds => 'Удержание, секунды';

  @override
  String get settingsTargetValue => 'Значение';

  @override
  String get settingsTargetFrom => 'От';

  @override
  String get settingsTargetTo => 'До';

  @override
  String get settingsSectionProgression => 'Прогрессия нагрузки';

  @override
  String get settingsProgressionToggle => 'Подстройка нагрузки по истории';

  @override
  String get settingsProgressionHint =>
      'Алгоритм появится в версии 0.2: пока сохраняется только этот переключатель, нагрузка не меняется.';

  @override
  String get settingsOn => 'Вкл';

  @override
  String get settingsOff => 'Выкл';

  @override
  String get settingsSectionMore => 'Данные и приложение';

  @override
  String get settingsLinkCategories => 'Категории задач';

  @override
  String settingsLinkCategoriesSummary(int enabled, int total) {
    return 'Включено $enabled из $total';
  }

  @override
  String get settingsLinkTargets => 'Цели упражнений';

  @override
  String settingsLinkTargetsSummary(int count) {
    return 'Своих целей: $count';
  }

  @override
  String get settingsLinkExport => 'Экспорт данных';

  @override
  String get settingsLinkAbout => 'О приложении';

  @override
  String get categoriesTitle => 'Категории задач';

  @override
  String get categoriesLoading => 'Загрузка категорий';

  @override
  String get categoriesLoadError => 'Не удалось собрать список категорий';

  @override
  String get categoriesSectionVerifiable => 'Проверяемые';

  @override
  String get categoriesSectionVerifiableHint =>
      'Ответ проверяет приложение: верно или нет.';

  @override
  String get categoriesSectionUnverifiable => 'Непроверяемые';

  @override
  String get categoriesSectionUnverifiableHint =>
      'Самооценка по чек-листу: не влияют на Индекс и рейтинги.';

  @override
  String categoriesSectionSummary(int enabled, int total) {
    return 'Включено категорий: $enabled из $total';
  }

  @override
  String get categoriesEnableAll => 'Включить все';

  @override
  String get categoriesDisableAll => 'Выключить все';

  @override
  String categoriesTasksCount(int count) {
    return 'Задач: $count';
  }

  @override
  String get categoriesEmptySection => 'В этом разделе пока нет задач';

  @override
  String get categoriesEmptyPool =>
      'Нельзя отключить всё: должна остаться хотя бы одна включённая категория.';

  @override
  String get categoriesSaveError => 'Не удалось сохранить выбор категорий';

  @override
  String get categoriesStateOn => 'Включена';

  @override
  String get categoriesStateOff => 'Выключена';

  @override
  String get categoriesStateMixed => 'Включена частично';

  @override
  String get categoriesGroupMath => 'Математика';

  @override
  String get categoriesGroupCog => 'Когнитивные';

  @override
  String get categoriesGroupArithmetic => 'Арифметика';

  @override
  String get categoriesGroupMemory => 'Память';

  @override
  String get categoriesGroupUncertainty => 'Неопределённость';

  @override
  String get categoriesGroupVerbal => 'Вербальные';

  @override
  String get targetsTitle => 'Цели упражнений';

  @override
  String get targetsHint =>
      'Своя цель заменяет значение по умолчанию. Заданные вручную цели прогрессия не меняет.';

  @override
  String get targetsLoading => 'Загрузка упражнений';

  @override
  String get targetsLoadError => 'Не удалось загрузить упражнения';

  @override
  String get targetsEmpty => 'Упражнений нет';

  @override
  String get targetsCustom => 'Своя цель';

  @override
  String get targetsDefault => 'По умолчанию';

  @override
  String get targetsReset => 'Сбросить к умолчанию';

  @override
  String get targetsSaveError => 'Не удалось сохранить цель';

  @override
  String get targetsUnitReps => 'повт.';

  @override
  String get targetsUnitSeconds => 'сек';

  @override
  String get targetsRangeToggle => 'Диапазон';

  @override
  String get targetsValue => 'Значение';

  @override
  String get targetsFrom => 'От';

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
  String get exportTitle => 'Экспорт данных';

  @override
  String get exportDescription =>
      'Все записанные события тренировок одним JSON-файлом: сессии, круги, подходы и попытки. Файл можно сохранить или отправить через системное меню.';

  @override
  String get exportPrivacy =>
      'Приложение само ничего не отправляет: файл уйдёт только туда, куда вы его направите.';

  @override
  String exportCounts(int sessions, int rounds, int sets, int attempts) {
    return 'Сессий: $sessions · кругов: $rounds · подходов: $sets · попыток: $attempts';
  }

  @override
  String get exportEmpty => 'Данных пока нет. Проведите хотя бы одну операцию.';

  @override
  String get exportButton => 'Поделиться файлом';

  @override
  String get exportPreparing => 'Подготовка файла';

  @override
  String get exportError => 'Не удалось подготовить или отправить файл';

  @override
  String get exportLoadError => 'Не удалось прочитать данные';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutDescription =>
      'Офлайн-тренажёр: физические круги чередуются с когнитивными задачами.';

  @override
  String get aboutLicenses => 'Лицензии';

  @override
  String get aboutFonts =>
      'Шрифты Oswald и JetBrains Mono распространяются по лицензии SIL Open Font License 1.1.';

  @override
  String get aboutNotMedical =>
      'Приложение не даёт медицинских рекомендаций: нагрузку подбирайте по самочувствию.';

  @override
  String get sessionLoading => 'Подготовка операции';

  @override
  String get sessionErrorTitle => 'Не удалось начать операцию';

  @override
  String get sessionErrorNoExercises =>
      'Нет упражнений для выбранного места. Смените место или добавьте упражнения.';

  @override
  String get sessionErrorEmptyTaskPool =>
      'Нет доступных когнитивных задач: проверьте включённые категории и уровень сложности.';

  @override
  String get sessionErrorGeneric => 'Не удалось построить план операции.';

  @override
  String get sessionBackToDashboard => 'На дашборд';

  @override
  String sessionRoundTitle(int n, int total) {
    return 'Круг $n из $total';
  }

  @override
  String sessionTaskTitle(int n, int total) {
    return 'Задача $n из $total';
  }

  @override
  String get sessionRestPhase => 'Отдых';

  @override
  String get sessionRestTitle => 'Пассивный отдых';

  @override
  String get sessionUnitReps => 'повт.';

  @override
  String get sessionUnitSeconds => 'с';

  @override
  String get sessionExerciseDone => 'Выполнено';

  @override
  String get sessionExerciseCurrent => 'Текущее';

  @override
  String get sessionExerciseUpcoming => 'Впереди';

  @override
  String sessionTimerRemaining(String time) {
    return 'Осталось $time';
  }

  @override
  String sessionTimerElapsed(String time) {
    return 'Круг идёт $time';
  }

  @override
  String get sessionSetDone => 'Подход выполнен';

  @override
  String get sessionSetCustom => 'Другое число';

  @override
  String get sessionSkipExercise => 'Пропустить';

  @override
  String get sessionEvacuate => 'Эвакуация';

  @override
  String get sessionEvacuateTitle => 'Прервать операцию?';

  @override
  String get sessionEvacuateBody =>
      'Незавершённое упражнение не будет записано. Уже выполненное сохранится в итогах.';

  @override
  String get sessionEvacuateConfirm => 'Прервать';

  @override
  String get sessionEvacuateCancel => 'Продолжить';

  @override
  String get sessionActualTitle => 'Сколько сделано?';

  @override
  String get sessionActualConfirm => 'Записать';

  @override
  String get sessionKeyBackspace => 'Стереть';

  @override
  String get sessionKeyMinus => 'Минус';

  @override
  String get sessionKeyDecimal => 'Десятичный разделитель';

  @override
  String get sessionRatingTitle => 'Как прошёл прошлый круг?';

  @override
  String get sessionEffortHard => 'Тяжело';

  @override
  String get sessionEffortNormal => 'Нормально';

  @override
  String get sessionEffortEasy => 'Легко';

  @override
  String sessionRatingSaved(String label) {
    return 'Оценка круга: $label';
  }

  @override
  String get sessionAnswerSubmit => 'Ответить';

  @override
  String get sessionAnswerHint => 'Ваш ответ';

  @override
  String get sessionTaskSkip => 'Пропустить задачу';

  @override
  String get sessionStudyHint => 'Запоминайте';

  @override
  String get sessionStudyDone => 'Запомнил';

  @override
  String get sessionRecallQuestionHint => 'Вопрос по запомненному';

  @override
  String get sessionSpatialStudyHint => 'Запомните расположение';

  @override
  String get sessionSpatialAnswerHint => 'Нажмите клетку и подтвердите';

  @override
  String sessionSpatialCell(int row, int col) {
    return 'Ряд $row, столбец $col';
  }

  @override
  String get sessionOrderingHint =>
      'Нажимайте шаги в верном порядке. Нажатие на выбранный шаг снимает его и все следующие.';

  @override
  String get sessionVerbalSpeak => 'Говорите вслух';

  @override
  String get sessionVerbalFinish => 'Закончил';

  @override
  String get sessionVerbalSelfCheckTitle => 'Самопроверка';

  @override
  String get sessionVerbalSelfCheckHint =>
      'Отвечайте честно: машина это не проверяет';

  @override
  String get sessionYes => 'Да';

  @override
  String get sessionNo => 'Нет';

  @override
  String get sessionCueTitle => 'Смена условия';

  @override
  String get sessionTaskUnsupported => 'Этот тип задачи пока не поддерживается';

  @override
  String get sessionOutcomeCorrect => 'Задача: верно';

  @override
  String get sessionOutcomeWrong => 'Задача: неверно';

  @override
  String get sessionOutcomeTimeout => 'Задача: время вышло';

  @override
  String get sessionOutcomeSkipped => 'Задача пропущена';

  @override
  String get sessionOutcomeSelfChecked => 'Самопроверка принята';

  @override
  String sessionOutcomeReveal(String text) {
    return 'Разбор: $text';
  }

  @override
  String get sessionFinishedTitle => 'Операция завершена';

  @override
  String get sessionToSummary => 'К итогам';

  @override
  String get sessionSummaryTitle => 'Итоги операции';

  @override
  String get sessionSummaryStatusCompleted => 'Завершена';

  @override
  String get sessionSummaryStatusAborted => 'Прервана';

  @override
  String sessionSummaryNotFound(String id) {
    return 'Операция $id не найдена';
  }

  @override
  String get sessionSummaryLoadError => 'Не удалось прочитать итоги операции.';

  @override
  String get sessionSummaryGeneral => 'Общее';

  @override
  String get sessionSummaryDuration => 'Длительность';

  @override
  String get sessionSummaryRounds => 'Кругов';

  @override
  String get sessionSummaryPhysical => 'Физика';

  @override
  String get sessionSummarySets => 'Подходов выполнено';

  @override
  String get sessionSummaryReps => 'Повторения: факт / план';

  @override
  String get sessionSummarySeconds => 'Секунды: факт / план';

  @override
  String get sessionSummaryTasks => 'Задачи';

  @override
  String get sessionSummaryNoTasks => 'Задач не было';

  @override
  String get sessionSummaryCorrect => 'Верно';

  @override
  String get sessionSummaryWrong => 'Неверно';

  @override
  String get sessionSummaryTimeout => 'Время вышло';

  @override
  String get sessionSummarySkipped => 'Пропущено';

  @override
  String get sessionSummaryLatency => 'Средняя задержка ответа';

  @override
  String get sessionSummaryVerbal => 'Вербальные (самопроверка)';

  @override
  String get sessionSummaryVerbalDone => 'Отвечено';

  @override
  String get sessionSummaryVerbalRating => 'Средняя самооценка';

  @override
  String get sessionSummaryToDashboard => 'На дашборд';

  @override
  String get sessionSummaryNone => '—';

  @override
  String sessionSummaryOutOf(int done, int total) {
    return '$done из $total';
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
    return '$value из 3';
  }
}
