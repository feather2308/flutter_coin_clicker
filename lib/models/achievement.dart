
import 'package:flutter/material.dart';

enum AchievementTier {
  brass,
  silver,
  gold,
  platinum,
  diamond,
}

class Achievement {
  final String name;
  final String description;
  final AchievementTier tier;
  final int condition;
  bool isUnlocked;

  Achievement({
    required this.name,
    required this.description,
    required this.tier,
    required this.condition,
    this.isUnlocked = false,
  });

  IconData get icon => Icons.emoji_events; // Trophy icon

  Color get color {
    switch (tier) {
      case AchievementTier.brass:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }
}
