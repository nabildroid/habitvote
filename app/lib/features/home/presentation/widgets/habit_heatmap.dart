import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitHeatmapWidget extends StatefulWidget {
  final List<DateTime> completedDates;

  const HabitHeatmapWidget({
    super.key,
    this.completedDates = const [],
  });

  @override
  State<HabitHeatmapWidget> createState() => _HabitHeatmapWidgetState();
}

class _HabitHeatmapWidgetState extends State<HabitHeatmapWidget> {
  // Day labels to display on the left
  final List<String> _dayLabels = const ['Mon', 'Wed', 'Fri', 'Sun'];

  // Separate scroll controllers for the month labels and the heatmap
  late ScrollController _monthScrollController;
  late ScrollController _heatmapScrollController;

  // Calculate date information
  late final DateTime _today = DateTime.now();
  late final DateTime _startDate;
  late final int _totalDays;
  late final int _totalWeeks;

  @override
  void initState() {
    super.initState();

    // Initialize dates - go back 1 year from today
    _startDate = _today.subtract(const Duration(days: 365));

    // Calculate total days and weeks
    _totalDays = _today.difference(_startDate).inDays + 1;
    _totalWeeks = (_totalDays / 7).ceil();

    // Initialize scroll controllers
    _monthScrollController = ScrollController();
    _heatmapScrollController = ScrollController();

    // Link the controllers to scroll together
    _heatmapScrollController.addListener(_syncScrolling);

    // Start scrolled to the end (most recent dates)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_heatmapScrollController.hasClients) {
        _heatmapScrollController
            .jumpTo(_heatmapScrollController.position.maxScrollExtent);
      }
    });
  }

  // Sync month labels with the heatmap
  void _syncScrolling() {
    if (_monthScrollController.hasClients &&
        _heatmapScrollController.hasClients) {
      _monthScrollController.jumpTo(_heatmapScrollController.offset);
    }
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _heatmapScrollController.removeListener(_syncScrolling);
    _monthScrollController.dispose();
    _heatmapScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade900,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_walk),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    FittedBox(
                      child: Text(
                        'Walk around the block',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'Go for a short walk to clear the mind',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                // onTap: () => _showStatsBottomSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Add the heatmap with labels
          Expanded(child: _buildHeatmapWithLabels()),
        ],
      ),
    );
  }

  Widget _buildHeatmapWithLabels() {
    return Row(
      children: [
        // Day labels column (left side)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _dayLabels
              .map((day) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(day,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ))
              .toList(),
        ),
        // Main heatmap content
        Expanded(
          child: Column(
            children: [
              // Month labels row (top) - make this scrollable
              SizedBox(
                height: 20,
                child: _buildMonthLabelsRow(),
              ),
              const SizedBox(height: 4),
              // Actual heatmap grid
              Expanded(
                child: _buildHabitHeatmap(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthLabelsRow() {
    // Create a list of all months in the date range
    List<DateTime> monthStarts = [];
    DateTime currentDate = DateTime(_startDate.year, _startDate.month, 1);

    // Generate all month starts until we reach today's month
    while (currentDate.isBefore(_today) ||
        (currentDate.year == _today.year &&
            currentDate.month == _today.month)) {
      monthStarts.add(currentDate);
      // Move to next month
      if (currentDate.month == 12) {
        currentDate = DateTime(currentDate.year + 1, 1, 1);
      } else {
        currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      }
    }

    return ListView.builder(
      controller: _monthScrollController, // Use month controller
      scrollDirection: Axis.horizontal,
      physics:
          const NeverScrollableScrollPhysics(), // Prevent direct scrolling of month labels
      itemCount: _totalWeeks,
      itemBuilder: (context, weekIndex) {
        // Calculate the date for this week
        DateTime weekDate = _startDate.add(Duration(days: weekIndex * 7));

        // Determine if this week starts a new month
        bool isMonthStart = weekDate.day <= 7 &&
            (weekIndex == 0 ||
                _startDate.add(Duration(days: (weekIndex - 1) * 7)).month !=
                    weekDate.month);

        // Only show month label at the start of each month
        return Container(
          width: 30, // Match the width of grid cells
          alignment: Alignment.center,
          child: isMonthStart
              ? Text(
                  DateFormat('MMM').format(weekDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildHabitHeatmap() {
    return GridView.builder(
      controller: _heatmapScrollController, // Use heatmap controller
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days in a week
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: _totalWeeks * 7, // Total cells needed
      itemBuilder: (context, index) {
        // Calculate the date for this cell
        final int dayOffset = index;
        final DateTime cellDate = _startDate.add(Duration(days: dayOffset));

        // Check if this date is today
        final bool isToday = _isToday(cellDate);

        // Check if this date is in the completed list
        final bool isCompleted = _isCompletedDate(cellDate);

        // Check if this date is in the future
        final bool isFuture = cellDate.isAfter(_today);

        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _getCellColor(context, isCompleted, isToday, isFuture),
            borderRadius: BorderRadius.circular(4),
            border: isToday ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: isToday
              ? Center(
                  child: Text(
                    cellDate.day.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    return date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
  }

  bool _isCompletedDate(DateTime date) {
    return widget.completedDates.any((completedDate) =>
        completedDate.year == date.year &&
        completedDate.month == date.month &&
        completedDate.day == date.day);
  }

  Color _getCellColor(
      BuildContext context, bool isCompleted, bool isToday, bool isFuture) {
    if (isFuture) {
      return Colors.grey.shade900; // Very dark for future dates
    }

    if (isCompleted) {
      return Theme.of(context).primaryColor;
    }

    return Colors.grey.shade800;
  }
}
