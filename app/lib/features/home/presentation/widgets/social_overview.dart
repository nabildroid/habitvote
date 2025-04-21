import 'package:flutter/material.dart';

class SocialOverview extends StatelessWidget {
  const SocialOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
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
      ),
    );
  }
}
