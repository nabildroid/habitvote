import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/widgets/checkin/checkin_actions.dart';

class CheckInOpenWindowCheckIn extends StatelessWidget {
  const CheckInOpenWindowCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "30 Voters are waiting for your Response",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
        CheckInActions(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment(-0.8, 0),
          child: Text(
            "If you just showed up that counts",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
          ),
        )
      ],
    );
  }
}
