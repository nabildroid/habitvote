import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/user/data/auth_service.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';

class VotesRemote extends AuthorizedDio {
  VotesRemote() : super(rawHttp: AuthorizedDio.defaultHttp) {
    locator.get<AuthService>().subscribeToToken(this);
  }

  Future<void> attendVoting() async {
    await (await http).post("/votes/attend");
  }

  Future<List<VoteModel>> getAll() async {
    final response = await (await http).get("/votes");
    final data = List.from(response.data);
    return data.map((e) => VoteModel.fromJson(e)).toList();
  }

  Future<List<VoteModel>> getByHabitId(String habitId) async {
    final all = await getAll();
    return all.where((e) => e.habitId == habitId).toList();
  }

  Future<List<String>> getAvailableCandidats() async {
    final response = await (await http).get("/votes/candidates");

    final data = List<String>.from(response.data["available"]);

    return data;
  }

  Future<void> voteOn({
    required String candidatId,
    required String habitId,
    required bool positive,
  }) async {
    final response = await (await http).post(
      "/votes/on/$candidatId/$habitId",
      data: {
        "decision": positive ? "up" : "down",
      },
    );
  }

  Future<void> activate(String voteId) async {
    final response = await (await http).post(
      "/votes/$voteId/activate",
    );
  }
}
