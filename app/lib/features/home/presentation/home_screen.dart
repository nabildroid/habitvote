import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vocafusion/features/home/presentation/widgets/today_voters.dart';

import 'widgets/checkin_slider.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/habit_heatmap.dart';
import 'widgets/social_overview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double sliderPosition = 0.5;
  bool isCheckedIn = false;
  DateTime checkInTime = DateTime.now().add(const Duration(hours: 2));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff111111),
            Color(0xff1B1B1B),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(),
          body: SingleChildScrollView(
            child: Column(children: [
              SocialOverview(),
              const SizedBox(height: 24),
              TodayVotersWidget(),
              const SizedBox(height: 16),
              HabitHeatmapWidget(
                completedDates: List.generate(200, (_) {
                  // Generate a random number of days between 1 and 365
                  final randomDays = 1 + Random().nextInt(365);
                  return DateTime.now().subtract(Duration(days: randomDays));
                }),
              ),
            ]),
          ),
          bottomNavigationBar: CheckinSliderWidget(),
        ),
      ),
    );
  }
}
