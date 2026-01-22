import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const String _keyUnlockedLevels = 'unlocked_levels';
  static const String _keyUnlockedSkins = 'unlocked_skins';
  static const String _keyCurrentSkin = 'current_skin';
  static const String _keyTotalScore = 'total_score';
  static const String _keyLevelScores = 'level_scores';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keyCurrentMusic = 'current_music';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Levels
  static Future<List<int>> getUnlockedLevels() async {
    final prefs = await _prefs;
    final levels = prefs.getStringList(_keyUnlockedLevels) ?? ['1'];
    return levels.map((e) => int.parse(e)).toList();
  }

  static Future<void> unlockLevel(int level) async {
    final prefs = await _prefs;
    final unlocked = await getUnlockedLevels();
    if (!unlocked.contains(level)) {
      unlocked.add(level);
      await prefs.setStringList(
        _keyUnlockedLevels,
        unlocked.map((e) => e.toString()).toList(),
      );
    }
  }

  static Future<bool> isLevelUnlocked(int level) async {
    final unlocked = await getUnlockedLevels();
    return unlocked.contains(level);
  }

  // Skins
  static Future<List<String>> getUnlockedSkins() async {
    final prefs = await _prefs;
    return prefs.getStringList(_keyUnlockedSkins) ?? ['default'];
  }

  static Future<void> unlockSkin(String skinId) async {
    final prefs = await _prefs;
    final unlocked = await getUnlockedSkins();
    if (!unlocked.contains(skinId)) {
      unlocked.add(skinId);
      await prefs.setStringList(_keyUnlockedSkins, unlocked);
    }
  }

  static Future<bool> isSkinUnlocked(String skinId) async {
    final unlocked = await getUnlockedSkins();
    return unlocked.contains(skinId);
  }

  static Future<String> getCurrentSkin() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCurrentSkin) ?? 'default';
  }

  static Future<void> setCurrentSkin(String skinId) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCurrentSkin, skinId);
  }

  // Scores
  static Future<int> getTotalScore() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyTotalScore) ?? 0;
  }

  static Future<void> addToTotalScore(int points) async {
    final prefs = await _prefs;
    final current = await getTotalScore();
    await prefs.setInt(_keyTotalScore, current + points);
  }

  static Future<Map<int, int>> getLevelScores() async {
    final prefs = await _prefs;
    final scores = prefs.getString(_keyLevelScores);
    if (scores == null) return {};
    final map = <int, int>{};
    scores.split(',').forEach((entry) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        map[int.parse(parts[0])] = int.parse(parts[1]);
      }
    });
    return map;
  }

  static Future<void> setLevelScore(int level, int score) async {
    final prefs = await _prefs;
    final scores = await getLevelScores();
    final currentScore = scores[level] ?? 0;
    if (score > currentScore) {
      scores[level] = score;
      final scoreString = scores.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      await prefs.setString(_keyLevelScores, scoreString);
    }
  }

  // Music
  static Future<bool> isMusicEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyMusicEnabled) ?? true;
  }

  static Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyMusicEnabled, enabled);
  }

  static Future<String> getCurrentMusic() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCurrentMusic) ?? 'track1';
  }

  static Future<void> setCurrentMusic(String track) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCurrentMusic, track);
  }
}
