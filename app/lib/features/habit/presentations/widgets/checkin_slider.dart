import 'package:flutter/material.dart';
import 'package:habitvote/features/habit/presentations/utils/habit_context_extension.dart';

class CheckinSliderWidget extends StatefulWidget {
  final VoidCallback onChecked;
  const CheckinSliderWidget({super.key, required this.onChecked});

  @override
  State<CheckinSliderWidget> createState() => _CheckinSliderWidgetState();
}

class _CheckinSliderWidgetState extends State<CheckinSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff111111),
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 80, 80, 80),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
          .copyWith(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xff111111),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Color(0xff333333), width: 1),
                  ),
                  child: SlideToConfirm(onConfirmed: (completed) {
                    widget.onChecked();
                  }),
                ),
              ),
              const SizedBox(width: 16),
              if (context.habitState.todayCheckin == null)
                GestureDetector(
                  onTap: () {
                    context.habitCubit.checkIn(isDone: false);
                  },
                  child: SkipButton(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.watchHabitState.todayCheckin != null
                ? (context.habitState.todayCheckin!.isDone
                    ? 'Completed habit!'
                    : 'Failed habit!')
                : 'Slide right to complete or tap left to fail',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade700,
      ),
      child: Icon(Icons.thumb_down, color: Colors.white),
    );
  }
}

class SlideToConfirm extends StatefulWidget {
  final Function(bool) onConfirmed;
  final bool canRevert;

  const SlideToConfirm({
    Key? key,
    required this.onConfirmed,
    this.canRevert = true, // Default to true to allow reverting
  }) : super(key: key);

  @override
  _SlideToConfirmState createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  // Constants for sizing and padding
  static const double _thumbSize = 50.0;
  static const double _padding = 5.0;
  static const double _animationDuration = 350.0; // Increased duration

  double position = 0.0;
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Check if there's a check-in already and adjust slider position
    final hasCheckin = context.watchHabitState.todayCheckin != null;

    // Update position if there's a check-in already
    if (hasCheckin && position == 0.0 && !isDragging) {
      position = 1.0; // Move to completed position
    }

    if (position == 1.0 && !hasCheckin && !isDragging) {
      position = 0.0; // Move to initial position
    }

    return LayoutBuilder(builder: (context, constraints) {
      final double trackWidth =
          constraints.maxWidth - (_padding * 2) - _thumbSize;

      return GestureDetector(
        onHorizontalDragStart: (details) {
          // Allow dragging if reverting is enabled and there's a check-in,
          // or if there's no check-in yet
          if (hasCheckin && !widget.canRevert) return;
          setState(() {
            isDragging = true;
          });
        },
        onHorizontalDragUpdate: (details) {
          // Allow dragging if reverting is enabled and there's a check-in,
          // or if there's no check-in yet
          if (hasCheckin && !widget.canRevert) return;
          setState(() {
            position += details.delta.dx / trackWidth;
            position = position.clamp(0.0, 1.0);
          });
        },
        onHorizontalDragEnd: (details) {
          if (hasCheckin && !widget.canRevert) return;

          setState(() {
            isDragging = false;

            if (hasCheckin) {
              // Handle revert logic
              if (position <= 0.1) {
                // Reverted action if dragged back to start
                position = 0.0;
                _revertAction(context);
              } else {
                // Snap back to end if not dragged enough
                position = 1.0;
              }
            } else {
              // Original completion logic
              if (position >= 0.9) {
                position = 1.0;
                context.habitCubit.checkIn();
                widget.onConfirmed(true);
              } else {
                position = 0.0;
              }
            }
          });
        },
        child: Container(
          height: 60,
          width: double.infinity,
          child: Stack(
            children: [
              // Text row with habit description
              Row(
                children: [
                  SizedBox(
                      width: hasCheckin ? _padding : _thumbSize + _padding * 2),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        child: _buildHabitDescription(context),
                      ),
                    ),
                  ),
                  SizedBox(width: _thumbSize + _padding),
                ],
              ),

              // Animated thumb
              AnimatedPositioned(
                duration: Duration(
                    milliseconds: isDragging ? 0 : _animationDuration.toInt()),
                curve: Curves.easeOutCubic, // Smoother curve
                left: _padding + position * trackWidth,
                top: (60 - _thumbSize) / 2,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: _animationDuration.toInt()),
                  switchInCurve: Curves.easeOutCubic, // Smoother curve
                  switchOutCurve: Curves.easeInCubic, // Smoother curve
                  child: (context.habitState.todayCheckin == null ||
                          context.habitState.todayCheckin!.isDone)
                      ? PostiveSlider()
                      : SkipButton(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Helper function to revert the check-in action
  void _revertAction(BuildContext context) {
    if (context.habitState.todayCheckin != null) {
      context.habitCubit.undoCheckIn();
    }
  }

  Text _buildHabitDescription(BuildContext context) {
    final isToday = context.watchHabitState.todayCheckin != null;
    final isDone = context.watchHabitState.todayCheckin?.isDone ?? false;
    return Text(
      context.habitState.habit!.description,
      style: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
        decoration: isToday ? TextDecoration.lineThrough : TextDecoration.none,
        decorationStyle: TextDecorationStyle.solid,
        decorationThickness: 3,
        decorationColor: isToday
            ? (isDone ? Colors.green.shade400 : Colors.red.shade400)
            : Colors.transparent,
        fontSize: 16,
      ),
    );
  }
}

class PostiveSlider extends StatelessWidget {
  const PostiveSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xff9ece04),
      ),
      child: Icon(Icons.double_arrow, color: Colors.black, size: 28),
    );
  }
}
