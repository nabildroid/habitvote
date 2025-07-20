import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/onboarding/application/cubits/onboarding_cubit.dart';
import 'package:habitvote/shared/widgets/verticalTimeHeatmap/vertical_time_heatmap.dart';

class TriggerHeatMap extends StatelessWidget {
  const TriggerHeatMap({super.key});

  @override
  Widget build(BuildContext context) {
    final triggers = context.watch<OnboardingCubit>().state.triggers;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... Title and Subtitle ...
          Text("When Do You Need Motivation?",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          const SizedBox(height: 16),
          Text(
              "Tap on the timeline to mark the moments you usually struggle. We'll send you extra support during these critical times.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          const SizedBox(height: 40),
          SizedBox(
            height: 400, // Define a height for the heatmap
            child: VerticalTimeHeatmap(
              // todo use the time windown the user previosily chosen
              selectedTimes: triggers,
              onTimeTap: context.read<OnboardingCubit>().addTrigger,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${triggers.length} critical times selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
