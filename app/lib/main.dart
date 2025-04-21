import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:vocafusion/features/home/presentation/home_screen.dart';

void main() {
  runApp(const HabitVoteApp());
}

class HabitVoteApp extends StatelessWidget {
  const HabitVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitVote',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFCBE724), // Bright green color
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HabitVotePage extends StatefulWidget {
  const HabitVotePage({super.key});

  @override
  State<HabitVotePage> createState() => _HabitVotePageState();
}

class _HabitVotePageState extends State<HabitVotePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsAnimationController;
  double sliderPosition = 0.5;
  bool isCheckedIn = false;
  DateTime checkInTime = DateTime.now().add(const Duration(hours: 2));
  SlideDirection? _confirmedDirection;
  double _confirmedSliderPosition = 0.5;

  @override
  void initState() {
    super.initState();
    _dotsAnimationController = AnimationController(
      // Increase duration for slower, smoother animation
      duration: const Duration(seconds: 10), // e.g., 10 seconds
      vsync: this,
    )..repeat(); // No need to call forward() when repeating
  }

  @override
  void dispose() {
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff111111),
            Color(0xff1B1B1B),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // Use a Column to stack the sticky header and the scrollable content
          body: Column(
            children: [
              // Header section (remains fixed at the top)
              _buildHeader(),
              // Use Expanded + SingleChildScrollView for the rest
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Stats section
                      _buildStatsSection(),
                      // Today section
                      _buildTodaySection(),
                      // Habit section
                      _buildHabitSectionContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Place the slider in the bottom navigation bar area
          bottomNavigationBar: _buildCheckInSlider(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Define the gradient
    final Shader linearGradient = LinearGradient(
      colors: <Color>[
        const Color(0xFFE3FF00), // Color at 38%
        const Color(0xFF008A00), // Color at 100%
      ],
      stops: [0.38, 1.0], // Define the stops
      // Adjust begin/end for desired gradient direction (e.g., left to right)
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(
        Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)); // Provide bounds for the shader

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Apply ShaderMask to the Text
          ShaderMask(
            blendMode: BlendMode.srcIn, // Apply gradient based on text alpha
            shaderCallback: (bounds) => linearGradient,
            child: Text(
              'HabitVote',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // Text color needs to be non-transparent for ShaderMask to work
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey, fontSize: 16),
          children: [
            const TextSpan(text: 'You proved '),
            TextSpan(
              text: '100 person wrong',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' and gained '),
            TextSpan(
              text: '50 believers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' since November 10'),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildVoteTypeWidget(
                    emoji: '😑',
                    label: 'Challengers',
                    isPositive: false,
                  ),
                  const SizedBox(width: 16),
                  _buildVoteTypeWidget(
                    emoji: '😎',
                    label: 'Believers',
                    isPositive: true,
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
    int count = 88, // Example count for visual effect
  }) {
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
              color: Colors.grey.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPositive
                    ? Theme.of(context).primaryColor // Green for believers
                    : Colors.red.shade700, // Red for challengers
                width: 1.5, // Slightly thicker border
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
          const SizedBox(height: 6), // Space between label and count
          // Blurred count
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 3,
              sigmaY: 1.5,
            ),
            child: Text(
              count.toString().padLeft(2, '8'), // Pad with '8' for blur effect
              style: TextStyle(
                color: Colors.grey.shade700, // Darker grey for blurred effect
                fontSize: 16, // Slightly larger font for blurred number
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteCircle() {
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
                      Theme.of(context).primaryColor, // Use theme color
                  negativeColor: Colors.red.shade700, // Use red for negative
                ),
                size: const Size(120, 120),
              );
            },
          ),
          // Blur overlay using BackdropFilter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.1), // Slight tint
                ),
              ),
            ),
          ),
          // Vote count
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '30',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
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

  Widget _buildHabitSectionContent() {
    return Container(
      // Added fixed height for demonstration; adjust as needed for your content
      // Or ensure the GridView inside has constraints if not wrapped in Expanded
      height: 350, // Example fixed height
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_walk),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Walk around the block',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Go for a short walk to clear the mind',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showStatsBottomSheet(
                    context), // Call bottom sheet function
                borderRadius:
                    BorderRadius.circular(8), // Match container radius
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Expanded needs constraints from parent Column, which now has constraints from Container
          Expanded(child: _buildHabitHeatmap()),
        ],
      ),
    );
  }

  Widget _buildHabitHeatmap() {
    // Generate heatmap data (0 for not done, 1 for done)
    final random = math.Random(42); // Fixed seed for consistent pattern
    final int numRows = 7; // Days of the week
    final int numCols = 15; // Number of weeks/columns to show
    // Generate binary data (0 or 1)
    final List<List<int>> heatmapData = List.generate(numRows, (row) {
      return List.generate(numCols, (col) {
        // Example: 70% chance of being done
        return random.nextDouble() < 0.7 ? 1 : 0;
      });
    });

    // Use GridView for better layout control and scrolling
    return GridView.builder(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numRows, // Number of rows (days of the week)
        mainAxisSpacing: 4, // Spacing between columns (weeks)
        crossAxisSpacing: 4, // Spacing between rows (days)
        childAspectRatio: 1, // Make cells square
      ),
      itemCount: numRows * numCols,
      itemBuilder: (context, index) {
        // Calculate row (day of week) and column (week)
        final row = index % numRows;
        final col = index ~/ numRows;
        // Ensure we don't go out of bounds if data structure changes
        if (row < heatmapData.length && col < heatmapData[row].length) {
          final isDone = heatmapData[row][col] == 1;
          final color = _getHeatmapColor(isDone); // Pass boolean

          return Container(
            width: 20, // Slightly smaller squares
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }
        return SizedBox
            .shrink(); // Return empty widget if index is out of bounds
      },
    );
  }

  // Updated to accept a boolean indicating if the habit was done
  Color _getHeatmapColor(bool isDone) {
    if (isDone) {
      // Use the primary color for completed days
      return Theme.of(context).primaryColor;
    } else {
      // Use a dark grey for days not done
      return Colors.grey.shade800;
    }
  }

  Widget _buildCheckInSlider() {
    // Check if the slider has been confirmed
    bool isConfirmed = _confirmedDirection != null;

    // Wrap with SafeArea for bottom padding if needed, or handle padding manually
    return SafeArea(
      top: false, // Only apply SafeArea padding to the bottom
      child: Container(
        // Use the dark background color consistent with the bottom area
        color: Color(0xff111111),
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
                              : Theme.of(context)
                                  .primaryColor, // Confirmed green
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
      ),
    );
  }

  // Function to show the first custom bottom sheet (VS)
  void _showStatsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 50),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xff1C1C1E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white, // White border color
                  width: 4.0, // Border width
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ... existing VS content ...
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('😑', style: TextStyle(fontSize: 40)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text('😎', style: TextStyle(fontSize: 40)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Let's See who among 30 Voters\nbelieved On You and how many\npeople you crashed today",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                // Update Next Button's onPressed
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    // Pop the current sheet first
                    Navigator.pop(context);
                    // Immediately show the second sheet
                    _showVotingWorksBottomSheet(context);
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Update the _showVotingWorksBottomSheet method to transition to the voting card
  void _showVotingWorksBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          // Use a local state to control the animation
          bool showVotingCard = false;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: showVotingCard ? 20 : 50, // Reduce top margin when expanding
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xff1C1C1E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white,
                  width: 4.0,
                ),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: !showVotingCard
                  ? _buildVotingWorksContent(context, () {
                      // On button press, show the voting card
                      setState(() {
                        showVotingCard = true;
                      });
                      // Add a short delay before showing the full card sheet
                      Future.delayed(Duration(milliseconds: 300), () {
                        Navigator.pop(context);
                        _showVotingCardSheet(context);
                      });
                    })
                  : Container(), // Empty container during transition
            ),
          );
        });
      },
    );
  }

  // Extract the content to a separate method for cleaner code
  Widget _buildVotingWorksContent(
      BuildContext context, VoidCallback onButtonPressed) {
    return Column(
      key: ValueKey('voting-works'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 24),
        Text(
          "Voting Works Because 30 Persons\ntook their time to bet their Scores\non You",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: onButtonPressed, // Use callback
          child: const Text(
            "Let's Vote first On 3 Persons",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // Add a new method to show the voting card sheet based on the image
  void _showVotingCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Create a bottom sheet that looks like the image
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 10, // Less top margin to make it larger
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white,
                width: 4.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag and Title Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Romanian flag (approximate colors)
                    Container(
                      width: 24,
                      height: 16,
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF002B7F), // Blue
                            Color(0xFFFFD100), // Yellow
                            Color(0xFFCE1126), // Red
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    // Title and counter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I want to Meditate',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '30 min a day',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Counter
                    Text(
                      '1 / 3',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Grid of squares - simplified version
                Container(
                  height: 200,
                  child: _buildHabitGrid(),
                ),

                const SizedBox(height: 20),

                // Win/Lose buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Win',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Loose', // Note: Spelled as shown in the image
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build the green/gray grid shown in the image
  Widget _buildHabitGrid() {
    // Create a random pattern of green and gray squares like in the image
    final random = math.Random(42); // Use fixed seed for consistent pattern

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(), // Disable scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10, // Approximately 10 squares per row based on image
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: 70, // Approximately 70 squares in the grid
      itemBuilder: (context, index) {
        // Create a pattern where about 70% of squares are green (similar to image)
        final bool isActive = random.nextDouble() < 0.7;

        return Container(
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor // Green for active
                : Colors.grey.shade800, // Dark gray for inactive
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

class DotsPainter extends CustomPainter {
  final Animation<double> animation;
  final Color positiveColor;
  final Color negativeColor;
  // Use a single Random instance seeded once for consistent randomness across paints
  final math.Random random = math.Random(42);
  // Store initial random properties for each dot
  late final List<_DotProperties> _dotProperties;

  DotsPainter({
    required this.animation,
    required this.positiveColor,
    required this.negativeColor,
  }) {
    // Initialize properties once
    _dotProperties = List.generate(35, (i) {
      // Increased dot count slightly
      final angle = random.nextDouble() * 2 * math.pi;
      // Start dots more spread out, not just at center
      final initialRadius = math.pow(random.nextDouble(), 0.5) *
          0.9; // Power < 1 biases towards edge
      final speedFactor = random.nextDouble() * 0.5 + 0.5; // Vary speed
      final direction = random.nextBool() ? 1.0 : -1.0; // Vary direction
      final size = random.nextDouble() * 2.0 + 1.5; // Vary size
      final isPositive = random.nextDouble() < 0.66; // ~2/3 positive
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

enum SlideDirection { left, right }

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
