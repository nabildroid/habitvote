import 'package:sembast/sembast_io.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';

class HabitCache {
  final Database _db = locator.get();
  final _habits = stringMapStoreFactory.store("habits");

  Future<void> create(HabitModel habit) async {
    await _habits.record(habit.id).put(_db, habit.toJson());
  }

  Future<void> delete(String id) async {
    await _habits.record(id).delete(_db);
  }

  Future<HabitModel?> get(String id) async {
    final record = await _habits.record(id).get(_db);
    if (record == null) return null;
    return HabitModel.fromJson(record);
  }

  Future<List<HabitModel>> getAll() async {
    final records = await _habits.find(_db);
    return records.map((record) => HabitModel.fromJson(record.value)).toList();
  }

  Future<void> clear() async {
    await _habits.delete(_db);
  }
}

extension HabitLoader on HabitCache {
  Future<void> load() async {}
}
