import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitvote/features/habit/presentations/stats/stats_screen.dart';

class ActivitiesSection extends StatelessWidget {
  final ScrollController scrollController1;
  final ScrollController scrollController2;
  final List<Activity> activities;

  const ActivitiesSection({
    super.key,
    required this.scrollController1,
    required this.scrollController2,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 120.0;
    const double cardSpacing = 16.0;
    const int virtualItemCount = 1000; // To make the list appear infinite

    return Column(
      children: [
        Text(
          'Mini moments make\nmomentum',
          textAlign: TextAlign.center,
          style: GoogleFonts.lora(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'All of the activities below count\ntowards your progress.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 240, // Height for 2 rows of items
          child: AbsorbPointer(
            // Disable user scrolling to not interfere with auto-scroll
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController1,
                    scrollDirection: Axis.horizontal,
                    itemCount: virtualItemCount,
                    itemBuilder: (context, index) {
                      final activity = activities[index % activities.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: cardSpacing / 2),
                        child: _buildActivityCard(activity, cardWidth),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController2,
                    scrollDirection: Axis.horizontal,
                    itemCount: virtualItemCount,
                    itemBuilder: (context, index) {
                      final activity =
                          activities[(index + 5) % activities.length];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: (index == 0
                                  ? cardWidth / 2 + cardSpacing
                                  : cardSpacing / 2) +
                              (cardSpacing / 2),
                          right: cardSpacing / 2,
                        ),
                        child: _buildActivityCard(activity, cardWidth),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildActivityCard(Activity activity, double width) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: const Color(0xFFF9F9F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(activity.icon, size: 32, color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text(
              activity.name,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
