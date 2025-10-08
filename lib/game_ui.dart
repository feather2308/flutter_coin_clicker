import 'package:flutter/material.dart';
import 'package:flutter_coin_clicker/game_logic.dart';
import 'package:flutter_coin_clicker/widgets/achievement_menu.dart';
import 'package:flutter_coin_clicker/widgets/auto_miner_upgrade_menu.dart';
import 'package:flutter_coin_clicker/widgets/click_upgrade_menu.dart';
import 'package:flutter_coin_clicker/widgets/game_menu_sheet.dart';
import 'package:flutter_coin_clicker/widgets/theme_menu.dart';

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
              onThemeShopPressed: showThemeShop,
              onFeatureShopPressed: gameLogic.gameState.isArtifactExpeditionUnlocked
                  ? showArtifactExpeditionUpgradeMenu
                  : showFeatureShop,
              isArtifactExpeditionUnlocked: gameLogic.gameState.isArtifactExpeditionUnlocked,
              onSettingsPressed: showSettings,
            ),
          ),
        );
      },
    );
  }

  void showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        bool musicOn = true;
        bool soundOn = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('배경음악'),
                    value: musicOn,
                    onChanged: (v) => setState(() => musicOn = v),
                  ),
                  SwitchListTile(
                    title: const Text('효과음'),
                    value: soundOn,
                    onChanged: (v) => setState(() => soundOn = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void showThemeShop() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ThemeMenu(gameLogic: gameLogic),
    ));
  }

  void showFeatureShop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('기능 상점'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.explore, color: Colors.brown),
                title: const Text('유물 탐사 기능 활성화'),
                subtitle: Text('앱 종료 중에도 코인을 법니다.\n비용: ${gameLogic.artifactExpeditionUnlockCost} 코인'),
                onTap: gameLogic.unlockArtifactExpedition,
              ),
            ],
          ),
        );
      },
    );
  }

  void showArtifactExpeditionUpgradeMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('유물 탐사 강화'),
          content: Text('강화 기능은 곧 추가될 예정입니다!'),
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
                coinCount: gameLogic.gameState.coins.round(),
                clickPower: gameLogic.gameState.clickPower,
                clickUpgradeCost: gameLogic.gameState.clickUpgradeCost.round(),
                onUpgradeClick: () {
                  gameLogic.upgradeClickPower();
                  setDialogState(() {});
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
                height: 400,
                child: AutoMinerUpgradeMenu(
                  coinCount: gameLogic.gameState.coins.round(),
                  autoMiners: gameLogic.autoMiners,
                  onUpgradeAutoMiner: (index) {
                    gameLogic.upgradeAutoMiner(index);
                    setDialogState(() {});
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