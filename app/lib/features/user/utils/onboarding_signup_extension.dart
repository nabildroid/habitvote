import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/onboarding/application/cubits/onboarding_cubit.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

extension OnboardingSignupExtension on OnboardingCubit {
  Future<void> signupWithGoogle() async {
    await locator.get<AuthService>().loginWithGoogle();
  }
}
