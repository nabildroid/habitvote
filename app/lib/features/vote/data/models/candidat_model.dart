import 'package:equatable/equatable.dart';
import 'package:habitvote/features/habit/data/models/checkin_model.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';

class CandidatModel extends Equatable {
  final String id;

  final HabitModel habit;

  final List<CheckinModel> checkins;

  const CandidatModel({
    required this.id,
    required this.habit,
    required this.checkins,
  });

  @override
  List<Object?> get props => [id, habit.id, checkins.length];
}
