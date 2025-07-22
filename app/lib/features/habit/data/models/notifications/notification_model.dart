import 'dart:math';

import 'package:habitvote/features/habit/data/models/habit_model.dart';

abstract class HabitNotificationModel {
  final DateTime dateTime;

  final int id;
  String get _type;

  String title(HabitModel habit);
  String description(HabitModel habit);

  HabitNotificationModel(this.dateTime) : id = Random().nextInt(999999);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "dateTime": dateTime.toIso8601String(),
      "type": _type,
    };
  }

  factory HabitNotificationModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final dateTime = DateTime.parse(json['dateTime'] as String);

    switch (type) {
      case "5min":
        return Before5MinHabitNotificationModel(dateTime);
      case "random":
        return RandomWindownHabitNotificationModel(dateTime);
      default:
        throw Exception("Unknown notification type: $type");
    }
  }
}

class Before5MinHabitNotificationModel extends HabitNotificationModel {
  Before5MinHabitNotificationModel(super.dateTime);

  @override
  String get _type => "5min";

  @override
  String toString() =>
      'Before5MinHabitNotificationModel(id: $id, dateTime: $dateTime)';

  @override
  String description(HabitModel habit) {
    return 'Reminder to check-in for your habit: ${habit.name}';
  }

  @override
  String title(HabitModel habit) {
    return 'Habit Reminder: ${habit.name}';
  }
}

class RandomWindownHabitNotificationModel extends HabitNotificationModel {
  RandomWindownHabitNotificationModel(super.dateTime);

  @override
  String toString() =>
      'Before5MinHabitNotificationModel(id: $id, dateTime: $dateTime)';

  @override
  String description(HabitModel habit) {
    return 'Reminder to check-in for your habit: ${habit.name}';
  }

  @override
  String title(HabitModel habit) {
    return 'Habit Reminder: ${habit.name}';
  }

  @override
  String get _type => "random";
}
