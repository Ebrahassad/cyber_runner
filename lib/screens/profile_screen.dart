import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import '../models/player_profile.dart';

class ProfileScreen extends StatelessWidget {
  final PlayerStats stats;
  const ProfileScreen({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfile.getProfileForScore(stats.highScore);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CYBER ID & STATS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.cyan.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.cyan.shade900, Colors.black]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Text(profile.badge, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 10),
                  Text(profile.title, style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 5),
                  const Text('OPERATIVE STATUS', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildStatCard('HIGH SCORE', '${stats.highScore}', Icons.emoji_events, Colors.amber),
            const SizedBox(height: 15),
            _buildStatCard('TOTAL CREDITS', '${stats.coins}', Icons.monetization_on, Colors.greenAccent),
            const SizedBox(height: 15),
            _buildStatCard('EQUIPPED SKIN', stats.selectedSkin, Icons.person, Colors.purpleAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
