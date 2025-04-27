import 'package:flutter/material.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/checkin_model.dart';
import 'package:habitvote/features/habit/data/repositories/habit_repository.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';
import 'package:intl/intl.dart';

class HabitHeatmapWidget extends StatefulWidget {
  final IconData habitIcon;
  final int startDayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

  const HabitHeatmapWidget({
    super.key,
    this.startDayOfWeek = 1,
    required this.habitIcon, // Default to Monday
  });

  @override
  State<HabitHeatmapWidget> createState() => _HabitHeatmapWidgetState();
}

class _HabitHeatmapWidgetState extends State<HabitHeatmapWidget> {
  // Day labels to display on the left - will be dynamically generated
  late final List<String> _dayLabels;

  // All days of the week in order
  final List<String> _allDayLabels = const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

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

    // Generate day labels starting from the configured start day
    _dayLabels = _generateDayLabels();

    // Initialize dates - go back 1 year from today and align to start of week
    _startDate = _calculateStartDate();

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

  // Generate day labels based on the start day of week
  List<String> _generateDayLabels() {
    // Pick every other day for display (to avoid crowding)
    List<String> orderedDays = [];

    // Start from configured start day and wrap around
    for (int i = 0; i < 7; i += 2) {
      int dayIndex = (widget.startDayOfWeek + i) % 7;
      orderedDays.add(_allDayLabels[dayIndex]);
    }

    return orderedDays;
  }

  // Calculate the start date aligned to the specified day of week
  DateTime _calculateStartDate() {
    // Go back 1 year from today
    DateTime oneYearAgo = DateTime(_today.year - 1, _today.month, _today.day);

    // Find the previous occurrence of the start day of week
    int daysToSubtract = (oneYearAgo.weekday - widget.startDayOfWeek) % 7;
    if (daysToSubtract > 0) {
      daysToSubtract = 7 - daysToSubtract;
    }

    return oneYearAgo.subtract(Duration(days: daysToSubtract));
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
      margin: const EdgeInsets.all(6),
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
              Icon(widget.habitIcon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        context.habitState.habit!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        context.habitState.habit!.description,
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
                onTap: () async {
                  final habits = await locator.get<HabitRepo>().getAll();

                  print(habits);
                },
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
    return ListView.builder(
      controller: _monthScrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _totalWeeks,
      itemBuilder: (context, weekIndex) {
        // Calculate the first day shown in this week's column
        DateTime firstDayOfWeek = _getDateFromWeekIndex(weekIndex);

        // For month label positioning, check if any day in this column is the first day of a month
        bool showMonthLabel = false;
        String monthLabel = '';

        // Check each day in the column
        for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
          DateTime currentDate = firstDayOfWeek.add(Duration(days: dayOffset));
          // If this is the first day of a month, we should show the month label
          if (currentDate.day == 1) {
            showMonthLabel = true;
            monthLabel = DateFormat('MMM').format(currentDate);
            break;
          }
        }

        return Container(
          width: 30,
          alignment: Alignment.center,
          child: showMonthLabel
              ? Text(
                  monthLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  // Helper method to get the date from a week index
  DateTime _getDateFromWeekIndex(int weekIndex) {
    // The weekIndex represents columns in our grid
    // Each column is 7 days starting from our startDate
    return _startDate.add(Duration(days: weekIndex * 7));
  }

  Widget _buildHabitHeatmap() {
    context.watchHabitState.checkins;
    return GridView.builder(
      controller: _heatmapScrollController,
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days in a week
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: _totalWeeks * 7,
      itemBuilder: (context, index) {
        final int col = index ~/ 7; // Column/week index
        final int row = index % 7; // Row/day of week index

        // Calculate this cell's date by finding its column's first day and adding the row offset
        final DateTime firstDayOfColumn = _getDateFromWeekIndex(col);
        final DateTime cellDate = firstDayOfColumn.add(Duration(days: row));

        // Check if this date is today
        final bool isToday = _isToday(cellDate);

        // Don't allow interactions with future dates
        final bool isFuture = cellDate.isAfter(_today);

        // Get check-in status for this date directly from HabitTrackerState
        final checkin = _getCheckInForDate(context, cellDate);
        final bool isCompleted = checkin != null && checkin.isDone;
        final bool isFailed = checkin != null && !checkin.isDone;

        return GestureDetector(
          onTap: isFuture ? null : () => _handleTap(context, cellDate, checkin),
          onLongPress: checkin == null || isFuture
              ? null
              : () => _handleLongPress(context, cellDate),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getCellColor(
                  context, isCompleted, isFailed, isToday, isFuture),
              borderRadius: BorderRadius.circular(4),
              border:
                  isToday ? Border.all(color: Colors.white, width: 2) : null,
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
          ),
        );
      },
    );
  }

  // Get check-in for a specific date from the state
  CheckinModel? _getCheckInForDate(BuildContext context, DateTime date) {
    return context.habitState.checkins
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .firstOrNull;
  }

  // Handle tap on a cell
  void _handleTap(
      BuildContext context, DateTime date, CheckinModel? existingCheckin) {
    if (existingCheckin == null) {
      // First tap - mark as completed (done=true)
      context.habitCubit.checkIn(isDone: true, date: date);
    } else if (existingCheckin.isDone) {
      // Second tap - change to failed (done=false)
      context.habitCubit.undoCheckIn(date: date);
      context.habitCubit.checkIn(isDone: false, date: date);
    } else {
      // Third tap (on failed) - remove check-in
      context.habitCubit.undoCheckIn(date: date);
    }
  }

  // Handle long press - remove check-in
  void _handleLongPress(BuildContext context, DateTime date) {
    context.habitCubit.undoCheckIn(date: date);
  }

  bool _isToday(DateTime date) {
    return date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
  }

  Color _getCellColor(BuildContext context, bool isCompleted, bool isFailed,
      bool isToday, bool isFuture) {
    if (isFuture) {
      return Colors.grey.shade900; // Very dark for future dates
    }

    if (isCompleted) {
      return Theme.of(context).primaryColor;
    }

    if (isFailed) {
      return Colors.red.shade700; // Color for failed check-ins
    }

    return Colors.grey.shade800;
  }
}
