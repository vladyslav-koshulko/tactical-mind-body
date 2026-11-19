import 'package:material_ui/material_ui.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../l10n/app_localizations.dart';
import 'location_tile.dart';

/// Экран №01 «Тактический дашборд» — пустой каркас без логики.
/// Рекламы здесь пока нет (инвариант 10 разрешает баннер только тут и в архиве).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TmbSpace.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.appName.toUpperCase(),
                      style: TmbType.labelMd.copyWith(
                        color: TmbColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TmbSpace.x2),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.dashboardTitle.toUpperCase(),
                        style: TmbType.displayHero.copyWith(
                          color: TmbColor.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: TmbSpace.x6),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: LocationTile(
                              index: '01',
                              name: l10n.locationHome,
                              selectedLabel: l10n.locationSelected,
                              selected: true,
                            ),
                          ),
                          const SizedBox(width: TmbSpace.x2),
                          Expanded(
                            child: LocationTile(
                              index: '02',
                              name: l10n.locationGym,
                              selectedLabel: l10n.locationSelected,
                            ),
                          ),
                          const SizedBox(width: TmbSpace.x2),
                          Expanded(
                            child: LocationTile(
                              index: '03',
                              name: l10n.locationStreet,
                              selectedLabel: l10n.locationSelected,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TmbSpace.x6),
                    const _LastOperationPanel(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TmbSpace.x4),
              child: SizedBox(
                width: double.infinity,
                // Единственная Primary-кнопка экрана (DESIGN.md, правило 1).
                child: FilledButton(
                  onPressed: () {
                    // TODO(v0.1): запуск операции.
                  },
                  child: Text(l10n.startOperation.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastOperationPanel extends StatelessWidget {
  const _LastOperationPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(TmbSpace.x4),
      decoration: BoxDecoration(
        color: TmbColor.surface,
        borderRadius: BorderRadius.circular(TmbRadius.sharp),
        border: Border.all(color: TmbColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lastOperationTitle.toUpperCase(),
            style: TmbType.labelLg.copyWith(color: TmbColor.textPrimary),
          ),
          const SizedBox(height: TmbSpace.x3),
          Text(
            l10n.lastOperationEmpty,
            style: TmbType.bodyMd.copyWith(color: TmbColor.textSecondary),
          ),
          const SizedBox(height: TmbSpace.x4),
          // Легенда фаз: цвет + форма + текст (инвариант 6).
          Wrap(
            spacing: TmbSpace.x4,
            runSpacing: TmbSpace.x2,
            children: [
              TmbPhaseBadge(
                phase: TmbPhase.physical,
                label: l10n.phasePhysical,
              ),
              TmbPhaseBadge(
                phase: TmbPhase.cognitive,
                label: l10n.phaseCognitive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
