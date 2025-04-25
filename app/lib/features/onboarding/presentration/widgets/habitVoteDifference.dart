import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HabitVoteDifferenceWidget extends StatelessWidget {
  const HabitVoteDifferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final habitVoteColor = Color(0xff2D2C2D); // Or your app's primary color
    final otherAppsColor = Colors.redAccent;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Your Deterioration Level',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1, // Adjust interval as needed
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5], // Dashed lines
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval:
                            5, // Show label every 5 months (Month 1 and Month 6)
                        getTitlesWidget: bottomTitleWidgets,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      // Hide Y-axis labels
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false, // Hide chart border
                  ),
                  minX: 0,
                  maxX: 6, // Representing 6 months
                  minY: 0, // Min procrastination level
                  maxY: 6, // Max procrastination level (adjust as needed)
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 4), // Start Month 1 - High procrastination
                        FlSpot(1, 4.2),
                        FlSpot(2, 4.8),
                        FlSpot(3, 5),
                        FlSpot(4, 5.5),
                        FlSpot(5, 5.8),
                        FlSpot(6, 6), // End Month 6 - Higher procrastination
                      ],
                      isCurved: true,
                      color: otherAppsColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: otherAppsColor.withOpacity(0.08),
                      ),
                    ),

                    // HabitVote Line
                    LineChartBarData(
                      spots: const [
                        FlSpot(0,
                            4), // Start Month 1 (index 0) - High procrastination
                        FlSpot(1, 3.8),
                        FlSpot(2, 3),
                        FlSpot(3, 2),
                        FlSpot(4, 1.5),
                        FlSpot(5, 1.2),
                        FlSpot(6,
                            1), // End Month 6 (index 6) - Low procrastination
                      ],
                      isCurved: true,
                      color: habitVoteColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData:
                          const FlDotData(show: false), // Hide dots on line
                      belowBarData: BarAreaData(
                        show: true,
                        color: habitVoteColor.withOpacity(0.3),
                      ),
                    ),
                    // Other Apps Line
                  ],
                  // Add touch interaction if needed
                  // lineTouchData: LineTouchData(...)
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Legends or Labels within the chart area might be better placed using Stack
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend(habitVoteColor, 'HabitVote'),
                _buildLegend(otherAppsColor, 'Other Apps'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '80% of HabitVote users reduce their procrastination significantly within 6 months',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.grey,
    );
    Widget text;
    switch (value.toInt()) {
      case 0: // Corresponds to Month 1
        text = const Text('Week 1', style: style);
        break;
      case 6: // Corresponds to Month 6
        text = const Text('Month 6', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
