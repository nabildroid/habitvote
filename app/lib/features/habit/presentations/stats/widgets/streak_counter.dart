import 'dart:math';

import 'package:flutter/material.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(150, 150),
                painter: LaurelWreathPainter(),
              ),
              Text(
                '$streak',
                style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'consecutive days',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    );
  }
}

class LaurelWreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2.2);
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw two arcs for the wreath
    canvas.drawArc(rect, -pi / 2 - 0.8, pi * 0.8, false, paint);
    canvas.drawArc(rect, -pi / 2 + 0.8, -pi * 0.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
