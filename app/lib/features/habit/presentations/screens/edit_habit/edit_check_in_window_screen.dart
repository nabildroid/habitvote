import 'package:flutter/material.dart';
import 'package:habitvote/shared/widgets/timeWindowPicker/time_window_picker.dart';

class EditCheckInWindowScreen extends StatefulWidget {
  final String habitId;
  const EditCheckInWindowScreen({super.key, required this.habitId});

  @override
  State<EditCheckInWindowScreen> createState() =>
      _EditCheckInWindowScreenState();
}

class _EditCheckInWindowScreenState extends State<EditCheckInWindowScreen> {
  late TimeOfDay _openWindow;
  late TimeOfDay _closeWindow;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch initial values from habit using widget.habitId
    _openWindow = const TimeOfDay(hour: 8, minute: 0);
    _closeWindow = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Check-in Window'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save logic
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Set Your Daily Check-in Time",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
            const SizedBox(height: 8),
            Text(
              "Select the time window to report your habit's status for the day.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TimeDisplay(
                  title: 'Check-in Starts',
                  time: _openWindow,
                  icon: Icons.notifications_active_outlined,
                ),
                _TimeDisplay(
                  title: 'Check-in Ends',
                  time: _closeWindow,
                  icon: Icons.notifications_off_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TimeWindowPicker(
              startTime: _openWindow,
              endTime: _closeWindow,
              onTimeChanged: (start, end) {
                setState(() {
                  _openWindow = start;
                  _closeWindow = end;
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      "You can only report your habit's status during this time. Missing the check-in marks the habit as failed for the day.",
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final IconData icon;

  const _TimeDisplay({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time.format(context),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
