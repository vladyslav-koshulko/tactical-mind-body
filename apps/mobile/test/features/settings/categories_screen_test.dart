import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/data/providers.dart';
import 'package:tmb_mobile/features/settings/categories_screen.dart';
import 'package:tmb_mobile/features/settings/category_catalog.dart';
import 'package:tmb_mobile/features/settings/settings_providers.dart';
import 'package:tmb_mobile/l10n/app_localizations_ru.dart';
import 'package:tmb_mobile/l10n/app_localizations_uk.dart';

import 'settings_test_support.dart';

final _l10n = AppLocalizationsRu();

/// Профиль из БД — через тот же контейнер, что и у экрана.
Future<ProfileSettings> _profile(WidgetTester tester, ProviderContainer c) =>
    db(tester, () => c.read(profileRepositoryProvider).loadProfile());

void main() {
  group('экран категорий', () {
    testWidgets('два раздела, заголовки из паков, числа задач', (tester) async {
      final c = await pumpScreen(tester, const CategoriesScreen());
      final catalog = await db(
        tester,
        () => c.read(categoryCatalogProvider.future),
      );

      expect(
        find.text(_l10n.categoriesSectionVerifiable.toUpperCase()),
        findsOneWidget,
      );
      // Название категории — из categories[].title пака.
      expect(find.text('Умножение'), findsOneWidget);
      // Группа по сегменту пути.
      expect(
        find.text(_l10n.categoriesGroupArithmetic.toUpperCase()),
        findsOneWidget,
      );
      // Число задач видно: у «Умножения» их 20.
      expect(find.text(_l10n.categoriesTasksCount(20)), findsWidgets);
      expect(catalog.taskCountOf(CategorySection.verifiable), greaterThan(0));
      // Всё включено: ни одной пустой рамки.
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
      await reveal(
        tester,
        find.text(_l10n.categoriesSectionUnverifiable.toUpperCase()),
      );
      await reveal(tester, find.text('Описание вслух'));
    });

    testWidgets('галочка сохраняется в профиль и убирает категорию из пула', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(find.text('Умножение'));
      await settle(tester);

      final profile = await _profile(tester, c);
      expect(profile.disabledCategories, ['math.arithmetic.mult']);
      // Галочка сменила форму значка, а не только цвет.
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      // Группа над ней стала «частично».
      expect(find.byIcon(Icons.indeterminate_check_box), findsWidgets);

      // Пул: и сам провайдер, и планировщик с этим профилем.
      final content = await db(tester, () => c.read(contentProvider.future));
      for (final pack in content.taskPacks) {
        final provider = PackTaskProvider(
          pack,
          disabledCategories: profile.disabledCategories,
        );
        expect(
          provider.pool.where((t) => t.domain == 'math.arithmetic.mult'),
          isEmpty,
        );
      }
      final sources = await db(
        tester,
        () => c.read(taskSourcesProvider.future),
      );
      final exercises = await db(
        tester,
        () => c.read(exercisesProvider.future),
      );
      final planner = SessionPlanner(
        exercises: exercises,
        sources: sources,
        profile: profile,
      );
      final domains = <String>{};
      for (var seed = 1; seed <= 40; seed++) {
        final plan = planner.plan(
          template: SessionTemplate.dualTask(rounds: 8, cognitiveSec: 60),
          seed: seed,
          location: Location.home,
          difficulty: DifficultyLevel.fighter,
        );
        for (final block in plan.blocks.whereType<PlannedCognitiveBlock>()) {
          domains.addAll(block.tasks.map((t) => t.task.domain));
        }
      }
      expect(domains, isNotEmpty);
      expect(domains, isNot(contains('math.arithmetic.mult')));

      // Обратно: включили — в профиле пусто, категория снова в пуле.
      await tester.tap(find.text('Умножение'));
      await settle(tester);
      expect((await _profile(tester, c)).disabledCategories, isEmpty);
    });

    testWidgets('группа выключает всех потомков одной галочкой', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(
        find.text(_l10n.categoriesGroupArithmetic.toUpperCase()),
      );
      await settle(tester);

      final profile = await _profile(tester, c);
      expect(profile.disabledCategories, [
        'math.arithmetic.addsub',
        'math.arithmetic.mixed',
        'math.arithmetic.mult',
        'math.arithmetic.serial',
      ]);
      expect(profile.isEnabled('math.arithmetic.mult'), isFalse);
      expect(profile.isEnabled('cog.memory.digits'), isTrue);
    });

    testWidgets('«выключить все» и «включить все» на уровне раздела', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const CategoriesScreen());
      final catalog = await db(
        tester,
        () => c.read(categoryCatalogProvider.future),
      );

      await tester.tap(
        find.text(_l10n.categoriesDisableAll.toUpperCase()).first,
      );
      await settle(tester);
      expect(
        (await _profile(tester, c)).disabledCategories,
        unorderedEquals(catalog.domainsOf(CategorySection.verifiable)),
      );

      await tester.tap(
        find.text(_l10n.categoriesEnableAll.toUpperCase()).first,
      );
      await settle(tester);
      expect((await _profile(tester, c)).disabledCategories, isEmpty);
    });

    testWidgets('пустой пул запрещён: сообщение вместо тихого игнора', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const CategoriesScreen());
      final catalog = await db(
        tester,
        () => c.read(categoryCatalogProvider.future),
      );

      // Первый раздел выключаем целиком — это разрешено, второй остаётся.
      await tester.tap(
        find.text(_l10n.categoriesDisableAll.toUpperCase()).first,
      );
      await settle(tester);
      expect(find.text(_l10n.categoriesEmptyPool), findsNothing);
      final before = (await _profile(tester, c)).disabledCategories;

      // Второй раздел выключить нельзя: пул остался бы пустым.
      final second = find.text(_l10n.categoriesDisableAll.toUpperCase());
      await reveal(
        tester,
        find.text(_l10n.categoriesSectionUnverifiable.toUpperCase()),
      );
      await reveal(tester, second.last);
      await tester.tap(second);
      await settle(tester);

      expect(find.text(_l10n.categoriesEmptyPool), findsOneWidget);
      expect((await _profile(tester, c)).disabledCategories, before);
      expect(
        catalog
            .domainsOf(CategorySection.unverifiable)
            .any((d) => isCategoryEnabled(d, before)),
        isTrue,
      );
    });

    testWidgets('последняя включённая категория не отключается по одной', (
      tester,
    ) async {
      final c = await pumpScreen(tester, const CategoriesScreen());
      final catalog = await db(
        tester,
        () => c.read(categoryCatalogProvider.future),
      );
      // Оставляем включённой одну категорию, остальные отключаем в БД.
      final keep = catalog.allDomains.first;
      await db(
        tester,
        () => c.read(profileRepositoryProvider).setDisabledCategories([
          for (final d in catalog.allDomains)
            if (d != keep) d,
        ]),
      );
      await settle(tester);

      final title = _titleOf(catalog, keep);
      await reveal(tester, find.text(title));
      await tester.tap(find.text(title));
      await settle(tester);

      expect(find.text(_l10n.categoriesEmptyPool), findsOneWidget);
      expect(
        (await _profile(tester, c)).isEnabled(keep),
        isTrue,
        reason: 'категория осталась включённой',
      );
    });

    testWidgets('репозиторий сам бросает EmptyPoolException', (tester) async {
      final c = await pumpScreen(tester, const CategoriesScreen());
      final catalog = await db(
        tester,
        () => c.read(categoryCatalogProvider.future),
      );
      expect(
        () => c
            .read(settingsWriterProvider)
            .setCategoriesEnabled(
              targets: catalog.allDomains,
              enabled: false,
              known: catalog.allDomains,
            ),
        throwsA(isA<EmptyPoolException>()),
      );
      await settle(tester);
    });

    testWidgets('uk: заголовки разделов на украинском', (tester) async {
      await pumpScreen(
        tester,
        const CategoriesScreen(),
        locale: const Locale('uk'),
      );
      await reveal(
        tester,
        find.text(
          AppLocalizationsUk().categoriesSectionUnverifiable.toUpperCase(),
        ),
      );
    });

    testWidgets('320 px, textScale 1.5: без overflow по всему списку', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const CategoriesScreen(),
        width: narrowLogicalWidth,
        textScale: bigTextScale,
      );
      expect(tester.takeException(), isNull);
      // Список ленивый: проходим его целиком, строки строятся по ходу.
      for (var i = 0; i < 40; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}

String _titleOf(CategoryCatalog catalog, String domain) {
  for (final s in CategorySection.values) {
    CategoryNode? find(Iterable<CategoryNode> nodes) {
      for (final n in nodes) {
        if (n.path == domain) return n;
        final r = find(n.children);
        if (r != null) return r;
      }
      return null;
    }

    final node = find(catalog.rootsOf(s));
    if (node != null) return node.title ?? node.segment;
  }
  throw StateError('нет $domain');
}
