import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarCard extends StatelessWidget {
  final int totalDays;
  final int nextMilestone;
  final DateTime currentMonth;
  final Set<DateTime> completedDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarCard({
    super.key,
    required this.totalDays,
    required this.nextMilestone,
    required this.currentMonth,
    required this.completedDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF9F9F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              '$totalDays total day${totalDays == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 4),
            Text(
              'Next milestone in $nextMilestone days',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildCalendarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    // Weekday is 1 for Monday and 7 for Sunday. We want Mo to be the first column.
    final firstDayWeekday = firstDayOfMonth.weekday;
    final emptyCells = (firstDayWeekday - 1);

    final List<String> weekDayHeaders = [
      'Mo',
      'Tu',
      'We',
      'Th',
      'Fr',
      'Sa',
      'Su'
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
              onPressed: onPreviousMonth,
            ),
            Text(
              DateFormat.yMMMM().format(currentMonth),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
              onPressed: onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDayHeaders
              .map((day) => Text(day,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w500)))
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: daysInMonth + emptyCells,
          itemBuilder: (context, index) {
            if (index < emptyCells) {
              return Container(); // Empty cell before the 1st day
            }
            final day = index - emptyCells + 1;
            final date = DateTime(currentMonth.year, currentMonth.month, day);
            final isCompleted = completedDays.contains(date);
            final isToday = DateUtils.isSameDay(date, DateTime.now());

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.teal[400] : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isCompleted
                    ? Border.all(color: Colors.teal[400]!, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.white
                        : (isToday ? Colors.teal[600] : Colors.black87),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
