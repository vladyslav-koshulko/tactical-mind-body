import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_ui/tmb_ui.dart';

import '../../l10n/app_localizations.dart';
import 'category_catalog.dart';
import 'settings_providers.dart';
import 'widgets/settings_page.dart';
import 'widgets/settings_panel.dart';

/// Маршрут `/settings/categories` — включение и отключение категорий задач.
///
/// Два крупных раздела («Проверяемые» / «Непроверяемые», D2), внутри — дерево
/// по сегментам пути `domain` с галочками и числом задач. В БД хранится
/// множество ОТКЛЮЧЁННЫХ путей; пустой пул невозможен: попытка отключить
/// последнюю включённую категорию отклоняется с сообщением.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(categoryCatalogProvider);
    final profile = ref.watch(profileProvider);

    if (catalog.hasError || profile.hasError) {
      return SettingsPage(
        title: l10n.categoriesTitle,
        children: [StatusMessage.error(l10n.categoriesLoadError)],
      );
    }
    final catalogValue = catalog.value;
    final profileValue = profile.value;
    if (catalogValue == null || profileValue == null) {
      return SettingsPage(
        title: l10n.categoriesTitle,
        children: [StatusMessage.loading(l10n.categoriesLoading)],
      );
    }

    return SettingsPage(
      title: l10n.categoriesTitle,
      children: [
        for (final section in CategorySection.values)
          _SectionPanel(
            section: section,
            catalog: catalogValue,
            disabled: profileValue.disabledCategories,
          ),
      ],
    );
  }
}

class _SectionPanel extends ConsumerWidget {
  const _SectionPanel({
    required this.section,
    required this.catalog,
    required this.disabled,
  });

  final CategorySection section;
  final CategoryCatalog catalog;
  final List<String> disabled;

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    List<String> targets, {
    required bool enable,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    String? problem;
    try {
      await ref
          .read(settingsWriterProvider)
          .setCategoriesEnabled(
            targets: targets,
            enabled: enable,
            known: catalog.allDomains,
          );
    } on EmptyPoolException {
      problem = l10n.categoriesEmptyPool;
    } on Object {
      problem = l10n.categoriesSaveError;
    }
    if (problem != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(problem)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final verifiable = section == CategorySection.verifiable;
    final roots = catalog.rootsOf(section);
    final domains = catalog.domainsOf(section);
    final summary = catalog.summary(domains, disabled);

    return SettingsPanel(
      heading: verifiable
          ? l10n.categoriesSectionVerifiable
          : l10n.categoriesSectionUnverifiable,
      hint: verifiable
          ? l10n.categoriesSectionVerifiableHint
          : l10n.categoriesSectionUnverifiableHint,
      children: [
        if (roots.isEmpty)
          Text(
            l10n.categoriesEmptySection,
            style: TmbType.bodyMd.copyWith(color: TmbColor.textSecondary),
          )
        else ...[
          Text(
            '${l10n.categoriesSectionSummary(summary.enabled, summary.total)}'
            ' · ${l10n.categoriesTasksCount(catalog.taskCountOf(section))}',
            style: TmbType.dataMono.copyWith(color: TmbColor.textSecondary),
          ),
          const SizedBox(height: TmbSpace.x3),
          Wrap(
            spacing: TmbSpace.x2,
            runSpacing: TmbSpace.x2,
            children: [
              OutlinedButton(
                onPressed: () => _apply(context, ref, domains, enable: true),
                child: Text(l10n.categoriesEnableAll.toUpperCase()),
              ),
              OutlinedButton(
                onPressed: () => _apply(context, ref, domains, enable: false),
                child: Text(l10n.categoriesDisableAll.toUpperCase()),
              ),
            ],
          ),
          const SizedBox(height: TmbSpace.x3),
          for (final root in roots)
            _NodeView(
              node: root,
              depth: 0,
              disabled: disabled,
              onToggle: (domains, enable) =>
                  _apply(context, ref, domains, enable: enable),
            ),
        ],
      ],
    );
  }
}

class _NodeView extends StatelessWidget {
  const _NodeView({
    required this.node,
    required this.depth,
    required this.disabled,
    required this.onToggle,
  });

  final CategoryNode node;
  final int depth;
  final List<String> disabled;
  final void Function(List<String> domains, bool enable) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final domains = node.domains;
    final state = stateOf(domains, disabled);
    final title = node.title ?? _groupTitle(l10n, node.path) ?? node.segment;
    final stateText = switch (state) {
      CategoryState.on => l10n.categoriesStateOn,
      CategoryState.off => l10n.categoriesStateOff,
      CategoryState.mixed => l10n.categoriesStateMixed,
    };
    final count = l10n.categoriesTasksCount(node.totalCount);
    // Форма значка — основной канал: галочка / минус / пустая рамка.
    final icon = switch (state) {
      CategoryState.on => Icons.check_box,
      CategoryState.off => Icons.check_box_outline_blank,
      CategoryState.mixed => Icons.indeterminate_check_box,
    };
    final isGroup = !node.hasOwnTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          checked: state == CategoryState.on,
          mixed: state == CategoryState.mixed,
          label: '$title. $count',
          value: stateText,
          excludeSemantics: true,
          onTap: () => onToggle(domains, state != CategoryState.on),
          child: InkWell(
            onTap: () => onToggle(domains, state != CategoryState.on),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TmbTheme.minTapTarget,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: depth * TmbSpace.x4),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: TmbSize.icon + TmbSpace.x1,
                      color: state == CategoryState.off
                          ? TmbColor.textSecondary
                          : TmbColor.accent500,
                    ),
                    const SizedBox(width: TmbSpace.x3),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: TmbSpace.x2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGroup ? title.toUpperCase() : title,
                              style:
                                  (isGroup ? TmbType.labelMd : TmbType.bodyMd)
                                      .copyWith(color: TmbColor.textPrimary),
                            ),
                            Text(
                              count,
                              style: TmbType.bodySm.copyWith(
                                color: TmbColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final child in node.children)
          _NodeView(
            node: child,
            depth: depth + 1,
            disabled: disabled,
            onToggle: onToggle,
          ),
      ],
    );
  }
}

/// Название узла, у которого нет своей записи в `categories` пака (корни и
/// промежуточные сегменты пути). Для неизвестного пути вернётся `null`, и
/// экран покажет сам сегмент как есть.
String? _groupTitle(AppLocalizations l10n, String path) => switch (path) {
  'math' => l10n.categoriesGroupMath,
  'cog' => l10n.categoriesGroupCog,
  'math.arithmetic' => l10n.categoriesGroupArithmetic,
  'cog.memory' => l10n.categoriesGroupMemory,
  'cog.uncertainty' => l10n.categoriesGroupUncertainty,
  'cog.verbal' => l10n.categoriesGroupVerbal,
  _ => null,
};
