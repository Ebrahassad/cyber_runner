import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

enum ObstacleType { lowBarrier, highGate, drone }

class DynamicObstacle {
  ObstacleType type;
  int lane;
  double positionZ;

  DynamicObstacle({required this.type, required this.lane, required this.positionZ});
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int playerLane = 1;
  double playerY = 0;
  double playerHeightScale = 1.0;
  bool isJumping = false;
  bool isSliding = false;

  double score = 0;
  double speed = 12.0;
  List<DynamicObstacle> obstacles = [];
  Timer? gameLoop;
  Offset? dragStartOffset;

  @override
  void initState() {
    super.initState();
    _initObstacles();
    _startGameLoop();
  }

  void _initObstacles() {
    obstacles = [
      DynamicObstacle(type: ObstacleType.lowBarrier, lane: 1, positionZ: 300),
      DynamicObstacle(type: ObstacleType.highGate, lane: 0, positionZ: 450),
      DynamicObstacle(type: ObstacleType.drone, lane: 2, positionZ: 600),
    ];
  }

  void _startGameLoop() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      setState(() {
        score += 0.2;
        speed += 0.001;

        if (isJumping) {
          playerY += 4;
          if (playerY >= 80) {
            isJumping = false;
          }
        } else if (playerY > 0) {
          playerY -= 5;
          if (playerY < 0) playerY = 0;
        }

        for (var obstacle in obstacles) {
          obstacle.positionZ -= speed;

          if (obstacle.positionZ < -20) {
            obstacle.positionZ = 400 + math.Random().nextDouble() * 200;
            obstacle.lane = math.Random().nextInt(3);
            obstacle.type = ObstacleType.values[math.Random().nextInt(ObstacleType.values.length)];
          }
        }
      });
    });
  }

  void _jump() {
    if (playerY == 0 && !isSliding) {
      setState(() {
        isJumping = true;
      });
    }
  }

  void _slide() {
    if (playerY == 0 && !isSliding) {
      setState(() {
        isSliding = true;
        playerHeightScale = 0.5;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            isSliding = false;
            playerHeightScale = 1.0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF05050D),
      body: GestureDetector(
        onPanStart: (details) => dragStartOffset = details.localPosition,
        onPanUpdate: (details) {
          if (dragStartOffset == null) return;
          final dx = details.localPosition.dx - dragStartOffset!.dx;
          final dy = details.localPosition.dy - dragStartOffset!.dy;

          if (dx.abs() > 30 || dy.abs() > 30) {
            if (dx.abs() > dy.abs()) {
              if (dx > 0 && playerLane < 2) setState(() => playerLane++);
              if (dx < 0 && playerLane > 0) setState(() => playerLane--);
            } else {
              if (dy < 0) _jump();
              if (dy > 0) _slide();
            }
            dragStartOffset = null;
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              size: size,
              painter: Pseudo3DCanvasPainter(),
            ),
            ...obstacles.map((obstacle) {
              double perspectiveFactor = (400 - obstacle.positionZ).clamp(10, 400) / 400;
              if (obstacle.positionZ > 380) return const SizedBox.shrink();

              double topPos = size.height * 0.3 + (perspectiveFactor * size.height * 0.55);
              double scale = math.pow(perspectiveFactor, 2).toDouble();
              double laneWidth = size.width * perspectiveFactor;
              double leftPos = (size.width / 2) + ((obstacle.lane - 1) * (laneWidth / 2.5)) - (30 * scale);

              return Positioned(
                top: topPos - (obstacle.type == ObstacleType.highGate ? 40 * scale : 0),
                left: leftPos,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 60,
                    height: obstacle.type == ObstacleType.highGate ? 70 : 35,
                    decoration: BoxDecoration(
                      color: obstacle.type == ObstacleType.lowBarrier
                          ? Colors.redAccent
                          : (obstacle.type == ObstacleType.highGate ? Colors.orangeAccent : Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        obstacle.type == ObstacleType.lowBarrier
                            ? Icons.block
                            : (obstacle.type == ObstacleType.highGate ? Icons.south : Icons.air),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
            Positioned(
              bottom: (size.height * 0.1) + playerY,
              left: (size.width / 3) * playerLane + (size.width / 6) - 25,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 50 * playerHeightScale,
                width: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent,
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.navigation,
                  color: Colors.cyanAccent,
                  size: 50 * playerHeightScale,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SCORE: ${score.toInt()}",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      "SPEED: ${speed.toStringAsFixed(1)}",
                      style: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Pseudo3DCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final horizonY = size.height * 0.3;
    final bottomY = size.height;

    for (int i = 0; i <= 3; i++) {
      double startX = size.width * 0.45 + (i * (size.width * 0.1 / 3));
      double endX = (size.width / 3) * i;
      canvas.drawLine(Offset(startX, horizonY), Offset(endX, bottomY), paint);
    }

    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      Paint()
        ..color = Colors.pinkAccent
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
