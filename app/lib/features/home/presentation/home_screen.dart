import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitvote/features/vote/presentation/widgets/today_voters.dart';

import '../../tracker/presentations/widgets/checkin_slider.dart';
import 'widgets/custom_app_bar.dart';
import '../../tracker/presentations/widgets/habit_heatmap.dart';
import '../../vote/presentation/widgets/social_overview.dart';

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
              TodayVotersWidget(
                showEmpty: true,
              ),
              const SizedBox(height: 16),
              HabitHeatmapWidget(
                habitIcon: Icons.book,
                startDayOfWeek: 0, // 0 = Sunday
              ),
            ]),
          ),
          bottomNavigationBar: CheckinSliderWidget(),
        ),
      ),
    );
  }
}
