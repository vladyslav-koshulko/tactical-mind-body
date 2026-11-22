import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Каркас экрана настроек: кнопка «назад», заголовок, прокручиваемое тело.
///
/// Заголовок — стиль [TmbType.displayLg] капсом (регистр делает UI, DESIGN.md,
/// правило 5). Цель касания «назад» — 48.
class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TmbSpace.x2,
                TmbSpace.x2,
                TmbSpace.x4,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.settingsBack,
                    constraints: const BoxConstraints(
                      minWidth: TmbTheme.minTapTarget,
                      minHeight: TmbTheme.minTapTarget,
                    ),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: TmbSpace.x2),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title.toUpperCase(),
                        style: TmbType.displayLg.copyWith(
                          color: TmbColor.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(TmbSpace.x4),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
