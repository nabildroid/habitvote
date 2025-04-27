import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

class VotesRemote extends AuthorizedDio {
  VotesRemote() : super(rawHttp: AuthorizedDio.defaultHttp) {
    locator.get<AuthService>().subscribeToToken(this);
  }

  Future<void> attendVoting() async {
    await (await http).post("/votes/attend");
  }
}
