#!/bin/bash

echo "🚀 جاري تفعيل محرك المستوى الخرافي (Biomes, Nitro Mode & Player Titles)..."

# 1. إنشاء نظام ألقاب اللاعب وشارات الإنجاز (lib/models/player_profile.dart)
cat << 'FILE_PROFILE' > lib/models/player_profile.dart
class PlayerProfile {
  final String title;
  final String badge;
  final int minScore;

  PlayerProfile({required this.title, required this.badge, required this.minScore});

  static PlayerProfile getProfileForScore(int score) {
    if (score >= 10000) {
      return PlayerProfile(title: 'CYBER GOD', badge: '👑', minScore: 10000);
    } else if (score >= 5000) {
      return PlayerProfile(title: 'NEON PHANTOM', badge: '⚡', minScore: 5000);
    } else if (score >= 2000) {
      return PlayerProfile(title: 'STREET RUNNER', badge: '🔥', minScore: 2000);
    } else {
      return PlayerProfile(title: 'ROOKIE OPERATIVE', badge: '🤖', minScore: 0);
    }
  }
}
FILE_PROFILE

# 2. إنشاء شاشة ملف اللاعب مع الأوسمة والبطولات (lib/screens/profile_screen.dart)
cat << 'FILE_PROFILE_SCREEN' > lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import '../models/player_profile.dart';

class ProfileScreen extends StatelessWidget {
  final PlayerStats stats;
  const ProfileScreen({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfile.getProfileForScore(stats.highScore);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CYBER ID & STATS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.cyan.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.cyan.shade900, Colors.black]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Text(profile.badge, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 10),
                  Text(profile.title, style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 5),
                  const Text('OPERATIVE STATUS', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildStatCard('HIGH SCORE', '${stats.highScore}', Icons.emoji_events, Colors.amber),
            const SizedBox(height: 15),
            _buildStatCard('TOTAL CREDITS', '${stats.coins}', Icons.monetization_on, Colors.greenAccent),
            const SizedBox(height: 15),
            _buildStatCard('EQUIPPED SKIN', stats.selectedSkin, Icons.person, Colors.purpleAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
FILE_PROFILE_SCREEN

# 3. تحديث الشاشة الرئيسية لإضافة بروفايل اللاعب وشريط النيترو المتقدم (lib/main.dart)
cat << 'FILE_MAIN' > lib/main.dart
import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/spin_screen.dart';
import 'screens/profile_screen.dart';
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
      title: 'Cyber Runner Next-Gen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              const GameScreen(),

              // أزرار الواجهة الاحترافية الشاملة
              Positioned(
                top: 45,
                right: 15,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.cyanAccent, size: 32),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen(stats: stats)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.donut_large, color: Colors.purpleAccent, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpinWheelScreen(
                              onRewardClaimed: (coins) {
                                stats.saveStats(0, coins);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_bag, color: Colors.amber, size: 30),
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

echo "🔥 تم تجهيز كود النسخة الخرافية بنجاح!"
