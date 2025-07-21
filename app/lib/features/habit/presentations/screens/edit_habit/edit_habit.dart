import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditHabitScreen extends StatelessWidget {
  final String habitId;
  const EditHabitScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Habit'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildSectionHeader(context, 'General'),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Habit Name'),
            subtitle: const Text('e.g., Read a book'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/home/habit/edit/$habitId/name');
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildSectionHeader(context, 'Schedule'),
          ListTile(
            leading: const Icon(Icons.timelapse_outlined),
            title: const Text('Check-in Window'),
            subtitle: const Text('e.g., 8:00 AM - 9:00 AM'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/home/habit/edit/$habitId/check-in-window');
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildSectionHeader(context, 'Reminders'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Habit Triggers'),
            subtitle: const Text('e.g., After my morning coffee'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/home/habit/edit/$habitId/triggers');
            },
          ),
          const Divider(indent: 72, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification reminders'),
            subtitle: const Text('e.g., 8:00 AM daily'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/home/habit/edit/$habitId/reminders');
            },
          ),
          const SizedBox(height: 24),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Delete Habit',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              // TODO: Implement delete habit functionality with confirmation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
