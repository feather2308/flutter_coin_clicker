import 'package:flutter/material.dart';

class GameMenuSheet extends StatelessWidget {
  final VoidCallback onAchievementsPressed;
  final VoidCallback onClickUpgradePressed;
  final VoidCallback onAutoMinerUpgradePressed;
  final VoidCallback onThemeShopPressed;
  final VoidCallback onFeatureShopPressed;
  final VoidCallback onSettingsPressed; // ✅ 새로 추가됨
  final bool isArtifactExpeditionUnlocked;

  const GameMenuSheet({
    super.key,
    required this.onAchievementsPressed,
    required this.onClickUpgradePressed,
    required this.onAutoMinerUpgradePressed,
    required this.onThemeShopPressed,
    required this.onFeatureShopPressed,
    required this.onSettingsPressed, // ✅ 새로 추가됨
    required this.isArtifactExpeditionUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
      _MenuItem(Icons.star, '도전과제', Colors.amber, onAchievementsPressed),
      _MenuItem(Icons.touch_app, '클릭 강화', Colors.blue, onClickUpgradePressed),
      _MenuItem(Icons.memory, '자동 생산기', Colors.green, onAutoMinerUpgradePressed),
      _MenuItem(Icons.palette, '꾸미기', Colors.orange, onThemeShopPressed),
      _MenuItem(
        isArtifactExpeditionUnlocked ? Icons.explore : Icons.store,
        isArtifactExpeditionUnlocked ? '유물 탐사 강화' : '기능 상점',
        Colors.brown,
        onFeatureShopPressed,
      ),
      _MenuItem(Icons.settings, '설정', Colors.grey, onSettingsPressed), // ✅ 설정 추가됨
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 드래그바
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 아이콘 + 텍스트 격자
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 가로로 3개씩
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return GestureDetector(
                onTap: item.onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.color, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 내부 데이터 클래스
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.label, this.color, this.onTap);
}
