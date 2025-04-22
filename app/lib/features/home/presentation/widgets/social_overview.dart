import 'package:flutter/material.dart';

class SocialOverview extends StatelessWidget {
  const SocialOverview({super.key});

  Widget _buildSocialProof() {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        children: [
          const TextSpan(text: 'You proved '),
          TextSpan(
            text: '100 person wrong',
            style: TextStyle(
              color: Colors.grey.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: ' and gained '),
          TextSpan(
            text: '50 believers',
            style: TextStyle(
              color: Colors.grey.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: ' since November 10'),
        ],
      ),
    );
  }

  Widget _buildNoSocialProof() {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        children: [
          const TextSpan(text: 'You have '),
          TextSpan(
            text: 'Potential',
            style: TextStyle(
              color: Colors.grey.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: ', other Habit Builders will '),
          TextSpan(
            text: 'Vote on you soon',
            style: TextStyle(
              color: Colors.grey.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildNoSocialProof(),
    );
  }
}
