import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../data/content_loader.dart';
import '../l10n/app_localizations.dart';

/// Держит навигатор, пока не загружен встроенный контент. Пока идёт чтение —
/// экран загрузки; при ошибке — экран ошибки (встроенный пак с дефектом не
/// пропускается молча). Подключается через `MaterialApp.router(builder:)`.
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    return content.when(
      data: (_) => child,
      loading: () => const _StartupLoading(),
      error: (error, _) => _StartupError(
        error: error,
        onRetry: () => ref.invalidate(contentProvider),
      ),
    );
  }
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: l10n.appLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: TmbSpace.x4),
              Text(
                l10n.appLoading.toUpperCase(),
                style: TmbType.labelMd.copyWith(color: TmbColor.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

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
                  l10n.appLoadErrorTitle.toUpperCase(),
                  style: TmbType.displayLg.copyWith(color: TmbColor.danger),
                ),
              ),
              const SizedBox(height: TmbSpace.x3),
              Text(
                l10n.appLoadErrorBody,
                style: TmbType.bodyMd.copyWith(color: TmbColor.textPrimary),
              ),
              const SizedBox(height: TmbSpace.x3),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    l10n.appLoadErrorDetails('$error'),
                    style: TmbType.dataMono.copyWith(
                      color: TmbColor.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TmbSpace.x6),
              FilledButton(
                onPressed: onRetry,
                child: Text(l10n.appRetry.toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
