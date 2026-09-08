#!/bin/bash

echo "🔥 جاري تحويل اللعبة إلى تجربة احترافية متكاملة بأسلوب Cyberpunk..."

# 1. تحديث Pubspec.yaml بجميع المكتبات الاحترافية المطلوبة
cat << 'FILE_PUBSPEC' > pubspec.yaml
name: cyber_runner
description: Ultimate Professional Cyberpunk Endless Runner Game
version: 2.0.0+4

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.8.0
  flame_audio: ^2.1.0
  shared_preferences: ^2.0.15
  google_mobile_ads: ^3.0.0
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

# 2. إنشاء نموذج البيانات المتطور والنظام المالي للمتجر واليوميات (lib/models/player_stats.dart)
cat << 'FILE_MODEL' > lib/models/player_stats.dart
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
FILE_MODEL

# 3. بناء متجر احترافي وتفاعلي كامل لشراء وتحديد الشخصيات (lib/screens/shop_screen.dart)
cat << 'FILE_SHOP' > lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import '../models/player_stats.dart';

class ShopScreen extends StatefulWidget {
  final PlayerStats stats;
  const ShopScreen({Key? key, required this.stats}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Map<String, dynamic>> skins = [
    {'name': 'Cyber Ninja', 'price': 0, 'color': Colors.cyan, 'desc': 'Speed Boost + Fast Jump'},
    {'name': 'Neon Knight', 'price': 500, 'color': Colors.purpleAccent, 'desc': 'Shield Duration +50%'},
    {'name': 'Mech Runner', 'price': 1200, 'color': Colors.orangeAccent, 'desc': 'Double Coin Magnet'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CYBER ARMORY', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade900,
        elevation: 10,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.black]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AVAILABLE CREDITS:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text('${widget.stats.coins}', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: skins.length,
              itemBuilder: (context, index) {
                final skin = skins[index];
                final bool isUnlocked = widget.stats.unlockedSkins.contains(skin['name']);
                final bool isSelected = widget.stats.selectedSkin == skin['name'];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white10, width: isSelected ? 2 : 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: skin['color'],
                      child: Icon(isSelected ? Icons.check : Icons.person, color: Colors.black),
                    ),
                    title: Text(skin['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${skin['desc']}\nPrice: ${skin['price']} Coins', style: TextStyle(color: Colors.grey.shade400)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.green : (isUnlocked ? Colors.cyan : Colors.amber),
                      ),
                      onPressed: () async {
                        if (isUnlocked) {
                          setState(() {
                            widget.stats.selectedSkin = skin['name'];
                          });
                        } else {
                          bool success = await widget.stats.buySkin(skin['name'], skin['price']);
                          if (success) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Unlocked ${skin['name']}!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not enough coins!')),
                            );
                          }
                        }
                      },
                      child: Text(isSelected ? 'EQUIPPED' : (isUnlocked ? 'EQUIP' : 'BUY')),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
FILE_SHOP

# 4. تحديث المحرك الرئيسي ودعم الشاشة الرئيسية مع زر المكافأة اليومية (lib/main.dart)
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
      title: 'Cyber Runner Ultra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              const GameScreen(),

              // زر المتجر وزر المكافأة اليومية
              Positioned(
                top: 45,
                right: 15,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 30),
                      onPressed: () async {
                        bool claimed = await stats.claimDailyReward();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(claimed ? '🎉 Claimed 250 Daily Coins!' : '⏳ Next reward available tomorrow!'),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_bag, color: Colors.amber, size: 32),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShopScreen(stats: stats)),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ],
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

echo "🚀 تم إعداد جميع ملفات الترقية الفائقة بنجاح!"
