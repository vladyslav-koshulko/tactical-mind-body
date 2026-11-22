import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/app/app.dart';
import 'package:tmb_mobile/app/router.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/settings/file_share_service.dart';
import 'package:tmb_mobile/features/settings/settings_providers.dart';
import 'package:tmb_mobile/l10n/app_localizations.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../helpers.dart';

/// Фейк «Поделиться»: запоминает файл, платформенный плагин не трогает.
class FakeFileShareService implements FileShareService {
  final shared = <({String fileName, Uint8List bytes, String mimeType})>[];

  /// Если задан — `shareFile` бросает его.
  Object? failWith;

  @override
  Future<void> shareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (failWith != null) throw failWith!;
    shared.add((fileName: fileName, bytes: bytes, mimeType: mimeType));
  }
}

/// Снимает дерево и даёт отработать нулевым таймерам Drift (закрытие
/// потоков запросов). Без этого тест падает на «Timer is still pending».
/// Регистрировать через `addTearDown(() => unmountApp(tester))` — до
/// `container.dispose`, то есть после него в порядке регистрации.
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Размер и масштаб текста для прогона «без overflow».
const narrowLogicalWidth = 320.0;
const bigTextScale = 1.5;

void setView(WidgetTester tester, {double width = 360, double height = 800}) {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Экран целиком в `MaterialApp` (без роутера) — для экранов без навигации.
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  Locale locale = const Locale('ru'),
  double width = 360,
  double textScale = 1,
}) async {
  setView(tester, width: width);
  final container = ProviderContainer(
    overrides: [...testOverrides(), ...overrides],
  );
  addTearDown(container.dispose);
  addTearDown(() => unmountApp(tester));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: TmbTheme.dark(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Приложение целиком на заданном маршруте (нужно экранам с навигацией).
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  String initialLocation = TmbRoutes.home,
  List<Override> overrides = const [],
  Locale locale = const Locale('ru'),
  double width = 360,
  double textScale = 1,
}) async {
  setView(tester, width: width);
  final router = createRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final container = ProviderContainer(
    overrides: [
      ...testOverrides(),
      routerProvider.overrideWithValue(router),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  addTearDown(() => unmountApp(tester));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TmbApp(locale: locale),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Доступ к БД из теста: настоящие `Future` вне фейковых часов виджет-теста.
Future<T> db<T>(WidgetTester tester, Future<T> Function() action) async {
  final result = await tester.runAsync(action);
  return result as T;
}

/// Прокручивает список, пока [finder] не окажется на экране (список ленивый:
/// строки далеко за экраном не строятся).
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Дать записи дойти до БД, потокам обновиться, а экрану — перерисоваться.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
  }
}

/// Сохраняет образец событий из `tmb_domain/test` (одна завершённая сессия).
Future<EventsExport> seedSampleSession(
  WidgetTester tester,
  ProviderContainer container, {
  int? endedAt,
  bool interrupted = false,
}) async {
  final json = jsonDecode(
    File('../../packages/tmb_domain/test/events_export.sample.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;
  final export = EventsExport.fromJson(json);
  final session = interrupted
      ? Session(
          id: export.sessions.first.id,
          startedAt: export.sessions.first.startedAt,
          endedAt: null,
          utcOffsetMin: export.sessions.first.utcOffsetMin,
          location: export.sessions.first.location,
          difficulty: export.sessions.first.difficulty,
          template: export.sessions.first.template,
          appVersion: export.sessions.first.appVersion,
        )
      : export.sessions.first;
  await db(
    tester,
    () => container
        .read(sessionRepositoryProvider)
        .saveSession(
          SessionBundle(
            session: session,
            rounds: export.rounds,
            sets: export.sets,
            attempts: export.attempts,
          ),
        ),
  );
  return export;
}

/// Подмена платформенного «Поделиться» фейком.
Override shareOverride(FakeFileShareService fake) =>
    fileShareServiceProvider.overrideWithValue(fake);
