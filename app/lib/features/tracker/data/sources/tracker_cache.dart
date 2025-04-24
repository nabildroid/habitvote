import 'package:sembast/sembast_io.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/tracker/data/models/checkin_model.dart';

class TrackerCache {
  final Database _db = locator.get();
  final _tracker = stringMapStoreFactory.store("habit_tracking");

  Future<List<CheckinModel>> getCheckins({required String habitId}) async {
    final record = await _tracker.record(habitId).get(_db);
    if (record == null) return [];
    final list =
        (record['checkins'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((e) => CheckinModel.fromJson(e)).toList();
  }

  Future<void> put(CheckinModel checkin) async {
    final key = checkin.habitId;
    final record = await _tracker.record(key).get(_db);
    final item = checkin.toJson();
    if (record == null) {
      await _tracker.record(key).put(_db, {
        'checkins': [item]
      });
    } else {
      final existingItems =
          (record['checkins'] as List<dynamic>).cast<Map<String, dynamic>>();
      final list = List<Map<String, dynamic>>.from(existingItems);
      list.add(item);
      await _tracker.record(key).put(_db, {'checkins': list});
    }
  }

  Future<void> delete(String id, {required String habitId}) async {
    final record = await _tracker.record(habitId).get(_db);
    if (record == null) return;

    final existingItems =
        (record['checkins'] as List<dynamic>).cast<Map<String, dynamic>>();
    final list = List<Map<String, dynamic>>.from(existingItems);
    list.removeWhere((e) => e['id'] == id);
    await _tracker.record(habitId).put(_db, {'checkins': list});
  }

  Future<void> deleteAll({required String habitId}) async {
    await _tracker.record(habitId).delete(_db);
  }

  Future<void> clear() async {
    await _tracker.delete(_db);
  }
}
