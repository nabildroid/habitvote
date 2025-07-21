import 'package:flutter/material.dart';

class EditNotificationRemindersScreen extends StatefulWidget {
  final String habitId;
  const EditNotificationRemindersScreen({super.key, required this.habitId});

  @override
  State<EditNotificationRemindersScreen> createState() =>
      _EditNotificationRemindersScreenState();
}

class _EditNotificationRemindersScreenState
    extends State<EditNotificationRemindersScreen> {
  bool _remindBeforeCheckin = true;
  bool _remindRandomly = false;
  bool _remindOnVote = true;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch initial reminder settings for the habit using widget.habitId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Reminders'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save logic
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Choose when you'd like to be reminded about your habit.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('5 minutes before check-in'),
            subtitle: const Text('Get a heads-up before the window opens.'),
            value: _remindBeforeCheckin,
            onChanged: (bool value) {
              setState(() {
                _remindBeforeCheckin = value;
              });
            },
            secondary: const Icon(Icons.alarm_on_outlined),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Randomly during check-in'),
            subtitle:
                const Text('Receive a surprise reminder within the window.'),
            value: _remindRandomly,
            onChanged: (bool value) {
              setState(() {
                _remindRandomly = value;
              });
            },
            secondary: const Icon(Icons.shuffle_outlined),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('When someone votes on you'),
            subtitle: const Text('Get notified when you receive a vote.'),
            value: _remindOnVote,
            onChanged: (bool value) {
              setState(() {
                _remindOnVote = value;
              });
            },
            secondary: const Icon(Icons.how_to_vote_outlined),
          ),
        ],
      ),
    );
  }
}
