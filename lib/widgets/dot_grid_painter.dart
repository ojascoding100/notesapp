import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

/// Custom painter that renders the soft micro-dot grid background
/// characteristic of the Neo-Brutalist stationery aesthetic.
class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NB.borderBlack.withValues(alpha: NB.dotOpacity)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += NB.dotSpacing) {
      for (double y = 0; y < size.height; y += NB.dotSpacing) {
        canvas.drawCircle(Offset(x, y), NB.dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
