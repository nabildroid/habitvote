import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';
import 'package:habitvote/features/vote/presentation/utils/voting_popup_context_extension.dart';
import 'package:habitvote/features/vote/presentation/widgets/vote_summary_bottom_sheet.dart';

class TodayVotersWidget extends StatefulWidget {
  // add empty-state toggle
  final bool showEmpty;
  const TodayVotersWidget({super.key, this.showEmpty = false});

  @override
  State<TodayVotersWidget> createState() => _TodayVotersWidgetState();
}

class _TodayVotersWidgetState extends State<TodayVotersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsAnimationController;

  @override
  void initState() {
    super.initState();
    _dotsAnimationController = AnimationController(
      duration: const Duration(seconds: 10), // e.g., 10 seconds
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TODAY',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildVoteTypeWidget(
                    emoji: '😑',
                    label: 'Challengers',
                    description: 'They Say You Can\'t',
                    isPositive: false,
                    count: context.voteState.today?.down ?? 0,
                  ),
                  const SizedBox(width: 16),
                  _buildVoteTypeWidget(
                    emoji: '😎',
                    label: 'Believers',
                    description: 'They Say You Can',
                    isPositive: true,
                    count: context.voteState.today?.up ?? 0,
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          _buildVoteCircle(),
        ],
      ),
    );
  }

  Widget _buildVoteTypeWidget({
    required String emoji,
    required String label,
    required bool isPositive,
    String? description,
    int count = 88, // Example count for visual effect
  }) {
    final showEmpty = context.watchVoteState.votes.length < 2 &&
        (context.voteState.today?.total ?? 0) == 0;

    final isVoteActivated = context.voteState.today?.isActivated == true;

    final showDescription =
        showEmpty && description != null && !isVoteActivated;
    // Use IntrinsicWidth to make the column take the width of its widest child
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Take minimum vertical space
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Make children stretch horizontally
        children: [
          // Container for the emoji
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6), // Adjust padding
            decoration: BoxDecoration(
              // Slightly darker background or transparent if needed
              color: Colors.grey.shade900.withAlpha(125),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPositive
                    ? Theme.of(context)
                        .primaryColor
                        .withAlpha(50) // Green for believers
                    : Colors.red.shade700.withAlpha(50), // Red for challengers
                width: 1, // Slightly thicker border
              ),
            ),
            alignment: Alignment.center, // Center the emoji
            child: Text(emoji,
                style: const TextStyle(fontSize: 24)), // Larger emoji
          ),
          const SizedBox(height: 8), // Space between emoji container and label
          // Label below the container
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            textAlign: TextAlign.center,
          ),

          if (showDescription)
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

          // Blurred count
          if (!showDescription)
            GestureDetector(
              onTap: () {
                if (context.voteState.today?.isActivated == true) return;
                context.showVoteBottomsheet();
              },
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: isVoteActivated ? 0 : 3,
                  sigmaY: isVoteActivated ? 0 : 2,
                ),
                child: Text(
                  count
                      .toString()
                      .padLeft(2, '0'), // Pad with '8' for blur effect
                  style: TextStyle(
                    color: Colors.white, // Darker grey for blurred effect
                    fontSize: 16, // Slightly larger font for blurred number
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoteCircle() {
    final showEmpty = context.watchVoteState.votes.length < 2 &&
        (context.voteState.today?.total ?? 0) == 0;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xff424242),
          width: 3,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      // Clip the contents to the circle shape
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated dots in background
          AnimatedBuilder(
            animation: _dotsAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: DotsPainter(
                  animation: _dotsAnimationController,
                  positiveColor:
                      Theme.of(context).primaryColorLight, // Use theme color
                  negativeColor: Colors.red.shade700, // Use red for negative
                  positiveCount:
                      context.voteState.today?.up ?? 23, // total positives
                  negativeCount:
                      context.voteState.today?.down ?? 7, // total negatives
                ),
                size: const Size(120, 120),
              );
            },
          ),
          // Blur overlay using BackdropFilter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.1), // Slight tint
                ),
              ),
            ),
          ),
          // Vote count
          if (showEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your',
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  'Voters',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Zone',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          if (!showEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.voteState.today?.total.toString() ?? "0",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Votes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  final Animation<double> animation;
  final Color positiveColor;
  final Color negativeColor;
  final int positiveCount;
  final int negativeCount;
  // Use a single Random instance seeded once for consistent randomness across paints
  final math.Random random = math.Random(42);
  // Store initial random properties for each dot
  late final List<_DotProperties> _dotProperties;

  DotsPainter({
    required this.animation,
    required this.positiveColor,
    required this.negativeColor,
    required this.positiveCount,
    required this.negativeCount,
  }) {
    final total = positiveCount + negativeCount;
    // Initialize properties once
    _dotProperties = List.generate(total, (i) {
      // Increased dot count slightly
      final angle = random.nextDouble() * 2 * math.pi;
      // Start dots more spread out, not just at center
      final initialRadius = math.pow(random.nextDouble(), 0.5) *
          0.9; // Power < 1 biases towards edge
      final speedFactor = random.nextDouble() * 0.5 + 0.5; // Vary speed
      final direction = random.nextBool() ? 1.0 : -1.0; // Vary direction
      final size = random.nextDouble() * 4.0 + 1.5; // Vary size
      final isPositive = i < positiveCount;
      final initialOpacity =
          0.5 + random.nextDouble() * 0.4; // Vary initial opacity

      return _DotProperties(
        initialAngle: angle,
        initialRadiusFactor: initialRadius,
        speedFactor: speedFactor,
        direction: direction,
        size: size,
        isPositive: isPositive,
        initialOpacity: initialOpacity,
      );
    });
    _dotProperties.shuffle(random);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.9; // Max distance from center

    for (int i = 0; i < _dotProperties.length; i++) {
      final props = _dotProperties[i];

      // Calculate current angle: initial + animation progress * speed * direction
      // Add a slow sinusoidal variation to the angle for drifting effect
      final drift =
          math.sin(animation.value * 2 * math.pi * 0.5 + props.initialAngle) *
              0.3; // Slow drift
      final currentAngle = props.initialAngle +
          drift +
          (animation.value * 2 * math.pi * props.speedFactor * props.direction);

      // Calculate current distance from center: vary slightly with animation
      // Use a sine wave based on animation value and initial radius for pulsing effect
      final radiusVariation = math.sin(animation.value * 2 * math.pi +
          (i / _dotProperties.length * math.pi)); // Offset phase per dot
      final currentRadius = maxRadius *
          props.initialRadiusFactor *
          (1 + radiusVariation * 0.1); // 10% pulse

      final x = center.dx + math.cos(currentAngle) * currentRadius;
      final y = center.dy + math.sin(currentAngle) * currentRadius;

      // Fade opacity slightly based on animation value (e.g., pulse opacity)
      final opacityVariation = math.sin(animation.value * 2 * math.pi * 2 +
          props.initialAngle); // Faster pulse
      final currentOpacity =
          (props.initialOpacity * (1 + opacityVariation * 0.2))
              .clamp(0.3, 0.9); // Clamp opacity

      final color = (props.isPositive ? positiveColor : negativeColor)
          .withOpacity(currentOpacity);

      final paint = Paint()..color = color;
      // Prevent drawing outside the circle bounds (optional, clipBehavior handles most)
      if ((Offset(x, y) - center).distanceSquared < maxRadius * maxRadius) {
        canvas.drawCircle(Offset(x, y), props.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotsPainter oldDelegate) =>
      true; // Always repaint for animation
}

// Helper class to store properties for each dot
class _DotProperties {
  final double initialAngle;
  final double initialRadiusFactor;
  final double speedFactor;
  final double direction;
  final double size;
  final bool isPositive;
  final double initialOpacity;

  _DotProperties({
    required this.initialAngle,
    required this.initialRadiusFactor,
    required this.speedFactor,
    required this.direction,
    required this.size,
    required this.isPositive,
    required this.initialOpacity,
  });
}
