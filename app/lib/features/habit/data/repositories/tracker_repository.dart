import 'dart:async';

import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/checkin_model.dart';
import 'package:habitvote/features/habit/data/sources/tracker_remote.dart';
import 'package:habitvote/services/kv_service.dart';

import '../sources/tracker_cache.dart';

class TrackerRepo {
  final TrackerCache cache;
  final TrackerRemote remote;

  final KvService kv = locator.get(); // Get KvService instance

  TrackerRepo({required this.cache, required this.remote});

  Future<List<CheckinModel>?> getAll(String habitId, {fresh = false}) async {
    final remoteFuture = remote.getAll(habitId: habitId).then((val) {
      unawaited(() async {
        await cache.clear();
        for (final record in val) {
          await cache.create(record);
        }
      }());

      return val;
    });

    final futures = [remoteFuture, if (!fresh) cache.getAll(habitId: habitId)];
    final records = await Future.any(futures);

    return records;
  }

  Future<void> create(CheckinModel checkin) async {
    // Always save to cache first
    await cache.create(checkin);

    try {
      await remote.create(checkin);
      // Optional: If successful, ensure it's not in the pending list
      // await kv.removePendingHabitId(checkin.id);
    } catch (e) {
      // await kv.addPendingHabitId(checkin.id);
    }
  }
}
