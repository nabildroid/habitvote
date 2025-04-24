import 'package:equatable/equatable.dart';

class CheckinModel extends Equatable {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isMissed; // when user forgets to checkin
  final bool isDone;
  final String? notes;
  final DateTime createdAt;

  const CheckinModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isMissed,
    required this.isDone,
    this.notes,
    required this.createdAt,
  });

  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      id: json['id'],
      habitId: json['habitId'],
      date: DateTime.parse(json['date']),
      isMissed: json['isMissed'],
      isDone: json['isDone'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isMissed': isMissed,
      'isDone': isDone,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CheckinModel copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isMissed,
    bool? isDone,
    String? notes,
    DateTime? createdAt,
    double? value,
  }) {
    return CheckinModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isMissed: isMissed ?? this.isMissed,
      isDone: isDone ?? this.isDone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, habitId, date, isMissed, isDone, notes, createdAt];
}
