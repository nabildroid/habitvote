import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/habit_model.dart';
import 'package:habitvote/features/habit/data/repositories/habit_repository.dart';
import 'package:habitvote/features/onboarding/application/cubits/onboarding_cubit.dart';
import 'package:habitvote/features/user/data/auth_service.dart';

extension OnboardingHabitRegisterExtension on OnboardingCubit {
  Future<void> registerHabit() async {
    final habitName = state.selectedHabit!;
    final habitType = state.habitType!;

    final habit = HabitModel(
      description: habitName,
      isNegative: habitType == "bad",
      name: habitName,
      publicName: habitName,
      checkinOpenWindow: state.openWindow,
      checkinCloseWindow: state.closeWindow,
      triggers: state.triggers,
    );

    final repo = locator.get<HabitRepo>();

    await repo.create(habit);

    // repo.addHabit(
    //   habit: habit,
    //   type: habitType,
    // );
  }
}
