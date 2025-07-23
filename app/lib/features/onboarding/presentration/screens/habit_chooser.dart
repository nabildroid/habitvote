import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/onboarding/application/cubits/onboarding_cubit.dart';

class HabitChooser extends StatefulWidget {
  const HabitChooser({super.key});

  @override
  State<HabitChooser> createState() => _HabitChooserState();
}

class _HabitChooserState extends State<HabitChooser>
    with TickerProviderStateMixin {
  final TextEditingController _customHabitController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late AnimationController _shineAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Map<String, IconData> _positiveHabitSuggestions = {
    'Spend 25 minutes on my main project (Pomodoro)': Icons.timer_outlined,
    'Write 100 words of original content': Icons.drive_file_rename_outline,
    'Watch one educational video (not entertainment)': Icons.school_outlined,
    'Plan tomorrow\'s single most important task': Icons.flag_outlined,
    'Eat one meal with zero screen interaction': Icons.no_cell_outlined,
    'Send one meaningful message to a friend (no "hey")': Icons.forum_outlined,
  };

// --- Habits to STOP Doing ---
// These are the chains of modern life. Breaking them is not about wellness;
// it's about reclaiming freedom, focus, and control.

  static const Map<String, IconData> _negativeHabitSuggestions = {
    'Don\'t snooze the alarm clock': Icons.alarm_off_outlined,
    'Zero social media for the first hour of the day':
        Icons.hourglass_top_outlined,
    'No impulse shopping online': Icons.credit_card_off_outlined,
    'No ordering from food delivery apps': Icons.no_meals_outlined,
    'Zero outrage/news feed scrolling': Icons.block_flipped,
    'No phone in the bedroom': Icons.phone_locked_outlined,
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    final cubit = context.read<OnboardingCubit>();
    final initialHabit = cubit.state.selectedHabit;

    if (initialHabit != null) {
      _customHabitController.text = initialHabit;
    }

    _customHabitController.addListener(() {
      final text = _customHabitController.text;
      final currentHabit = context.read<OnboardingCubit>().state.selectedHabit;
      if (text.isNotEmpty) {
        if (currentHabit != text) {
          context.read<OnboardingCubit>().setSelectedHabit(text);
        }
      } else {
        // If text field is cleared, clear the habit in the cubit.
        if (currentHabit != null) {
          context.read<OnboardingCubit>().setSelectedHabit(null);
        }
      }
    });
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _customHabitController.dispose();
    _focusNode.removeListener(() {});
    _focusNode.dispose();
    _animationController.dispose();
    _shineAnimationController.dispose();
    super.dispose();
  }

  void _onSuggestionTapped(String habit) {
    _customHabitController.text = habit;
    _customHabitController.selection = TextSelection.fromPosition(
        TextPosition(offset: _customHabitController.text.length));
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;
    final habitType = state.habitType;

    if (habitType == null) {
      return const Center(child: Text("Error: Habit type not selected."));
    }

    final bool isGoodHabit = habitType == 'good';
    final String titleText = isGoodHabit
        ? "What new habit will you start?"
        : "What habit will you break?";
    final String promptText =
        isGoodHabit ? "I want to..." : "I want to stop...";
    final Map<String, IconData> suggestions =
        isGoodHabit ? _positiveHabitSuggestions : _negativeHabitSuggestions;
    final Color accentColor =
        isGoodHabit ? Colors.teal.shade400 : Colors.red.shade400;

    final suggestionEntries = suggestions.entries.toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF9F9F9),
                Colors.grey.shade200,
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 32, bottom: 40),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          titleText,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: _focusNode.hasFocus
                                            ? accentColor
                                            : Colors.grey.shade200,
                                        width: 2),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeOut,
                                        top: _focusNode.hasFocus ||
                                                _customHabitController
                                                    .text.isNotEmpty
                                            ? 4
                                            : 20,
                                        child: AnimatedOpacity(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          opacity: _focusNode.hasFocus ||
                                                  _customHabitController
                                                      .text.isNotEmpty
                                              ? 1.0
                                              : 0.0,
                                          child: Text(
                                            promptText,
                                            style: TextStyle(
                                              color: accentColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: _customHabitController,
                                        focusNode: _focusNode,
                                        decoration: InputDecoration(
                                          hintText: !_focusNode.hasFocus &&
                                                  _customHabitController
                                                      .text.isEmpty
                                              ? promptText
                                              : '',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  color: Colors.grey.shade400),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            top: _focusNode.hasFocus ||
                                                    _customHabitController
                                                        .text.isNotEmpty
                                                ? 26
                                                : 20,
                                            bottom: 12,
                                          ),
                                        ),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 3,
                                        minLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_focusNode.hasFocus)
                                  Positioned.fill(
                                    child: AnimatedBuilder(
                                      animation: _shineAnimationController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  2 *
                                                  (_shineAnimationController
                                                          .value -
                                                      0.5),
                                              0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  Colors.white.withOpacity(0),
                                                  Colors.white.withOpacity(0.5),
                                                  Colors.white.withOpacity(0),
                                                ],
                                                stops: const [0.4, 0.5, 0.6],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 40, bottom: 20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Or get inspired...",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = suggestionEntries[index];
                        return AnimatedSuggestionCard(
                          habit: entry.key,
                          icon: entry.value,
                          accentColor: accentColor,
                          onTap: () => _onSuggestionTapped(entry.key),
                        );
                      },
                      childCount: suggestionEntries.length,
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        "You can always change this later.",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedSuggestionCard extends StatefulWidget {
  final String habit;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const AnimatedSuggestionCard({
    super.key,
    required this.habit,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<AnimatedSuggestionCard> createState() => _AnimatedSuggestionCardState();
}

class _AnimatedSuggestionCardState extends State<AnimatedSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse(from: 0.5).then((_) => widget.onTap());
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: widget.accentColor, size: 32),
                const Spacer(),
                Text(
                  widget.habit,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
