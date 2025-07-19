import 'package:equatable/equatable.dart';

class CandidatModel extends Equatable {
  final String id;

  final String habitId;
  final String habitName;

  final List<DateTime> checkins;

  const CandidatModel({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.checkins,
  });

  @override
  List<Object?> get props => [id, habitId, habitName, ...checkins];

  factory CandidatModel.fromJson(Map<String, dynamic> json) {
    return CandidatModel(
      id: json['id'],
      habitId: json['habitId'],
      habitName: json['habitName'],
      checkins: (json['checkins'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );
  }
}
