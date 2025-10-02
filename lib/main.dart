import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_coin_clicker/models/floating_animation.dart';
import 'package:flutter_coin_clicker/widgets/animation_painter.dart';
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

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      _addAnimation(localPosition);
    }
  }

  void _incrementCoin() {
    setState(() {
      _coinCount++;
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

  void _addAnimation(Offset position) {
    final id = _animationCounter++;
    final horizontalOffset = (_random.nextDouble() - 0.5) * 80;
    final currentTime = _controller.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0;

    // Add to list and trigger a rebuild of the AnimatedBuilder
    setState(() {
      _animations.add(FloatingAnimation(
        id: id,
        position: position,
        horizontalOffset: horizontalOffset,
        creationTime: currentTime,
      ));
    });
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
            child: const GameMenuSheet(),
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
            // Static UI that doesn't rebuild on every frame
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
            // The animation painter, rebuilt by AnimatedBuilder for performance
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