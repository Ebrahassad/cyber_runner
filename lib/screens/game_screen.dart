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
                top: topPos - (obstacle.type == ObstacleType.highGate ? 50 * scale : 0),
                left: leftPos,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 60,
                    height: obstacle.type == ObstacleType.highGate ? 80 : 40,
                    child: CustomPaint(
                      painter: ObstacleSpritePainter(type: obstacle.type),
                    ),
                  ),
                ),
              );
            }),
            Positioned(
              bottom: (size.height * 0.1) + playerY,
              left: (size.width / 3) * playerLane + (size.width / 6) - 30,
              child: SizedBox(
                width: 60,
                height: 60 * playerHeightScale,
                child: CustomPaint(
                  painter: CyberPlayerSpritePainter(
                    isJumping: isJumping,
                    isSliding: isSliding,
                  ),
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

class CyberPlayerSpritePainter extends CustomPainter {
  final bool isJumping;
  final bool isSliding;

  CyberPlayerSpritePainter({required this.isJumping, required this.isSliding});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, size.width / 3, glowPaint);

    final firePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height * (isSliding ? 0.9 : 1.05))
      ..lineTo(size.width * 0.65, size.height * 0.75)
      ..close();
    canvas.drawPath(
      firePath,
      Paint()..color = Colors.pinkAccent,
    );

    final bodyPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.85, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.15, size.height * 0.7)
      ..close();

    final bodyPaint = Paint()
      ..color = const Color(0xFF102A43)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    final borderPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(bodyPath, borderPaint);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.35),
      size.width * 0.12,
      Paint()..color = Colors.cyanAccent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ObstacleSpritePainter extends CustomPainter {
  final ObstacleType type;

  ObstacleSpritePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    if (type == ObstacleType.lowBarrier) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.7),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = Colors.redAccent.withOpacity(0.85),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final stripePaint = Paint()..color = Colors.yellowAccent;
      for (double i = 5; i < size.width; i += 15) {
        canvas.drawLine(
          Offset(i, size.height * 0.35),
          Offset(i + 8, size.height * 0.95),
          stripePaint..strokeWidth = 3,
        );
      }
    } else if (type == ObstacleType.highGate) {
      final pillarPaint = Paint()..color = Colors.orangeAccent;
      canvas.drawRect(Rect.fromLTWH(0, 0, 10, size.height), pillarPaint);
      canvas.drawRect(Rect.fromLTWH(size.width - 10, 0, 10, size.height), pillarPaint);

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 15), pillarPaint);

      final laserPaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(
        Offset(5, 10),
        Offset(size.width - 5, 10),
        laserPaint,
      );
    } else {
      final center = Offset(size.width / 2, size.height / 2);

      canvas.drawCircle(Offset(size.width * 0.2, center.dy), 8, Paint()..color = Colors.purpleAccent);
      canvas.drawCircle(Offset(size.width * 0.8, center.dy), 8, Paint()..color = Colors.purpleAccent);

      canvas.drawCircle(center, 14, Paint()..color = const Color(0xFF2D1B69));
      canvas.drawCircle(center, 14, Paint()..color = Colors.purpleAccent..style = PaintingStyle.stroke..strokeWidth = 2);

      canvas.drawCircle(center, 5, Paint()..color = Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
