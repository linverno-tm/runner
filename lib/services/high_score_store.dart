import 'package:shared_preferences/shared_preferences.dart';

/// Persists the best score across launches.
///
/// Defined as an interface so the game can be driven by an in-memory fake in
/// tests without pulling in platform channels.
abstract interface class HighScoreStore {
  Future<int> read();

  Future<void> write(int score);
}

/// Backed by [SharedPreferences].
class SharedPreferencesHighScoreStore implements HighScoreStore {
  const SharedPreferencesHighScoreStore();

  static const String _key = 'deep_purple_runner.high_score';

  @override
  Future<int> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  @override
  Future<void> write(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, score);
  }
}

/// In-memory implementation used by tests and by the web build when storage
/// is unavailable.
class InMemoryHighScoreStore implements HighScoreStore {
  InMemoryHighScoreStore([this._score = 0]);

  int _score;

  @override
  Future<int> read() async => _score;

  @override
  Future<void> write(int score) async => _score = score;
}
