import 'package:flutter/material.dart';
import 'package:flutter_coin_clicker/game_logic.dart';
import 'package:flutter_coin_clicker/models/coin_theme.dart';

class ThemeMenu extends StatefulWidget {
  final GameLogic gameLogic;

  const ThemeMenu({super.key, required this.gameLogic});

  @override
  State<ThemeMenu> createState() => _ThemeMenuState();
}

class _ThemeMenuState extends State<ThemeMenu> {
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// 🛒 테마 구매 로직
  void _buyTheme(CoinTheme theme) {
    final gameState = widget.gameLogic.gameState;

    if (gameState.coins >= theme.price) {
      // 코인 차감
      gameState.coins -= theme.price;

      // 테마 잠금 해제
      gameState.unlockedCoinThemeIds.add(theme.id);

      // 저장
      widget.gameLogic.saveGameData();

      // 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${theme.name} 테마를 구매했습니다!')),
      );

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코인이 부족합니다.')),
      );
    }
  }

  /// 🎨 테마 적용 로직
  void _applyTheme(CoinTheme theme) {
    final gameState = widget.gameLogic.gameState;

    if (gameState.unlockedCoinThemeIds.contains(theme.id)) {
      // 적용
      gameState.activeCoinThemeId = theme.id;

      // 저장
      widget.gameLogic.saveGameData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${theme.name} 테마가 적용되었습니다!')),
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('꾸미기 상점'),
      ),
      body: ListView.builder(
        itemCount: widget.gameLogic.coinThemes.length,
        itemBuilder: (context, index) {
          final CoinTheme theme = widget.gameLogic.coinThemes[index];
          final gameState = widget.gameLogic.gameState;
          final bool isUnlocked = gameState.unlockedCoinThemeIds.contains(theme.id);
          final bool isActive = gameState.activeCoinThemeId == theme.id;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.monetization_on,
                color: _parseColor(theme.color),
                size: 40,
              ),
              title: Text(
                theme.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: isUnlocked
                  ? const Text("보유중")
                  : Text('가격: ${theme.price.round()} 코인'),
              trailing: isActive
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                  : isUnlocked
                      ? ElevatedButton(
                          onPressed: () => _applyTheme(theme),
                          child: const Text('적용'),
                        )
                      : ElevatedButton(
                          onPressed: gameState.coins >= theme.price
                              ? () => _buyTheme(theme)
                              : null,
                          child: const Text('구매'),
                        ),
            ),
          );
        },
      ),
    );
  }
}
