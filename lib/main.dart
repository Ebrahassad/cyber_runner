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
