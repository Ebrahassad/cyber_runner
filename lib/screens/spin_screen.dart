import 'package:flutter/material.dart';
import 'dart:math';

class SpinWheelScreen extends StatefulWidget {
  final Function(int) onRewardClaimed;
  const SpinWheelScreen({Key? key, required this.onRewardClaimed}) : super(key: key);

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _reward = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    final double endAngle = (360 * 5) + random.nextInt(360).toDouble(); // 5 دورات كاملة + زاوية عشوائية
    _reward = (random.nextInt(5) + 1) * 100;

    _animation = Tween<double>(begin: 0, end: endAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
      });
      widget.onRewardClaimed(_reward);
      _showRewardDialog();
    });
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo.shade900,
        title: const Text('🎉 CYBER REWARD!', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        content: Text('You won $_reward Coins!', style: const TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('CLAIM', style: TextStyle(color: Colors.cyanAccent, fontSize: 16)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('DAILY CYBER SPIN', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: (_animation.value ?? 0) * (pi / 180),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.cyanAccent, width: 4),
                      gradient: const SweepGradient(
                        colors: [Colors.cyan, Colors.purple, Colors.amber, Colors.redAccent, Colors.cyan],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.star, size: 80, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _isSpinning ? null : _spin,
              child: Text(
                _isSpinning ? 'SPINNING...' : 'SPIN FOR FREE',
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
