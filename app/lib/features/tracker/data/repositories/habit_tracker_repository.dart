import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:habitvote/features/tracker/data/models/checkin_model.dart';
import 'package:habitvote/features/tracker/data/models/habit_model.dart';
import 'package:habitvote/features/tracker/data/sources/habit_cache.dart';
import "package:rxdart/rxdart.dart";

import '../sources/tracker_cache.dart';

class HabitTrackerRepo {
  final TrackerCache cache;

  final isOnline = BehaviorSubject<bool>.seeded(false);
  HabitTrackerRepo({required this.cache}) {
    // locator.get<UserRepository>().subscribeToToken(this);

    Connectivity().onConnectivityChanged.listen((status) => isOnline.add(
          !status.contains(ConnectivityResult.none),
        ));
  }

  Future<List<CheckinModel>> getCheckins({
    required String habitId,
  }) async {
    final records = await cache.getCheckins(
      habitId: habitId,
    );

    return records;
  }
}
