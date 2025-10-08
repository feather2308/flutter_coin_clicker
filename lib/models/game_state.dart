
import 'package:hive/hive.dart';

part 'game_state.g.dart';

@HiveType(typeId: 1)
class GameState {
  @HiveField(0)
  double coins;

  @HiveField(1)
  int clickPower;

  @HiveField(2)
  List<int> autoMinerLevels; // Changed from int to List<int>

  @HiveField(3)
  List<String> unlockedCoinThemeIds;

  @HiveField(4)
  String activeCoinThemeId;

  @HiveField(5)
  bool isArtifactExpeditionUnlocked;

  @HiveField(6)
  double totalCoinsEarned; // Added

  @HiveField(7)
  double clickUpgradeCost; // Added

  GameState({
    this.coins = 0,
    this.clickPower = 1,
    List<int>? autoMinerLevels,
    List<String>? unlockedCoinThemeIds,
    this.activeCoinThemeId = 'default',
    this.isArtifactExpeditionUnlocked = false,
    this.totalCoinsEarned = 0,
    this.clickUpgradeCost = 10,
  }) : this.autoMinerLevels = autoMinerLevels ?? [],
       this.unlockedCoinThemeIds = unlockedCoinThemeIds ?? ['default'];
}
