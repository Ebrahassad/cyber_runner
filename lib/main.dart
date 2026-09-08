import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const CyberRunnerApp());
}

class CyberRunnerApp extends StatelessWidget {
  const CyberRunnerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}
