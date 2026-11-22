import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/dashboard_screen.dart';
import '../features/session/session_screen.dart';
import '../features/session/session_summary_screen.dart';
import '../features/settings/categories_screen.dart';
import '../features/settings/settings_screen.dart';
import 'route_not_found_screen.dart';

/// Пути и имена маршрутов. Навигация — только через эти константы:
/// `context.push(TmbRoutes.session)`, `context.go(TmbRoutes.summaryOf(id))`.
///
/// Договорённости швов (экраны за ними реализуют другие, router.dart не
/// трогают):
///  * `/session` без параметров: экран сам читает `SessionPreferences` и
///    профиль из репозиториев, строит план и открывает сессию. С дашборда
///    сюда ведёт `push`, чтобы «назад» возвращало на дашборд.
///  * Завершив сессию, экран сессии делает `context.go(summaryOf(id))`
///    (замена, а не `push`: в стеке не остаётся мёртвой сессии).
///  * `/session/summary/:sessionId` — сессия уже записана в БД, экран читает
///    её по `sessionId` (`SessionRepository.loadSession`). Это же deep link
///    из архива.
///  * `/settings/categories` — вложенный маршрут `/settings`: «назад» ведёт
///    в настройки.
abstract final class TmbRoutes {
  static const home = '/';
  static const session = '/session';
  static const summaryPattern = '/session/summary/:$sessionIdParam';
  static const settings = '/settings';
  static const categories = '/settings/categories';

  /// Имя path-параметра [summaryPattern].
  static const sessionIdParam = 'sessionId';

  static String summaryOf(String sessionId) =>
      '/session/summary/${Uri.encodeComponent(sessionId)}';

  // Имена для `context.goNamed`.
  static const homeName = 'home';
  static const sessionName = 'session';
  static const summaryName = 'sessionSummary';
  static const settingsName = 'settings';
  static const categoriesName = 'settingsCategories';
}

/// Таблица маршрутов. Вынесена отдельно, чтобы тесты могли строить свой
/// [GoRouter] с другим `initialLocation` на тех же маршрутах.
List<RouteBase> buildRoutes() => [
  GoRoute(
    path: TmbRoutes.home,
    name: TmbRoutes.homeName,
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    path: TmbRoutes.session,
    name: TmbRoutes.sessionName,
    builder: (context, state) => const SessionScreen(),
  ),
  GoRoute(
    path: TmbRoutes.summaryPattern,
    name: TmbRoutes.summaryName,
    builder: (context, state) => SessionSummaryScreen(
      sessionId: state.pathParameters[TmbRoutes.sessionIdParam]!,
    ),
  ),
  GoRoute(
    path: TmbRoutes.settings,
    name: TmbRoutes.settingsName,
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'categories',
        name: TmbRoutes.categoriesName,
        builder: (context, state) => const CategoriesScreen(),
      ),
    ],
  ),
];

GoRouter createRouter({String initialLocation = TmbRoutes.home}) => GoRouter(
  initialLocation: initialLocation,
  routes: buildRoutes(),
  errorBuilder: (context, state) => const RouteNotFoundScreen(),
);

/// Роутер приложения. В тестах: `routerProvider.overrideWithValue(
/// createRouter(initialLocation: ...))`.
final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});
