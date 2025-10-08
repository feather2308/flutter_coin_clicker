import 'package:json_annotation/json_annotation.dart';

part 'coin_theme.g.dart';

@JsonSerializable()
class CoinTheme {
  final String id;
  final String name;
  final String color;
  final double price;

  CoinTheme({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
  });

  factory CoinTheme.fromJson(Map<String, dynamic> json) => _$CoinThemeFromJson(json);
  Map<String, dynamic> toJson() => _$CoinThemeToJson(this);
}
