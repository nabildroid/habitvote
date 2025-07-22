import 'dart:math';

import 'package:flutter/material.dart';

class MilestoneGoalTracker extends StatelessWidget {
  final int streak;
  final List<int> milestones = const [3, 5, 10, 15, 30, 40, 70, 100, 200];

  const MilestoneGoalTracker({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDayLabels(),
        _buildMilestoneProgressBar(),
      ],
    );
  }

  int get _previousMilestone {
    if (streak == 0) return 0;
    return milestones.lastWhere((m) => m < streak, orElse: () => 0);
  }

  int get _nextMilestone {
    return milestones.firstWhere((m) => m > streak,
        orElse: () => milestones.last);
  }

  int get _startDay {
    if (streak == 0) return 1;

    // Center the 7-day view around the current streak
    // but don't go below 1.
    return max(1, streak - 3);
  }

  Widget _buildDayLabels() {
    final int startDay = _startDay;
    final List<int> days = List.generate(7, (index) => startDay + index);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        final isCurrentDay = day == streak;
        return Text(
          day.toString(),
          style: TextStyle(
            color: isCurrentDay ? Colors.black : Colors.grey[600],
            fontWeight: isCurrentDay ? FontWeight.w900 : FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestoneProgressBar() {
    final int startDay = _startDay;
    final int endDay = startDay + 6;
    final int nextMilestone = _nextMilestone;

    // Progress of current streak within the 7-day view
    final double progressPercent =
        ((streak - startDay) / (endDay - startDay)).clamp(0.0, 1.0);

    // Progress of next milestone within the 7-day view
    final double milestonePercent =
        ((nextMilestone - startDay) / (endDay - startDay)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final thumbSize = 18.0;
        final starSize = 20.0;

        final progressPosition = progressPercent * (barWidth - thumbSize);
        final starPosition = milestonePercent * (barWidth - starSize);

        return SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base track
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              // Star for next milestone
              Positioned(
                left: starPosition,
                child: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: starSize,
                ),
              ),
              // Progress bar with gradient and glow
              Positioned(
                left: 0,
                child: Container(
                  height: 14,
                  width: progressPosition + thumbSize / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.shade300,
                        Colors.greenAccent.shade400,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      )
                    ],
                  ),
                ),
              ),
              // Fading line inside progress bar
              Positioned(
                left: 0,
                child: Container(
                  height: 14,
                  width: progressPosition + thumbSize / 2,
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: progressPosition,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              // Circular thumb for current progress
              Positioned(
                left: progressPosition,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
