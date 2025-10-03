import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coin_clicker/models/achievement.dart';
import 'package:flutter_coin_clicker/models/auto_miner.dart';
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
  bool _isLoading = true;
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
  List<AutoMiner> _autoMiners = [];
  int _totalAutoMinerProduction = 0;
  Timer? _autoMinerTimer;

  // Achievement state
  int _totalCoinsEarned = 0;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadGameData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  Future<void> _loadGameData() async {
    await _initializeAutoMiners();
    await _initializeAchievements();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeAutoMiners() async {
    final String response = await rootBundle.loadString('assets/data/auto_miners.json');
    final data = await json.decode(response) as List;
    setState(() {
      _autoMiners = data.map((d) => AutoMiner.fromJson(d)).toList();
    });
  }

  Future<void> _initializeAchievements() async {
    final String response = await rootBundle.loadString('assets/data/achievements.json');
    final data = await json.decode(response) as List;
    setState(() {
      _achievements = data.map((d) => Achievement.fromJson(d)).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoMinerTimer?.cancel();
    super.dispose();
  }

  void _checkAchievements() {
    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      bool unlocked = false;
      switch (achievement.type) {
        case AchievementType.totalCoins:
          if (_totalCoinsEarned >= achievement.condition) unlocked = true;
          break;
        case AchievementType.clickLevel:
          if (_clickPower >= achievement.condition) unlocked = true;
          break;
        case AchievementType.autoMinerLevel:
          final totalLevel = _autoMiners.fold<int>(0, (sum, miner) => sum + miner.level);
          if (totalLevel >= achievement.condition) unlocked = true;
          break;
      }

      if (unlocked) {
        setState(() {
          achievement.isUnlocked = true;
        });
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
    if (_totalAutoMinerProduction > 0) {
      setState(() {
        _coinCount += _totalAutoMinerProduction;
        _totalCoinsEarned += _totalAutoMinerProduction;
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

    _addAnimation(Offset(localPosition.dx + autoMinerRenderBox.size.width / 2, localPosition.dy), _totalAutoMinerProduction);
  }

  void _startAutoMiner() {
    _autoMinerTimer?.cancel();
    _autoMinerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _autoMine();
    });
  }

  void _recalculateTotalProduction() {
    _totalAutoMinerProduction = _autoMiners.fold(0, (sum, miner) => sum + miner.currentProduction);
  }

  void _upgradeClickPower(StateSetter setDialogState) {
    if (_coinCount >= _clickUpgradeCost) {
      setState(() {
        _coinCount -= _clickUpgradeCost;
        _clickPower++;
        _clickUpgradeCost = (_clickUpgradeCost * 1.5).round();
      });
      _checkAchievements();
      setDialogState(() {});
    }
  }

  void _upgradeAutoMiner(int index, StateSetter setDialogState) {
    final miner = _autoMiners[index];
    if (_coinCount >= miner.currentCost) {
      setState(() {
        _coinCount -= miner.currentCost;
        miner.levelUp();
        _recalculateTotalProduction();
      });
      if (_autoMinerTimer == null || !_autoMinerTimer!.isActive) {
        _startAutoMiner();
      }
      _checkAchievements();
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
              content: SizedBox(
                height: 400, // Constrain height for the ListView
                child: AutoMinerUpgradeMenu(
                  coinCount: _coinCount,
                  autoMiners: _autoMiners,
                  onUpgradeAutoMiner: (index) => _upgradeAutoMiner(index, setDialogState),
                ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
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
                      visible: _autoMiners.any((miner) => miner.level > 0),
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
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _showGameMenu,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu),
            ),
    );
  }
}