import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/features/onboarding/presentration/widgets/habitVoteDifference.dart';
import 'package:habitvote/features/onboarding/presentration/widgets/brilliant_ok_button.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../application/cubits/onboarding_cubit.dart';
// Assuming OnboardingState has a 'selectedHabit' property and OnboardingCubit has a 'setHabit' method.
// import '../../application/cubits/onboarding_state.dart';
import '../widgets/selectable_option.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  // totalInteractiveSteps remains 9 if TopicChooser is replaced by CustomPlanSlide
  final int totalInteractiveSteps = 9;

  void next() {
    // Adjust the page count check if CreateAccountSlide is the last step
    // Now check against the updated totalSteps
    if (controller.page == totalInteractiveSteps) {
      context.push("/register");
      return;
    } else {
      controller.nextPage(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }

    setState(() {});
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
                // Use updated totalSteps for progress calculation
                final progress =
                    ((controller.page ?? 0) + 1) / totalInteractiveSteps;
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
              HabitVoteDifference(), // 3
              HabitCategoryChooser(), // 4
              HabitChooser(), // 5
              AgeGroupSelector(), // 6
              // Replace TopicChooser with CustomPlanSlide
              CustomPlanSlide(), // 7
              ThankYouSlide(), // 8
              SetupProgressSlide(), // 9 (Auto-navigates)
            ],
          ),
        ),
        persistentFooterButtons: [
          BlocListener<OnboardingCubit, OnboardingState>(
            listener: (context, state) {},
            child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                    bool allowControll = true;
                    int currentPage = controller.page?.round() ?? 0;

                    // Update page indices based on the new order
                    if (currentPage == 0) {
                      // GenderChooser
                      allowControll = state.gender != null;
                    } else if (currentPage == 1) {
                      // CommitmentQuestion
                      allowControll = state.languageLevel != null;
                    } else if (currentPage == 2) {
                      // OtherAppsUsage
                      allowControll = true;
                    } else if (currentPage == 3) {
                      // HabitVoteDifference
                      allowControll = true;
                    } else if (currentPage == 4) {
                      // HabitCategoryChooser
                      allowControll = true;
                    } else if (currentPage == 5) {
                      // HabitChooser
                      // allowControll = state.selectedHabit != null && state.selectedHabit!.isNotEmpty;
                    } else if (currentPage == 6) {
                      // AgeGroupSelector
                      allowControll = state.age != null;
                    } else if (currentPage == 7) {
                      // CustomPlanSlide (new index)
                      allowControll =
                          true; // Always allow moving from plan slide
                    } else if (currentPage == 8) {
                      // ThankYouSlide (new index)
                      allowControll = true;
                    }

                    // Hide button on the final SetupProgressSlide (index 9)
                    if (currentPage >= totalInteractiveSteps) {
                      return SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: BrilliantOkButton(
                        // Text changes on the last interactive slide (ThankYouSlide)
                        text: currentPage == totalInteractiveSteps - 1
                            ? "Finish Setup"
                            : "Next",
                        tag: "continue",
                        disabled: !allowControll,
                        onPressed: next,
                      ),
                    );
                  });
                }),
          ),
        ]);
  }
}

class TargetLanguageChooser extends StatefulWidget {
  const TargetLanguageChooser({super.key});

  @override
  State<TargetLanguageChooser> createState() => _TargetLanguageChooserState();
}

class _TargetLanguageChooserState extends State<TargetLanguageChooser> {
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Japanese',
    'Turkish',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Target Language",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text(
              "This will be the language you are about to learn +1000 new words in",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
              return ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SelectableOption(
                      isSelected: state.targetLanguage == _languages[index],
                      onSelected: () {
                        context
                            .read<OnboardingCubit>()
                            .setTargetLanguage(_languages[index]);
                      },
                      child: Center(child: Text(_languages[index])),
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

class HabitCategoryChooser extends StatefulWidget {
  const HabitCategoryChooser({super.key});

  @override
  State<HabitCategoryChooser> createState() => HabitCategoryChooserState();
}

class HabitCategoryChooserState extends State<HabitCategoryChooser> {
  @override
  Widget build(BuildContext context) {
    final target = context.read<OnboardingCubit>().state.targetLanguage;
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
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableOption(
                  isSelected: false,
                  onSelected: () {},
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.back_hand_sharp,
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
                SelectableOption(
                  isSelected: false,
                  onSelected: () {},
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.gpp_good,
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

class AgeGroupSelector extends StatefulWidget {
  const AgeGroupSelector({super.key});

  @override
  State<AgeGroupSelector> createState() => AgeGroupSelectorState();
}

class AgeGroupSelectorState extends State<AgeGroupSelector> {
  final List<String> _ages = [
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
          Text("Choose Your Age",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text(
              "So we can Pick you the most interesting topics that keep you engage with with language",
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SelectableOption(
                      isSelected: state.age == _ages[index],
                      onSelected: () {
                        context.read<OnboardingCubit>().setAge(_ages[index]);
                      },
                      child: Center(child: Text(_ages[index])),
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

class GenderChooser extends StatefulWidget {
  const GenderChooser({super.key});

  @override
  State<GenderChooser> createState() => GenderChooserState();
}

class GenderChooserState extends State<GenderChooser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Your Gender",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text(
              "We will Select The most interesting Topics that provides better contexts for learning",
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
                    isSelected: state.gender == "male",
                    onSelected: () {
                      context.read<OnboardingCubit>().setGender("male");
                    },
                    child: Center(child: Text("Male")),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableOption(
                    isSelected: state.gender == "female",
                    onSelected: () {
                      context.read<OnboardingCubit>().setGender("female");
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

class TopicChooser extends StatefulWidget {
  const TopicChooser({super.key});

  @override
  State<TopicChooser> createState() => TopicChooserState();
}

class TopicChooserState extends State<TopicChooser> {
  Widget _buildOption(
    String id, {
    required String leading,
    required String text,
    required String subtext,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SelectableOption(
        isSelected: context.read<OnboardingCubit>().state.selectedTopic == id,
        onSelected: () {
          context.read<OnboardingCubit>().setSelectedTopic(id);
        },
        child: Row(
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
    final target = context.read<OnboardingCubit>().state.targetLanguage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xff2D2C2D),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text("Congratulations\n your custom plan is ready",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
            SizedBox(height: 8),
            Text("You should Learn:",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
            SizedBox(height: 4),
            Chip(
              label: Text(
                "+1000 $target words by November 15",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xff2D2C2D)),
              ),
              backgroundColor: Colors.grey.shade200,
              shape: StadiumBorder(),
              side: BorderSide.none,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Topic Recomendation",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                  Text(
                    "You can edit this any time",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                  SizedBox(height: 8),
                  BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                    return Column(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ...state.filtredFlows
                        //         ?.map((flow) => _buildOption(
                        //               flow.id,
                        //               leading: [
                        //                 "A1",
                        //                 "A2",
                        //                 "B1",
                        //                 "B2",
                        //                 "C1",
                        //                 "C2"
                        //               ][flow.level],
                        //               text: flow.id,
                        //               subtext: flow.title,
                        //             ))
                        //         .toList() ??
                        //     [],
                      ],
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CommitmentQuestion extends StatefulWidget {
  const CommitmentQuestion({super.key});

  @override
  State<CommitmentQuestion> createState() => CommitmentQuestionState();
}

class CommitmentQuestionState extends State<CommitmentQuestion> {
  Widget _buildOption(
    int index, {
    required String leading,
    required String text,
    required String subtext,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SelectableOption(
        isSelected:
            context.read<OnboardingCubit>().state.languageLevel == index,
        onSelected: () {
          context.read<OnboardingCubit>().setLanguageLevel(index);
        },
        child: Row(
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
    final target = context.read<OnboardingCubit>().state.targetLanguage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How You Rate Your new Habits Decipline?",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text(
              "what is your current Decipline with new habits, knowing this will help us to create a custom plan for you",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 20),
          Expanded(child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOption(
                    1,
                    leading: "F",
                    text: "Never Started",
                    subtext:
                        "I can say hello, goodbye and ask simple questions.",
                  ),
                  _buildOption(
                    2,
                    leading: "C",
                    text: "Can't finish one Week",
                    subtext:
                        "I can talk about myself and my routine in basic sentences.",
                  ),
                  _buildOption(
                    3,
                    leading: "E",
                    text: "Solid when i want the Habit",
                    subtext:
                        "I can handle common travel, work and social situations.",
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

class OtherAppsUsage extends StatefulWidget {
  const OtherAppsUsage({super.key});

  @override
  State<OtherAppsUsage> createState() => OtherAppsUsageState();
}

class OtherAppsUsageState extends State<OtherAppsUsage> {
  @override
  Widget build(BuildContext context) {
    final target = context.read<OnboardingCubit>().state.targetLanguage;
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
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableOption(
                  isSelected: false,
                  onSelected: () {},
                  child: Row(
                    children: [
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
                SelectableOption(
                  isSelected: false,
                  onSelected: () {},
                  child: Row(
                    children: [
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

class NativeLanguageChooser extends StatefulWidget {
  const NativeLanguageChooser({super.key});

  @override
  State<NativeLanguageChooser> createState() => NativeLanguageChooserState();
}

class NativeLanguageChooserState extends State<NativeLanguageChooser> {
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Japanese',
    'Turkish',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Your Native Language",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
          SizedBox(height: 16),
          Text("the Language You master",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  )),
          SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
              return ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SelectableOption(
                      isSelected: state.nativeLanguage == _languages[index],
                      onSelected: () {
                        context
                            .read<OnboardingCubit>()
                            .setNativeLanguage(_languages[index]);
                      },
                      child: Center(child: Text(_languages[index])),
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
  String? _selectedPredefinedHabit;

  // Example habit data structure: Map<CategoryName, List<MapEntry<IconData, HabitTitle>>>
  final Map<String, List<MapEntry<IconData, String>>> _habitGroups = {
    'Health & Fitness': [
      MapEntry(Icons.fitness_center, 'Exercise Regularly'),
      MapEntry(Icons.water_drop, 'Drink More Water'),
      MapEntry(Icons.restaurant, 'Eat Healthier'),
      MapEntry(Icons.bedtime, 'Sleep Earlier'),
    ],
    'Productivity': [
      MapEntry(Icons.book, 'Read Daily'),
      MapEntry(Icons.work, 'Focus Work'),
      MapEntry(Icons.cleaning_services, 'Tidy Up Space'),
      MapEntry(Icons.timer, 'Time Management'),
    ],
    'Mindfulness': [
      MapEntry(Icons.self_improvement, 'Meditate'),
      MapEntry(Icons.book_online, 'Journaling'),
      MapEntry(Icons.nature_people, 'Spend Time Outside'),
      MapEntry(Icons.favorite, 'Practice Gratitude'),
    ],
    'Learning': [
      MapEntry(Icons.language, 'Learn Language'),
      MapEntry(Icons.code, 'Code Daily'),
      MapEntry(Icons.music_note, 'Practice Instrument'),
      MapEntry(Icons.school, 'Study Subject'),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Update cubit if initial value exists
    final initialHabit = null;
    if (initialHabit != null && initialHabit.isNotEmpty) {
      // Check if it's a predefined habit
      bool isPredefined = false;
      for (var group in _habitGroups.values) {
        if (group.any((entry) => entry.value == initialHabit)) {
          _selectedPredefinedHabit = initialHabit;
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
      if (text.isNotEmpty) {
        // If user types, deselect predefined and update cubit with text
        if (_selectedPredefinedHabit != null) {
          setState(() {
            _selectedPredefinedHabit = null;
          });
        }
        // context.read<OnboardingCubit>().setHabit(text);
      } else {
        // If text is cleared, update cubit (might set to null or empty based on cubit logic)
        //  context.read<OnboardingCubit>().setHabit(null); // Or ""
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
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _focusNode.requestFocus();
  }

  Widget _buildHabitGroup(
      String title, List<MapEntry<IconData, String>> habits) {
    final selectedHabit = "";

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
                  20 -
                  5, // Adjust width for 2 columns + spacing
              child: SelectableOption(
                isSelected: isSelected,
                onSelected: () {
                  setState(() {
                    _selectedPredefinedHabit = habitTitle;
                    _customHabitController
                        .clear(); // Clear text field if predefined is chosen
                  });
                  // context.read<OnboardingCubit>().setHabit(habitTitle);
                  FocusScope.of(context).unfocus(); // Hide keyboard
                },
                child: Row(
                  children: [
                    Icon(icon,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.black87),
                    SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          habitTitle,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
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
    // Re-read state here if needed, or rely on BlocBuilder/watch
    // final selectedHabit = context.watch<OnboardingCubit>().state.selectedHabit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose or Define Your Habit",
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
              hintText: 'E.g., Stop scrolling social media',
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
              // When user taps text field, deselect predefined habit visually
              if (_selectedPredefinedHabit != null) {
                setState(() {
                  _selectedPredefinedHabit = null;
                });
                // Optionally clear cubit state immediately or wait for text input listener
                // context.read<OnboardingCubit>().setHabit(null);
              }
            },
            // onChanged handled by listener in initState
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: _habitGroups.entries
                  .map((entry) => _buildHabitGroup(entry.key, entry.value))
                  .toList(),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              icon: Icon(Icons.arrow_upward_rounded),
              label: Text("Write New Habit"),
              onPressed: _scrollToTopAndFocus,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
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
  const SetupProgressSlide({super.key});

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
        context.go('/home'); // Use goRouter's go method to replace the stack
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
