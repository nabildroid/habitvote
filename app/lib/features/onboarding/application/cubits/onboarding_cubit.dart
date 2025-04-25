import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class OnboardingState extends Equatable {
  final String? nativeLanguage;
  final String? targetLanguage;
  final int? languageLevel;
  final String? age;
  final String? gender;
  final String? selectedTopic;

  const OnboardingState({
    this.nativeLanguage,
    this.targetLanguage,
    this.languageLevel,
    this.age,
    this.gender,
    this.selectedTopic,
  });

  OnboardingState copyWith({
    String? identifyAs,
    String? grade,
    List<String>? focusOn,
    int? desiredDuration,
    bool? skipLearning,
    String? nativeLanguage,
    String? targetLanguage,
    int? languageLevel,
    String? age,
    String? gender,
    String? selectedTopic,
  }) {
    return OnboardingState(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      languageLevel: languageLevel ?? this.languageLevel,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      selectedTopic: selectedTopic ?? this.selectedTopic,
    );
  }

  @override
  List<Object?> get props => [
        nativeLanguage,
        targetLanguage,
        languageLevel,
        age,
        gender,
        selectedTopic,
      ];
}

class OnboardingCubit extends HydratedCubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState());

  // New methods for onboarding screen
  void setNativeLanguage(String language) {
    emit(state.copyWith(nativeLanguage: language));
  }

  void setTargetLanguage(String language) {
    emit(state.copyWith(targetLanguage: language));
  }

  void setLanguageLevel(int level) {
    emit(state.copyWith(languageLevel: level));

    // by hear, we can register the user!
  }

  void setAge(String age) {
    emit(state.copyWith(age: age));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  @override
  void onChange(Change<OnboardingState> change) {
    super.onChange(change);
  }

  void setSelectedRootFlow(dynamic rootFlow) {}

  void setSelectedTopic(String topic) {
    emit(state.copyWith(selectedTopic: topic));
  }

  @override
  OnboardingState? fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      nativeLanguage: json["nativeLanguage"],
      targetLanguage: json["targetLanguage"],
      languageLevel: json["languageLevel"],
      age: json["age"],
      gender: json["gender"],
      selectedTopic: json["selectedTopic"],
    );
  }

  @override
  Map<String, dynamic>? toJson(OnboardingState state) {
    return {
      "nativeLanguage": state.nativeLanguage,
      "targetLanguage": state.targetLanguage,
      "languageLevel": state.languageLevel,
      "age": state.age,
      "gender": state.gender,
      "selectedTopic": state.selectedTopic,
    };
  }
}
