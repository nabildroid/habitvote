import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/habit/utils/onboarding_habit_register_extension.dart';
import 'package:habitvote/features/onboarding/application/cubits/onboarding_cubit.dart';
import 'package:habitvote/features/user/data/auth_service.dart';
import 'package:habitvote/features/user/utils/onboarding_signup_extension.dart';

import '../widgets/brilliant_ok_button.dart';

class CreateAccountSlide extends StatelessWidget {
  const CreateAccountSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text("Create Account",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          Spacer(),
          SizedBox(height: 20),
          Text(
            "137 Habit trackers sign in today",
          ),
          SizedBox(height: 4),
          BrilliantOkButton(
            tag: "continue",
            onPressed: () async {
              await context.read<OnboardingCubit>().signupWithGoogle();
              await context.read<OnboardingCubit>().registerHabit();

              await context.read<HabitTrackerCubit>().init(fresh: true);

              context.go("/home");
            },
            text: "Sign in with Google",
          ),
          SizedBox(height: 16),
          // TextButton(
          //   child: Text(
          //     "Skip",
          //   ),
          //   onPressed: () {},
          // ),
          Spacer(),
        ],
      ),
    );
  }
}
