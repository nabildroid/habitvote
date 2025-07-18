import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';
import 'package:habitvote/features/habit/presentations/widgets/checkin/checkin_close_window.dart';
import 'package:habitvote/features/habit/presentations/widgets/checkin/checkin_open_windown.dart';

// todo change the name to be something more meanful

class HabitCheckin extends StatelessWidget {
  const HabitCheckin({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: context.habitCubit.durationToOpenWindow,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: (snapshot.data?.inSeconds ?? 10) < 5
                ? CheckInOpenWindowCheckIn()
                : ClosedWindowCheckIn(),
          );
        });
  }
}
