import 'package:flutter/material.dart';
import 'package:habitvote/shared/widgets/verticalTimeHeatmap/vertical_time_heatmap.dart';

class TriggerHeatMap extends StatefulWidget {
  const TriggerHeatMap({super.key});

  @override
  State<TriggerHeatMap> createState() => _TriggerHeatMapState();
}

class _TriggerHeatMapState extends State<TriggerHeatMap> {
  List<TimeOfDay> _selectedTimes = [];

  void _addTime(TimeOfDay time) {
    setState(() {
      // Avoid adding duplicate times
      if (!_selectedTimes
          .any((t) => t.hour == time.hour && t.minute == time.minute)) {
        _selectedTimes.add(time);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... Title and Subtitle ...
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
          const SizedBox(height: 40),
          SizedBox(
            height: 400, // Define a height for the heatmap
            child: VerticalTimeHeatmap(
              selectedTimes: _selectedTimes,
              onTimeTap: _addTime,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${_selectedTimes.length} critical times selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
