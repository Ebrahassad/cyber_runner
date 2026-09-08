#!/bin/bash

echo "🚀 جاري تطبيق المرحلة الثالثة من التطوير..."

# 1. تحديث workflow لبناء APK + AAB
cat << 'FILE_WORKFLOW' > .github/workflows/android_build.yml
name: Build Android Releases

on:
  push:
    branches: [ "main", "master" ]
  pull_request:
    branches: [ "main", "master" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Install Dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release --split-per-abi

      - name: Build App Bundle (AAB for Google Play)
        run: flutter build appbundle --release

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/*.apk

      - name: Upload AAB Artifact (Google Play Store)
        uses: actions/upload-artifact@v3
        with:
          name: android-aab
          path: build/app/outputs/bundle/release/*.aab
FILE_WORKFLOW

# 2. تحديث pubspec.yaml
cat << 'FILE_PUBSPEC' > pubspec.yaml
name: cyber_runner
description: A professional 3D-styled Endless Runner game with Monetization.
version: 1.2.0+3

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

# 3. إعداد خدمة الإعلانات
cat << 'FILE_ADS' > lib/services/ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool isAdLoaded = false;

  final String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/5224354917';

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          isAdLoaded = false;
        },
      ),
    );
  }

  void showRewardedAd({required Function onRewardEarned}) {
    if (_rewardedAd != null && isAdLoaded) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned();
        },
      );
      _rewardedAd = null;
      isAdLoaded = false;
      loadRewardedAd();
    }
  }
}
FILE_ADS

# 4. تحديث الشاشة الرئيسية
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
  double playerY = 1.0;
  double obstacleX = 2.0;
  int score = 0;
  int coins = 0;
  bool isJumping = false;
  bool isGameOver = false;

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
    });

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (isGameOver) {
        timer.cancel();
        _showGameOverDialog();
        return;
      }

      setState(() {
        obstacleX -= 0.05;
        score++;

        if (obstacleX < -1.5) {
          obstacleX = 1.5 + Random().nextDouble();
          coins += 10;
        }

        if ((obstacleX - 0.0).abs() < 0.2 && playerY > 0.6) {
          isGameOver = true;
        }
      });
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

  void jump() {
    if (isJumping || isGameOver) return;

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
              label: const Text('WATCH AD TO REVIVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        onTap: jump,
        child: Container(
          color: Colors.black87,
          child: Stack(
            children: [
              Positioned(
                top: 50,
                left: 20,
                child: Text('SCORE: $score  |  COINS: $coins',
                    style: const TextStyle(fontSize: 22, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              ),
              AnimatedContainer(
                alignment: Alignment(0, playerY),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.cyan, blurRadius: 10)],
                  ),
                ),
              ),
              AnimatedContainer(
                alignment: Alignment(obstacleX, 1.0),
                duration: const Duration(milliseconds: 0),
                child: Container(
                  width: 40,
                  height: 70,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
FILE_GAME

echo "✅ تم إعداد ملفات المرحلة الثالثة بنجاح!"
