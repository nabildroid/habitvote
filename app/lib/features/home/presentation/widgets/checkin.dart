import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/habit/presentations/widgets/checkin/habit_checkin.dart';
import 'package:habitvote/features/vote/presentation/widgets/checkin/vote_checkin.dart';

class CheckIn extends StatelessWidget {
  const CheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    final todayCheckIn = context.watch<HabitTrackerCubit>().state.todayCheckin;

    return Card(
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          )),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: todayCheckIn == null ? HabitCheckin() : VoteCheckin(),
        ),
      ),
    );
  }
}

class CheckinLoading extends StatelessWidget {
  const CheckinLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
