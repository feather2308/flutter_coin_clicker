
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coin_clicker/models/achievement.dart';
import 'package:flutter_coin_clicker/models/auto_miner.dart';

class GameLogic {
  final VoidCallback onUpdate;
  final VoidCallback onAutoMine;
  final BuildContext context;

  int coinCount = 0;
  int totalCoinsEarned = 0;

  // Upgrades
  int clickPower = 1;
  int clickUpgradeCost = 10;
  List<AutoMiner> autoMiners = [];
  int totalAutoMinerProduction = 0;
  Timer? autoMinerTimer;

  // Achievements
  List<Achievement> achievements = [];

  GameLogic({required this.onUpdate, required this.onAutoMine, required this.context});

  Future<void> loadGameData() async {
    await _initializeAutoMiners();
    await _initializeAchievements();
  }

  Future<void> _initializeAutoMiners() async {
    final String response = await rootBundle.loadString('assets/data/auto_miners.json');
    final data = await json.decode(response) as List;
    autoMiners = data.map((d) => AutoMiner.fromJson(d)).toList();
  }

  Future<void> _initializeAchievements() async {
    final String response = await rootBundle.loadString('assets/data/achievements.json');
    final data = await json.decode(response) as List;
    achievements = data.map((d) => Achievement.fromJson(d)).toList();
  }

  void incrementCoin() {
    final amount = clickPower;
    coinCount += amount;
    totalCoinsEarned += amount;
    _checkAchievements();
    onUpdate();
  }

  void autoMine() {
    if (totalAutoMinerProduction > 0) {
      coinCount += totalAutoMinerProduction;
      totalCoinsEarned += totalAutoMinerProduction;
      _checkAchievements();
      onUpdate();
      onAutoMine();
    }
  }

  void startAutoMiner() {
    autoMinerTimer?.cancel();
    autoMinerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      autoMine();
    });
  }

  void _recalculateTotalProduction() {
    totalAutoMinerProduction = autoMiners.fold(0, (sum, miner) => sum + miner.currentProduction);
  }

  void upgradeClickPower() {
    if (coinCount >= clickUpgradeCost) {
      coinCount -= clickUpgradeCost;
      clickPower++;
      clickUpgradeCost = (clickUpgradeCost * 1.5).round();
      _checkAchievements();
      onUpdate();
    }
  }

  void upgradeAutoMiner(int index) {
    final miner = autoMiners[index];
    if (coinCount >= miner.currentCost) {
      coinCount -= miner.currentCost;
      miner.levelUp();
      _recalculateTotalProduction();

      if (autoMinerTimer == null || !autoMinerTimer!.isActive) {
        startAutoMiner();
      }
      _checkAchievements();
      onUpdate();
    }
  }

  void _checkAchievements() {
    for (var achievement in achievements) {
      if (achievement.isUnlocked) continue;

      bool unlocked = false;
      switch (achievement.type) {
        case AchievementType.totalCoins:
          if (totalCoinsEarned >= achievement.condition) unlocked = true;
          break;
        case AchievementType.clickLevel:
          if (clickPower >= achievement.condition) unlocked = true;
          break;
        case AchievementType.autoMinerLevel:
          final totalLevel = autoMiners.fold<int>(0, (sum, miner) => sum + miner.level);
          if (totalLevel >= achievement.condition) unlocked = true;
          break;
      }

      if (unlocked) {
        achievement.isUnlocked = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: achievement.color,
            content: Row(
              children: [
                Icon(achievement.icon, color: Colors.white),
                const SizedBox(width: 8),
                Text('도전과제 달성: ${achievement.name}!', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
        onUpdate();
      }
    }
  }

  void dispose() {
    autoMinerTimer?.cancel();
  }
}
