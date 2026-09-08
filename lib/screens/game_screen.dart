import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  void initState() {
    super.initState();
    startGame();
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
