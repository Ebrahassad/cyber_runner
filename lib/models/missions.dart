import 'package:shared_preferences/shared_preferences.dart';

class MissionManager {
  static const String keyTotalMissions = 'completed_missions';

  int completedMissions = 0;

  Future<void> loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    completedMissions = prefs.getInt(keyTotalMissions) ?? 0;
  }

  bool checkScoreMission(int currentScore) {
    if (currentScore >= 500 && completedMissions == 0) {
      completedMissions = 1;
      _save();
      return true;
    } else if (currentScore >= 1500 && completedMissions == 1) {
      completedMissions = 2;
      _save();
      return true;
    }
    return false;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTotalMissions, completedMissions);
  }
}
