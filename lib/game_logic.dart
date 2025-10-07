import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coin_clicker/models/achievement.dart';
import 'package:flutter_coin_clicker/models/auto_miner.dart';
import 'package:hive/hive.dart';

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

  // Artifact Expedition (formerly Idle Rewards)
  bool isArtifactExpeditionUnlocked = false;
  final int artifactExpeditionUnlockCost = 1000;

  GameLogic({required this.onUpdate, required this.onAutoMine, required this.context});

  // --- Data Persistence ---

  Future<void> saveGameData() async {
    final box = await Hive.openBox('gameState');
    await box.put('coinCount', coinCount);
    await box.put('totalCoinsEarned', totalCoinsEarned);
    await box.put('clickPower', clickPower);
    await box.put('clickUpgradeCost', clickUpgradeCost);
    final minerLevels = autoMiners.map((m) => m.level).toList();
    await box.put('autoMinerLevels', minerLevels);
    final achievementStatus = achievements.map((a) => a.isUnlocked).toList();
    await box.put('achievementStatus', achievementStatus);
    await box.put('isArtifactExpeditionUnlocked', isArtifactExpeditionUnlocked);
    await box.put('lastSessionEndTime', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> loadGameData() async {
    await _initializeAutoMiners();
    await _initializeAchievements();

    final box = await Hive.openBox('gameState');

    coinCount = box.get('coinCount', defaultValue: 0);
    totalCoinsEarned = box.get('totalCoinsEarned', defaultValue: 0);
    clickPower = box.get('clickPower', defaultValue: 1);
    clickUpgradeCost = box.get('clickUpgradeCost', defaultValue: 10);
    isArtifactExpeditionUnlocked = box.get('isArtifactExpeditionUnlocked', defaultValue: false);

    final List<int> minerLevels = List<int>.from(box.get('autoMinerLevels', defaultValue: []));
    if (minerLevels.isNotEmpty && minerLevels.length == autoMiners.length) {
      for (int i = 0; i < autoMiners.length; i++) {
        autoMiners[i].setLevel(minerLevels[i]);
      }
    }

    final List<bool> achievementStatus = List<bool>.from(box.get('achievementStatus', defaultValue: []));
    if (achievementStatus.isNotEmpty && achievementStatus.length == achievements.length) {
      for (int i = 0; i < achievements.length; i++) {
        achievements[i].isUnlocked = achievementStatus[i];
      }
    }

    _recalculateTotalProduction();
    if (isArtifactExpeditionUnlocked) {
      _calculateArtifactExpeditionRewards(box);
    }

    onUpdate();
  }

  void _calculateArtifactExpeditionRewards(Box box) {
    final lastSessionEndTime = box.get('lastSessionEndTime', defaultValue: null);
    if (lastSessionEndTime == null || totalAutoMinerProduction == 0) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final offlineDurationInSeconds = (currentTime - lastSessionEndTime) / 1000;

    const maxOfflineSeconds = 2 * 60 * 60;
    final effectiveOfflineSeconds = offlineDurationInSeconds > maxOfflineSeconds ? maxOfflineSeconds : offlineDurationInSeconds;

    if (effectiveOfflineSeconds <= 10) return;

    final earnings = (effectiveOfflineSeconds * totalAutoMinerProduction).round();

    if (earnings > 0) {
      coinCount += earnings;
      totalCoinsEarned += earnings;
      _showArtifactExpeditionDialog(earnings, effectiveOfflineSeconds.round());
    }
  }

  void _showArtifactExpeditionDialog(int earnings, int offlineSeconds) {
    final duration = Duration(seconds: offlineSeconds);
    String durationString = "";
    if (duration.inHours > 0) durationString += "${duration.inHours}시간 ";
    if (duration.inMinutes.remainder(60) > 0) durationString += "${duration.inMinutes.remainder(60)}분 ";
    durationString += "${duration.inSeconds.remainder(60)}초";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('유물 탐사 완료!'),
          content: Text('자리를 비운 $durationString 동안\n위대한 탐험가들이 $earnings 개의 코인을 발견했습니다!'),
          actions: <Widget>[
            TextButton(child: const Text('확인'), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  // --- Initialization ---
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

  // --- Core Game Logic ---
  void unlockArtifactExpedition() {
    if (coinCount >= artifactExpeditionUnlockCost) {
      coinCount -= artifactExpeditionUnlockCost;
      isArtifactExpeditionUnlocked = true;
      onUpdate();
      saveGameData();
      // Close menu and show confirmation
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유물 탐사 기능이 활성화되었습니다!')), 
      );
    }
  }

  void incrementCoin() {
    final amount = clickPower;
    coinCount += amount;
    totalCoinsEarned += amount;
    _checkAchievements();
    onUpdate();
    saveGameData();
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
    autoMinerTimer = Timer.periodic(const Duration(seconds: 1), (timer) => autoMine());
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
      saveGameData();
    }
  }

  void upgradeAutoMiner(int index) {
    final miner = autoMiners[index];
    if (coinCount >= miner.currentCost) {
      coinCount -= miner.currentCost;
      miner.levelUp();
      _recalculateTotalProduction();
      if (autoMinerTimer == null || !autoMinerTimer!.isActive) startAutoMiner();
      _checkAchievements();
      onUpdate();
      saveGameData();
    }
  }

  void _checkAchievements() {
    for (var achievement in achievements) {
      if (achievement.isUnlocked) continue;
      bool unlocked = false;
      switch (achievement.type) {
        case AchievementType.totalCoins: if (totalCoinsEarned >= achievement.condition) unlocked = true; break;
        case AchievementType.clickLevel: if (clickPower >= achievement.condition) unlocked = true; break;
        case AchievementType.autoMinerLevel: final totalLevel = autoMiners.fold<int>(0, (sum, miner) => sum + miner.level); if (totalLevel >= achievement.condition) unlocked = true; break;
      }
      if (unlocked) {
        achievement.isUnlocked = true;
        saveGameData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: achievement.color,
            content: Row(children: [Icon(achievement.icon, color: Colors.white), const SizedBox(width: 8), Text('도전과제 달성: ${achievement.name}!', style: const TextStyle(fontWeight: FontWeight.bold))]),
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