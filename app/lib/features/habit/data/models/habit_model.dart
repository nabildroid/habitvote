import "package:equatable/equatable.dart";
import "package:flutter/material.dart";
import "package:uuid/uuid.dart";

import "package:habitvote/shared/dates_utils.dart";

/// Model class representing a habit
class HabitModel extends Equatable {
  /// Unique identifier for the habit
  final String id;

  /// Short name/title of the habit
  final String name;

  /// if Gemini think of the name as something bad, the public name is the good (AI generated) version
  final String publicName;

  /// Brief description of the habit
  final String description;

  /// Whether this is a negative habit to eliminate (true) or positive habit to acquire (false)
  final bool isNegative;

  final bool isActive = true;

  final TimeOfDay checkinOpenWindow;
  final TimeOfDay checkinCloseWindow;
  final List<TimeOfDay> triggers;

  HabitModel({
    String? id,
    required this.name,
    required this.description,
    required this.isNegative,
    required this.publicName,
    required this.checkinOpenWindow,
    required this.checkinCloseWindow,
    required this.triggers,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4();

  /// Convert habit to a map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isNegative': isNegative,
      'publicName': publicName,
      'checkinOpenWindow': checkinOpenWindow.toTimeString(),
      'checkinCloseWindow': checkinCloseWindow.toTimeString(),
      'triggers': triggers.map((e) => e.toTimeString()).toList(),
    };
  }

  /// Create a habit from a map (JSON deserialization)
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      publicName: json['publicName'],
      name: json['name'],
      description: json['description'],
      isNegative: json['isNegative'],
      checkinOpenWindow:
          TimeInDayParser.parseFromString(json['checkinOpenWindow']),
      checkinCloseWindow:
          TimeInDayParser.parseFromString(json['checkinCloseWindow']),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => TimeInDayParser.parseFromString(e as String))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, description, isNegative];
}
