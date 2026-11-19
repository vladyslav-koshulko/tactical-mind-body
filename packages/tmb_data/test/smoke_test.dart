import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('БД в памяти открывается и создаёт схему', () async {
    final db = openMemoryDb();
    addTearDown(db.close);
    expect(await db.select(db.sessions).get(), isEmpty);
  });
}
