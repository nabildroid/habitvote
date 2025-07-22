import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';

class AppBarStreakBadge extends StatelessWidget {
  const AppBarStreakBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final checkins = context.watchHabitState.checkins;

    final doneDates = checkins
        .where((e) => e.isDone && !e.isMissed)
        .map((e) => DateUtils.dateOnly(e.date))
        .toSet();

    if (doneDates.isEmpty) {
      return const SizedBox.shrink();
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final isTodayDone = doneDates.contains(today);
    final streak = _calculateStreak(doneDates, today);

    if (streak == 0) {
      return const SizedBox.shrink();
    }

    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = Colors.grey;
    final displayColor = isTodayDone ? activeColor : inactiveColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$streak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: displayColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.local_fire_department,
          color: displayColor,
          size: 22,
        ),
      ],
    );
  }

  int _calculateStreak(Set<DateTime> doneDates, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime startDate;
    if (doneDates.contains(today)) {
      startDate = today;
    } else if (doneDates.contains(yesterday)) {
      startDate = yesterday;
    } else {
      return 0;
    }

    int streakCount = 0;
    DateTime currentDate = startDate;
    while (doneDates.contains(currentDate)) {
      streakCount++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streakCount;
  }
}
