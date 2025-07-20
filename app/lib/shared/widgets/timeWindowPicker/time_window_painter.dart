import 'dart:math' as math;
import 'package:flutter/material.dart';

class TimeWindowPainter extends CustomPainter {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeWindowPainter({required this.startTime, required this.endTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const strokeWidth = 18.0;

    final trackPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw the background track
    canvas.drawCircle(center, radius, trackPaint);

    // Calculate angles
    final startHour = startTime.hour + startTime.minute / 60.0;
    final endHour = endTime.hour + endTime.minute / 60.0;

    // Adjust for coordinate system (0 is at the top)
    final startAngle = ((startHour - 6) % 24 / 24) * 2 * math.pi;
    final endAngle = ((endHour - 6) % 24 / 24) * 2 * math.pi;
    final sweepAngle = (endAngle - startAngle) > 0
        ? endAngle - startAngle
        : (endAngle - startAngle) + 2 * math.pi;

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle - math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw handles
    _drawHandle(canvas, center, radius, startAngle, false);
    _drawHandle(canvas, center, radius, endAngle, true);

    // Draw hour markers
    _drawHourMarkers(canvas, center, radius);

    // Draw center text
    _drawCenterText(canvas, size);
  }

  void _drawHandle(
      Canvas canvas, Offset center, double radius, double angle, bool isEnd) {
    final handlePaint = Paint()..color = Colors.white;
    final handleBorderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final handlePosition = center +
        Offset(math.cos(angle - math.pi / 2) * radius,
            math.sin(angle - math.pi / 2) * radius);

    canvas.drawCircle(handlePosition, 14, handlePaint);
    canvas.drawCircle(handlePosition, 14, handleBorderPaint);

    final icon = isEnd
        ? Icons.notifications_off_outlined
        : Icons.notifications_active_outlined;
    final iconColor = Colors.grey[800];
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 16,
          fontFamily: icon.fontFamily,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        handlePosition - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 12);
    const textRadius = 28.0;

    for (int i = 5; i <= 23; i += 1) {
      if (i % 2 != 0 && i != 5 && i != 23) continue; // Show even hours
      final hour = i;
      final angle = ((hour - 6) % 24 / 24) * 2 * math.pi;
      final position = center +
          Offset(math.cos(angle - math.pi / 2) * (radius - textRadius),
              math.sin(angle - math.pi / 2) * (radius - textRadius));
      textPainter.text = TextSpan(text: '$hour', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas,
          position - Offset(textPainter.width / 2, textPainter.height / 2));
    }
    // Draw 00
    final angle0 = ((0 - 6) % 24 / 24) * 2 * math.pi;
    final position0 = center +
        Offset(math.cos(angle0 - math.pi / 2) * (radius - textRadius),
            math.sin(angle0 - math.pi / 2) * (radius - textRadius));
    textPainter.text = TextSpan(text: '00', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas,
        position0 - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawCenterText(Canvas canvas, Size size) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final checkinDurationMinutes =
        (endMinutes - startMinutes + 24 * 60) % (24 * 60);

    // Total available time from 5:00 AM to 00:00 AM is 19 hours.
    const totalAvailableMinutes = (24 - 5) * 60;
    final workTimeMinutes = totalAvailableMinutes - checkinDurationMinutes;

    final hours = workTimeMinutes ~/ 60;
    final minutes = workTimeMinutes % 60;

    final titleSpan = TextSpan(
      text: 'Habit Work Time\n',
      style: TextStyle(color: Colors.grey[500], fontSize: 16),
    );
    final durationSpan = TextSpan(
      text: '${hours}h ${minutes}m',
      style: TextStyle(
          color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
    );

    final textPainter = TextPainter(
      text: TextSpan(children: [titleSpan, durationSpan]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final position = Offset((size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2);
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
