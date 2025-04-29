import 'package:flutter/material.dart';
import 'package:habitvote/shared/activate_notification_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Define the gradient
    final Shader linearGradient = LinearGradient(
      colors: <Color>[
        const Color(0xFFE3FF00), // Color at 38%
        const Color(0xFF008A00), // Color at 100%
      ],
      stops: [0.38, 1.0], // Define the stops
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => linearGradient,
        child: const Text(
          'HabitVote',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            showActivateNotificationDialog(context);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
