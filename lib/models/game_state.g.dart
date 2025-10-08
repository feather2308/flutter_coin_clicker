// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 1;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      coins: fields[0] as double,
      clickPower: fields[1] as int,
      autoMinerLevels: (fields[2] as List?)?.cast<int>(),
      unlockedCoinThemeIds: (fields[3] as List?)?.cast<String>(),
      activeCoinThemeId: fields[4] as String,
      isArtifactExpeditionUnlocked: fields[5] as bool,
      totalCoinsEarned: fields[6] as double,
      clickUpgradeCost: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.coins)
      ..writeByte(1)
      ..write(obj.clickPower)
      ..writeByte(2)
      ..write(obj.autoMinerLevels)
      ..writeByte(3)
      ..write(obj.unlockedCoinThemeIds)
      ..writeByte(4)
      ..write(obj.activeCoinThemeId)
      ..writeByte(5)
      ..write(obj.isArtifactExpeditionUnlocked)
      ..writeByte(6)
      ..write(obj.totalCoinsEarned)
      ..writeByte(7)
      ..write(obj.clickUpgradeCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
