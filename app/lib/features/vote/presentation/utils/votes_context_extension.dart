import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/vote/application/votes_cubit.dart';

extension VotesContextExtension on BuildContext {
  VotesCubit get voteCubit => read<VotesCubit>();
  VotesState get voteState => read<VotesCubit>().state;
  VotesState get watchVoteState => watch<VotesCubit>().state;
}
