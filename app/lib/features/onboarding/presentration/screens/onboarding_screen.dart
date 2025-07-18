import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/features/user/presentation/screens/create_account_slide.dart';
import 'package:habitvote/features/onboarding/presentration/widgets/habitVoteDifference.dart';
import 'package:habitvote/features/onboarding/presentration/widgets/brilliant_ok_button.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../application/cubits/onboarding_cubit.dart';
// Removed unused import
import '../widgets/selectable_option.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  // totalInteractiveSteps remains 9 if TopicChooser is replaced by CustomPlanSlide
  // Let's keep totalSteps as the total number of pages (0-indexed)
  final int totalSteps = 10; // 0 to 9

  void next() {
    // Navigate to register on the last step (CreateAccountSlide)

    controller.nextPage(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    setState(() {}); // Rebuild to update progress bar potentially
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
            children: [
              GenderChooser(), // 0
              CommitmentQuestion(), // 1
              OtherAppsUsage(), // 2
              HabitVoteDifference(), // 3 - No input needed
              HabitCategoryChooser(), // 4
              HabitChooser(), // 5
              AgeGroupSelector(), // 6
              ThankYouSlide(), // 7 - No input needed
              SetupProgressSlide(
                onComplete: () => controller.nextPage(
                  duration: Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                ),
              ), // 8 - No input needed
              CustomPlanSlide(), // 9 - No input needed
              CreateAccountSlide(), // 10 - Leads to registration
              // Removed SetupProgressSlide as it seems replaced or unused
            ],
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
                    bool allowControl =
                        true; // Default to true for non-input slides
                    int currentPage = controller.page?.round() ?? 0;

                    // Enable/disable based on current page's required state
                    if (currentPage == 0) {
                      // GenderChooser
                      allowControl = state.gender != null;
                    } else if (currentPage == 1) {
                      // CommitmentQuestion
                      allowControl = state.commitmentLevel != null;
                    } else if (currentPage == 2) {
                      // OtherAppsUsage
                      allowControl = state.usedOtherApps != null;
                    } else if (currentPage == 4) {
                      // HabitCategoryChooser
                      allowControl = state.habitType != null;
                    } else if (currentPage == 5) {
                      // HabitChooser
                      allowControl = state.selectedHabit != null &&
                          state.selectedHabit!.isNotEmpty;
                    } else if (currentPage == 6) {
                      // AgeGroupSelector
                      allowControl = state.age != null;
                    }
                    // Pages 3, 7, 8 don't require input, allowControl remains true.
                    // Page 9 (CreateAccountSlide) has specific button text.

                    // Hide button if controller is not ready
                    if (!controller.hasClients ||
                        currentPage == 8 ||
                        currentPage == 10) {
                      return SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: BrilliantOkButton(
                        // Text changes on the last slide before registration
                        text: currentPage == 7
                            ? "Create my plan"
                            : currentPage == 9
                                ? "Let's get started!"
                                : "Next",
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
                                  .back_hand_sharp, // Consider a 'stop' or 'negative' icon
                              color: Colors.black,
                            )),
                        SizedBox(width: 16),
                        Text(
                          "I want to Stop BAD habit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SelectableOption(
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
                        "I want to Start GOOD habit",
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

class HabitChooser extends StatefulWidget {
  const HabitChooser({super.key});

  @override
  State<HabitChooser> createState() => _HabitChooserState();
}

class _HabitChooserState extends State<HabitChooser> {
  final TextEditingController _customHabitController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  // String? _selectedPredefinedHabit; // Removed, rely on cubit state

  // --- Positive Habits Data ---
  static const Map<String, List<MapEntry<IconData, String>>>
      _positiveHabitGroups = {
    'Digital Wellness': [
      MapEntry(Icons.phone_android_outlined, 'Grayscale Phone after 9 PM'),
      MapEntry(Icons.savings_outlined, 'Save \$5 on Doomscroll >10min'),
      MapEntry(Icons.directions_walk, 'Take "Rage Walk" (No Phone)'),
      MapEntry(Icons.delete_sweep_outlined, 'Delete Delivery Apps After Use'),
      MapEntry(Icons.reply_outlined, 'Reply DMs within 24h'),
      MapEntry(Icons.photo_camera_back_outlined, 'Vibe Check Before Posting'),
      MapEntry(Icons.send_outlined, 'Text Meme to Friend'),
      MapEntry(Icons.block_flipped, 'Block Distractions after 8 PM'),
      MapEntry(Icons.power_off_outlined, 'Charge Devices Elsewhere'),
      MapEntry(Icons.mic_none_outlined, '1-Sentence Voice Journal'),
      MapEntry(Icons.do_not_disturb_on_outlined, 'Skip 1 "Trauma Dump" Convo'),
    ],
    'Productivity & Learning': [
      MapEntry(Icons.cleaning_services_outlined, '1-Min Speed Clean (Ads)'),
      MapEntry(Icons.work_outline, 'Open Job App Before Gaming'),
      MapEntry(Icons.book_outlined, 'Open Textbook Before Netflix'),
      MapEntry(Icons.bookmark_add_outlined, 'Bookmark Recipes You Cook'),
      MapEntry(Icons.speed_outlined, 'Podcast 2x Speed (Chores)'),
      MapEntry(Icons.edit_note_outlined, 'Replace "Busy" Correctly'),
    ],
    'Sustainability & Finance': [
      MapEntry(Icons.coffee_maker_outlined, 'Use Reusable Coffee Cup'),
      MapEntry(Icons.sell_outlined, 'Photo Outfit for Resale'),
      MapEntry(Icons.recycling_outlined, 'Leave 1 Toxic Group Weekly'),
    ],
  };

  // --- Negative Habits Data ---
  static const Map<String, List<MapEntry<IconData, String>>>
      _negativeHabitGroups = {
    'Digital Habits to Break': [
      MapEntry(Icons.textsms_outlined, 'Stop 100+ Unread Texts'),
      MapEntry(Icons.subtitles_off_outlined, 'Stop Always Using Subtitles'),
      MapEntry(Icons.screenshot_monitor_outlined, 'Stop Screenshotting Inspo'),
      MapEntry(Icons.bed_outlined, 'Stop Using Bed as Desk'),
      MapEntry(Icons.smart_display_outlined, 'Stop Watching "Study With Me"'),
      MapEntry(Icons.tab_unselected_outlined, 'Stop Keeping 50+ Tabs Open'),
      MapEntry(Icons.phonelink_erase_outlined, 'Stop 2 AM Scrolling'),
      MapEntry(Icons.visibility_off_outlined, 'Stop "Seen" Ghosting'),
    ],
    'Spending & Consumption': [
      MapEntry(Icons.fastfood_outlined, 'Stop Ordering Food When Bored'),
      MapEntry(Icons.coffee_outlined, 'Stop \$7 Lattes (False Productivity)'),
      MapEntry(Icons.shopping_bag_outlined, 'Stop Fast Fashion (One Use)'),
      MapEntry(Icons.storefront_outlined, 'Stop Shein/Temu after 8 PM'),
    ],
    'Mindset & Social': [
      MapEntry(Icons.event_busy_outlined, 'Stop "Start Monday" Excuse'),
      MapEntry(
          Icons.sentiment_dissatisfied_outlined, 'Stop Saying "I\'m Fine"'),
      MapEntry(
          Icons.phone_disabled_outlined, 'Stop Calling Family Only for \$'),
      MapEntry(
          Icons.cancel_presentation_outlined, 'Stop Saying Yes & Canceling'),
      MapEntry(Icons.workspaces_outline, 'Stop Pretending Work in Cafes'),
      MapEntry(Icons.folder_delete_outlined, 'Stop Hoarding Free PDFs'),
      MapEntry(
          Icons.mark_email_unread_outlined, 'Stop Apologizing "Double Text"'),
    ],
  };

  // Removed single _habitGroups map

  @override
  void initState() {
    super.initState();
    // Initialize text field if cubit has a custom habit value
    final cubit = context.read<OnboardingCubit>();
    final initialHabit = cubit.state.selectedHabit;
    final habitType = cubit.state.habitType; // Get habit type

    bool isPredefined = false;
    if (initialHabit != null && habitType != null) {
      // Check against the correct list based on type
      final groupsToCheck =
          habitType == 'good' ? _positiveHabitGroups : _negativeHabitGroups;
      for (var group in groupsToCheck.values) {
        if (group.any((entry) => entry.value == initialHabit)) {
          isPredefined = true;
          break;
        }
      }
      if (!isPredefined) {
        _customHabitController.text = initialHabit;
      }
    }

    _customHabitController.addListener(() {
      final text = _customHabitController.text;
      final currentHabit = context.read<OnboardingCubit>().state.selectedHabit;
      if (text.isNotEmpty) {
        if (currentHabit != text) {
          context.read<OnboardingCubit>().setSelectedHabit(text);
        }
      } else {
        if (currentHabit != null) {
          // Check if the current habit was predefined before clearing
          final habitType = context.read<OnboardingCubit>().state.habitType;
          bool wasPredefined = false;
          if (habitType != null) {
            final groupsToCheck = habitType == 'good'
                ? _positiveHabitGroups
                : _negativeHabitGroups;
            for (var group in groupsToCheck.values) {
              if (group.any((entry) => entry.value == currentHabit)) {
                wasPredefined = true;
                break;
              }
            }
          }
          // Only clear cubit state if the text field is cleared AND the current state wasn't a predefined one
          // Or if it was a custom one that's now empty.
          if (!wasPredefined || currentHabit == text) {
            // Allow clearing if it was custom text
            context.read<OnboardingCubit>().setSelectedHabit(null);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _customHabitController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToTopAndFocus() {
    // Clear predefined selection when focusing text field
    // context.read<OnboardingCubit>().setSelectedHabit(_customHabitController.text.isNotEmpty ? _customHabitController.text : null);
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _focusNode.requestFocus();
    // Ensure text field content updates cubit state via listener
  }

  Widget _buildHabitGroup(
      String title, List<MapEntry<IconData, String>> habits) {
    // Read selected habit from cubit state within BlocBuilder or context.watch
    final selectedHabit = context.watch<OnboardingCubit>().state.selectedHabit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
        ),
        Wrap(
          spacing: 10.0, // Horizontal space between items
          runSpacing: 10.0, // Vertical space between lines
          children: habits.map((habit) {
            final icon = habit.key;
            final habitTitle = habit.value;
            final isSelected = selectedHabit == habitTitle;

            return SizedBox(
              width: (MediaQuery.of(context).size.width / 2) -
                  20 - // Padding
                  5, // Spacing / 2
              child: SelectableOption(
                isSelected: isSelected,
                onSelected: () {
                  // Update cubit state with the selected predefined habit
                  context.read<OnboardingCubit>().setSelectedHabit(habitTitle);
                  _customHabitController.clear(); // Clear text field
                  FocusScope.of(context).unfocus(); // Hide keyboard
                  // No need for setState if UI relies on BlocBuilder/watch
                },
                child: Row(
                  children: [
                    Icon(icon,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.black87),
                    SizedBox(width: 8),
                    Expanded(
                      // Use Flexible + Text instead of FittedBox for better control
                      child: Center(
                        child: Text(
                          habitTitle,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                          maxLines: 2, // Ensure single line
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder or context.watch for reactive UI updates
    final state = context.watch<OnboardingCubit>().state;
    final habitType = state.habitType; // 'good' or 'bad'
    final selectedHabitGroups = (habitType == 'good')
        ? _positiveHabitGroups
        : _negativeHabitGroups; // Default to negative if null? Or handle error.

    // Determine title and hint text based on habitType
    final String titleText = (habitType == 'good')
        ? "Choose or Define a GOOD Habit"
        : "Choose or Define a BAD Habit to Stop";
    final String hintText = (habitType == 'good')
        ? 'E.g., Read one chapter daily'
        : 'E.g., Stop scrolling social media after 10 PM';
    final String buttonText =
        (habitType == 'good') ? "Write New GOOD Habit" : "Write New BAD Habit";

    // Handle case where habitType might be null (shouldn't happen if flow is correct)
    if (habitType == null) {
      return Center(child: Text("Error: Habit type not selected."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... Title and Subtitle ...
          Text(titleText, // Use dynamic title
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 8),
          Text("Select a common habit or type your own goal below.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 16),
          TextField(
            controller: _customHabitController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: hintText, // Use dynamic hint text
              prefixIcon:
                  Icon(Icons.edit_outlined, color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onTap: () {
              // Tapping text field implicitly deselects predefined via listener logic
              // If text field is empty when tapped, ensure cubit state is cleared
              if (_customHabitController.text.isEmpty) {
                context.read<OnboardingCubit>().setSelectedHabit(null);
              }
            },
            // onChanged handled by listener in initState
          ),
          SizedBox(height: 20),
          Expanded(
            // Use BlocBuilder here to rebuild habit groups when state changes
            // No need for BlocBuilder if context.watch is used above for state
            child: ListView(
              controller: _scrollController,
              children: selectedHabitGroups.entries // Use selected groups
                  .map((entry) => _buildHabitGroup(entry.key, entry.value))
                  .toList(),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              icon: Icon(Icons.arrow_upward_rounded),
              label: Text(buttonText), // Use dynamic button text
              onPressed: _scrollToTopAndFocus,
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).primaryColor, // Use theme color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class SetupProgressSlide extends StatefulWidget {
  final VoidCallback onComplete; // Optional callback for completion
  const SetupProgressSlide({
    super.key,
    required this.onComplete,
  });

  @override
  State<SetupProgressSlide> createState() => _SetupProgressSlideState();
}

class _SetupProgressSlideState extends State<SetupProgressSlide> {
  int _subtitleIndex = 0;
  Timer? _subtitleTimer;
  Timer? _navigationTimer;

  final List<String> _subtitles = [
    "Analyzing your preferences...",
    "Selecting your habits...",
    "Finding peers like you...",
    "Preparing your votes...",
    "Building your custom plan...",
    "Finalizing setup...",
  ];

  @override
  void initState() {
    super.initState();

    // Timer to change subtitle every 2 seconds
    _subtitleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _subtitleIndex = (_subtitleIndex + 1) % _subtitles.length;
      });
    });

    // Timer to navigate after a delay (e.g., 5 seconds)
    // Adjust duration as needed
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        // Navigate to the main app screen, replace '/home' with your actual route
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Setting things up for you",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2D2C2D)),
            strokeWidth: 3.0,
          ),
          SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              _subtitles[_subtitleIndex],
              key: ValueKey<int>(
                  _subtitleIndex), // Important for AnimatedSwitcher
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ),
          Spacer(), // Pushes content towards center
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
