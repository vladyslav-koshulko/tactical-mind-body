import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'startup_gate.dart';

/// Корень приложения. Требует `ProviderScope` выше по дереву.
class TmbApp extends ConsumerWidget {
  const TmbApp({super.key, this.locale = const Locale('ru')});

  /// Локаль по умолчанию — ru; переопределяется только в тестах.
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
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
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) =>
          StartupGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
