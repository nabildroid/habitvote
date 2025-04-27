import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

Future<bool> isUserLoggedIn() async {
  final response =
      await locator.get<AuthService>().currentAccessToken.first.timeout(
            const Duration(milliseconds: 200), // todo, 200 is a random number
            onTimeout: () => null,
          );

  if (response == null) {
    return false;
  } else {
    return true;
  }
}
