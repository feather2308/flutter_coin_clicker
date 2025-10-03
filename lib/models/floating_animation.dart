
import 'dart:ui';

class FloatingAnimation {
  final int id;
  final Offset position;
  final double horizontalOffset;
  final double creationTime;
  final int amount;

  FloatingAnimation({
    required this.id,
    required this.position,
    required this.horizontalOffset,
    required this.creationTime,
    required this.amount,
  });
}
