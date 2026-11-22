import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/content_loader.dart';
import 'package:tmb_mobile/features/settings/category_catalog.dart';

TaskPack _pack(List<CognitiveTask> items, {List<TaskCategory>? categories}) =>
    TaskPack(
      pack: 'test.pack',
      title: 'Тест',
      locale: 'ru',
      license: 'CC0-1.0',
      packSource: PackSource.builtin,
      status: PackStatus.draft,
      levels: DifficultyLevel.values,
      categories: categories ?? const [],
      items: items,
    );

VerbalTask _verbal(String id, String domain, {bool verifiable = false}) =>
    VerbalTask(
      id: id,
      domain: domain,
      verifiable: verifiable,
      timeSec: 60,
      difficulty: 0.5,
      prompt: 'Скажи вслух',
      selfCheck: const ['Уложился'],
    );

RecallTask _recall(String id, String domain) => RecallTask(
  id: id,
  domain: domain,
  verifiable: true,
  timeSec: 30,
  difficulty: 0.5,
  prompt: '2+2',
  answer: 4,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoryCatalog', () {
    test('разделы по verifiable/архетипу; verbal всегда непроверяемый', () {
      final catalog = CategoryCatalog.build([
        _pack([
          _recall('t.recall', 'math.a.mult'),
          // Пак пометил verbal проверяемым — инвариант 7: решает архетип.
          _verbal('t.verbal', 'cog.verbal.speak', verifiable: true),
        ]),
      ]);
      expect(catalog.domainsOf(CategorySection.verifiable), ['math.a.mult']);
      expect(catalog.domainsOf(CategorySection.unverifiable), [
        'cog.verbal.speak',
      ]);
      expect(catalog.allDomains, {'math.a.mult', 'cog.verbal.speak'});
    });

    test('иерархия по сегментам, заголовки из categories, счётчики', () {
      final catalog = CategoryCatalog.build([
        _pack(
          [
            _recall('t.1', 'math.a.mult'),
            _recall('t.2', 'math.a.mult'),
            _recall('t.3', 'math.a.add'),
          ],
          categories: const [
            TaskCategory(domain: 'math.a.mult', title: 'Умножение'),
            TaskCategory(domain: 'math.a.add', title: 'Сложение'),
          ],
        ),
      ]);
      final roots = catalog.rootsOf(CategorySection.verifiable);
      expect(roots.map((r) => r.path), ['math']);
      final a = roots.single.children.single;
      expect(a.path, 'math.a');
      expect(a.title, isNull, reason: 'у группы нет своего заголовка');
      expect(a.children.map((c) => c.title), ['Умножение', 'Сложение']);
      expect(a.children.map((c) => c.ownCount), [2, 1]);
      expect(a.totalCount, 3);
      expect(catalog.taskCountOf(CategorySection.verifiable), 3);
      expect(catalog.rootsOf(CategorySection.unverifiable), isEmpty);
    });

    test('stream не попадает в каталог (движок v0.1 его не проводит)', () {
      final stream = StreamTask(
        id: 't.stream',
        domain: 'cog.stream.rule',
        verifiable: true,
        timeSec: 30,
        difficulty: 0.5,
        prompt: 'Поток',
        stimuli: const ['a'],
        targets: const ['a'],
      );
      final catalog = CategoryCatalog.build([
        _pack([stream, _recall('t.1', 'math.a.mult')]),
      ]);
      expect(catalog.allDomains, {'math.a.mult'});
    });

    test(
      'встроенные паки: оба раздела непусты, названия есть у категорий',
      () async {
        final content = await ContentLoader(rootBundle).load();
        final catalog = CategoryCatalog.build(content.taskPacks);
        expect(catalog.domainsOf(CategorySection.verifiable), isNotEmpty);
        expect(catalog.domainsOf(CategorySection.unverifiable), isNotEmpty);
        expect(
          catalog.domainsOf(CategorySection.verifiable),
          contains('math.arithmetic.mult'),
        );
        expect(
          catalog.domainsOf(CategorySection.unverifiable),
          contains('cog.verbal.description'),
        );
        // Оценка «на глаз» проверяется машиной — она в «Проверяемых».
        expect(
          catalog.domainsOf(CategorySection.verifiable),
          contains('cog.uncertainty.estimation'),
        );
        expect(
          catalog.domainsOf(CategorySection.unverifiable),
          isNot(contains('cog.uncertainty.estimation')),
        );
        expect(
          catalog.taskCountOf(CategorySection.verifiable) +
              catalog.taskCountOf(CategorySection.unverifiable),
          content.taskCount,
        );
      },
    );
  });

  group('disabledAfter', () {
    const known = {'math.a.add', 'math.a.mult', 'cog.v.one'};

    test('выключение добавляет путь, включение убирает', () {
      final off = disabledAfter(
        disabled: const [],
        known: known,
        targets: const ['math.a.mult'],
        enable: false,
      );
      expect(off, ['math.a.mult']);
      final on = disabledAfter(
        disabled: off,
        known: known,
        targets: const ['math.a.mult'],
        enable: true,
      );
      expect(on, isEmpty);
    });

    test('включить одну категорию под отключённым родителем', () {
      final next = disabledAfter(
        disabled: const ['math.a'],
        known: known,
        targets: const ['math.a.add'],
        enable: true,
      );
      expect(next, ['math.a.mult']);
      expect(isCategoryEnabled('math.a.add', next), isTrue);
      expect(isCategoryEnabled('math.a.mult', next), isFalse);
    });

    test('путь неустановленного пака сохраняется', () {
      final next = disabledAfter(
        disabled: const ['legacy.removed'],
        known: known,
        targets: const ['math.a.add'],
        enable: false,
      );
      expect(next, ['legacy.removed', 'math.a.add']);
    });

    test('stateOf: все/ни одной/часть', () {
      const all = ['math.a.add', 'math.a.mult'];
      expect(stateOf(all, const []), CategoryState.on);
      expect(stateOf(all, const ['math.a']), CategoryState.off);
      expect(stateOf(all, const ['math.a.add']), CategoryState.mixed);
    });
  });
}
