import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmb_data/tmb_data.dart';
import 'package:tmb_domain/tmb_domain.dart';
import 'package:tmb_mobile/data/providers.dart';

import 'helpers.dart';

void main() {
  late ProviderContainer container;
  var now = fakeNowMs;

  setUp(() {
    now = fakeNowMs;
    container = ProviderContainer(overrides: testOverrides(clock: () => now));
    addTearDown(container.dispose);
  });

  test('clockProvider отдаёт подставленные часы', () {
    final nowMs = container.read(clockProvider);
    expect(nowMs(), fakeNowMs);
    now += 1500;
    expect(nowMs(), fakeNowMs + 1500);
  });

  test('clockProvider по умолчанию — мс эпохи UTC', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final before = DateTime.now().toUtc().millisecondsSinceEpoch;
    final value = c.read(clockProvider)();
    expect(value, greaterThanOrEqualTo(before));
  });

  test('idSourceProvider: UUID v4, без повторов', () {
    final ids = container.read(idSourceProvider);
    final uuidV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final seen = <String>{};
    for (var i = 0; i < 100; i++) {
      final id = ids.nextId();
      expect(id, matches(uuidV4));
      seen.add(id);
    }
    expect(seen, hasLength(100));
  });

  test('репозитории работают поверх одной in-memory БД', () async {
    final db = container.read(databaseProvider);
    expect(container.read(databaseProvider), same(db));

    final profile = await container
        .read(profileRepositoryProvider)
        .loadProfile();
    expect(profile.disabledCategories, isEmpty);

    final prefs = await container
        .read(profileRepositoryProvider)
        .loadSessionPreferences();
    expect(prefs, SessionPreferences.standard);

    expect(
      await container.read(sessionRepositoryProvider).listSessions(),
      isEmpty,
    );
    expect(
      await container.read(contentRepositoryProvider).listPacks(),
      isEmpty,
    );
  });

  test('контракт типов провайдеров', () {
    expect(container.read(sessionRepositoryProvider), isA<SessionRepository>());
    expect(container.read(profileRepositoryProvider), isA<ProfileRepository>());
    expect(container.read(contentRepositoryProvider), isA<ContentRepository>());
    expect(container.read(idSourceProvider), isA<IdSource>());
  });
}
