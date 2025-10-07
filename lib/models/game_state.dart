
import 'package:hive/hive.dart';

part 'game_state.g.dart';

@HiveType(typeId: 1) // typeId를 1로 변경 (0은 이전에 사용)
class GameState {
  @HiveField(0)
  double coins;

  @HiveField(1)
  int clickPower;

  @HiveField(2)
  int autoMinerLevel;

  GameState({
    this.coins = 0,
    this.clickPower = 1,
    this.autoMinerLevel = 0,
  });
}
