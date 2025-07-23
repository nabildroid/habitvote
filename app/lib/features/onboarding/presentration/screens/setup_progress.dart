import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SetupProgressSlide extends StatefulWidget {
  final VoidCallback onComplete; // Optional callback for completion
  const SetupProgressSlide({
    super.key,
    required this.onComplete,
  });

  @override
  State<SetupProgressSlide> createState() => _SetupProgressSlideState();
}

class _SetupProgressSlideState extends State<SetupProgressSlide> {
  int _subtitleIndex = 0;
  Timer? _timer;
  double _progress = 0.0;
  int _completedSteps = 0;
  int _pauseCounter = 0;
  final Set<int> _triggeredPauses = {};
  final Map<int, int> _pausePoints = {
    37: 20, // Pause at 37% for 20 ticks (1s)
    51: 15, // Pause at 51% for 15 ticks (0.75s)
    87: 25, // Pause at 87% for 25 ticks (1.25s)
    98: 30, // Pause at 98% for 30 ticks (1.5s)
  };

  final List<String> _subtitles = [
    "Analyzing your preferences...",
    "Selecting your habits...",
    "Finding peers like you...",
    "Preparing your votes...",
    "Building your custom plan...",
    "Finalizing setup...",
  ];

  final List<String> _steps = [
    "Account setup",
    "Habit configuration",
    "Peer matching",
    "Voting system",
    "Personalized plan",
  ];

  @override
  void initState() {
    super.initState();
    _startSetupProcess();
  }

  void _startSetupProcess() {
    const totalDuration = Duration(seconds: 7);
    const updateInterval =
        Duration(milliseconds: 50); // Faster updates for smoother animation
    int ticks = 0;
    final totalTicks =
        totalDuration.inMilliseconds / updateInterval.inMilliseconds;
    final subtitleChangeTick = totalTicks / _subtitles.length;
    final stepChangeTick = totalTicks / _steps.length;
    final random = Random();

    _timer = Timer.periodic(updateInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      int currentPercentage = (_progress * 100).toInt();

      // Check if we should pause
      if (_pausePoints.containsKey(currentPercentage) &&
          !_triggeredPauses.contains(currentPercentage)) {
        _pauseCounter++;
        if (_pauseCounter < _pausePoints[currentPercentage]!) {
          // Still in pause duration, do nothing.
          return;
        } else {
          // Pause finished
          _triggeredPauses.add(currentPercentage);
          _pauseCounter = 0;
        }
      }

      // Simulate a "lag" by sometimes pausing the progress update
      // A lower threshold means longer and more frequent pauses.
      if (random.nextDouble() > 0.1 || _progress < 0.1) {
        ticks++;
        setState(() {
          _progress = min(1.0, ticks / totalTicks);
          _subtitleIndex = (ticks / subtitleChangeTick)
              .floor()
              .clamp(0, _subtitles.length - 1);
          _completedSteps =
              (ticks / stepChangeTick).floor().clamp(0, _steps.length);
        });
      }

      if (_progress >= 1.0) {
        timer.cancel();
        // A small delay before calling onComplete to show 100%
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const darkColor = Color(0xFF212529);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            '${(_progress * 100).toInt()}%',
            style: textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "We're setting\neverything up for you",
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: constraints.maxWidth * _progress,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6579FF), Color(0xFF9269FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              _subtitles[_subtitleIndex],
              key: ValueKey<int>(_subtitleIndex),
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF495057),
              ),
            ),
          ),
          const Spacer(flex: 1),
          _buildRecommendationCard(),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    const darkColor = Color(0xFF212529);
    return Card(
      color: darkColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily recommendation for",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_steps.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      "• ${_steps[index]}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _completedSteps > index ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: darkColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
