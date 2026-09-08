import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final int totalCoins;
  const ShopScreen({Key? key, required this.totalCoins}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('CYBER SHOP'),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Coins: $totalCoins', style: const TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildShopItem('Cyber Ninja', '500 Coins', Colors.cyan),
                _buildShopItem('Neon Knight', '1200 Coins', Colors.purpleAccent),
                _buildShopItem('Mech Runner', '2500 Coins', Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(String name, String price, Color color) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(price, style: const TextStyle(color: Colors.amber)),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: const Text('UNLOCK'),
        ),
      ),
    );
  }
}
