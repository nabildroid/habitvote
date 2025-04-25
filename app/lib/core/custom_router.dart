import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/features/onboarding/presentration/screens/ads_screen.dart';
import 'package:habitvote/features/onboarding/presentration/screens/onboarding_screen.dart';

// import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:habitvote/features/home/presentation/home_screen.dart';

final GoRouter router = GoRouter(
  observers: [
    // locator.get<RouteObserver<ModalRoute<dynamic>>>(),
    // SentryNavigatorObserver(),
    // if (Platform.isAndroid) PosthogObserver(),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    return null;
  },
  initialLocation: "/onboarding",
  routes: [
    GoRoute(
      path: "/home",
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: "favorites",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const Placeholder(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            barrierDismissible: true,
            barrierColor: Colors.black38,
            opaque: false,
            maintainState: true,
          ),
        ),
      ],
    ),
    GoRoute(
      path: "/onboarding",
      builder: (context, state) => const AdsScreen(),
    )
  ],
);
