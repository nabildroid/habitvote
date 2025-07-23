import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/presentations/screens/edit_habit/edit_check_in_window_screen.dart';
import 'package:habitvote/features/habit/presentations/screens/edit_habit/edit_habit.dart';
import 'package:habitvote/features/habit/presentations/screens/edit_habit/edit_habit_name_screen.dart';
import 'package:habitvote/features/habit/presentations/screens/edit_habit/edit_habit_triggers_screen.dart';
import 'package:habitvote/features/habit/presentations/screens/edit_habit/edit_notification_reminders_screen.dart';
import 'package:habitvote/features/habit/presentations/stats/stats_screen.dart';
import 'package:habitvote/features/onboarding/presentration/screens/welcome_screen.dart';
import 'package:habitvote/features/user/presentation/screens/live_presence_screen.dart';
import 'package:habitvote/features/user/utils/user_checker.dart';
import 'package:habitvote/shared/widgets/block_india.dart';

import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:habitvote/features/home/presentation/home_screen.dart';

final GoRouter router = GoRouter(
  observers: [
    locator.get<RouteObserver<ModalRoute<dynamic>>>(),
    // SentryNavigatorObserver(),
    if (Platform.isAndroid) PosthogObserver(),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    if (await BlockIndia.check()) {
      return "/block-india";
    }
    final isReady = await isUserLoggedIn();

    if (state.fullPath == null) return null;

    if (isReady) {
      if (state.fullPath!.startsWith("/home") ||
          state.fullPath!.startsWith("/favorites")) return null;
      return "/home";
    } else {
      if (state.fullPath!.startsWith("/register") ||
          state.fullPath!.startsWith("/onboarding")) return null;
      return "/onboarding";
    }
  },
  initialLocation: "/onboarding",
  routes: [
    GoRoute(
      path: "/block-india",
      builder: (context, state) => const BlockIndia(),
    ),
    GoRoute(
        path: "/home",
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: "users/presence",
            builder: (context, state) => LivePresenceScreen(),
          ),
          // GoRoute(
          //     path: "votes/today/people",
          //     builder: (context, state) => TodayVotePeopleScreen()),
          GoRoute(
              path: "habit/stats", builder: (context, state) => StatsScreen()),
          GoRoute(
            path: "habit/edit/:habitId",
            builder: (context, state) =>
                EditHabitScreen(habitId: state.pathParameters["habitId"]!),
            routes: [
              GoRoute(
                path: "name",
                builder: (context, state) => EditHabitNameScreen(
                    habitId: state.pathParameters["habitId"]!),
              ),
              GoRoute(
                path: "check-in-window",
                builder: (context, state) => EditCheckInWindowScreen(
                    habitId: state.pathParameters["habitId"]!),
              ),
              GoRoute(
                path: "triggers",
                builder: (context, state) => EditHabitTriggersScreen(
                    habitId: state.pathParameters["habitId"]!),
              ),
              GoRoute(
                path: "reminders",
                builder: (context, state) => EditNotificationRemindersScreen(
                    habitId: state.pathParameters["habitId"]!),
              ),
            ],
          ),
        ]),
    GoRoute(
      path: "/onboarding",
      builder: (context, state) => const WelcomeScreen(),
    )
  ],
);
