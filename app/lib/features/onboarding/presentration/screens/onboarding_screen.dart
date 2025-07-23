import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/features/onboarding/presentration/screens/checkinWindowPicker.dart';
import 'package:habitvote/features/onboarding/presentration/screens/habit_chooser.dart';
import 'package:habitvote/features/onboarding/presentration/screens/setup_progress.dart';
import 'package:habitvote/features/onboarding/presentration/screens/triggerHitmap.dart';
import 'package:habitvote/features/user/presentation/screens/create_account_slide.dart';
import 'package:habitvote/features/onboarding/presentration/widgets/habitVoteDifference.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../application/cubits/onboarding_cubit.dart';
// Removed unused import
import '../widgets/selectable_option.dart';

class _OnboardingStep {
  final Widget widget;
  final bool Function(OnboardingState state) isStepCompleted;
  final String? buttonText;
  final bool showButton;

  const _OnboardingStep({
    required this.widget,
    required this.isStepCompleted,
    this.buttonText,
    this.showButton = true,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  // totalInteractiveSteps remains 9 if TopicChooser is replaced by CustomPlanSlide
  // Let's keep totalSteps as the total number of pages (0-indexed)
  late final List<_OnboardingStep> _steps;
  int get totalSteps => _steps.length;

  @override
  void initState() {
    super.initState();
    _steps = [
      // _OnboardingStep(
      //   widget: GenderChooser(),
      //   isStepCompleted: (state) => state.gender != null,
      // ), // 0
      // _OnboardingStep(
      //   widget: CommitmentQuestion(),
      //   isStepCompleted: (state) => state.commitmentLevel != null,
      // ), // 1
      // _OnboardingStep(
      //   widget: OtherAppsUsage(),
      //   isStepCompleted: (state) => state.usedOtherApps != null,
      // ), // 2
      // _OnboardingStep(
      //   widget: HabitVoteDifference(),
      //   isStepCompleted: (state) => true,
      // ), // 3
      _OnboardingStep(
        widget: HabitCategoryChooser(),
        isStepCompleted: (state) => state.habitType != null,
      ), // 4
      _OnboardingStep(
        widget: HabitChooser(),
        isStepCompleted: (state) =>
            state.selectedHabit != null && state.selectedHabit!.isNotEmpty,
      ), // 5
      // _OnboardingStep(
      //   widget: AgeGroupSelector(),
      //   isStepCompleted: (state) => state.age != null,
      // ), // 6
      _OnboardingStep(
        widget: CheckInWindownPicker(),
        isStepCompleted: (state) => true,
      ), // 7
      _OnboardingStep(
        widget: TriggerHeatMap(),
        isStepCompleted: (state) => true,
      ), // 8
      _OnboardingStep(
        widget: ThankYouSlide(),
        isStepCompleted: (state) => true,
        buttonText: "Create my plan",
      ), // 9
      _OnboardingStep(
        widget: SetupProgressSlide(
          onComplete: () => controller.nextPage(
            duration: Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          ),
        ),
        isStepCompleted: (state) => true,
        showButton: false,
      ), // 10
      _OnboardingStep(
        widget: CustomPlanSlide(),
        isStepCompleted: (state) => true,
        buttonText: "Let's get started!",
      ), // 11
      _OnboardingStep(
        widget: CreateAccountSlide(),
        isStepCompleted: (state) => true,
        showButton: false,
      ), // 12
    ];
  }

  void next() {
    // Navigate to register on the last step (CreateAccountSlide)

    controller.nextPage(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    setState(() {}); // Rebuild to update progress bar potentially

    logStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              if (controller.page == 0) {
                context.pop();
                return;
              }
              controller.previousPage(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );

              setState(() {});
            },
          ),
          title: FractionallySizedBox(
            widthFactor: 0.9,
            child: Center(
              child: Builder(builder: (context) {
                // Use totalSteps for progress calculation
                final progress = ((controller.page ?? 0) + 1) / totalSteps;
                return LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xff2D2C2D),
                  minHeight: 6,
                );
              }),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: PageView(
            controller: controller,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: _steps.map((step) => step.widget).toList(),
          ),
        ),
        persistentFooterButtons: [
          BlocListener<OnboardingCubit, OnboardingState>(
            listener: (context, state) {
              // Optional: Trigger rebuild if needed based on state changes affecting button
              setState(() {});
            },
            child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  // Use BlocBuilder here for direct access to state for button logic
                  return BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                    if (!controller.hasClients) {
                      return SizedBox.shrink();
                    }

                    int currentPage = controller.page?.round() ?? 0;
                    final currentStep = _steps[currentPage];

                    if (!currentStep.showButton) {
                      return SizedBox.shrink();
                    }

                    final allowControl = currentStep.isStepCompleted(state);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: BrilliantOkButton(
                        text: currentStep.buttonText ?? "Next",
                        tag: "continue",
                        disabled: !allowControl,
                        onPressed: next,
                      ),
                    );
                  });
                }),
          ),
        ]);
  }

  void logStep() {
    final currentPage = controller.page?.round() ?? 0;
    if (currentPage < totalSteps - 1) {
      final nextStep = _steps[currentPage + 1];
      final nextPageName = nextStep.widget.runtimeType.toString();

      Posthog().capture(eventName: "onboarding_step_completed", properties: {
        "step": nextPageName,
      });
    }
  }
}

class HabitCategoryChooser extends StatelessWidget {
  // Changed to StatelessWidget
  const HabitCategoryChooser({super.key});

  @override
  Widget build(BuildContext context) {
    // final target = context.read<OnboardingCubit>().state.targetLanguage; // Removed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Good & Bad",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          Expanded(child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
            return Column(
              // spacing: 12, // Use Padding instead
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SelectableOption(
                    order: 0,
                    isSelected: state.habitType == "bad", // Check state
                    onSelected: () {
                      context
                          .read<OnboardingCubit>()
                          .setHabitType("bad"); // Update state
                    },
                    child: Row(
                      children: [
                        // ... Icon and Text ...
                        CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons
                                  .delete_forever_outlined, // Consider a 'stop' or 'negative' icon
                              color: Colors.black,
                            )),
                        SizedBox(width: 16),
                        Text(
                          "Stop BAD habit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SelectableOption(
                  order: 1,
                  isSelected: state.habitType == "good", // Check state
                  onSelected: () {
                    context
                        .read<OnboardingCubit>()
                        .setHabitType("good"); // Update state
                  },
                  child: Row(
                    children: [
                      // ... Icon and Text ...
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons
                                .gpp_good, // Consider a 'start' or 'positive' icon
                            color: Colors.black,
                          )),
                      SizedBox(width: 16),
                      Text(
                        "Start GOOD habit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }))
        ],
      ),
    );
  }
}

class AgeGroupSelector extends StatelessWidget {
  // Changed to StatelessWidget
  const AgeGroupSelector({super.key});

  final List<String> _ages = const [
    // Made const
    'Under 18',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... Title and Subtitle ...
          Text("Choose Your Age",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text("This helps us tailor the experience.", // Simplified text
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
              return ListView.builder(
                itemCount: _ages.length,
                itemBuilder: (context, index) {
                  final ageOption = _ages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SelectableOption(
                      isSelected: state.age == ageOption, // Check state
                      onSelected: () {
                        context
                            .read<OnboardingCubit>()
                            .setAge(ageOption); // Update state
                      },
                      child: Center(child: Text(ageOption)),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}

class GenderChooser extends StatelessWidget {
  // Changed to StatelessWidget
  const GenderChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... Title and Subtitle ...
          Text("Choose Your Gender",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text("This helps personalize content.", // Simplified text
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 20),
          Expanded(child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableOption(
                    isSelected: state.gender == "male", // Check state
                    onSelected: () {
                      context
                          .read<OnboardingCubit>()
                          .setGender("male"); // Update state
                    },
                    child: Center(child: Text("Male")),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableOption(
                    isSelected: state.gender == "female", // Check state
                    onSelected: () {
                      context
                          .read<OnboardingCubit>()
                          .setGender("female"); // Update state
                    },
                    child: Center(child: Text("Female")),
                  ),
                )
              ],
            );
          }))
        ],
      ),
    );
  }
}

class CommitmentQuestion extends StatelessWidget {
  // Changed to StatelessWidget
  const CommitmentQuestion({super.key});

  Widget _buildOption(
    BuildContext context, // Pass context
    int index, {
    required String leading,
    required String text,
    required String subtext,
  }) {
    // Read state inside build or pass selected value
    final selectedLevel = context.read<OnboardingCubit>().state.commitmentLevel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SelectableOption(
        isSelected: selectedLevel == index, // Check state
        onSelected: () {
          context
              .read<OnboardingCubit>()
              .setCommitmentLevel(index); // Update state
        },
        child: Row(
          // ... Row content ...
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Text(
                leading,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    subtext,
                    softWrap: true,
                    maxLines: 3,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final target = context.read<OnboardingCubit>().state.targetLanguage; // Removed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How You Rate Your Habit Discipline?", // Adjusted title
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text(
              "What is your current discipline with new habits? Knowing this helps us create a custom plan.", // Adjusted subtitle
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 20),
          Expanded(child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
            // Use BlocBuilder to rebuild options on state change
            return SingleChildScrollView(
              child: Column(
                // spacing: 12, // Use Padding instead
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOption(
                    context, // Pass context
                    1,
                    leading: "F", // Example rating
                    text: "Never Started / Struggle Early",
                    subtext:
                        "Often find it hard to begin or stick past a few days.",
                  ),
                  _buildOption(
                    context, // Pass context
                    2,
                    leading: "C", // Example rating
                    text: "Inconsistent / Short Streaks",
                    subtext:
                        "Can maintain for a week or two, but fall off easily.",
                  ),
                  _buildOption(
                    context, // Pass context
                    3,
                    leading: "A", // Example rating
                    text: "Fairly Consistent / Determined",
                    subtext:
                        "Generally stick to it when committed, but seek improvement.",
                  ),
                ],
              ),
            );
          }))
        ],
      ),
    );
  }
}

class OtherAppsUsage extends StatelessWidget {
  // Changed to StatelessWidget
  const OtherAppsUsage({super.key});

  @override
  Widget build(BuildContext context) {
    // final target = context.read<OnboardingCubit>().state.targetLanguage; // Removed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Have you tried other habit tracking Apps?",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          Expanded(child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
            return Column(
              // spacing: 12, // Use Padding instead
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SelectableOption(
                    isSelected: state.usedOtherApps ==
                        false, // Check state (explicitly false)
                    onSelected: () {
                      context
                          .read<OnboardingCubit>()
                          .setUsedOtherApps(false); // Update state
                    },
                    child: Row(
                      children: [
                        // ... Icon and Text ...
                        CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.thumb_down_off_alt_rounded,
                              color: Colors.black,
                            )),
                        SizedBox(width: 16),
                        Text(
                          "No",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SelectableOption(
                  isSelected: state.usedOtherApps ==
                      true, // Check state (explicitly true)
                  onSelected: () {
                    context
                        .read<OnboardingCubit>()
                        .setUsedOtherApps(true); // Update state
                  },
                  child: Row(
                    children: [
                      // ... Icon and Text ...
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.thumb_up_off_alt_rounded,
                            color: Colors.black,
                          )),
                      SizedBox(width: 16),
                      Text(
                        "Yes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }))
        ],
      ),
    );
  }
}

class HabitVoteDifference extends StatelessWidget {
  const HabitVoteDifference({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("HabitVote creates Long-term Decipline",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 30),
          Expanded(child: HabitVoteDifferenceWidget()),
        ],
      ),
    );
  }
}

// --- Add the new HabitChooser Widget ---

// --- Add the new ThankYouSlide Widget ---

class ThankYouSlide extends StatelessWidget {
  const ThankYouSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon similar to the image (Checkmark in a circle)
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100, // Light orange background
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded, // Checkmark icon
              color: Colors.orange.shade700, // Orange checkmark
              size: 36,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "All done!",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          SizedBox(height: 24),
          Text(
            "Thank you for\ntrusting us",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2, // Adjust line height
                ),
          ),
          SizedBox(height: 20),
          Text(
            "We promise to always keep your\npersonal information private and secure.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.4, // Adjust line height
                ),
          ),
          Spacer(), // Pushes content towards center if needed
        ],
      ),
    );
  }
}

// --- Add the new CustomPlanSlide Widget ---

class CustomPlanSlide extends StatelessWidget {
  const CustomPlanSlide({super.key});

  // Helper to build metric cards
  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
    required double progress, // 0.0 to 1.0
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          // Optional: Add edit icon if needed later
          // Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400)
        ],
      ),
    );
  }

  // Helper to build strategy list items
  Widget _buildStrategyItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate target date (15 days from now)
    final targetDate = DateTime.now().add(const Duration(days: 15));
    final formattedDate =
        DateFormat('MMMM d').format(targetDate); // e.g., "July 28"

    // Placeholder values - replace with actual data from state later
    final String peersStarted = "12";
    final String positiveVotes = "85%";
    final String doubtsCast = "3";
    final double supportScore = 0.7; // 7/10

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Header ---
          CircleAvatar(
            backgroundColor: Color(0xff2D2C2D),
            child: Icon(Icons.check, color: Colors.white, size: 32),
          ),
          SizedBox(height: 16),
          Text(
            "Congratulations!\nYour custom plan is ready!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          SizedBox(height: 8),
          Text(
            "You should achieve:",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500, // Slightly less bold
                  color: Colors.black87,
                ),
          ),
          SizedBox(height: 4),
          Chip(
            label: Text(
              "Huge Progress by $formattedDate",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xff2D2C2D)),
            ),
            backgroundColor: Colors.grey.shade200,
            shape: StadiumBorder(),
            side: BorderSide.none,
          ),
          SizedBox(height: 24),

          // --- What We Found Section ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100, // Slightly different background
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Here's what we found for you:",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  "Based on your goals and community trends.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0, // Adjust for square-like cards
                  children: [
                    _buildMetricCard(
                      context: context,
                      title: "Peers Started Today",
                      value: peersStarted,
                      color: Colors.blue.shade600,
                      progress: 0.6, // Example progress
                    ),
                    _buildMetricCard(
                      context: context,
                      title: "Positive Votes Avg.",
                      value: positiveVotes,
                      color: Colors.green.shade600,
                      progress: 0.85, // Example progress
                    ),
                    _buildMetricCard(
                      context: context,
                      title: "Doubts Cast Avg.",
                      value: doubtsCast,
                      color: Colors.orange.shade700,
                      progress: 0.15, // Example progress
                    ),
                    _buildMetricCard(
                      context: context,
                      title: "Streak Potential", // Example metric
                      value: "High",
                      color: Colors.purple.shade500,
                      progress: 0.9, // Example progress
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // --- Community Support Score ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Community Support Score",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${(supportScore * 10).toInt()}/10",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade400),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: supportScore,
                  backgroundColor: Colors.pink.shade100,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 4),
                Text(
                  "How much encouragement you can expect based on similar habits.",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // --- Strategies Section ---
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Strategies for Success:",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
          SizedBox(height: 16),
          _buildStrategyItem(
            context: context,
            icon: Icons.link, // Icon for stacking/linking
            text: "Habit Stacking: Link new habits to existing ones.",
            iconColor: Colors.teal.shade500,
          ),
          _buildStrategyItem(
            context: context,
            icon: Icons.sentiment_very_satisfied, // Icon for positivity
            text: "Positive Framing: Focus on progress, not perfection.",
            iconColor: Colors.lightBlue.shade500,
          ),
          _buildStrategyItem(
            context: context,
            icon: Icons.thumb_up_alt, // Icon for challenging/proving
            text:
                "Challenge Doubters: Prove down-voters wrong with consistency.",
            iconColor: Colors.red.shade500,
          ),
          SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }
}
