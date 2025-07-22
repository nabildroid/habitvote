import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';
import 'package:habitvote/features/user/application/cubits/auth_cubit.dart';
import 'package:habitvote/features/vote/presentation/widgets/candidats_voting.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    backgroundImage: NetworkImage(
                      context.read<AuthCubit>().state.user?.photoURL ??
                          'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.read<AuthCubit>().state.user?.displayName ??
                            'Guest User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Free Plan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      Navigator.pop(context);
                      // Add profile edit navigation
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // Points display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '150 Points',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Edit Habit',
                    onTap: () {
                      Navigator.pop(context);

                      final habitId =
                          context.read<HabitTrackerCubit>().state.habit?.id;

                      if (habitId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No habit selected')));
                        return;
                      }
                      context.go("/home/habit/edit/$habitId");
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.insights_outlined,
                    title: 'Statistics',
                    onTap: () {
                      Navigator.pop(context);
                      context.go("/home/habit/stats");
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Subscription Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: BrilliantOkButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Add subscription navigation
                },
                text: "Upgrade to Premium",
                color: Theme.of(context).primaryColor,
                borderColor: Color.lerp(
                    Theme.of(context).primaryColor, Colors.black, 0.4)!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isHighlighted ? Theme.of(context).primaryColor : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color:
                isHighlighted ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -0.5),
      ),
    );
  }
}
