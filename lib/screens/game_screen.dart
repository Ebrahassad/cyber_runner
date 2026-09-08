import 'package:flutter/material.dart';
import 'dart:async';
import '../models/dynamic_obstacle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int playerLane = 1;
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
            obstacle.positionZ = 300;
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
    final screenWidth = MediaQuery.of(context).size.width;

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
            ...obstacles.map((obstacle) {
              double scale = (300 - obstacle.positionZ).clamp(50, 300) / 300;
              return Positioned(
                top: 200 + (obstacle.positionZ * 0.8),
                left: (screenWidth / 3) * obstacle.lane + (screenWidth / 6) - 20,
                child: Opacity(
                  opacity: (obstacle.positionZ / 300).clamp(0.2, 1.0),
                  child: Container(
                    width: 40 * scale,
                    height: 20 * scale,
                    decoration: BoxDecoration(
                      color: obstacle.type == ObstacleType.laserGate
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "DYNAMIC CYBER ZONE\nScore: ${score.toInt()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: (screenWidth / 3) * playerLane + (screenWidth / 6) - 25,
              child: const Icon(
                Icons.navigation,
                color: Colors.pinkAccent,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
