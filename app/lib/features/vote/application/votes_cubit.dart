import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';

class VotesState {
  final List<VoteModel> votes;

  VotesState({
    required this.votes,
  });

  VoteModel? get today {
    return votes.where((vote) => vote.openDate == DateTime.now()).firstOrNull;
  }

  factory VotesState.initial() {
    return VotesState(
      votes: [],
    );
  }

  // copyWith method to create a new instance of VotesState with updated values
  VotesState copyWith({
    List<VoteModel>? votes,
  }) {
    return VotesState(
      votes: votes ?? this.votes,
    );
  }
}

class VotesCubit extends Cubit<VotesState> {
  VotesCubit() : super(VotesState.initial());
}
