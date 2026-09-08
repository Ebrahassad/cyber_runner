import 'package:shared_preferences/shared_preferences.dart';

class PlayerStats {
  static const String keyHighScore = 'high_score';
  static const String keyCoins = 'total_coins';
  static const String keySelectedSkin = 'selected_skin';
  static const String keyUnlockedSkins = 'unlocked_skins';
  static const String keyLastClaim = 'last_daily_claim';

  int highScore = 0;
  int coins = 0;
  String selectedSkin = 'Cyber Ninja';
  List<String> unlockedSkins = ['Cyber Ninja'];

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(keyHighScore) ?? 0;
    coins = prefs.getInt(keyCoins) ?? 0;
    selectedSkin = prefs.getString(keySelectedSkin) ?? 'Cyber Ninja';
    unlockedSkins = prefs.getStringList(keyUnlockedSkins) ?? ['Cyber Ninja'];
  }

  Future<void> saveStats(int newScore, int newCoins) async {
    final prefs = await SharedPreferences.getInstance();
    if (newScore > highScore) {
      highScore = newScore;
      await prefs.setInt(keyHighScore, highScore);
    }
    coins += newCoins;
    await prefs.setInt(keyCoins, coins);
  }

  Future<bool> buySkin(String skinName, int price) async {
    if (coins >= price && !unlockedSkins.contains(skinName)) {
      coins -= price;
      unlockedSkins.add(skinName);
      selectedSkin = skinName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyCoins, coins);
      await prefs.setStringList(keyUnlockedSkins, unlockedSkins);
      await prefs.setString(keySelectedSkin, selectedSkin);
      return true;
    }
    return false;
  }

  Future<bool> claimDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getInt(keyLastClaim) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // مكافأة كل 24 ساعة (86400000 ms)
    if (now - lastClaim >= 86400000) {
      coins += 250; // منح 250 كوينز مجاناً
      await prefs.setInt(keyCoins, coins);
      await prefs.setInt(keyLastClaim, now);
      return true;
    }
    return false;
  }
}
