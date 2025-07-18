import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    List<Widget>? actions,
  }) : super(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
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
              child: Row(
                children: [
                  const Text(
                    '150',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ],
        );
}
