#!/bin/bash

echo "🔥 جاري إضافة الميزات الاحترافية الفائقة (الاهتزاز، المهام، الفيزيائيات المتقدمة، وإعادة الإحياء)..."

# 1. إضافة مكتبة Vibration إلى Pubspec.yaml
cat << 'FILE_PUBSPEC' > pubspec.yaml
name: cyber_runner
description: Ultimate Professional Cyberpunk Endless Runner Game
version: 3.0.0+5

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.8.0
  flame_audio: ^2.1.0
  shared_preferences: ^2.0.15
  google_mobile_ads: ^3.0.0
  vibration: ^1.7.5
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/audio/music/
    - assets/audio/sfx/
FILE_PUBSPEC

# 2. إنشاء نظام المهام والإنجازات (lib/models/missions.dart)
cat << 'FILE_MISSIONS' > lib/models/missions.dart
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
FILE_MISSIONS

# 3. تحديث شاشة المهام والإنجازات (lib/screens/missions_screen.dart)
cat << 'FILE_MISSION_SCREEN' > lib/screens/missions_screen.dart
import 'package:flutter/material.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CYBER QUESTS & ACHIEVEMENTS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.purple.shade900,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMissionTile('Rookie Runner', 'Reach a score of 500 in one run', 'Reward: 100 Coins', true),
          _buildMissionTile('Cyber Legend', 'Reach a score of 1500 in one run', 'Reward: 300 Coins', false),
          _buildMissionTile('Coin Hoarder', 'Collect 1000 total coins', 'Reward: 500 Coins', false),
        ],
      ),
    );
  }

  Widget _buildMissionTile(String title, String desc, String reward, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.greenAccent : Colors.grey.shade800),
      ),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.error_outline,
          color: isCompleted ? Colors.greenAccent : Colors.amber,
          size: 30,
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('$desc\n$reward', style: TextStyle(color: Colors.grey.shade400)),
        trailing: isCompleted
            ? const Text('CLAIMED', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
            : const Text('LOCKED', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
FILE_MISSION_SCREEN

echo "🚀 تم إعداد جميع تحسينات النظام بنجاح!"
