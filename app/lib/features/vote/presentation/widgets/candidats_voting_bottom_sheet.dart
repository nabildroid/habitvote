import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:habitvote/features/vote/data/models/candidat_model.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart'; // For Path dash effects

class CandidatsVotingBottomSheet extends StatefulWidget {
  const CandidatsVotingBottomSheet({super.key});

  @override
  State<CandidatsVotingBottomSheet> createState() =>
      _CandidatsVotingBottomSheetState();
}

class _CandidatsVotingBottomSheetState
    extends State<CandidatsVotingBottomSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  finish() {
    context.voteCubit.activateTodayVotes();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final candidats = context.watchVoteState.todayCandidats;
    return Container(
      padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E), // Dark background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional: Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          if (candidats.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else
            SizedBox(
              // Constrain the height of the PageView area
              // Adjust height as needed based on content
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView(
                controller: _pageController,
                children: candidats.map((candidat) {
                  return HabitProgressPage(
                    data: candidat,
                    currentPage: _currentPage + 1,
                    totalPages: candidats.length,
                    onWin: () {
                      context.voteCubit.voteOn(candidat, true);
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                      if (_currentPage == candidats.length - 1) {
                        finish();
                      }
                    },
                    onLose: () {
                      context.voteCubit.voteOn(candidat, false);
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );

                      if (_currentPage == candidats.length - 1) {
                        finish();
                      }
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Page Content Widget ---
class HabitProgressPage extends StatelessWidget {
  final CandidatModel data;
  final int currentPage;
  final int totalPages;
  final VoidCallback onWin;
  final VoidCallback onLose;

  const HabitProgressPage({
    super.key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onWin,
    required this.onLose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Title Area ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1", style: const TextStyle(fontSize: 24)), // Flag
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.habit.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data.habit.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentPage / $totalPages',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Grid Area ---
          // Use a fixed height container for the grid + arrow area
          LayoutBuilder(builder: (context, constraints) {
            // Calculate grid dimensions
            final gridPainter = HabitGridPainter(
              completedIndices: _getCompletedIndices(
                  data.checkins
                      .where((e) => e.isDone)
                      .map((e) => e.date)
                      .toList(),
                  35),
              totalSquares: 35,
              highlightIndex: 10,
              gridColumns: 7,
            );

            final bottomRightSquarePosition = gridPainter
                .getBottomRightSquarePosition(Size(constraints.maxWidth, 200));

            return SizedBox(
              height: 200, // Adjust as needed
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: gridPainter,
                      size: Size(constraints.maxWidth, 200),
                    ),
                  ),
                  // Dashed Arrow Painter - Positioned from bottom-right to center
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Transform(
                      alignment: Alignment(0, 1.5),
                      transform: Matrix4.identity()..scale(1.0, -1.0),
                      child: CustomPaint(
                        size: Size(constraints.maxWidth,
                            85), // Adjust height as needed
                        painter: DashedArrowPainter(
                          startPosition: bottomRightSquarePosition,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Flexible spacer to push buttons down if needed, or use SizedBox
          const Spacer(),

          // --- Buttons Area ---
          Padding(
            // Add padding to prevent buttons touching screen edge if sheet is full height
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAFFF3C), // Bright green
                    foregroundColor: Colors.black, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: onWin,
                  child: const Text('Win', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE84C5A), // Red
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: onLose,
                  child: const Text('Lose', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to convert dates to grid indices (needs refinement based on actual start date)
  Set<int> _getCompletedIndices(List<DateTime> dates, int totalDays) {
    final Set<int> indices = {};
    final now = DateTime.now();
    for (final date in dates) {
      final daysAgo = now.difference(date).inDays;
      if (daysAgo >= 0 && daysAgo < totalDays) {
        // This assumes index 0 is 'today' or the most recent day displayed
        // and counts backwards. Adjust logic if grid represents a fixed period.
        indices.add(daysAgo);
      }
    }
    // This logic is basic and might need adjustment depending on how
    // the grid represents time (e.g., fixed calendar weeks vs. last N days).
    // For the image, it looks like the most recent day is bottom-right.
    // Let's reverse the index calculation for that layout:
    final reversedIndices = <int>{};
    for (final index in indices) {
      reversedIndices.add(totalDays - 1 - index);
    }
    // return indices;
    return reversedIndices; // Use this if bottom-right is the most recent
  }
}

// --- Custom Painter for the Grid ---
class HabitGridPainter extends CustomPainter {
  final Set<int> completedIndices;
  final int totalSquares;
  final int highlightIndex; // Index of the square to highlight
  final int gridColumns;
  final double squareSize;
  final double gap;
  final Color completedColor;
  final Color defaultColor;
  final Color highlightColor;
  final double highlightStrokeWidth;

  HabitGridPainter({
    required this.completedIndices,
    required this.totalSquares,
    this.highlightIndex = 29, // Default to no highlight
    this.gridColumns = 7, // Default to 7 columns (like a week)
    this.squareSize = 30.0,
    this.gap = 4.0,
    this.completedColor = const Color(0xFFAFFF3C), // Bright green from image
    this.defaultColor = const Color(0xFF3A3A3C), // Darker grey/green
    this.highlightColor = Colors.white,
    this.highlightStrokeWidth = 2.0,
  });

  // Method to calculate the position of the bottom-right square
  Offset getBottomRightSquarePosition(Size canvasSize) {
    final gridRows = (totalSquares / gridColumns).ceil();
    final totalGridWidth = gridColumns * squareSize + (gridColumns - 1) * gap;
    final totalGridHeight = gridRows * squareSize + (gridRows - 1) * gap;

    // Center the grid within the canvas size
    final startX = (canvasSize.width - totalGridWidth) / 2;
    final startY = (canvasSize.height - totalGridHeight) / 2;

    // Get the position of the last square (bottom-right corner)
    final lastSquareIndex = gridColumns * gridRows - 1;
    final lastSquareRow = lastSquareIndex ~/ gridColumns;
    final lastSquareCol = (lastSquareIndex % gridColumns);

    // If we don't have enough squares to fill the entire grid,
    // use the bottom-right of the actual last square
    final lastActualSquareIndex = min(totalSquares - 1, lastSquareIndex);
    final actualRow = lastActualSquareIndex ~/ gridColumns;
    final actualCol = lastActualSquareIndex % gridColumns;

    // Calculate center of the bottom-right square
    final x = startX + actualCol * (squareSize + gap) + squareSize / 2;
    final y = startY + actualRow * (squareSize + gap) + squareSize / 2;

    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paintCompleted = Paint()..color = completedColor;
    final paintDefault = Paint()..color = defaultColor;
    final paintHighlight = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlightStrokeWidth;

    final gridRows = (totalSquares / gridColumns).ceil();
    final totalGridWidth = gridColumns * squareSize + (gridColumns - 1) * gap;
    final totalGridHeight = gridRows * squareSize + (gridRows - 1) * gap;

    // Center the grid within the canvas size
    final startX = (size.width - totalGridWidth) / 2;
    final startY = (size.height - totalGridHeight) / 2;

    for (int i = 0; i < totalSquares; i++) {
      final row = i ~/ gridColumns;
      final col = i % gridColumns;

      final x = startX + col * (squareSize + gap);
      final y = startY + row * (squareSize + gap);

      final rect = Rect.fromLTWH(x, y, squareSize, squareSize);
      final rrect = RRect.fromRectAndRadius(
          rect, const Radius.circular(3.0)); // Rounded squares

      // Determine paint based on completion status
      final paint =
          completedIndices.contains(i) ? paintCompleted : paintDefault;
      canvas.drawRRect(rrect, paint);

      // Draw highlight border if this is the index to highlight
      if (i == totalSquares - 1) {
        // Draw slightly larger rect for the border outline
        final highlightRect = Rect.fromLTWH(
            x - highlightStrokeWidth / 2,
            y - highlightStrokeWidth / 2,
            squareSize + highlightStrokeWidth,
            squareSize + highlightStrokeWidth);
        final highlightRRect = RRect.fromRectAndRadius(highlightRect,
            const Radius.circular(4.0)); // Slightly larger radius
        canvas.drawRRect(highlightRRect, paintHighlight);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HabitGridPainter oldDelegate) {
    return oldDelegate.completedIndices != completedIndices ||
        oldDelegate.highlightIndex != highlightIndex ||
        oldDelegate.totalSquares != totalSquares;
  }
}

// --- Custom Painter for the Dashed Arrow ---
class DashedArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Offset startPosition;

  DashedArrowPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
    this.dashPattern = const [4, 4],
    this.startPosition = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Define the path for the arrow starting from the bottom-right square
    // and ending at the middle between buttons
    final path = Path();

    // Start point - use the exact position of the bottom-right square
    final startX = startPosition.dx != 0 ? startPosition.dx : size.width * 0.85;
    final startY = startPosition.dy != 0 ? startPosition.dy : 0.0;
    path.moveTo(startX, startY);

    // Middle point of the bottom of the canvas (between the buttons)
    final endX = size.width * 0.5;
    final endY = size.height;

    // Control points for a smooth curve
    // First control point - move out from the start point
    final ctrl1X = startX;
    final ctrl1Y = startY + (endY - startY) * 0.4;

    // Second control point - approach the target from above
    final ctrl2X = endX;
    final ctrl2Y = endY - (endY - startY) * 0.4;

    // Draw a cubic Bezier curve for a smoother path
    path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, endX, endY);

    // Draw the dashed line
    final dashedPath = _dashPath(path, dashPattern);
    canvas.drawPath(dashedPath, paint);

    // Calculate the approaching angle for the arrowhead
    // For a cubic Bezier, we can approximate the end tangent
    final dx = endX - ctrl2X;
    final dy = endY - ctrl2Y;
    final angle = atan2(dy, dx);

    // Draw the arrowhead
    final arrowSize = 6.0;
    final arrowPath = Path();
    arrowPath.moveTo(endX - arrowSize * cos(angle - pi / 6),
        endY - arrowSize * sin(angle - pi / 6));
    arrowPath.lineTo(endX, endY); // Tip of arrow
    arrowPath.lineTo(endX - arrowSize * cos(angle + pi / 6),
        endY - arrowSize * sin(angle + pi / 6));

    canvas.drawPath(arrowPath, paint); // Draw arrowhead
  }

  // Helper function to create a dashed path
  Path _dashPath(Path source, List<double> dashPattern) {
    final Path dest = Path();
    final dashLength = dashPattern.length;
    int dashIndex = 0;
    bool draw = true;

    for (final pathMetric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double len = dashPattern[dashIndex];
        if (draw) {
          dest.addPath(
              pathMetric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        dashIndex = (dashIndex + 1) % dashLength;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant DashedArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern;
  }
}
