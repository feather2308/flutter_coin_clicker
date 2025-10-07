import 'package:flutter/material.dart';

class GameMenuSheet extends StatelessWidget {
  final VoidCallback onAchievementsPressed;
  final VoidCallback onClickUpgradePressed;
  final VoidCallback onAutoMinerUpgradePressed;
  final VoidCallback onFeatureShopPressed;
  final bool isArtifactExpeditionUnlocked;

  const GameMenuSheet({
    super.key,
    required this.onAchievementsPressed,
    required this.onClickUpgradePressed,
    required this.onAutoMinerUpgradePressed,
    required this.onFeatureShopPressed,
    required this.isArtifactExpeditionUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: const Text('도전과제'),
          onTap: onAchievementsPressed,
        ),
        ListTile(
          leading: const Icon(Icons.touch_app, color: Colors.blue),
          title: const Text('클릭 강화'),
          onTap: onClickUpgradePressed,
        ),
        ListTile(
          leading: const Icon(Icons.memory, color: Colors.green),
          title: const Text('자동 생산기'),
          onTap: onAutoMinerUpgradePressed,
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            isArtifactExpeditionUnlocked ? Icons.explore : Icons.store,
            color: Colors.brown,
          ),
          title: Text(isArtifactExpeditionUnlocked ? '유물 탐사 강화' : '기능 상점'),
          onTap: onFeatureShopPressed,
        ),
      ],
    );
  }
}