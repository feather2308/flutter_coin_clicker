
import 'package:flutter/material.dart';
import '../models/auto_miner.dart';

class AutoMinerUpgradeMenu extends StatelessWidget {
  final int coinCount;
  final List<AutoMiner> autoMiners;
  final Function(int) onUpgradeAutoMiner;

  const AutoMinerUpgradeMenu({
    super.key,
    required this.coinCount,
    required this.autoMiners,
    required this.onUpgradeAutoMiner,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('보유 코인: $coinCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: autoMiners.length,
              itemBuilder: (context, index) {
                final miner = autoMiners[index];
                return _buildUpgradeItem(
                  context: context,
                  miner: miner,
                  onPressed: coinCount >= miner.currentCost ? () => onUpgradeAutoMiner(index) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeItem({
    required BuildContext context,
    required AutoMiner miner,
    required VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(miner.icon, size: 40),
        title: Text(miner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('레벨: ${miner.level}\n효율: +${miner.baseProduction} 코인/초\n비용: ${miner.currentCost} 코인'),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: const Text('구매'),
        ),
      ),
    );
  }
}
