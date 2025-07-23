import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitvote/shared/utils.dart';

// Top-level function for isolate computation
List<Point<int>> _generatePathIsolate(int gridSize) {
  // Create a simple path with connected points
  final path = <Point<int>>[];
  final random = Random();

  // Start with a random point not too close to the edges
  final startX = random.nextInt(gridSize - 2) + 1;
  final startY = random.nextInt(gridSize - 2) + 1;
  path.add(Point(startX, startY));

  // Add 15-20 more points, each adjacent to the previous point
  int currentX = startX;
  int currentY = startY;

  for (int i = 0; i < 15 + random.nextInt(6); i++) {
    // List possible next moves (must be adjacent on the grid)
    final possibleMoves = <Point<int>>[];

    // Check all 4 directions
    if (currentX > 0) possibleMoves.add(Point(currentX - 1, currentY));
    if (currentX < gridSize - 1)
      possibleMoves.add(Point(currentX + 1, currentY));
    if (currentY > 0) possibleMoves.add(Point(currentX, currentY - 1));
    if (currentY < gridSize - 1)
      possibleMoves.add(Point(currentX, currentY + 1));

    // Filter out points that are already in the path
    final availableMoves =
        possibleMoves.where((p) => !path.contains(p)).toList();

    // If no available moves, break out of the loop
    if (availableMoves.isEmpty) break;

    // Choose a random available move
    final nextPoint = availableMoves[random.nextInt(availableMoves.length)];
    path.add(nextPoint);

    // Update current position
    currentX = nextPoint.x;
    currentY = nextPoint.y;
  }

  return path;
}

class BlockIndia extends StatefulWidget {
  const BlockIndia({super.key});

  static Future<bool> check() async {
    // if (kDebugMode) return false; // Skip check in debug mode
    try {
      final now = DateTime.now();
      final cutoffDate = DateTime(now.year, 8, 15);

      // If the current date is on or after August 1st, the condition is not met.
      if (!now.isBefore(cutoffDate)) {
        return false;
      }

      // List of blocked country codes.
      // IN: India, PK: Pakistan, RW: Rwanda, SO: Somalia, KH: Cambodia
      const blockedCountries = [
        'SS', // South Sudan
        'GQ', // Equatorial Guinea
        'MG', // Madagascar
        'CF', // Central African Republic
        'BI', // Burundi
        'HN', // Honduras
        'CD', // DR Congo
        'ZM', // Zambia
        'GT', // Guatemala
        'SZ', // Eswatini
        'HT', // Haiti
        'SL', // Sierra Leone
        'ZA', // South Africa
        'ST', // Sao Tome and Principe
        'AF', // Afghanistan
        'SO', // Somalia
        'GM', // Gambia
        'LR', // Liberia
        'MW', // Malawi
        'GW', // Guinea-Bissau
        'LS', // Lesotho
        'YE', // Yemen
        'SN', // Senegal
        'SD', // Sudan
        'MZ', // Mozambique
        'NE', // Niger
        'TG', // Togo
        'ML', // Mali
        'GN', // Guinea
        'BF', // Burkina Faso
        'KM', // Comoros
        'TD', // Chad
        'TL', // Timor-Leste
        'FM', // Micronesia
        'CG', // Republic of the Congo
        'NG', // Nigeria
        'PG', // Papua New Guinea
        'AR', // Argentina
        'KE', // Kenya
        'BJ', // Benin
        'ZW', // Zimbabwe
        'RW', // Rwanda
        'CI', // Ivory Coast
        'CM', // Cameroon
        'CO', // Colombia
        'BO', // Bolivia
        'MX', // Mexico
        'SY', // Syria
        'IN', // India
        'PK', // Pakistan
        'BD', // Bangladesh
        'KH', // Cambodia
        'LK', // Sri Lanka
        'VN', // Vietnam
        'MM', // Myanmar
        'NP', // Nepal
        'BN', // Brunei
        'PH', // Philippines
        'ID', // Indonesia
        'TH', // Thailand
        'MY', // Malaysia
        'SG', // Singapore
        'DZ', // Algeria
      ];

      final dio = Dio();
      final response = await dio.get('https://api.country.is/');

      if (response.statusCode == 200 && response.data != null) {
        final countryCode = response.data['country'];
        // Return true if the country is in the blocked list.
        return blockedCountries.contains(countryCode);
      }
    } catch (e) {
      // In case of any error (network, parsing, etc.), assume not blocked.
      return true;
    }

    // Default to false if the API call fails or conditions are not met.
    return true;
  }

  @override
  State<BlockIndia> createState() => _BlockIndiaState();
}

class _BlockIndiaState extends State<BlockIndia> {
  static const int gridSize = 6;
  List<Point<int>> _solutionPath = [];
  final List<Point<int>> _userPath = [];
  bool _isDrawing = false;
  bool _hasWon = false;
  bool _isLoading = true;
  bool _gameStarted = false;

  // Number of points to show as the starting line
  int _initialPoints = 3;

  @override
  void initState() {
    super.initState();
    _resetGame();

    removeSplashScreen(Duration.zero);
  }

  Future<void> _resetGame() async {
    setState(() {
      _isLoading = true;
      _userPath.clear();
      _isDrawing = false;
      _hasWon = false;
      _gameStarted = false;
    });

    try {
      // Generate path in a separate isolate
      final newPath = await compute(_generatePathIsolate, gridSize).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return _generateSimplePath();
        },
      );

      if (mounted) {
        setState(() {
          _solutionPath = newPath;
          // Show 3-4 initial points (randomly chosen)
          _initialPoints = min(3 + Random().nextInt(2), newPath.length - 1);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _solutionPath = _generateSimplePath();
          _isLoading = false;
        });
      }
    }
  }

  // Fallback method to generate a simple path quickly
  List<Point<int>> _generateSimplePath() {
    final path = <Point<int>>[];
    final random = Random();

    // Create a simple snake pattern
    int direction = 0; // 0: right, 1: down, 2: left, 3: up
    int x = random.nextInt(gridSize);
    int y = random.nextInt(gridSize);

    path.add(Point(x, y));

    // Generate 15-20 points
    final pointsCount = 15 + random.nextInt(6);

    for (int i = 0; i < pointsCount; i++) {
      switch (direction) {
        case 0: // right
          x = (x + 1) % gridSize;
          break;
        case 1: // down
          y = (y + 1) % gridSize;
          break;
        case 2: // left
          x = (x - 1 + gridSize) % gridSize;
          break;
        case 3: // up
          y = (y - 1 + gridSize) % gridSize;
          break;
      }

      // Change direction occasionally
      if (random.nextInt(3) == 0) {
        direction = (direction + 1) % 4;
      }

      final newPoint = Point(x, y);
      if (!path.contains(newPoint)) {
        path.add(newPoint);
      }
    }

    return path;
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (_hasWon || _isLoading) return;
    final point = _getPointFromOffset(details.localPosition, size);

    // Start drawing from the last point of the initial line
    if (point == _solutionPath[_initialPoints]) {
      setState(() {
        _isDrawing = true;
        _gameStarted = true;
        _userPath.clear();
        // Add the last point of the initial segment
        _userPath.add(_solutionPath[_initialPoints]);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!_isDrawing || _hasWon || _isLoading) return;

    final point = _getPointFromOffset(details.localPosition, size);
    if (point != _userPath.last) {
      // Calculate the next expected point in the solution
      final nextIndex = _initialPoints + _userPath.length;

      // Check if the point is the next in the solution path
      if (nextIndex < _solutionPath.length &&
          point == _solutionPath[nextIndex]) {
        setState(() {
          _userPath.add(point);
          if (nextIndex == _solutionPath.length - 1) {
            _hasWon = true;
            _isDrawing = false;
          }
        });
      } else {
        // Wrong path, reset
        setState(() {
          _userPath.clear();
          _isDrawing = false;
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing && !_hasWon) {
      // Lifted finger before finishing, reset
      setState(() {
        _userPath.clear();
        _isDrawing = false;
      });
    }
  }

  Point<int> _getPointFromOffset(Offset offset, Size size) {
    final double cellWidth = size.width / gridSize;
    final double cellHeight = size.height / gridSize;
    final int x = (offset.dx / cellWidth).floor().clamp(0, gridSize - 1);
    final int y = (offset.dy / cellHeight).floor().clamp(0, gridSize - 1);
    return Point(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'One Line Puzzle',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connect all dots with a single line.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.0,
              child: LayoutBuilder(builder: (context, constraints) {
                if (_isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                return GestureDetector(
                  onPanStart: (details) =>
                      _onPanStart(details, constraints.biggest),
                  onPanUpdate: (details) =>
                      _onPanUpdate(details, constraints.biggest),
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: _GamePainter(
                      gridSize: gridSize,
                      solutionPath: _solutionPath,
                      userPath: _userPath,
                      hasWon: _hasWon,
                      initialPoints: _initialPoints,
                      gameStarted: _gameStarted,
                    ),
                    child: Container(),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (_hasWon)
              const Text(
                'You Win!',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(_hasWon ? 'Play Again' : 'Try Again',
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final int gridSize;
  final List<Point<int>> solutionPath;
  final List<Point<int>> userPath;
  final bool hasWon;
  final int initialPoints;
  final bool gameStarted;

  _GamePainter({
    required this.gridSize,
    required this.solutionPath,
    required this.userPath,
    required this.hasWon,
    required this.initialPoints,
    this.gameStarted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (solutionPath.isEmpty) return;

    final double cellWidth = size.width / gridSize;
    final double cellHeight = size.height / gridSize;

    Offset getCenterForPoint(Point<int> p) {
      return Offset(
          p.x * cellWidth + cellWidth / 2, p.y * cellHeight + cellHeight / 2);
    }

    // Draw the initial line (starting red line)
    if (solutionPath.length > 1 && initialPoints > 0) {
      final initialPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round;

      final initialPath = Path();
      initialPath.moveTo(
        getCenterForPoint(solutionPath[0]).dx,
        getCenterForPoint(solutionPath[0]).dy,
      );

      // Draw only the first few points as a red line
      for (int i = 1; i <= initialPoints; i++) {
        initialPath.lineTo(
          getCenterForPoint(solutionPath[i]).dx,
          getCenterForPoint(solutionPath[i]).dy,
        );
      }

      canvas.drawPath(initialPath, initialPaint);
    }

    // Draw user path
    if (userPath.isNotEmpty) {
      final userPathPaint = Paint()
        ..color = Colors.greenAccent
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(
        getCenterForPoint(userPath[0]).dx,
        getCenterForPoint(userPath[0]).dy,
      );

      for (int i = 1; i < userPath.length; i++) {
        path.lineTo(
          getCenterForPoint(userPath[i]).dx,
          getCenterForPoint(userPath[i]).dy,
        );
      }

      canvas.drawPath(path, userPathPaint);
    }

    // Draw dots
    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        canvas.drawCircle(getCenterForPoint(Point(i, j)), 6.0, dotPaint);
      }
    }

    // Highlight start, end dots and the point where user should start drawing
    if (solutionPath.isNotEmpty) {
      // Blue starting point
      final startDotPaint = Paint()..color = Colors.blue;
      canvas.drawCircle(
        getCenterForPoint(solutionPath[0]),
        10.0,
        startDotPaint,
      );

      // Orange ending point
      final endDotPaint = Paint()..color = Colors.orange;
      canvas.drawCircle(
        getCenterForPoint(solutionPath.last),
        10.0,
        endDotPaint,
      );

      // Highlight the point where the user should start drawing
      if (!gameStarted && !hasWon) {
        final nextDotPaint = Paint()..color = Colors.lightGreenAccent;
        canvas.drawCircle(
          getCenterForPoint(solutionPath[initialPoints]),
          12.0,
          nextDotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
