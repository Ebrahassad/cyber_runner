import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _playerHighScore = 0;

  @override
  void initState() {
    super.initState();
    _loadLocalScore();
  }

  Future<void> _loadLocalScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _playerHighScore = prefs.getInt('high_score') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // قائمة التحدي المحلي (دمج سكور اللاعب الحقيقي مع منافسين محاكين)
    final List<Map<String, dynamic>> allPlayers = [
      {'name': 'CyberGod99', 'score': 12500, 'badge': '👑'},
      {'name': 'YOU (Player)', 'score': _playerHighScore, 'badge': '⚡'},
      {'name': 'NeonPhantom', 'score': 8400, 'badge': '🔥'},
      {'name': 'SynthWaveX', 'score': 5200, 'badge': '🤖'},
      {'name': 'PixelRider', 'score': 3100, 'badge': '🎮'},
    ];

    // ترتيب اللاعبين حسَب السكور
    allPlayers.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('LOCAL CHAMPIONS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.amber.shade900,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allPlayers.length,
        itemBuilder: (context, index) {
          final player = allPlayers[index];
          final bool isPlayer = player['name'].contains('YOU');

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isPlayer ? Colors.cyan.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlayer ? Colors.cyanAccent : (index == 0 ? Colors.amber : Colors.white10),
                width: isPlayer ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Text(
                '#${index + 1}',
                style: TextStyle(
                  color: index == 0 ? Colors.amber : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              title: Row(
                children: [
                  Text(player['badge'], style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    player['name'],
                    style: TextStyle(
                      color: isPlayer ? Colors.cyanAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '${player['score']} pts',
                style: TextStyle(
                  color: isPlayer ? Colors.greenAccent : Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
