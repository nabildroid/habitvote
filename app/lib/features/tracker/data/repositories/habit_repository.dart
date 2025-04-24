import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:habitvote/features/tracker/data/models/habit_model.dart';
import 'package:habitvote/features/tracker/data/sources/habit_cache.dart';
import "package:rxdart/rxdart.dart";

class HabitRepo {
  final HabitCache cache;

  final isOnline = BehaviorSubject<bool>.seeded(false);
  HabitRepo({required this.cache}) {
    // locator.get<UserRepository>().subscribeToToken(this);

    Connectivity().onConnectivityChanged.listen((status) => isOnline.add(
          !status.contains(ConnectivityResult.none),
        ));
  }

  Future<List<HabitModel>> getAll() async {
    final records = await cache.getAll();

    if (records.isEmpty) {
      await cache.load();
      final records = await cache.getAll();
      return records;
    }
    return records;
  }
}
