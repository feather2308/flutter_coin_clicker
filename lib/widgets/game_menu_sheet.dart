
import 'package:flutter/material.dart';

class GameMenuSheet extends StatelessWidget {
  final VoidCallback onAchievementsPressed;
  final VoidCallback onClickUpgradePressed;
  final VoidCallback onAutoMinerUpgradePressed;

  const GameMenuSheet({
    super.key,
    required this.onAchievementsPressed,
    required this.onClickUpgradePressed,
    required this.onAutoMinerUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('도전과제'),
            onTap: () {
              Navigator.pop(context);
              onAchievementsPressed();
            },
          ),
          ListTile(
            leading: const Icon(Icons.touch_app),
            title: const Text('클릭 강화'),
            onTap: () {
              Navigator.pop(context);
              onClickUpgradePressed();
            },
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('자동 생산기'),
            onTap: () {
              Navigator.pop(context);
              onAutoMinerUpgradePressed();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Implement settings navigation or functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
