import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/vote/data/models/candidat_model.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';
import 'package:habitvote/features/vote/data/repositories/votes_repository.dart';
import 'package:habitvote/shared/dates_utils.dart';
import 'package:habitvote/shared/utils.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:rxdart/rxdart.dart';

class VotesState extends Equatable {
  final List<CandidatModel> todayCandidats;

  final List<String> votedOnToday;

  final VoteModel? today;
  final bool showTodayResults;

  VotesState({
    required this.todayCandidats,
    required this.showTodayResults,
    required this.votedOnToday,
    this.today,
  });

  factory VotesState.initial() {
    return VotesState(
      votedOnToday: [],
      showTodayResults: false,
      todayCandidats: [],
    );
  }

  // copyWith method to create a new instance of VotesState with updated values
  VotesState copyWith({
    List<CandidatModel>? todayCandidats,
    bool? showTodayResults,
    List<String>? votedOnToday,
    VoteModel? today,
  }) {
    return VotesState(
      todayCandidats: todayCandidats ?? this.todayCandidats,
      showTodayResults: showTodayResults ?? this.showTodayResults,
      votedOnToday: votedOnToday ?? this.votedOnToday,
      today: today ?? this.today,
    );
  }

  @override
  List<Object?> get props =>
      [today, todayCandidats, showTodayResults, votedOnToday];
}

class VotesCubit extends HydratedCubit<VotesState> {
  final VotesRepo repo = locator.get();

  VotesCubit() : super(VotesState.initial());

  init() async {
    emit(state.copyWith(
      showTodayResults: await repo.cache.isTodayOpen(),
    ));
  }

  load(VoteModel vote) async {
    emit(state.copyWith(today: vote));
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

    emit(state.copyWith(
      todayCandidats: candidats,
    ));
  }

  voteOn(CandidatModel candidat, bool positive) async {
    await repo.remote.voteOn(
      candidatId: candidat.id,
      habitId: candidat.habitId,
      positive: positive,
    );

    emit(state.copyWith(
      votedOnToday: [...state.votedOnToday, candidat.id],
    ));
    logVote(candidat, positive);
  }

  showVoteResults() async {
    await repo.cache.openToday();
    emit(state.copyWith(
      showTodayResults: true,
    ));

    logShowResults();
  }

  @override
  VotesState? fromJson(Map<String, dynamic> json) {
    final todayString = DateTime.now().toIso8601String().split('T').first;

    return VotesState.initial().copyWith(
      votedOnToday: List<String>.from(json['votedOn_$todayString'] ?? []),
    );
  }

  @override
  Map<String, dynamic>? toJson(VotesState state) {
    final todayString = DateTime.now().toIso8601String().split('T').first;
    return {"votedOn_$todayString": state.votedOnToday};
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
      final vote = await repo.getTodayVoteByHabitId(habit.id);

      removeSplashScreen(Duration(milliseconds: 100));

      if (vote != null) {
        load(vote);
      }
    }));
  }
}

extension _Analytics on VotesCubit {
  void logVote(CandidatModel checkin, bool isPositive) {
    Posthog().capture(eventName: 'voteOn', properties: {
      'habit_id': checkin.habitId,
      'candidat_id': checkin.id,
      'is_positive': isPositive,
    });
  }

  void logShowResults() {
    Posthog().capture(eventName: 'showVoteResults');
  }
}
