import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';

import 'widgets/activities_section.dart';
import 'widgets/believers_chart.dart';
import 'widgets/calendar_card.dart';
import 'widgets/streak_counter.dart';
import 'widgets/milestone_goal_tracker.dart';

class Activity {
  final IconData icon;
  final String name;

  const Activity({required this.icon, required this.name});
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitTrackerCubit, HabitTrackerState>(
      builder: (context, state) {
        return _StatsScreen(
          completedDates: state.checkins.map((e) => e.date).toList(),
        );
      },
    );
  }
}

class _StatsScreen extends StatefulWidget {
  // Example data. In a real app, you'd pass this in.
  final List<DateTime> completedDates;

  const _StatsScreen({
    super.key,
    this.completedDates = const [],
  });

  @override
  State<_StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<_StatsScreen> {
  late DateTime _currentMonth;
  late Set<DateTime> _completedDays;
  late final ScrollController _scrollController1;
  late final ScrollController _scrollController2;
  bool isPremium = false;

  final List<Activity> _activities = const [
    Activity(icon: Icons.how_to_vote_outlined, name: 'Vote'),
    Activity(icon: Icons.emoji_events_outlined, name: 'Challenge'),
    Activity(icon: Icons.check_circle_outline, name: 'Track'),
    Activity(icon: Icons.edit_outlined, name: 'Journal'),
    Activity(icon: Icons.group_outlined, name: 'Support'),
    Activity(icon: Icons.trending_up, name: 'Growth'),
    Activity(icon: Icons.center_focus_strong_outlined, name: 'Focus'),
    Activity(icon: Icons.share_outlined, name: 'Share'),
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    // Normalize dates to ignore time, for accurate lookups.
    _completedDays =
        widget.completedDates.map((d) => DateUtils.dateOnly(d)).toSet();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }

  void _autoScroll() {
    if (!_scrollController1.hasClients) return;

    final maxScroll = _scrollController1.position.maxScrollExtent;
    const scrollSpeed = 50.0; // pixels per second
    final scrollDuration = (maxScroll / scrollSpeed).round();

    if (scrollDuration <= 0) return;

    _scrollController1
        .animateTo(
      maxScroll,
      duration: Duration(seconds: scrollDuration),
      curve: Curves.linear,
    )
        .then((_) {
      if (mounted) {
        _scrollController1.jumpTo(0);
        _autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  int _calculateStreak() {
    if (_completedDays.isEmpty) return 0;

    int streak = 0;
    DateTime today = DateUtils.dateOnly(DateTime.now());
    DateTime yesterday = today.subtract(const Duration(days: 1));

    DateTime startDate = _completedDays.contains(today) ? today : yesterday;

    if (!_completedDays.contains(startDate)) return 0;

    while (_completedDays.contains(startDate)) {
      streak++;
      startDate = startDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final streak = _calculateStreak();
    final totalDays = _completedDays.length;
    final nextMilestone = 50 - totalDays > 0 ? 50 - totalDays : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  StreakCounter(streak: streak),
                  const SizedBox(height: 30),
                  MilestoneGoalTracker(streak: streak),
                  const SizedBox(height: 20),
                  BelieversChart(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(40, 3.5),
                      FlSpot(80, 5.4),
                      FlSpot(120, 6),
                      FlSpot(160, 5.8),
                      FlSpot(200, 6.5),
                      FlSpot(240, 7),
                      FlSpot(280, 7.2),
                    ],
                  ),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'One Habit at Time',
                      style: TextStyle(
                        color: Colors.teal[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'to help maintain a daily\nwellbeing practice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  CalendarCard(
                    totalDays: totalDays,
                    nextMilestone: nextMilestone,
                    currentMonth: _currentMonth,
                    completedDays: _completedDays,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                  ),
                  const SizedBox(height: 40),
                  ActivitiesSection(
                    scrollController1: _scrollController1,
                    scrollController2: _scrollController2,
                    activities: _activities,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (!isPremium)
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.white.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: BrilliantOkButton(
                            text: "Go Premium",
                            onPressed: () {
                              // Navigate to premium page
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unlock your full potential',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
