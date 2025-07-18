import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';

class StreakView extends StatelessWidget {
  const StreakView({super.key});

  @override
  Widget build(BuildContext context) {
    final checkins = context.watchHabitState.checkins;

    final streak = checkins
        .where((e) => e.isDone && !e.isMissed)
        .map((e) => e.date)
        .toList();

    final last20Days = List.generate(20, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });

    final streakData = last20Days
        .map((date) {
          return streak.any((streakDate) =>
              streakDate.year == date.year &&
              streakDate.month == date.month &&
              streakDate.day == date.day);
        })
        .toList()
        .reversed;

    return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: streakData
            .map(
              (check) => Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: check ? Colors.black : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
              ),
            )
            .toList());
  }
}
