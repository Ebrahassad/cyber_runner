import 'package:flutter/material.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CYBER QUESTS & ACHIEVEMENTS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.purple.shade900,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMissionTile('Rookie Runner', 'Reach a score of 500 in one run', 'Reward: 100 Coins', true),
          _buildMissionTile('Cyber Legend', 'Reach a score of 1500 in one run', 'Reward: 300 Coins', false),
          _buildMissionTile('Coin Hoarder', 'Collect 1000 total coins', 'Reward: 500 Coins', false),
        ],
      ),
    );
  }

  Widget _buildMissionTile(String title, String desc, String reward, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.greenAccent : Colors.grey.shade800),
      ),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.error_outline,
          color: isCompleted ? Colors.greenAccent : Colors.amber,
          size: 30,
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('$desc\n$reward', style: TextStyle(color: Colors.grey.shade400)),
        trailing: isCompleted
            ? const Text('CLAIMED', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
            : const Text('LOCKED', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
