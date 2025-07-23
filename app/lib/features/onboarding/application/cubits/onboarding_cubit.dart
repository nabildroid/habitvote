import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class OnboardingState extends Equatable {
  final String? age;
  final String? gender;
  final int? commitmentLevel; // Renamed from languageLevel
  final bool? usedOtherApps; // New property
  final String? habitType; // New property: "good" or "bad"
  final String? selectedHabit; // New property
  final bool isCustomHabit; // New property

  final TimeOfDay openWindow;
  final TimeOfDay closeWindow;
  final List<TimeOfDay> triggers;

  const OnboardingState({
    this.age,
    this.gender,
    this.commitmentLevel,
    this.usedOtherApps,
    this.habitType,
    this.selectedHabit,
    this.isCustomHabit = false,
    this.openWindow = const TimeOfDay(hour: 19, minute: 0),
    this.closeWindow = const TimeOfDay(hour: 24, minute: 0),
    this.triggers = const [],
  });

  OnboardingState copyWith({
    String? age,
    String? gender,
    int? commitmentLevel,
    bool? usedOtherApps,
    String? habitType,
    String? selectedHabit,
    bool? isCustomHabit,
    TimeOfDay? openWindow,
    TimeOfDay? closeWindow,
    List<TimeOfDay>? triggers,
  }) {
    return OnboardingState(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      commitmentLevel: commitmentLevel ?? this.commitmentLevel,
      usedOtherApps: usedOtherApps ?? this.usedOtherApps,
      habitType: habitType ?? this.habitType,
      selectedHabit: selectedHabit ?? this.selectedHabit,
      isCustomHabit: isCustomHabit ?? this.isCustomHabit,
      openWindow: openWindow ?? this.openWindow,
      closeWindow: closeWindow ?? this.closeWindow,
      triggers: triggers ?? this.triggers,
    );
  }

  @override
  List<Object?> get props => [
        age,
        gender,
        commitmentLevel,
        usedOtherApps,
        habitType,
        selectedHabit,
        isCustomHabit,
        openWindow,
        closeWindow,
        triggers,
      ];
}

class OnboardingCubit extends HydratedCubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  // Keep relevant methods
  void setAge(String age) {
    emit(state.copyWith(age: age));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  // Add new methods
  void setCommitmentLevel(int level) {
    emit(state.copyWith(commitmentLevel: level));
  }

  void setUsedOtherApps(bool used) {
    emit(state.copyWith(usedOtherApps: used));
  }

  void setHabitType(String type) {
    // Consider adding validation for "good" or "bad" if needed
    emit(state.copyWith(habitType: type));
  }

  void setSelectedHabit(String? habit) {
    // Allow null in case custom text is cleared
    emit(state.copyWith(selectedHabit: habit));
  }

  void setOpenWindow(TimeOfDay? time) {
    emit(state.copyWith(openWindow: time));
  }

  void setCloseWindow(TimeOfDay? time) {
    emit(state.copyWith(closeWindow: time));
  }

  void addTrigger(TimeOfDay time) {
    if (state.triggers.contains(time)) return;
    final updatedTriggers = List<TimeOfDay>.from(state.triggers);
    updatedTriggers.add(time);
    emit(state.copyWith(triggers: updatedTriggers));
  }

  @override
  void onChange(Change<OnboardingState> change) {
    super.onChange(change);
    _handleHabitChange(change);
  }

  @override
  OnboardingState? fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      age: json["age"],
      gender: json["gender"],
      commitmentLevel: json["commitmentLevel"],
      usedOtherApps: json["usedOtherApps"],
      habitType: json["habitType"],
      selectedHabit: json["selectedHabit"],
      isCustomHabit: json["isCustomHabit"] ?? false,
      openWindow: TimeOfDay(
        hour: json["openWindow"]["hour"],
        minute: json["openWindow"]["minute"],
      ),
      closeWindow: TimeOfDay(
        hour: json["closeWindow"]["hour"],
        minute: json["closeWindow"]["minute"],
      ),
      triggers: (json["triggers"] as List?)
              ?.map((e) => TimeOfDay(
                    hour: e["hour"],
                    minute: e["minute"],
                  ))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic>? toJson(OnboardingState state) {
    return {
      "age": state.age,
      "gender": state.gender,
      "commitmentLevel": state.commitmentLevel,
      "usedOtherApps": state.usedOtherApps,
      "habitType": state.habitType,
      "selectedHabit": state.selectedHabit,
      "isCustomHabit": state.isCustomHabit,
      "openWindow": {
        "hour": state.openWindow.hour,
        "minute": state.openWindow.minute,
      },
      "closeWindow": {
        "hour": state.closeWindow.hour,
        "minute": state.closeWindow.minute,
      },
      "triggers": state.triggers
          ?.map((e) => {
                "hour": e.hour,
                "minute": e.minute,
              })
          .toList(),
    };
  }
}

// the bellow code is for tracking if the user pickup a habit from a list of habits or he made it him self, or he pick it up and did a significate change
final _editCounts = Expando<int>();

extension _OnboardingCubitHabitTracking on OnboardingCubit {
  int get _editCount => _editCounts[this] ?? 0;
  set _editCount(int value) => _editCounts[this] = value;

  void _handleHabitChange(Change<OnboardingState> change) {
    final oldHabit = change.currentState.selectedHabit;
    final newHabit = change.nextState.selectedHabit;

    if (oldHabit == newHabit) return;

    final oldIsCustom = change.currentState.isCustomHabit;
    bool newIsCustom = oldIsCustom;

    if (newHabit == null || newHabit.isEmpty) {
      // Habit cleared
      newIsCustom = false;
      _editCount = 0;
    } else if ((oldHabit == null || oldHabit.isEmpty) && newHabit.isNotEmpty) {
      // Habit was picked from a list or first character typed
      newIsCustom = newHabit.length == 1;
      _editCount = 0;
    } else if (oldHabit != null && !oldIsCustom) {
      // Tracking edits on a picked habit
      if ((newHabit.length - oldHabit.length).abs() < 10) {
        _editCount++;
        if (_editCount > 5) {
          newIsCustom = true;
        }
      } else {
        // A large change still makes it custom immediately
        newIsCustom = true;
      }
    }

    if (newIsCustom != oldIsCustom) {
      emit(state.copyWith(isCustomHabit: newIsCustom));
    }
  }
}
