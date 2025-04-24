import 'package:sembast/sembast_io.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/tracker/data/models/habit_model.dart';

class HabitCache {
  final Database _db = locator.get();
  final _habits = stringMapStoreFactory.store("habits");

  Future<void> put(HabitModel habit) async {
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
  Future<void> load() async {
    final defaultHabits = [
      HabitModel(
        id: "1",
        name: "Drink Water",
        description: "Stay hydrated by drinking enough water.",
        isNegative: false,
      ),
      HabitModel(
        id: "2",
        name: "Exercise",
        description: "Engage in physical activity regularly.",
        isNegative: false,
      ),
      HabitModel(
        id: "3",
        name: "Read Books",
        description: "Spend time reading books for knowledge and relaxation.",
        isNegative: false,
      ),
    ];

    for (var habit in defaultHabits) {
      await put(habit);
    }
  }
}
