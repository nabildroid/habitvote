import 'package:flutter/material.dart';

class CheckinSliderWidget extends StatefulWidget {
  const CheckinSliderWidget({super.key});

  @override
  State<CheckinSliderWidget> createState() => _CheckinSliderWidgetState();
}

class _CheckinSliderWidgetState extends State<CheckinSliderWidget> {
  bool? isDone; // null = not checked, false = failed, true = completed

  @override
  Widget build(BuildContext context) {
    final isChecked = isDone != null;

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
          Row(
            children: [
              // Right slide-to-confirm area
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xff111111),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xff333333), width: 1),
                  ),
                  child: SlideToConfirm(onConfirmed: (completed) {
                    setState(() {
                      isDone = completed;
                    });
                  }),
                ),
              ),
              const SizedBox(width: 16),

              GestureDetector(
                onTap: () {
                  setState(() {
                    isDone = false; // Mark as failed
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade700,
                  ),
                  child: Icon(Icons.thumb_down, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isChecked
                ? (isDone == true ? 'Completed habit!' : 'Failed habit!')
                : 'Slide right to complete or tap left to fail',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class SlideToConfirm extends StatefulWidget {
  final Function(bool) onConfirmed;

  const SlideToConfirm({Key? key, required this.onConfirmed}) : super(key: key);

  @override
  _SlideToConfirmState createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double position = 0.0; // start at left
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
            if (position >= 0.9) {
              // Threshold for right confirmation
              position = 1.0; // Snap to end
              widget.onConfirmed(true); // Mark as completed
            } else {
              // Return to start if not confirmed
              position = 0.0;
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

              Row(
                children: [
                  SizedBox(width: 50 + _padding), // Left padding
                  Expanded(
                    child: Center(
                      child: Text(
                        'Meditated for 60 min',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 50 + _padding), // Left padding
                ],
              ),

              AnimatedPositioned(
                duration: Duration(
                    milliseconds: isDragging ? 0 : 200), // Animate snap back
                curve: Curves.easeOut,
                left: _padding + position * trackWidth, // Calculate left offset
                top: (60 - _thumbSize) / 2, // Center vertically
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff9ece04), // Bright green color from image
                  ),
                  child:
                      Icon(Icons.double_arrow, color: Colors.black, size: 28),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
