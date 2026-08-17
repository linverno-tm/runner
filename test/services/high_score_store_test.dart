import 'package:endless_runner/services/high_score_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryHighScoreStore', () {
    test('starts at zero', () async {
      expect(await InMemoryHighScoreStore().read(), 0);
    });

    test('can be seeded with a previous best', () async {
      expect(await InMemoryHighScoreStore(42).read(), 42);
    });

    test('write is read back', () async {
      final store = InMemoryHighScoreStore();

      await store.write(17);

      expect(await store.read(), 17);
    });

    test('the latest write wins', () async {
      final store = InMemoryHighScoreStore(10);

      await store.write(25);
      await store.write(19);

      expect(await store.read(), 19);
    });
  });
}
