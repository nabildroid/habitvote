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

  const OnboardingState({
    this.age,
    this.gender,
    this.commitmentLevel,
    this.usedOtherApps,
    this.habitType,
    this.selectedHabit,
  });

  OnboardingState copyWith({
    String? age,
    String? gender,
    int? commitmentLevel,
    bool? usedOtherApps,
    String? habitType,
    String? selectedHabit,
  }) {
    return OnboardingState(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      commitmentLevel: commitmentLevel ?? this.commitmentLevel,
      usedOtherApps: usedOtherApps ?? this.usedOtherApps,
      habitType: habitType ?? this.habitType,
      selectedHabit: selectedHabit ?? this.selectedHabit,
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
    };
  }
}
