#!/bin/bash

echo "🚀 جاري ترقية المشروع إلى مستوى احترافي باستخدام Flame Engine..."

# 1. تحديث pubspec.yaml لإضافة المحرك والاعتمادات الاحترافية
cat << 'FILE_PUBSPEC' > pubspec.yaml
name: cyber_runner
description: A professional 3D-styled Endless Runner game using Flame.
version: 1.1.0+2

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.8.0
  flame_audio: ^2.1.0
  shared_preferences: ^2.0.15
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/character/
    - assets/images/environment/
    - assets/images/obstacles/
    - assets/audio/music/
    - assets/audio/sfx/
FILE_PUBSPEC

# 2. إنشاء نموذج الحفظ والمحتوى المالي (lib/models/player_stats.dart)
cat << 'FILE_MODEL' > lib/models/player_stats.dart
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
FILE_MODEL

# 3. محرك اللعبة الرئيسي مع دعم الفيزياء والسرعة المرتفعة (lib/services/game_engine.dart)
cat << 'FILE_ENGINE' > lib/services/game_engine.dart
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CyberRunnerGame extends FlameGame with TapDetector, HasCollisionDetection {
  int score = 0;
  int coins = 0;
  bool isGameOver = false;
  double gameSpeed = 300.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // إضافة الخلفية متعددة الطبقات واللاعب والعوائق
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameOver) {
      score += (dt * 10).toInt();
      gameSpeed += dt * 2; // زيادة الصعوبة تلقائياً مع الوقت
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    // تنفيذ ميكانيكية القفز السلس أو الانزلاق بناءً على موقع اللمس
  }
}
FILE_ENGINE

# 4. الشاشة الرئيسية والمتجر (lib/screens/shop_screen.dart)
cat << 'FILE_SHOP' > lib/screens/shop_screen.dart
import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final int totalCoins;
  const ShopScreen({Key? key, required this.totalCoins}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('CYBER SHOP'),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Coins: $totalCoins', style: const TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildShopItem('Cyber Ninja', '500 Coins', Colors.cyan),
                _buildShopItem('Neon Knight', '1200 Coins', Colors.purpleAccent),
                _buildShopItem('Mech Runner', '2500 Coins', Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(String name, String price, Color color) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(price, style: const TextStyle(color: Colors.amber)),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: const Text('UNLOCK'),
        ),
      ),
    );
  }
}
FILE_SHOP

# 5. تحديث الشاشة الرئيسية الواصلة بين اللعبة والمتجر (lib/main.dart)
cat << 'FILE_MAIN' > lib/main.dart
import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';
import 'models/player_stats.dart';

void main() {
  runApp(const CyberRunnerApp());
}

class CyberRunnerApp extends StatefulWidget {
  const CyberRunnerApp({Key? key}) : super(key: key);

  @override
  State<CyberRunnerApp> createState() => _CyberRunnerAppState();
}

class _CyberRunnerAppState extends State<CyberRunnerApp> {
  final PlayerStats stats = PlayerStats();

  @override
  void initState() {
    super.initState();
    stats.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Runner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              const GameScreen(),
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.amber, size: 32),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopScreen(totalCoins: stats.coins)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
FILE_MAIN

echo "✅ تم تحديث كود اللعبة بنجاح!"
