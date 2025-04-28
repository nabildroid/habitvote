import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter.blur

final _ctas = [
  "Vote to Reveal Your Votes",
  "Give a Vote, Get Yours!",
  "Help Others, Unlock Yours",
  "Cast a Vote & See Yours",
  "Spread Love, Show Your Score",
  "Support a Friend, View Yours",
  "Tap to Vote → View Your Count",
  "Give First, See Your Total",
  "Share a Vote, Reveal Yours",
  "Vote Now to Uncover Yours",
];
final _r = Random(DateTime.now().millisecondsSinceEpoch ~/ 1000);

class VoteSummaryBottomSheet extends StatelessWidget {
  VoteSummaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    _ctas.shuffle(_r);
    // Placeholder data
    const int todayUpVotes = 15;
    const int yesterdayUpVotes = 12;
    const int todayDownVotes = 3;
    const int yesterdayDownVotes = 5;

    return Container(
      // Add padding for the content to not touch the edges
      padding: const EdgeInsets.only(
          top: 12.0, left: 16.0, right: 16.0, bottom: 32.0),
      // Add margin to simulate the floating effect if needed, or rely on shape
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        children: [
          // Optional: Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'Vote Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Vote Boxes Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVoteBox(
                icon: Icons.thumb_up_alt,
                iconColor: Colors.green,
                todayVotes: todayUpVotes,
                yesterdayVotes: yesterdayUpVotes,
                label: 'Up Votes',
              ),
              // Simple arrow icon placeholder
              const Icon(Icons.arrow_forward, color: Colors.grey),
              _buildVoteBox(
                icon: Icons.thumb_down_alt,
                iconColor: Colors.red,
                todayVotes: todayDownVotes,
                yesterdayVotes: yesterdayDownVotes,
                label: 'Down Votes',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for other details if needed
          // Example:
          // _buildDetailRow('Total Votes', '${todayUpVotes + todayDownVotes}'),
          // const SizedBox(height: 8),
          // _buildDetailRow('Streak', '5 days'), // Placeholder
          // const SizedBox(height: 24),

          // Action Button (Placeholder - replace with Swipe Button later if needed)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Close the bottom sheet
            },
            child: Text(
              _ctas.first, // Random CTA from the list
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the vote boxes
  Widget _buildVoteBox({
    required IconData icon,
    required Color iconColor,
    required int todayVotes,
    required int yesterdayVotes,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.grey[300]!, style: BorderStyle.solid, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          // Blurred Today's Votes
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$todayVotes',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Apply blur - adjust sigma values for desired blur intensity
              ClipRect(
                // Clip the blur effect
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    // This container needs to have the same size as the text to cover it
                    // We make it transparent so only the blur effect is visible
                    width: 40, // Adjust width based on expected text size
                    height: 24, // Adjust height based on expected text size
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Yesterday: $yesterdayVotes',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Optional helper for detail rows
  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label, style: TextStyle(color: Colors.grey[600])),
  //         Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
  //       ],
  //     ),
  //   );
  // }
}
