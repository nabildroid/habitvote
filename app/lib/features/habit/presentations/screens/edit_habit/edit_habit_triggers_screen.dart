import 'package:flutter/material.dart';
import 'package:habitvote/shared/widgets/verticalTimeHeatmap/vertical_time_heatmap.dart';

class EditHabitTriggersScreen extends StatefulWidget {
  final String habitId;
  const EditHabitTriggersScreen({super.key, required this.habitId});

  @override
  State<EditHabitTriggersScreen> createState() =>
      _EditHabitTriggersScreenState();
}

class _EditHabitTriggersScreenState extends State<EditHabitTriggersScreen> {
  List<TimeOfDay> _triggers = [];

  @override
  void initState() {
    super.initState();
    // TODO: Fetch initial triggers for the habit using widget.habitId
  }

  void _toggleTrigger(TimeOfDay time) {
    setState(() {
      final index = _triggers
          .indexWhere((t) => t.hour == time.hour && t.minute == time.minute);
      if (index != -1) {
        _triggers.removeAt(index);
      } else {
        _triggers.add(time);
      }
    });
  }

  void _clearTriggers() {
    setState(() {
      _triggers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Habit Triggers'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("When Do You Need Motivation?",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
              const SizedBox(height: 16),
              Text(
                  "Tap on the timeline to mark the moments you usually struggle. We'll send you extra support during these critical times.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      )),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _clearTriggers,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400, // Define a height for the heatmap
                child: VerticalTimeHeatmap(
                  selectedTimes: _triggers,
                  onTimeTap: _toggleTrigger,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${_triggers.length} critical times selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
