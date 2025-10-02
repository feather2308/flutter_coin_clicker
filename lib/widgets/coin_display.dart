
import 'package:flutter/material.dart';

class CoinDisplay extends StatelessWidget {
  final GlobalKey coinKey;
  final double coinSize;

  const CoinDisplay({super.key, required this.coinKey, required this.coinSize});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: coinKey,
      duration: const Duration(milliseconds: 100),
      width: coinSize,
      height: coinSize,
      child: const Icon(
        Icons.monetization_on,
        color: Colors.amber,
        size: 200.0,
      ),
    );
  }
}
