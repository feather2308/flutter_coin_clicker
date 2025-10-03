
import 'package:flutter/material.dart';

class AutoMinerUpgradeMenu extends StatelessWidget {
  final int coinCount;
  final int autoMinerLevel;
  final int autoMinerCost;
  final int autoMinerProduction;
  final VoidCallback onUpgradeAutoMiner;

  const AutoMinerUpgradeMenu({
    super.key,
    required this.coinCount,
    required this.autoMinerLevel,
    required this.autoMinerCost,
    required this.autoMinerProduction,
    required this.onUpgradeAutoMiner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('보유 코인: $coinCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildUpgradeItem(
            context: context,
            icon: Icons.memory,
            title: '자동 생산기',
            level: autoMinerLevel,
            cost: autoMinerCost,
            onPressed: coinCount >= autoMinerCost ? onUpgradeAutoMiner : null,
            production: '+$autoMinerProduction 코인/초',
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int level,
    required int cost,
    required VoidCallback? onPressed,
    required String production,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('레벨: $level\n효율: $production\n비용: $cost 코인'),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: const Text('구매'),
        ),
      ),
    );
  }
}
