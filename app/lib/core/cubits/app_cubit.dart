import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/services/feature_flag_service.dart';
import 'package:habitvote/services/notification_service.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AppState extends Equatable {
  const AppState({
    required this.isNotificationEnabled,
    required this.themeMode,
  });

  factory AppState.initial() {
    return const AppState(
      isNotificationEnabled: false,
      themeMode: ThemeMode.system,
    );
  }

  final bool isNotificationEnabled;
  final ThemeMode themeMode;

  @override
  List<Object> get props => [isNotificationEnabled, themeMode];

  AppState copyWith({
    bool? isNotificationEnabled,
    ThemeMode? themeMode,
  }) {
    return AppState(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  final notifications = locator.get<NotificationService>();

  AppCubit() : super(AppState.initial()) {
    if (!Platform.isAndroid) return;

    recheckNotifications();

    locator
        .get<FeatureFlagService>()
        .get("welcome-screen-3-items-title")
        .then((a) {
      print(a);
    });
  }

  void updateTheme(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
  }
}

extension AppCubitNotificationExtension on AppCubit {
  void enableNotifications() async {
    await notifications.registerDevice();
    if (!(await recheckNotifications())) {
      Posthog().capture(eventName: 'notifications_refused');
    }
  }

  Future<bool> recheckNotifications() async {
    final isEnabled = await notifications.isNotificationEnabled();
    emit(state.copyWith(isNotificationEnabled: isEnabled));

    return isEnabled;
  }

  void scheduleHabitReminderNotifications(HabitModel habit) async {}
}
