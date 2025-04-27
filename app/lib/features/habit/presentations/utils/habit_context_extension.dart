import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';

extension HabitContextExtension on BuildContext {
  HabitTrackerCubit get habitCubit => read<HabitTrackerCubit>();
  HabitTrackerState get habitState => read<HabitTrackerCubit>().state;
  HabitTrackerState get watchHabitState => watch<HabitTrackerCubit>().state;
}
