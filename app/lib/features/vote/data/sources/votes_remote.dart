import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/user/data/auth_service.dart';
import 'package:habitvote/features/vote/data/models/candidat_model.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';

class VotesRemote extends AuthorizedDio {
  VotesRemote() : super(rawHttp: AuthorizedDio.defaultHttp) {
    locator.get<AuthService>().subscribeToToken(this);
  }

  Future<VoteModel?> get(String habitId) async {
    try {
      final response = await (await http).get("/votes/$habitId");
      if (response.data == null) return null;

      return VoteModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<CandidatModel>> getAvailableCandidats() async {
    final response = await (await http).get("/votes/candidates");

    final data = List.from(response.data["available"])
        .map((e) => CandidatModel.fromJson(e))
        .toList();

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
}
