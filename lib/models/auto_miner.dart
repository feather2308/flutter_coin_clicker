
import 'package:flutter/material.dart';
import 'dart:math';

IconData _getIconFromString(String iconName) {
  switch (iconName) {
    case 'mouse':
      return Icons.mouse;
    case 'keyboard':
      return Icons.keyboard;
    case 'code':
      return Icons.code;
    case 'agriculture':
      return Icons.agriculture;
    case 'factory':
      return Icons.factory;
    case 'account_balance':
      return Icons.account_balance;
    case 'rocket_launch':
      return Icons.rocket_launch;
    case 'public':
      return Icons.public;
    case 'circle_notifications':
      return Icons.circle_notifications;
    case 'history_toggle_off':
      return Icons.history_toggle_off;
    default:
      return Icons.help;
  }
}

class AutoMiner {
  final String name;
  final IconData icon;
  final int baseProduction;
  final int baseCost;
  final double costIncreaseRate;

  int level = 0;

  AutoMiner({
    required this.name,
    required this.icon,
    required this.baseProduction,
    required this.baseCost,
    this.costIncreaseRate = 1.15,
  });

  factory AutoMiner.fromJson(Map<String, dynamic> json) {
    return AutoMiner(
      name: json['name'],
      icon: _getIconFromString(json['icon']),
      baseProduction: json['baseProduction'],
      baseCost: json['baseCost'],
      costIncreaseRate: json['costIncreaseRate']?.toDouble() ?? 1.15,
    );
  }

  int get currentProduction {
    return level * baseProduction;
  }

  int get currentCost {
    if (level == 0) return baseCost;
    return (baseCost * pow(costIncreaseRate, level)).round();
  }

  void levelUp() {
    level++;
  }
}
