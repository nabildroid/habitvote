import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/widgets/appbar_streak_badge.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    List<Widget>? actions,
  }) : super(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          titleSpacing: 0,
          title: Builder(builder: (context) {
            return RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(text: 'Habit'),
                  TextSpan(
                    text: 'Vote',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            );
          }),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AppBarStreakBadge()),
          ],
        );
}
