import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/onboarding/application/cubits/onboarding_cubit.dart';
import 'package:habitvote/shared/widgets/timeWindowPicker/time_window_picker.dart';

class CheckInWindownPicker extends StatefulWidget {
  const CheckInWindownPicker({super.key});

  @override
  State<CheckInWindownPicker> createState() => _CheckInWindownPickerState();
}

class _CheckInWindownPickerState extends State<CheckInWindownPicker> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ... Title and Subtitle ...
          Text("Set Your Daily Check-in Time",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          const SizedBox(height: 8),
          Text(
            "Select the time window to report your habit's status for the day.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeDisplay(
                title: 'Check-in Starts',
                time: state.openWindow,
                icon: Icons.notifications_active_outlined,
              ),
              _TimeDisplay(
                title: 'Check-in Ends',
                time: state.closeWindow,
                icon: Icons.notifications_off_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TimeWindowPicker(
            startTime: state.openWindow,
            endTime: state.closeWindow,
            onTimeChanged: (start, end) {
              context.read<OnboardingCubit>().setCloseWindow(end);
              context.read<OnboardingCubit>().setOpenWindow(start);
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    "You can only report your habit's status during this time. Missing the check-in marks the habit as failed for the day.",
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final IconData icon;

  const _TimeDisplay({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time.format(context),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
