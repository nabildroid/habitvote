import "package:equatable/equatable.dart";
import "package:uuid/uuid.dart";

/// Model class representing a habit
class HabitModel extends Equatable {
  /// Unique identifier for the habit
  final String id;

  /// Short name/title of the habit
  final String name;

  /// Brief description of the habit
  final String description;

  /// Whether this is a negative habit to eliminate (true) or positive habit to acquire (false)
  final bool isNegative;

  HabitModel({
    String? id,
    required this.name,
    required this.description,
    required this.isNegative,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4();

  /// Convert habit to a map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isNegative': isNegative,
    };
  }

  /// Create a habit from a map (JSON deserialization)
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isNegative: json['isNegative'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, isNegative];
}
