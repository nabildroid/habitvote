import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:vocafusion/features/home/presentation/home_screen.dart';

void main() {
  runApp(const HabitVoteApp());
}

class HabitVoteApp extends StatelessWidget {
  const HabitVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitVote',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFCBE724), // Bright green color
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
