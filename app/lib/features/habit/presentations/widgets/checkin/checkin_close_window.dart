import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';
import 'package:habitvote/features/habit/presentations/widgets/checkin/checkin_actions.dart';
import 'package:habitvote/features/habit/presentations/widgets/skip_premium_popup.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ClosedWindowCheckIn extends StatelessWidget {
  const ClosedWindowCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckInTimer(),
        const SizedBox(height: 16),
        GestureDetector(
          onTapDown: (_) {
            Posthog().capture(eventName: 'click_checkin_closed_window');
          },
          child: CheckInActions(
            locked: true,
          ),
        ),
        const SizedBox(height: 8),
        SkipWaiting(),
      ],
    );
  }
}

class CheckInTimer extends StatelessWidget {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchHabitState;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next CheckIn',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${state.habit?.checkinOpenWindow.format(context)} - ${state.habit?.checkinCloseWindow.format(context)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        StreamBuilder(
            stream: context.habitCubit.durationToOpenWindow,
            builder: (context, s) {
              return Text(
                _formatDuration(s.data ?? Duration.zero),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
              );
            }),
      ],
    );
  }
}

class SkipWaiting extends StatelessWidget {
  const SkipWaiting({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Posthog().capture(eventName: 'click_skip_closed_window');

        showDialog(
          context: context,
          builder: (context) => SkipPremiumPopup(
            skipsLeft: 3,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Skip'),
          const SizedBox(width: 4),
          const CircleAvatar(
            backgroundColor: Colors.black,
            radius: 10,
            child: Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
