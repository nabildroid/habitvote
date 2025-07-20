import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class VerticalTimeHeatmapPainter extends CustomPainter {
  final List<TimeOfDay> selectedTimes;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  VerticalTimeHeatmapPainter({
    required this.selectedTimes,
    required this.startTime,
    required this.endTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackWidth = 24.0;
    final trackX = size.width / 2 - 20; // Shift track to the left
    final trackRect = RRect.fromLTRBR(
      trackX - trackWidth / 2,
      0,
      trackX + trackWidth / 2,
      size.height,
      const Radius.circular(12),
    );

    // A slightly darker, more defined track
    final trackPaint = Paint()..color = Colors.grey.shade200;
    canvas.drawRRect(trackRect, trackPaint);

    _drawMeterLines(canvas, size, trackX, trackWidth);
    _drawHeatSpots(canvas, size, trackX);
    _drawTimeLabels(canvas, size, trackX + trackWidth / 2 + 15);
  }

  void _drawHeatSpots(Canvas canvas, Size size, double trackX) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = 24 * 60;
    final totalMinutes = endMinutes - startMinutes;

    final heatPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        40, // Larger radius for a wider glow
        [
          Colors.amber.withOpacity(0.6),
          Colors.amber.withOpacity(0.0),
        ],
        [0.0, 1.0],
      )
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20)
      ..blendMode = BlendMode.difference;

    for (final time in selectedTimes) {
      final timeMinutes = time.hour * 60 + time.minute;
      if (timeMinutes < startMinutes) continue;

      final yPos = ((timeMinutes - startMinutes) / totalMinutes) * size.height;
      final center = Offset(trackX, yPos);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.drawCircle(Offset.zero, 40, heatPaint);
      canvas.restore();
    }
  }

  void _drawMeterLines(
      Canvas canvas, Size size, double trackX, double trackWidth) {
    final startHour = startTime.hour;
    final endHour = 24;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final totalMinutes = (endHour * 60) - startMinutes;

    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;

    for (int hour = startHour; hour <= endHour; hour++) {
      final timeMinutes = hour * 60;
      final yPos = ((timeMinutes - startMinutes) / totalMinutes) * size.height;

      // Make lines for every 3rd hour longer
      final isMajorTick = hour % 3 == 0;
      final tickLength = isMajorTick ? trackWidth : trackWidth / 2;

      canvas.drawLine(
        Offset(trackX - tickLength / 2, yPos),
        Offset(trackX + tickLength / 2, yPos),
        linePaint,
      );
    }
  }

  void _drawTimeLabels(Canvas canvas, Size size, double labelX) {
    final startHour = startTime.hour;
    final endHour = 24;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final totalMinutes = (endHour * 60) - startMinutes;

    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 12);

    for (int hour = startHour; hour <= endHour; hour += 3) {
      if (hour == 24 && endHour != 24) continue;
      final hourToShow = hour == 24 ? 0 : hour;

      final time = TimeOfDay(hour: hourToShow, minute: 0);
      final timeMinutes = hour * 60;
      final yPos = ((timeMinutes - startMinutes) / totalMinutes) * size.height;

      final textSpan = TextSpan(
        text: _formatTime(time),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(labelX, yPos - textPainter.height / 2));
    }
  }

  String _formatTime(TimeOfDay time) {
    // Manual time formatting to avoid needing BuildContext
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour $period';
  }

  @override
  bool shouldRepaint(covariant VerticalTimeHeatmapPainter oldDelegate) {
    return oldDelegate.selectedTimes != selectedTimes;
  }
}
