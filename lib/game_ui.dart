
import 'package:flutter/material.dart';
import 'package:flutter_coin_clicker/game_logic.dart';
import 'package:flutter_coin_clicker/widgets/achievement_menu.dart';
import 'package:flutter_coin_clicker/widgets/auto_miner_upgrade_menu.dart';
import 'package:flutter_coin_clicker/widgets/click_upgrade_menu.dart';
import 'package:flutter_coin_clicker/widgets/game_menu_sheet.dart';

class GameUI {
  final BuildContext context;
  final GameLogic gameLogic;

  GameUI({required this.context, required this.gameLogic});

  void showGameMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Menu'),
          content: SizedBox(
            width: double.maxFinite,
            child: GameMenuSheet(
              onAchievementsPressed: showAchievementsMenu,
              onClickUpgradePressed: showClickUpgradeMenu,
              onAutoMinerUpgradePressed: showAutoMinerUpgradeMenu,
            ),
          ),
        );
      },
    );
  }

  void showAchievementsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('도전과제'),
          content: AchievementMenu(achievements: gameLogic.achievements),
        );
      },
    );
  }

  void showClickUpgradeMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('클릭 강화'),
              content: ClickUpgradeMenu(
                coinCount: gameLogic.coinCount,
                clickPower: gameLogic.clickPower,
                clickUpgradeCost: gameLogic.clickUpgradeCost,
                onUpgradeClick: () {
                  gameLogic.upgradeClickPower();
                  setDialogState(() {}); // Rebuild dialog immediately
                },
              ),
            );
          },
        );
      },
    );
  }

  void showAutoMinerUpgradeMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('자동 생산기'),
              content: SizedBox(
                height: 400, // Constrain height for the ListView
                child: AutoMinerUpgradeMenu(
                  coinCount: gameLogic.coinCount,
                  autoMiners: gameLogic.autoMiners,
                  onUpgradeAutoMiner: (index) {
                    gameLogic.upgradeAutoMiner(index);
                    setDialogState(() {}); // Rebuild dialog immediately
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
