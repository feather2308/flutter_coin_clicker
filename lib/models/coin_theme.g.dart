// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinTheme _$CoinThemeFromJson(Map<String, dynamic> json) => CoinTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$CoinThemeToJson(CoinTheme instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'price': instance.price,
    };
