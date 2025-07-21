import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';
import 'package:habitvote/features/home/presentation/menu_drawer.dart';
import 'package:habitvote/features/home/presentation/widgets/checkin.dart';
import 'package:habitvote/features/habit/presentations/widgets/streak_view.dart';
import 'package:habitvote/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:habitvote/features/user/application/cubits/presence_cubit.dart';
import 'package:habitvote/features/user/presentation/widget/presence/users_live_map.dart';
import 'package:habitvote/features/vote/presentation/widgets/today_voters_overview.dart';
import 'package:habitvote/shared/widgets/gradientDevider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      drawer: const MenuDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Builder(builder: (ctx) {
                      return Text(
                        ctx.watch<HabitTrackerCubit>().state.habit?.name ??
                            'Welcome to HabitVote',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      );
                    }),
                    const SizedBox(height: 30),
                    StreakView(),
                    const SizedBox(height: 15),
                    Gradientdevider(),
                    const SizedBox(height: 30),
                    _buildTodayVotersOverview(context),
                    const SizedBox(height: 10),
                  ]),
            ),
            AspectRatio(
              aspectRatio: 15 / 5,
              child: UsersLiveMap(),
            ),
            const SizedBox(height: 20),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: 65,
                  child: ColoredBox(color: Colors.grey.shade100),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CheckIn(),
                ),
              ],
            ),
            Container(
              color: Colors.grey.shade100,
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Gradientdevider(),
                    const SizedBox(height: 40),
                    const Text(
                      'Know Your Why',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTodayVotersOverview(BuildContext context) {
    return StreamBuilder(
      stream: context.habitCubit.durationToOpenWindow,
      builder: (ctx, s) => TodayVotersOverview(
        activePeople: context.watch<PresenceCubit>().state.liveUsers,
        resultMin: s.data?.inMinutes ?? 0,
      ),
    );
  }
}
