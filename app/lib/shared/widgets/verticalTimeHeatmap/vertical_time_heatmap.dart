import 'package:flutter/material.dart';
import 'package:habitvote/shared/widgets/verticalTimeHeatmap/vertical_time_heatmap_painter.dart';

class VerticalTimeHeatmap extends StatelessWidget {
  final List<TimeOfDay> selectedTimes;
  final ValueChanged<TimeOfDay> onTimeTap;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const VerticalTimeHeatmap({
    super.key,
    required this.selectedTimes,
    required this.onTimeTap,
    this.startTime = const TimeOfDay(hour: 5, minute: 0),
    this.endTime = const TimeOfDay(hour: 0, minute: 0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final tapPosition = details.localPosition;
            final height = constraints.maxHeight;

            final startMinutes = startTime.hour * 60 + startTime.minute;
            final endMinutes = 24 * 60; // Midnight
            final totalMinutes = endMinutes - startMinutes;

            final tappedMinute =
                (tapPosition.dy / height) * totalMinutes + startMinutes;

            final hour = (tappedMinute ~/ 60) % 24;
            final minute = (tappedMinute % 60).round();

            // Snap to nearest 15 minutes
            final snappedMinute = (minute / 15).round() * 15;
            if (snappedMinute == 60) {
              onTimeTap(TimeOfDay(hour: (hour + 1) % 24, minute: 0));
            } else {
              onTimeTap(TimeOfDay(hour: hour, minute: snappedMinute));
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: VerticalTimeHeatmapPainter(
              selectedTimes: selectedTimes,
              startTime: startTime,
              endTime: endTime,
            ),
          ),
        );
      },
    );
  }
}
