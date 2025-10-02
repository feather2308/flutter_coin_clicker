
import 'package:flutter/material.dart';
import '../models/floating_animation.dart';

class AnimationPainter extends CustomPainter {
  final List<FloatingAnimation> animations;
  final double time;

  final TextPainter _textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  final Paint _iconPaint = Paint();

  AnimationPainter({required this.animations, required this.time}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    for (final animation in animations) {
      final progress = (time - animation.creationTime) / 1000; // 1 second duration
      if (progress < 0 || progress > 1) continue;

      final opacity = 1.0 - progress;
      if (opacity <= 0) continue;

      // Define the text style for measurement
      const coinStyle = TextStyle(color: Colors.amber, fontSize: 24);
      final plusOneStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(opacity),
      );

      // Layout coin text to get its width
      _textPainter.text = const TextSpan(text: '💰', style: coinStyle);
      _textPainter.layout();
      final coinWidth = _textPainter.width;

      // Layout +1 text to get its width
      _textPainter.text = TextSpan(text: '+1', style: plusOneStyle);
      _textPainter.layout();
      final plusOneWidth = _textPainter.width;
      final textHeight = _textPainter.height;

      // Calculate the total width of the animation element
      const spacing = 4.0;
      final totalWidth = coinWidth + spacing + plusOneWidth;

      // Calculate the centered starting position
      final initialX = animation.position.dx - (totalWidth / 2);
      final initialY = animation.position.dy - (textHeight / 2);

      // Calculate current position based on progress
      final currentX = initialX + (animation.horizontalOffset * progress);
      final currentY = initialY - (progress * 150);

      // Draw coin icon
      _textPainter.text = TextSpan(style: coinStyle.copyWith(color: coinStyle.color?.withOpacity(opacity)), text: '💰');
      _textPainter.layout();
      _textPainter.paint(canvas, Offset(currentX, currentY));

      // Draw +1 text
      _textPainter.text = TextSpan(text: '+1', style: plusOneStyle);
      _textPainter.layout();
      _textPainter.paint(canvas, Offset(currentX + coinWidth + spacing, currentY));
    }
  }

  @override
  bool shouldRepaint(covariant AnimationPainter oldDelegate) {
    return time != oldDelegate.time || animations.length != oldDelegate.animations.length;
  }
}
