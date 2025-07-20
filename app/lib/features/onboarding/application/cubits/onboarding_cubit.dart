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

  final TimeOfDay openWindow;
  final TimeOfDay closeWindow;
  final List<TimeOfDay>? triggers;

  const OnboardingState({
    this.age,
    this.gender,
    this.commitmentLevel,
    this.usedOtherApps,
    this.habitType,
    this.selectedHabit,
    this.openWindow = const TimeOfDay(hour: 19, minute: 0),
    this.closeWindow = const TimeOfDay(hour: 24, minute: 0),
    this.triggers,
  });

  OnboardingState copyWith({
    String? age,
    String? gender,
    int? commitmentLevel,
    bool? usedOtherApps,
    String? habitType,
    String? selectedHabit,
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
    final updatedTriggers = List<TimeOfDay>.from(state.triggers ?? []);
    updatedTriggers.add(time);
    emit(state.copyWith(triggers: updatedTriggers));
  }

  @override
  void onChange(Change<OnboardingState> change) {
    super.onChange(change);
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
