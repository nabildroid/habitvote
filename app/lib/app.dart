import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitvote/core/custom_router.dart';

import 'core/locator.dart';
import 'features/tracker/application/cubits/habit_tracker_cubit.dart';

class HabitVoteApp extends StatelessWidget {
  const HabitVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => HabitTrackerCubit()),
      ],
      child: MaterialApp.router(
        localizationsDelegates: [
          // AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
        ],
        debugShowCheckedModeBanner: false,
        title: 'HabitVote',
        locale: const Locale('en'),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFFCBE724), // Bright green color
          textTheme: GoogleFonts.vazirmatnTextTheme(),
        ),
        routerConfig: router,
      ),
    );
  }
}
