import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/habit/data/repositories/tracker_repository.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';

class SocialOverview extends StatelessWidget {
  const SocialOverview({super.key});

  Widget _buildSocialProof(BuildContext context) {
    final votes = context.voteState.votes.where((e) => e.isActivated).toList();

    final checkIn = context.read<HabitTrackerCubit>().state.checkins;
    // todo compare the checkin date with the vote date
    final positive = votes.fold(0, (int sum, e) => sum + e.up);
    final negative = votes.fold(0, (int sum, e) => sum + e.down);

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        children: [
          const TextSpan(text: 'You proved '),
          TextSpan(
            text: '$negative person wrong',
            style: TextStyle(
              color: Colors.grey.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: ' and gained '),
          TextSpan(
            text: '$positive believers',
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
      child: context.voteState.votes.length > 4
          ? _buildSocialProof(context)
          : _buildNoSocialProof(),
    );
  }
}
