import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:habitvote/shared/widgets/timeWindowPicker/time_window_painter.dart';

class TimeWindowPicker extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay, TimeOfDay) onTimeChanged;

  const TimeWindowPicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onTimeChanged,
  });

  @override
  State<TimeWindowPicker> createState() => _TimeWindowPickerState();
}

class _TimeWindowPickerState extends State<TimeWindowPicker> {
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;

  static const double _minHour = 5;
  static const double _maxHour = 24; // 00 AM is treated as 24 for calculation
  static const double _minDurationHours = 2.0;
  static const double _maxDurationHours = 5.0;

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final position = details.localPosition;
    final angle =
        (math.atan2(position.dy - center.dy, position.dx - center.dx) +
                math.pi / 2) %
            (2 * math.pi);

    double hour = (angle / (2 * math.pi)) * 24;
    hour = (hour + 6) % 24; // Rotate coordinate system to have 0 at the top

    // Snap to nearest 15 minutes
    hour = (hour * 4).round() / 4;

    // Clamp to allowed range [5, 24]
    if (hour < _minHour && hour > 0) {
      final distToMin = (_minHour - hour).abs();
      final distToMax = (24 - hour).abs();
      hour = distToMin < distToMax ? _minHour : _maxHour;
    }
    if (hour == 0) hour = 24;

    final newTime = _hourToTimeOfDay(hour);
    TimeOfDay newStartTime = widget.startTime;
    TimeOfDay newEndTime = widget.endTime;

    if (_isDraggingStart) {
      double newStartHour = _timeOfDayToHour(newTime);
      double endHour = _timeOfDayToHour(widget.endTime);

      // Handle minimum duration
      if (newStartHour >= endHour - _minDurationHours) {
        newStartHour = endHour - _minDurationHours;
      }

      newStartTime = _hourToTimeOfDay(newStartHour);
      newEndTime = widget.endTime;

      // Handle maximum duration
      double newEndHour = _timeOfDayToHour(newEndTime);
      if (newEndHour - newStartHour > _maxDurationHours) {
        newEndHour = newStartHour + _maxDurationHours;
        newEndTime = _hourToTimeOfDay(newEndHour);
      }
    } else if (_isDraggingEnd) {
      double newEndHour = _timeOfDayToHour(newTime);
      double startHour = _timeOfDayToHour(widget.startTime);

      // Handle minimum duration
      if (newEndHour <= startHour + _minDurationHours) {
        newEndHour = startHour + _minDurationHours;
      }

      newEndTime = _hourToTimeOfDay(newEndHour);
      newStartTime = widget.startTime;

      // Handle maximum duration
      double newStartHour = _timeOfDayToHour(newStartTime);
      if (newEndHour - newStartHour > _maxDurationHours) {
        newStartHour = newEndHour - _maxDurationHours;
        newStartTime = _hourToTimeOfDay(newStartHour);
      }
    }

    widget.onTimeChanged(newStartTime, newEndTime);
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final position = details.localPosition;
    final radius = size.width / 2;

    final startHandleAngle =
        (_timeOfDayToHour(widget.startTime) - 6) / 24 * 2 * math.pi -
            math.pi / 2;
    final endHandleAngle =
        (_timeOfDayToHour(widget.endTime) - 6) / 24 * 2 * math.pi - math.pi / 2;

    final startHandlePos = center +
        Offset(math.cos(startHandleAngle) * radius,
            math.sin(startHandleAngle) * radius);
    final endHandlePos = center +
        Offset(math.cos(endHandleAngle) * radius,
            math.sin(endHandleAngle) * radius);

    final distToStart = (position - startHandlePos).distance;
    final distToEnd = (position - endHandlePos).distance;

    // Increased touch target size
    if (distToStart < 30) {
      setState(() => _isDraggingStart = true);
    } else if (distToEnd < 30) {
      setState(() => _isDraggingEnd = true);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDraggingStart = false;
      _isDraggingEnd = false;
    });
  }

  double _timeOfDayToHour(TimeOfDay time) {
    double hour = time.hour + time.minute / 60.0;
    return hour == 0 ? 24.0 : hour;
  }

  TimeOfDay _hourToTimeOfDay(double hour) {
    if (hour >= 24) hour -= 24;
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    return TimeOfDay(hour: h, minute: m);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxWidth);
      return GestureDetector(
        onPanStart: (details) => _handlePanStart(details, size),
        onPanUpdate: (details) => _handlePanUpdate(details, size),
        onPanEnd: _handlePanEnd,
        child: CustomPaint(
          size: size,
          painter: TimeWindowPainter(
            startTime: widget.startTime,
            endTime: widget.endTime,
          ),
        ),
      );
    });
  }
}
