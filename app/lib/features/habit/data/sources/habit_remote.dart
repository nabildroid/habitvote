import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

class HabitRemote extends AuthorizedDio {
  HabitRemote() : super(rawHttp: AuthorizedDio.defaultHttp) {
    locator.get<AuthService>().subscribeToToken(this);
  }

  Future<void> create(HabitModel habit) async {
    await (await http).post(
      "/habits",
      data: habit.toJson(),
    );
  }

  Future<List<HabitModel>> getAll() async {
    final response = await (await http).get("/habits");
    final List<dynamic> data = response.data;
    return data.map((e) => HabitModel.fromJson(e)).toList();
  }
}
