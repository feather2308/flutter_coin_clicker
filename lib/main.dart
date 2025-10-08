import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_coin_clicker/game_logic.dart';
import 'package:flutter_coin_clicker/game_ui.dart';
import 'package:flutter_coin_clicker/models/floating_animation.dart';
import 'package:flutter_coin_clicker/models/game_state.dart';
import 'package:flutter_coin_clicker/widgets/animation_painter.dart';
import 'package:flutter_coin_clicker/widgets/coin_display.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(GameStateAdapter());
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

class _CoinClickerPageState extends State<CoinClickerPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  late final GameLogic _gameLogic;
  late final GameUI _gameUI;
  bool _isLoading = true;

  // Animation state
  double _coinSize = 200.0;
  final List<FloatingAnimation> _animations = [];
  int _animationCounter = 0;
  final Random _random = Random();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();
  final GlobalKey _autoMinerKey = GlobalKey();
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameLogic = GameLogic(onUpdate: () => setState(() {}), onAutoMine: _addAutoMineAnimation, context: context);
    _gameUI = GameUI(context: context, gameLogic: _gameLogic);
    _loadData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 비활성화되거나 일시정지될 때 데이터 저장
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _gameLogic.saveGameData();
    }
  }

  void _loadData() async {
    await _gameLogic.loadGameData();
    setState(() {
      _isLoading = false;
    });
    // Start auto miner timer after data is loaded
    if (_gameLogic.totalAutoMinerProduction > 0) {
      _gameLogic.startAutoMiner();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _gameLogic.dispose();
    super.dispose();
  }

  void _addAutoMineAnimation() {
    final RenderBox? stackRenderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? autoMinerRenderBox = _autoMinerKey.currentContext?.findRenderObject() as RenderBox?;

    if (stackRenderBox == null || autoMinerRenderBox == null) return;

    final autoMinerPosition = autoMinerRenderBox.localToGlobal(Offset.zero);
    final localPosition = stackRenderBox.globalToLocal(autoMinerPosition);

    final position = Offset(
      localPosition.dx + autoMinerRenderBox.size.width / 2,
      localPosition.dy + autoMinerRenderBox.size.height / 2,
    );

    _addAnimation(position, _gameLogic.totalAutoMinerProduction);
  }

  void _handleTap(TapDownDetails details) {
    final RenderBox? coinRenderBox = _coinKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackRenderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;

    if (coinRenderBox == null || stackRenderBox == null) return;

    final coinPosition = coinRenderBox.localToGlobal(Offset.zero);
    final coinRect = Rect.fromLTWH(coinPosition.dx, coinPosition.dy, coinRenderBox.size.width, coinRenderBox.size.height);

    if (coinRect.contains(details.globalPosition)) {
      final localPosition = stackRenderBox.globalToLocal(details.globalPosition);
      _gameLogic.incrementCoin();
      _addAnimation(localPosition, _gameLogic.gameState.clickPower);
      _triggerCoinAnimation();
    }
  }

  void _triggerCoinAnimation() {
    setState(() {
      _coinSize = 220.0;
    });
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
                          '${_gameLogic.gameState.coins.round()}',
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
                      key: _autoMinerKey,
                      visible: _gameLogic.autoMiners.any((m) => m.level > 0),
                      child: const Icon(
                        Icons.memory,
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
              onPressed: _gameUI.showGameMenu,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu),
            ),
    );
  }
}