#!/bin/bash

echo "⚡ جاري إضافة محرك الأعداء والحواجز الديناميكية..."

# 1. إنشاء ملف إدارة الأعداء والحواجز (lib/models/dynamic_obstacle.dart)
cat << 'FILE_OBSTACLE' > lib/models/dynamic_obstacle.dart
enum ObstacleType { staticWall, laserGate, movingDrone, slidingBarrier }

class DynamicObstacle {
  final ObstacleType type;
  int lane; // 0: Left, 1: Center, 2: Right
  double positionZ;
  bool isActive;
  int moveDirection; // 1 for right, -1 for left

  DynamicObstacle({
    required this.type,
    required this.lane,
    required this.positionZ,
    this.isActive = true,
    this.moveDirection = 1,
  });

  void update(double speed, double dt) {
    positionZ -= speed * dt;

    // حركة طائرات الدرون بين الحارات أفقياً
    if (type == ObstacleType.movingDrone) {
      if (lane == 0) moveDirection = 1;
      if (lane == 2) moveDirection = -1;
      
      // تغيير الحارة بشكل دوري
      if (positionZ % 50 < 1) {
        lane += moveDirection;
      }
    }
  }
}
FILE_OBSTACLE

# 2. تحديث شاشة اللعب لدمج الأعداء الحركية (lib/screens/game_screen.dart)
cat << 'FILE_GAME_SCREEN' > lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/dynamic_obstacle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int playerLane = 1; // 0, 1, 2
  double score = 0;
  List<DynamicObstacle> obstacles = [];
  Timer? gameLoop;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    obstacles = [
      DynamicObstacle(type: ObstacleType.laserGate, lane: 0, positionZ: 100),
      DynamicObstacle(type: ObstacleType.movingDrone, lane: 1, positionZ: 200),
      DynamicObstacle(type: ObstacleType.slidingBarrier, lane: 2, positionZ: 300),
    ];

    gameLoop = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      setState(() {
        score += 0.5;
        for (var obstacle in obstacles) {
          obstacle.update(10, 0.032);
          if (obstacle.positionZ < -10) {
            obstacle.positionZ = 300; // إعادة التدوير
          }
        }
      });
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0 && playerLane > 0) {
            setState(() => playerLane--);
          } else if (details.primaryVelocity! > 0 && playerLane < 2) {
            setState(() => playerLane++);
          }
        },
        child: Stack(
          children: [
            Center(
              child: Text(
                'DYNAMIC CYBER ZONE\nScore: ${score.toInt()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width / 3 * playerLane + 30,
              child: const Icon(Icons.navigation, color: Colors.magentaAccent, size: 50),
            ),
          ],
        ),
      ),
    );
  }
}
FILE_GAME_SCREEN

echo "✅ تم تفعيل الأعداء والحواجز الديناميكية بنجاح!"
