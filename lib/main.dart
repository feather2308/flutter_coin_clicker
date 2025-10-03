import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_coin_clicker/models/achievement.dart';
import 'package:flutter_coin_clicker/models/floating_animation.dart';
import 'package:flutter_coin_clicker/widgets/achievement_menu.dart';
import 'package:flutter_coin_clicker/widgets/animation_painter.dart';
import 'package:flutter_coin_clicker/widgets/auto_miner_upgrade_menu.dart';
import 'package:flutter_coin_clicker/widgets/click_upgrade_menu.dart';
import 'package:flutter_coin_clicker/widgets/coin_display.dart';
import 'package:flutter_coin_clicker/widgets/game_menu_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coin Clicker',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const CoinClickerPage(),
    );
  }
}

class CoinClickerPage extends StatefulWidget {
  const CoinClickerPage({super.key});

  @override
  State<CoinClickerPage> createState() => _CoinClickerPageState();
}

class _CoinClickerPageState extends State<CoinClickerPage> with TickerProviderStateMixin {
  int _coinCount = 0;
  double _coinSize = 200.0;
  final List<FloatingAnimation> _animations = [];
  int _animationCounter = 0;
  final Random _random = Random();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();
  final GlobalKey _autoMinerKey = GlobalKey();

  late final AnimationController _controller;

  // Upgrade state
  int _clickPower = 1;
  int _clickUpgradeCost = 10;
  int _autoMinerLevel = 0;
  int _autoMinerCost = 50;
  int _autoMinerProduction = 0;
  Timer? _autoMinerTimer;

  // Achievement state
  int _totalCoinsEarned = 0;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _initializeAchievements();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  void _initializeAchievements() {
    _achievements = [
      Achievement(name: '신입 광부', description: '총 1,000 코인 획득', tier: AchievementTier.brass, condition: 1000),
      Achievement(name: '숙련된 광부', description: '총 10,000 코인 획득', tier: AchievementTier.silver, condition: 10000),
      Achievement(name: '베테랑 광부', description: '총 100,000 코인 획득', tier: AchievementTier.gold, condition: 100000),
      Achievement(name: '광산의 지배자', description: '총 1,000,000 코인 획득', tier: AchievementTier.platinum, condition: 1000000),
      Achievement(name: '코인 신', description: '총 10,000,000 코인 획득', tier: AchievementTier.diamond, condition: 10000000),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoMinerTimer?.cancel();
    super.dispose();
  }

  void _checkAchievements() {
    for (var achievement in _achievements) {
      if (!achievement.isUnlocked && _totalCoinsEarned >= achievement.condition) {
        setState(() {
          achievement.isUnlocked = true;
        });
        // Optional: Show a notification for unlocked achievement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: achievement.color,
            content: Row(
              children: [
                Icon(achievement.icon, color: Colors.white), 
                const SizedBox(width: 8),
                Text('도전과제 달성: ${achievement.name}!', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    }
  }

  void _handleTap(TapDownDetails details) {
    final RenderBox? coinRenderBox = _coinKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackRenderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;

    if (coinRenderBox == null || stackRenderBox == null) return;

    final coinPosition = coinRenderBox.localToGlobal(Offset.zero);
    final coinRect = Rect.fromLTWH(coinPosition.dx, coinPosition.dy, coinRenderBox.size.width, coinRenderBox.size.height);

    if (coinRect.contains(details.globalPosition)) {
      final localPosition = stackRenderBox.globalToLocal(details.globalPosition);
      _incrementCoin();
      _addAnimation(localPosition, _clickPower);
    }
  }

  void _incrementCoin() {
    setState(() {
      final amount = _clickPower;
      _coinCount += amount;
      _totalCoinsEarned += amount;
      _coinSize = 220.0;
    });
    _checkAchievements();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _coinSize = 200.0;
        });
      }
    });
  }

  void _addAnimation(Offset position, int amount) {
    final id = _animationCounter++;
    final horizontalOffset = (_random.nextDouble() - 0.5) * 80;
    final currentTime = _controller.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0;

    setState(() {
      _animations.add(FloatingAnimation(
        id: id,
        position: position,
        horizontalOffset: horizontalOffset,
        creationTime: currentTime,
        amount: amount,
      ));
    });
  }

  void _autoMine() {
    if (_autoMinerProduction > 0) {
      setState(() {
        _coinCount += _autoMinerProduction;
        _totalCoinsEarned += _autoMinerProduction;
      });
      _addAutoMineAnimation();
      _checkAchievements();
    }
  }

  void _addAutoMineAnimation() {
    final RenderBox? stackRenderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? autoMinerRenderBox = _autoMinerKey.currentContext?.findRenderObject() as RenderBox?;

    if (stackRenderBox == null || autoMinerRenderBox == null) return;

    final autoMinerPosition = autoMinerRenderBox.localToGlobal(Offset.zero);
    final localPosition = stackRenderBox.globalToLocal(autoMinerPosition);

    _addAnimation(Offset(localPosition.dx + autoMinerRenderBox.size.width / 2, localPosition.dy), _autoMinerProduction);
  }

  void _startAutoMiner() {
    _autoMinerTimer?.cancel();
    _autoMinerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _autoMine();
    });
  }

  void _upgradeClickPower(StateSetter setDialogState) {
    if (_coinCount >= _clickUpgradeCost) {
      setState(() {
        _coinCount -= _clickUpgradeCost;
        _clickPower++;
        _clickUpgradeCost = (_clickUpgradeCost * 1.5).round();
      });
      setDialogState(() {});
    }
  }

  void _upgradeAutoMiner(StateSetter setDialogState) {
    if (_coinCount >= _autoMinerCost) {
      setState(() {
        _coinCount -= _autoMinerCost;
        _autoMinerLevel++;
        _autoMinerProduction = _autoMinerLevel;
        _autoMinerCost = (_autoMinerCost * 1.8).round();
      });
      if (_autoMinerTimer == null || !_autoMinerTimer!.isActive) {
        _startAutoMiner();
      }
      setDialogState(() {});
    }
  }

  void _showAchievementsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('도전과제'),
          content: AchievementMenu(achievements: _achievements),
        );
      },
    );
  }

  void _showClickUpgradeMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('클릭 강화'),
              content: ClickUpgradeMenu(
                coinCount: _coinCount,
                clickPower: _clickPower,
                clickUpgradeCost: _clickUpgradeCost,
                onUpgradeClick: () => _upgradeClickPower(setDialogState),
              ),
            );
          },
        );
      },
    );
  }

  void _showAutoMinerUpgradeMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('자동 생산기'),
              content: AutoMinerUpgradeMenu(
                coinCount: _coinCount,
                autoMinerLevel: _autoMinerLevel,
                autoMinerCost: _autoMinerCost,
                autoMinerProduction: _autoMinerProduction,
                onUpgradeAutoMiner: () => _upgradeAutoMiner(setDialogState),
              ),
            );
          },
        );
      },
    );
  }

  void _showGameMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Menu'),
          content: SizedBox(
            width: double.maxFinite,
            child: GameMenuSheet(
              onAchievementsPressed: _showAchievementsMenu,
              onClickUpgradePressed: _showClickUpgradeMenu,
              onAutoMinerUpgradePressed: _showAutoMinerUpgradeMenu,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Clicker'),
      ),
      body: GestureDetector(
        onTapDown: _handleTap,
        child: Stack(
          key: _stackKey,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Coins:',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    '$_coinCount',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  CoinDisplay(coinKey: _coinKey, coinSize: _coinSize),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final currentTime = _controller.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0;
                _animations.removeWhere((anim) => (currentTime - anim.creationTime) > 1000);

                return CustomPaint(
                  painter: AnimationPainter(animations: _animations, time: currentTime),
                  child: Container(),
                );
              },
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Visibility(
                visible: _autoMinerLevel > 0,
                child: Icon(
                  Icons.memory,
                  key: _autoMinerKey,
                  size: 50,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGameMenu,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.menu),
      ),
    );
  }
}