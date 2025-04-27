import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/checkin_model.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/habit/data/repositories/habit_repository.dart';

import '../../data/repositories/tracker_repository.dart';

class HabitTrackerState extends Equatable {
  final HabitModel? habit;
  final List<CheckinModel> checkins;

  const HabitTrackerState({
    this.habit,
    this.checkins = const [],
  });

  HabitTrackerState copyWith({
    HabitModel? habit,
    List<CheckinModel>? checkins,
  }) {
    return HabitTrackerState(
      habit: habit ?? this.habit,
      checkins: checkins ?? this.checkins,
    );
  }

  addCheckin(CheckinModel checkin) {
    final checkins = List<CheckinModel>.from(this.checkins);
    checkins.add(checkin);
    return copyWith(checkins: checkins);
  }

  removeCheckin(CheckinModel checkin) {
    final checkins = List<CheckinModel>.from(this.checkins);
    checkins.remove(checkin);
    return copyWith(checkins: checkins);
  }

  CheckinModel? get todayCheckin {
    if (checkins.isEmpty) return null;
    final today = DateTime.now();
    return checkins
        .where(
          (e) =>
              e.date.year == today.year &&
              e.date.month == today.month &&
              e.date.day == today.day,
        )
        .firstOrNull;
  }

  @override
  List<Object?> get props => [habit, checkins];
}

class HabitTrackerCubit extends Cubit<HabitTrackerState> {
  final trackerRepo = locator.get<TrackerRepo>();
  final habitRepo = locator.get<HabitRepo>();
  HabitTrackerCubit()
      : super(HabitTrackerState(
          habit: HabitModel(
            id: 'HABIT',
            name: 'Reading',
            description: 'Reading new books',
            publicName: 'Reading',
            isNegative: false,
            createdAt: DateTime.now(),
          ),
          checkins: [],
        ));

  init({fresh = false}) async {
    final habit = await habitRepo.getActive(fresh: fresh);
    emit(state.copyWith(habit: habit));

    final checkins = await trackerRepo.getAll(habit!.id, fresh: fresh);
    emit(state.copyWith(checkins: checkins));
  }

  void checkIn({bool isDone = true, DateTime? date}) async {
    final checkin = CheckinModel(
      id: DateTime.now().toString(),
      habitId: state.habit?.id ?? '',
      isDone: isDone,
      createdAt: DateTime.now(),
      date: date ?? DateTime.now(),
      isMissed: false,
    );

    emit(state.addCheckin(checkin));
    await trackerRepo.create(checkin);
  }

  void undoCheckIn({DateTime? date}) {
    final today = date ?? DateTime.now();

    // Find the check-in for the specified date
    final targetCheckin = state.checkins
        .where(
          (e) =>
              e.date.year == today.year &&
              e.date.month == today.month &&
              e.date.day == today.day,
        )
        .firstOrNull;

    if (targetCheckin != null) {
      emit(state.removeCheckin(targetCheckin));
      // Update the repository cache
      trackerRepo.cache
          .delete(targetCheckin.id, habitId: targetCheckin.habitId);
    }
  }

  // Get check-in for a specific date
  CheckinModel? getCheckInForDate(DateTime date) {
    return state.checkins
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .firstOrNull;
  }
}
