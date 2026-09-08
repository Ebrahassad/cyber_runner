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
