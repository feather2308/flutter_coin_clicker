
import 'package:flutter/material.dart';

enum AchievementTier {
  brass,
  silver,
  gold,
  platinum,
  diamond,
}

enum AchievementType {
  totalCoins,
  clickLevel,
  autoMinerLevel, // Can be total or for a specific miner
}

AchievementTier _getTierFromString(String tier) {
  return AchievementTier.values.firstWhere((e) => e.toString() == 'AchievementTier.$tier');
}

AchievementType _getTypeFromString(String type) {
  return AchievementType.values.firstWhere((e) => e.toString() == 'AchievementType.$type');
}

class Achievement {
  final String name;
  final String description;
  final AchievementTier tier;
  final AchievementType type;
  final int condition;
  final String? targetName; // e.g., name of a specific miner
  bool isUnlocked;

  Achievement({
    required this.name,
    required this.description,
    required this.tier,
    required this.type,
    required this.condition,
    this.targetName,
    this.isUnlocked = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      name: json['name'],
      description: json['description'],
      tier: _getTierFromString(json['tier']),
      type: _getTypeFromString(json['type']),
      condition: json['condition'],
      targetName: json['targetName'],
    );
  }

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
