import 'package:flutter/material.dart';

enum SlideDirection { left, right }

class CheckinSliderWidget extends StatefulWidget {
  const CheckinSliderWidget({super.key});

  @override
  State<CheckinSliderWidget> createState() => _CheckinSliderWidgetState();
}

class _CheckinSliderWidgetState extends State<CheckinSliderWidget> {
  SlideDirection? _confirmedDirection;
  double _confirmedSliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    final isConfirmed = _confirmedDirection != null;
    final isTimeToCheckIn = DateTime.now().hour >= 20; // Example check-in time

    return Container(
      // Use the dark background color consistent with the bottom area
      decoration: BoxDecoration(
        color: Color(0xff111111),
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(
                255, 80, 80, 80), // Slightly whiter than the background
            width: 1.0,
          ),
        ),
      ),

      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
          .copyWith(bottom: 16), // Add some bottom padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Take minimum space
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left Emoji (Challenger)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '😑',
                      style: TextStyle(
                        fontSize: 24,
                        // Dim if confirmed right
                        color: isConfirmed &&
                                _confirmedDirection == SlideDirection.right
                            ? Colors.grey.shade700
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Right Emoji (Believer)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      '😎',
                      style: TextStyle(
                        fontSize: 24,
                        // Dim if confirmed left
                        color: isConfirmed &&
                                _confirmedDirection == SlideDirection.left
                            ? Colors.grey.shade700
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Only show the slider if not confirmed
                if (!isConfirmed)
                  SlideToConfirm(
                    onConfirmed: (direction) {
                      setState(() {
                        _confirmedDirection = direction;
                        _confirmedSliderPosition =
                            direction == SlideDirection.left ? 0.0 : 1.0;
                        // Potentially trigger other actions here
                      });
                    },
                  )
                // Show a static indicator if confirmed
                else
                  Align(
                    alignment: _confirmedDirection == SlideDirection.left
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5), // Match slider margin
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _confirmedDirection == SlideDirection.left
                            ? Colors.red.shade700 // Confirmed red
                            : Theme.of(context).primaryColor, // Confirmed green
                      ),
                      child: Icon(
                        _confirmedDirection == SlideDirection.left
                            ? Icons.close // Example icon for confirmed left
                            : Icons.check, // Example icon for confirmed right
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Add navigation arrows (visual only based on image)
                if (!isConfirmed) // Hide arrows when confirmed
                  Positioned(
                    left: 60, // Adjust position as needed
                    child: Icon(Icons.keyboard_arrow_left,
                        color: Colors.grey.shade700),
                  ),
                if (!isConfirmed)
                  Positioned(
                    left: 80, // Adjust position as needed
                    child: Icon(Icons.keyboard_arrow_left,
                        color: Colors.grey.shade700),
                  ),
                if (!isConfirmed)
                  Positioned(
                    right: 60, // Adjust position as needed
                    child: Icon(Icons.keyboard_arrow_right,
                        color: Colors.grey.shade700),
                  ),
                if (!isConfirmed)
                  Positioned(
                    right: 80, // Adjust position as needed
                    child: Icon(Icons.keyboard_arrow_right,
                        color: Colors.grey.shade700),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // Update text based on confirmation or time
            isConfirmed
                ? (_confirmedDirection == SlideDirection.left
                    ? 'Checked in as Challenger!'
                    : 'Checked in as Believer!')
                : 'You can\'t check in until 8 PM.', // Or dynamic time
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class SlideToConfirm extends StatefulWidget {
  final Function(SlideDirection) onConfirmed;

  const SlideToConfirm({Key? key, required this.onConfirmed}) : super(key: key);

  @override
  _SlideToConfirmState createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double position = 0.5; // Start in the middle
  bool isDragging = false;
  final double _thumbSize = 50.0; // Size of the draggable thumb
  final double _padding = 5.0; // Padding on each side inside the container

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double trackWidth =
          constraints.maxWidth - (_padding * 2) - _thumbSize;

      return GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            isDragging = true;
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            // Calculate new position based on drag relative to the track width
            position += details.delta.dx / trackWidth;
            // Clamp position between 0 and 1
            position = position.clamp(0.0, 1.0);
          });
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            isDragging = false;
            // Check confirmation thresholds
            if (position <= 0.1) {
              // Threshold for left confirmation
              position = 0.0; // Snap to end
              widget.onConfirmed(SlideDirection.left);
            } else if (position >= 0.9) {
              // Threshold for right confirmation
              position = 1.0; // Snap to end
              widget.onConfirmed(SlideDirection.right);
            } else {
              // Return to center if not confirmed
              position = 0.5;
            }
          });
        },
        child: Container(
          height: 60, // Match parent height
          width: double.infinity,
          // Use Stack for precise positioning
          child: Stack(
            children: [
              // Position the thumb based on the 'position' value
              AnimatedPositioned(
                duration: Duration(
                    milliseconds: isDragging ? 0 : 200), // Animate snap back
                curve: Curves.easeOut,
                left: _padding + position * trackWidth, // Calculate left offset
                top: (60 - _thumbSize) / 2, // Center vertically
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Interpolate color from red to green based on position
                    color: Color.lerp(
                      Colors.red.shade700, // Start color (left)
                      Theme.of(context).primaryColor, // End color (right)
                      position, // Interpolation factor
                    ),
                    boxShadow: [
                      BoxShadow(
                        // Interpolate shadow color as well
                        color: Color.lerp(
                          Colors.red.withOpacity(0.4),
                          Theme.of(context).primaryColor.withOpacity(0.4),
                          position,
                        )!,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  // Use the swipe icon
                  child:
                      const Icon(Icons.touch_app_outlined, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
