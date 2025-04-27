import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/habit/data/models/checkin_model.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

class TrackerRemote extends AuthorizedDio {
  TrackerRemote() : super(rawHttp: AuthorizedDio.defaultHttp) {
    locator.get<AuthService>().subscribeToToken(this);
  }

  Future<void> create(CheckinModel checkin) async {
    await (await http).post(
      "/checkin",
      data: checkin.toJson(),
    );
  }

  Future<void> delete(String id) async {
    await (await http).delete("/checkin/$id");
  }

  Future<List<CheckinModel>> getAll({required String habitId}) async {
    final response = await (await http).get("/checkin");
    final List<dynamic> data = response.data;
    return data
        .map((e) => CheckinModel.fromJson(e))
        .where((e) => e.habitId == habitId)
        .toList();
  }
}
