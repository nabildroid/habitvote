import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/habit/data/repositories/habit_repository.dart';
import 'package:habitvote/features/habit/data/repositories/tracker_repository.dart';
import 'package:habitvote/features/vote/data/models/candidat_model.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';
import 'package:habitvote/features/vote/data/repositories/votes_repository.dart';
import 'package:habitvote/shared/dates_utils.dart';
import 'package:rxdart/rxdart.dart';

class VotesState extends Equatable {
  final List<VoteModel> votes;

  final List<CandidatModel> todayCandidats;

  final bool showTodayResults;

  VotesState({
    required this.votes,
    required this.todayCandidats,
    required this.showTodayResults,
  });

  VoteModel? get today {
    return votes
        .where(
            (v) => v.createdAt.diffDay(DateTime.now()) <= Duration(hours: 24))
        .firstOrNull;
  }

  VoteModel? get yesterday {
    return votes
        .where((v) =>
            v.createdAt.diffDay(DateTime.now()) <= Duration(hours: 48) &&
            v.createdAt.diffDay(DateTime.now()) > Duration(hours: 24))
        .firstOrNull;
  }

  factory VotesState.initial() {
    return VotesState(
      votes: [],
      showTodayResults: false,
      todayCandidats: [],
    );
  }

  // copyWith method to create a new instance of VotesState with updated values
  VotesState copyWith({
    List<VoteModel>? votes,
    List<CandidatModel>? todayCandidats,
    bool? showTodayResults,
  }) {
    return VotesState(
      votes: votes ?? this.votes,
      todayCandidats: todayCandidats ?? this.todayCandidats,
      showTodayResults: showTodayResults ?? this.showTodayResults,
    );
  }

  @override
  List<Object?> get props => [votes, todayCandidats, showTodayResults];
}

class VotesCubit extends Cubit<VotesState> {
  final VotesRepo repo = locator.get();

  VotesCubit() : super(VotesState.initial());

  init() async {
    unawaited(repo.remote.attendVoting());

    emit(state.copyWith(
      showTodayResults: await repo.cache.isTodayOpen(),
    ));
  }

  load(List<VoteModel> votes) {
    emit(state.copyWith(votes: votes));
  }

  final _listeners = CompositeSubscription();

  @override
  Future<void> close() {
    _listeners.clear();
    return super.close();
  }

  Future<void> fetchCandidats() async {
    final candidats =
        await locator.get<VotesRepo>().remote.getAvailableCandidats();

    final habitsFutures = candidats.map((c) async {
      return MapEntry(
        c,
        await locator.get<HabitRepo>().remote.getCandidateHabits(c),
      );
    }).toList();

    final habits = await Future.wait(habitsFutures);

    final habitPerUser = habits.map((e) {
      final habit = e.value.firstOrNull;
      if (habit != null) {
        return MapEntry(
          e.key,
          habit,
        );
      }
      return null;
    }).where((e) => e != null);

    final candidatModels = await Future.wait(habitPerUser.map((e) async {
      final checkins = await locator
          .get<TrackerRepo>()
          .remote
          .getCandidateCheckins(canditateId: e!.key, habitId: e.value.id);

      return CandidatModel(checkins: checkins, habit: e.value, id: e.key);
    }));

    emit(state.copyWith(
      todayCandidats: candidatModels,
    ));
  }

  voteOn(CandidatModel candidat, bool positive) async {
    await repo.remote.voteOn(
      candidatId: candidat.id,
      habitId: candidat.habit.id,
      positive: positive,
    );
  }

  showVoteResults() async {
    await repo.cache.openToday();
    emit(state.copyWith(
      showTodayResults: true,
    ));
  }
}

extension SyncWithHabit on VotesCubit {
  Future<void> syncWithHabit(BuildContext context) async {
    final habitStream = context
        .read<HabitTrackerCubit>()
        .stream
        .map((e) => e.habit)
        .distinctUnique()
        .whereNotNull();

    _listeners.add(habitStream.listen((habit) async {
      final votes = await repo.getVotesByHabitId(habit.id);

      if (votes.isNotEmpty) {
        load(votes);
      }
    }));
  }
}
