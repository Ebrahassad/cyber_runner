#!/bin/bash

echo "🚀 جاري تطبيق التحديثات المتقدمة (Power-ups + Slide + Dynamic Difficulty)..."

# 1. تحديث نموذج البيانات لدعم القوة والمزايا الحالية (lib/models/player_stats.dart)
cat << 'FILE_MODEL' > lib/models/player_stats.dart
import 'package:shared_preferences/shared_preferences.dart';

class PlayerStats {
  static const String keyHighScore = 'high_score';
  static const String keyCoins = 'total_coins';

  int highScore = 0;
  int coins = 0;

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(keyHighScore) ?? 0;
    coins = prefs.getInt(keyCoins) ?? 0;
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

# 2. تحديث الشاشة الرئيسية بالفيزياء المتطورة والعوائق والـ Power-ups (lib/screens/game_screen.dart)
cat << 'FILE_GAME' > lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../services/ad_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Player states
  double playerY = 1.0;
  bool isJumping = false;
  bool isSliding = false;

  // Game metrics
  double obstacleX = 2.0;
  double powerUpX = 3.5;
  String powerUpType = 'shield'; // shield, magnet

  int score = 0;
  int coins = 0;
  bool isGameOver = false;

  // Active Power-ups
  bool hasShield = false;
  bool hasMagnet = false;
  Timer? powerUpTimer;

  double time = 0;
  double height = 0;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
    startGame();
  }

  void startGame() {
    setState(() {
      isGameOver = false;
      score = 0;
      coins = 0;
      obstacleX = 2.0;
      powerUpX = 3.5;
      hasShield = false;
      hasMagnet = false;
    });

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (isGameOver) {
        timer.cancel();
        _showGameOverDialog();
        return;
      }

      setState(() {
        obstacleX -= 0.05;
        powerUpX -= 0.04;
        score++;

        // Regenerate obstacle
        if (obstacleX < -1.5) {
          obstacleX = 1.5 + Random().nextDouble();
          coins += hasMagnet ? 20 : 10;
        }

        // Regenerate power-up
        if (powerUpX < -2.0) {
          powerUpX = 4.0 + Random().nextDouble() * 3;
          powerUpType = Random().nextBool() ? 'shield' : 'magnet';
        }

        // Collect power-up collision
        if ((powerUpX - 0.0).abs() < 0.2) {
          if (powerUpType == 'shield') {
            hasShield = true;
          } else {
            hasMagnet = true;
          }
          powerUpX = -3.0; // hide
        }

        // Collision logic
        if ((obstacleX - 0.0).abs() < 0.2 && playerY > 0.6 && !isSliding) {
          if (hasShield) {
            hasShield = false; // Shield protects player once
            obstacleX = 2.0;
          } else {
            isGameOver = true;
          }
        }
      });
    });
  }

  void jump() {
    if (isJumping || isSliding || isGameOver) return;

    setState(() {
      time = 0;
      isJumping = true;
    });

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      time += 0.05;
      height = -4.9 * time * time + 3.0 * time;

      setState(() {
        playerY = 1.0 - height;
      });

      if (playerY >= 1.0) {
        playerY = 1.0;
        isJumping = false;
        timer.cancel();
      }
    });
  }

  void slide() {
    if (isJumping || isSliding || isGameOver) return;

    setState(() {
      isSliding = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          isSliding = false;
        });
      }
    });
  }

  void revivePlayer() {
    setState(() {
      isGameOver = false;
      obstacleX = 2.0;
      playerY = 1.0;
    });
    startGame();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo.shade900,
        title: const Text('GAME OVER', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Score: $score | Coins: $coins', style: const TextStyle(color: Colors.white)),
        actions: [
          if (_adService.isAdLoaded)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              icon: const Icon(Icons.ondemand_video, color: Colors.black),
              label: const Text('REVIVE WITH AD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _adService.showRewardedAd(onRewardEarned: revivePlayer);
              },
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('RETRY', style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -10) {
            jump();
          } else if (details.delta.dy > 10) {
            slide();
          }
        },
        child: Container(
          color: Colors.black87,
          child: Stack(
            children: [
              // HUD (Score, Coins, Active Buffs)
              Positioned(
                top: 50,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCORE: $score  |  COINS: $coins',
                        style: const TextStyle(fontSize: 22, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (hasShield)
                          const Chip(
                            backgroundColor: Colors.blueAccent,
                            label: Text('SHIELD ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        if (hasMagnet)
                          const Chip(
                            backgroundColor: Colors.orangeAccent,
                            label: Text('MAGNET ACTIVE', style: TextStyle(color: Colors.black, fontSize: 10)),
                          ),
                      ],
                    )
                  ],
                ),
              ),

              // Player
              AnimatedContainer(
                alignment: Alignment(0, playerY),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  width: 60,
                  height: isSliding ? 30 : 60,
                  decoration: BoxDecoration(
                    color: hasShield ? Colors.blue : Colors.cyan,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: hasShield ? Colors.blueAccent : Colors.cyan, blurRadius: 12)
                    ],
                  ),
                ),
              ),

              // Obstacle
              AnimatedContainer(
                alignment: Alignment(obstacleX, 1.0),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  width: 40,
                  height: 70,
                  color: Colors.redAccent,
                ),
              ),

              // Power-up
              AnimatedContainer(
                alignment: Alignment(powerUpX, 0.5),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: powerUpType == 'shield' ? Colors.blue : Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    powerUpType == 'shield' ? Icons.shield : Icons.bolt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              // Controls hint
              const Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text('Swipe Up: Jump | Swipe Down: Slide',
                      style: TextStyle(color: Colors.white38, fontSize: 14)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
FILE_GAME

echo "✅ تم تحديث الميزات المتقدمة بنجاح!"
