import 'dart:async';
import 'dart:convert';

import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/connectivity.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/habit/data/sources/habit_cache.dart';
import 'package:habitvote/features/habit/data/sources/habit_remote.dart';
import 'package:habitvote/services/kv_service.dart';

class HabitRepo {
  final HabitCache cache;
  final HabitRemote remote;
  final KvService kv = locator.get(); // Get KvService instance

  HabitRepo({required this.cache, required this.remote}) {
    isOnline.listen((status) {
      if (status) _syncPendingHabits();
    });
  }

  Future<HabitModel?> getActive({fresh = false}) async {
    final remoteFuture = remote.getAll().then((val) {
      unawaited(() async {
        await cache.clear();
        for (final record in val) {
          await cache.create(record);
        }
      }());

      return val;
    });

    final futures = [remoteFuture, if (!fresh) cache.getAll()];
    final records = await Future.any(futures);

    return records.where((e) => e.isActive).firstOrNull;
  }

  Future<void> create(HabitModel habit) async {
    // Always save to cache first
    await cache.create(habit);

    try {
      await remote.create(habit);
      // Optional: If successful, ensure it's not in the pending list
      await kv.removePendingHabitId(habit.id);
    } catch (e) {
      await kv.addPendingHabitId(habit.id);
    }
  }

  Future<void> update(HabitModel habit) async {
    // Update in cache first
    await cache.update(habit);

    try {
      await remote.update(habit);
      // Optional: If successful, ensure it's not in the pending list
      await kv.removePendingHabitId(habit.id);
    } catch (e) {
      await kv.addPendingHabitId(habit.id);
    }
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

extension HabitRepoSync on HabitRepo {
  Future<void> _syncPendingHabits() async {
    // todo make sure this also handle updates
    final pendingIds = await kv.getPendingHabitIds();
    if (pendingIds.isEmpty) {
      print("No pending habits to sync.");
      return;
    }

    print("Syncing ${pendingIds.length} pending habits...");

    for (final habitId in List<String>.from(pendingIds)) {
      // Iterate over a copy
      try {
        final habit = await cache.get(habitId); // Assuming cache has getById
        if (habit != null) {
          print("Attempting to sync habit: ${habit.id}");
          await remote.create(habit);
          // If remote creation succeeds, remove from pending list
          await kv.removePendingHabitId(habitId);
          print("Successfully synced habit: ${habit.id}");
        } else {
          // Habit not found in cache, likely an inconsistency. Remove from pending.
          print(
              "Pending habit $habitId not found in cache. Removing from pending list.");
          await kv.removePendingHabitId(habitId);
        }
      } catch (e) {
        // Handle sync error for this specific habit, leave it in the pending list
        print("Failed to sync habit $habitId: $e");
        // Optionally implement retry logic or logging here
      }
    }
    print("Sync process finished.");
  }
}

extension SyncExtension on KvService {
  Future<List<String>> getPendingHabitIds() async {
    final jsonString = await getString("pendingHabits");
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      // Decode the JSON string back into a List<dynamic> and cast to List<String>
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<String>().toList();
    } catch (e) {
      // Handle potential decoding errors, e.g., corrupted data
      print("Error decoding pending habit IDs: $e");
      await clearPendingHabitIds(); // Clear corrupted data
      return [];
    }
  }

  Future<void> addPendingHabitId(String habitId) async {
    final currentIds = await getPendingHabitIds();
    if (!currentIds.contains(habitId)) {
      currentIds.add(habitId);
      await setString("pendingHabits", jsonEncode(currentIds));
    }
  }

  Future<void> removePendingHabitId(String habitId) async {
    final currentIds = await getPendingHabitIds();
    if (currentIds.remove(habitId)) {
      await setString("pendingHabits", jsonEncode(currentIds));
    }
  }

  Future<void> clearPendingHabitIds() async {
    await remove("pendingHabits");
  }
}
