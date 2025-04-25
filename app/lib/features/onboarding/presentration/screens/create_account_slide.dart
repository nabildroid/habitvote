import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          Spacer(),
          SizedBox(height: 20),
          Text(
            "137 Language Learners sign in today",
          ),
          SizedBox(height: 4),
          BrilliantOkButton(
            tag: "continue",
            onPressed: () async {
              // final nativeLangauge =
              //     context.read<OnboardingCubit>().state.nativeLanguage;

              // final user = await locator<UserRepository>()
              //     .loginWithGoogle(nativeLanguage: nativeLangauge);

              // await Future.delayed(Duration(seconds: 1));
              // await InAppPurchase.instance.restorePurchases();
              // context.go("/home");

              final accessToken =
                  await locator.get<AuthService>().loginWithGoogle();

              print(accessToken);

              // print(user);
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
