import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coin_clicker/models/achievement.dart';
import 'package:flutter_coin_clicker/models/auto_miner.dart';
import 'package:flutter_coin_clicker/models/coin_theme.dart';
import 'package:flutter_coin_clicker/models/game_state.dart';
import 'package:hive/hive.dart';

class GameLogic {
  final VoidCallback onUpdate;
  final VoidCallback onAutoMine;
  final BuildContext context;

  late GameState gameState;

  // Non-persistent state
  List<AutoMiner> autoMiners = [];
  List<CoinTheme> coinThemes = [];
  int totalAutoMinerProduction = 0;
  Timer? autoMinerTimer;
  List<Achievement> achievements = [];
  final int artifactExpeditionUnlockCost = 1000;

  GameLogic({required this.onUpdate, required this.onAutoMine, required this.context});

  // --- Data Persistence ---

  Future<void> saveGameData() async {
    final box = await Hive.openBox('gameStateBox');

    // 게임 상태 전체 저장
    await box.put('gameState', gameState);

    // 도전과제 상태 저장
    final achievementStatus = achievements.map((a) => a.isUnlocked).toList();
    await box.put('achievementStatus', achievementStatus);

    // 🎨 테마 상태 저장 (별도로 안 해도 되지만, 명시적으로 한 번 더)
    await box.put('unlockedCoinThemeIds', gameState.unlockedCoinThemeIds);
    await box.put('activeCoinThemeId', gameState.activeCoinThemeId);

    // 세션 종료 시간
    await box.put('lastSessionEndTime', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> loadGameData() async {
    await _initializeAutoMiners();
    await _initializeAchievements();
    await _initializeCoinThemes();

    final box = await Hive.openBox('gameStateBox');

    // 기본 게임 상태 불러오기
    gameState = box.get('gameState', defaultValue: GameState());

    // 자동 생산기 복원
    if (gameState.autoMinerLevels.isNotEmpty && gameState.autoMinerLevels.length == autoMiners.length) {
      for (int i = 0; i < autoMiners.length; i++) {
        autoMiners[i].setLevel(gameState.autoMinerLevels[i]);
      }
    }

    // 도전과제 복원
    final List<bool> achievementStatus = List<bool>.from(box.get('achievementStatus', defaultValue: []));
    if (achievementStatus.isNotEmpty && achievementStatus.length == achievements.length) {
      for (int i = 0; i < achievements.length; i++) {
        achievements[i].isUnlocked = achievementStatus[i];
      }
    }

    // 🎨 테마 상태 복원
    final List<String> unlockedIds = List<String>.from(
      box.get('unlockedCoinThemeIds', defaultValue: ['default']),
    );
    final String activeId = box.get('activeCoinThemeId', defaultValue: 'default');

    gameState.unlockedCoinThemeIds = unlockedIds;
    gameState.activeCoinThemeId = activeId;

    // 생산량 갱신 및 기타 초기화
    _recalculateTotalProduction();
    if (gameState.isArtifactExpeditionUnlocked) {
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
      gameState.coins += earnings;
      gameState.totalCoinsEarned += earnings;
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

  Future<void> _initializeCoinThemes() async {
    final String response = await rootBundle.loadString('assets/data/coin_themes.json');
    final data = await json.decode(response) as List;
    coinThemes = data.map((d) => CoinTheme.fromJson(d)).toList();
  }

  // --- Core Game Logic ---
  void unlockArtifactExpedition() {
    if (gameState.coins >= artifactExpeditionUnlockCost) {
      gameState.coins -= artifactExpeditionUnlockCost;
      gameState.isArtifactExpeditionUnlocked = true;
      onUpdate();
      saveGameData();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유물 탐사 기능이 활성화되었습니다!')), 
      );
    }
  }

  void incrementCoin() {
    final amount = gameState.clickPower;
    gameState.coins += amount;
    gameState.totalCoinsEarned += amount;
    _checkAchievements();
    onUpdate();
    saveGameData();
  }

  void autoMine() {
    if (totalAutoMinerProduction > 0) {
      gameState.coins += totalAutoMinerProduction;
      gameState.totalCoinsEarned += totalAutoMinerProduction;
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
    if (gameState.coins >= gameState.clickUpgradeCost) {
      gameState.coins -= gameState.clickUpgradeCost;
      gameState.clickPower++;
      gameState.clickUpgradeCost = (gameState.clickUpgradeCost * 1.5).round().toDouble();
      _checkAchievements();
      onUpdate();
      saveGameData();
    }
  }

  void upgradeAutoMiner(int index) {
    final miner = autoMiners[index];
    if (gameState.coins >= miner.currentCost) {
      gameState.coins -= miner.currentCost;
      miner.levelUp();
      gameState.autoMinerLevels = autoMiners.map((m) => m.level).toList();
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
        case AchievementType.totalCoins: if (gameState.totalCoinsEarned >= achievement.condition) unlocked = true; break;
        case AchievementType.clickLevel: if (gameState.clickPower >= achievement.condition) unlocked = true; break;
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