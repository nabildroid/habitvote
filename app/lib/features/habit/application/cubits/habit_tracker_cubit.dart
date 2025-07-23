import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/application/cubits/notification_habit_cubit_extention.dart';
import 'package:habitvote/features/habit/data/models/checkin_model.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/habit/data/repositories/habit_repository.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:rxdart/rxdart.dart';

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

  final durationToOpenWindow = BehaviorSubject<Duration>.seeded(Duration.zero);

  HabitTrackerCubit()
      : super(HabitTrackerState(
          checkins: [],
        ));

  init({fresh = false}) async {
    final habit = await habitRepo.getActive(fresh: fresh);
    if (habit == null) return;
    emit(state.copyWith(habit: habit));
    this._startTimer();

    final checkins = await trackerRepo.getAll(habit.id, fresh: fresh);
    emit(state.copyWith(checkins: checkins));

    if (!(await isNotificationScheduled())) {
      rescheduleNotifcations();
    }
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

    rescheduleNotifcations();

    logCheckin(checkin);
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

    rescheduleNotifcations();
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

  @override
  Future<void> close() {
    this._cancelTimer();
    durationToOpenWindow.close();
    return super.close();
  }
}

extension HabitTimerExtension on HabitTrackerCubit {
  static Timer? _timer;
  static DateTime? _timerStartedAt;

  void _startTimer() {
    _cancelTimer();
    _timerStartedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDuration();
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _timerStartedAt = null;
  }

  void _updateDuration() {
    final habit = state.habit;
    if (habit?.checkinOpenWindow == null || habit?.checkinCloseWindow == null) {
      durationToOpenWindow.add(Duration.zero);
      return;
    }

    final now = DateTime.now();
    final openTime = habit!.checkinOpenWindow;
    final closeTime = habit.checkinCloseWindow;

    var openDateTime =
        DateTime(now.year, now.month, now.day, openTime.hour, openTime.minute);
    var closeDateTime = DateTime(
        now.year, now.month, now.day, closeTime.hour, closeTime.minute);

    if (closeDateTime.isBefore(openDateTime)) {
      if (now.isBefore(closeDateTime)) {
        openDateTime = openDateTime.subtract(const Duration(days: 1));
      } else {
        closeDateTime = closeDateTime.add(const Duration(days: 1));
      }
    }

    if (now.isAfter(openDateTime) && now.isBefore(closeDateTime)) {
      if (durationToOpenWindow.value != Duration.zero &&
          _timerStartedAt != null) {
        final waitedDuration = now.difference(_timerStartedAt!);
        logTimerWaited(waitedDuration);
      }
      durationToOpenWindow.add(Duration.zero);
    } else {
      DateTime nextOpenDateTime;
      if (now.isBefore(openDateTime)) {
        nextOpenDateTime = openDateTime;
      } else {
        nextOpenDateTime = openDateTime.add(const Duration(days: 1));
      }
      durationToOpenWindow.add(nextOpenDateTime.difference(now));
    }
  }
}

extension HabitEditingExtension on HabitTrackerCubit {
  Future<void> updateHabitDetails({String? name, bool? isNegative}) async {
    if (state.habit == null) return;
    final updatedHabit = state.habit!.copyWith(
      name: name,
      publicName: name,
      description: name,
      isNegative: isNegative,
    );
    emit(state.copyWith(habit: updatedHabit));
    await habitRepo.update(updatedHabit);
    rescheduleNotifcations();
    logUpdateHabitDetails(updatedHabit);
  }

  Future<void> updateCheckinWindow({TimeOfDay? open, TimeOfDay? close}) async {
    if (state.habit == null) return;
    final updatedHabit = state.habit!.copyWith(
      checkinOpenWindow: open,
      checkinCloseWindow: close,
    );
    emit(state.copyWith(habit: updatedHabit));
    _updateDuration();
    await habitRepo.update(updatedHabit);
    rescheduleNotifcations();

    logUpdateCheckinWindow(updatedHabit);
  }

  Future<void> updateTriggers(List<TimeOfDay> triggers) async {
    if (state.habit == null) return;
    final updatedHabit = state.habit!.copyWith(triggers: triggers);
    emit(state.copyWith(habit: updatedHabit));
    await habitRepo.update(updatedHabit);
  }
}

extension _Analytics on HabitTrackerCubit {
  void logCheckin(CheckinModel checkin) {
    Posthog().capture(eventName: 'checkin', properties: {
      'habit_id': checkin.habitId,
      'is_done': checkin.isDone,
    });
  }

  void logTimerWaited(Duration duration) {
    Posthog().capture(eventName: 'timer_waited', properties: {
      'duration_seconds': duration.inSeconds,
    });
  }

  void logUpdateHabitDetails(HabitModel habit) {
    Posthog().capture(eventName: 'update_habit_details', properties: {
      'name': habit.name,
      'is_negative': habit.isNegative,
    });
  }

  void logUpdateCheckinWindow(HabitModel habit) {
    Posthog().capture(eventName: 'update_checkin_window', properties: {
      'open': habit.checkinOpenWindow,
      'close': habit.checkinCloseWindow,
    });
  }
}
