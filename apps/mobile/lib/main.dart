import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import 'dashboard/dashboard_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const TmbApp());
}

class TmbApp extends StatelessWidget {
  const TmbApp({super.key, this.locale = const Locale('ru')});

  /// Локаль по умолчанию — ru; переопределяется только в тестах.
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: TmbTheme.dark(),
      darkTheme: TmbTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const DashboardScreen(),
    );
  }
}
