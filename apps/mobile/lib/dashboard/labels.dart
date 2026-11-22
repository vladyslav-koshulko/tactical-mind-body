import 'package:tmb_domain/tmb_domain.dart';

import '../l10n/app_localizations.dart';

/// Подписи перечислений домена. Строки — только из ARB (инвариант 9).
String locationLabel(AppLocalizations l10n, Location location) =>
    switch (location) {
      Location.home => l10n.locationHome,
      Location.gym => l10n.locationGym,
      Location.outdoor => l10n.locationStreet,
    };

String difficultyLabel(AppLocalizations l10n, DifficultyLevel level) =>
    switch (level) {
      DifficultyLevel.recruit => l10n.dashboardDifficultyRecruit,
      DifficultyLevel.fighter => l10n.dashboardDifficultyFighter,
      DifficultyLevel.operator => l10n.dashboardDifficultyOperator,
      DifficultyLevel.spetsnaz => l10n.dashboardDifficultySpetsnaz,
    };

String templateLabel(AppLocalizations l10n, SessionTemplateKind kind) =>
    switch (kind) {
      SessionTemplateKind.dualTask => l10n.settingsTemplateDualTask,
      SessionTemplateKind.physicalOnly => l10n.settingsTemplatePhysicalOnly,
      SessionTemplateKind.cognitiveOnly => l10n.settingsTemplateCognitiveOnly,
      SessionTemplateKind.custom => l10n.settingsTemplateCustom,
    };
