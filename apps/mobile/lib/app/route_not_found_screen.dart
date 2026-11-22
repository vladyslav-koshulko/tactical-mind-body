import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';

/// Неизвестный маршрут (битая ссылка): сообщение и выход на дашборд.
class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TmbSpace.x4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.appRouteNotFoundTitle.toUpperCase(),
                  style: TmbType.displayLg.copyWith(
                    color: TmbColor.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: TmbSpace.x6),
              FilledButton(
                onPressed: () => context.go(TmbRoutes.home),
                child: Text(l10n.appBackToDashboard.toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
