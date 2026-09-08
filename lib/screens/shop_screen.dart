import 'package:flutter/material.dart';
import '../models/player_stats.dart';

class ShopScreen extends StatefulWidget {
  final PlayerStats stats;
  const ShopScreen({Key? key, required this.stats}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Map<String, dynamic>> skins = [
    {'name': 'Cyber Ninja', 'price': 0, 'color': Colors.cyan, 'desc': 'Speed Boost + Fast Jump'},
    {'name': 'Neon Knight', 'price': 500, 'color': Colors.purpleAccent, 'desc': 'Shield Duration +50%'},
    {'name': 'Mech Runner', 'price': 1200, 'color': Colors.orangeAccent, 'desc': 'Double Coin Magnet'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CYBER ARMORY', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade900,
        elevation: 10,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.black]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AVAILABLE CREDITS:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text('${widget.stats.coins}', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: skins.length,
              itemBuilder: (context, index) {
                final skin = skins[index];
                final bool isUnlocked = widget.stats.unlockedSkins.contains(skin['name']);
                final bool isSelected = widget.stats.selectedSkin == skin['name'];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white10, width: isSelected ? 2 : 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: skin['color'],
                      child: Icon(isSelected ? Icons.check : Icons.person, color: Colors.black),
                    ),
                    title: Text(skin['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${skin['desc']}\nPrice: ${skin['price']} Coins', style: TextStyle(color: Colors.grey.shade400)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.green : (isUnlocked ? Colors.cyan : Colors.amber),
                      ),
                      onPressed: () async {
                        if (isUnlocked) {
                          setState(() {
                            widget.stats.selectedSkin = skin['name'];
                          });
                        } else {
                          bool success = await widget.stats.buySkin(skin['name'], skin['price']);
                          if (success) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Unlocked ${skin['name']}!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not enough coins!')),
                            );
                          }
                        }
                      },
                      child: Text(isSelected ? 'EQUIPPED' : (isUnlocked ? 'EQUIP' : 'BUY')),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
