import 'package:shared_preferences/shared_preferences.dart';

class PlayerStats {
  static const String keyHighScore = 'high_score';
  static const String keyCoins = 'total_coins';
  static const String keyUnlockedSkin = 'unlocked_skins';

  int highScore = 0;
  int coins = 0;
  List<String> unlockedSkins = ['default'];

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(keyHighScore) ?? 0;
    coins = prefs.getInt(keyCoins) ?? 0;
    unlockedSkins = prefs.getStringList(keyUnlockedSkin) ?? ['default'];
  }

  Future<void> saveStats(int newScore, int collectedCoins) async {
    final prefs = await SharedPreferences.getInstance();
    if (newScore > highScore) {
      highScore = newScore;
      await prefs.setInt(keyHighScore, highScore);
    }
    coins += collectedCoins;
    await prefs.setInt(keyCoins, coins);
  }
}
