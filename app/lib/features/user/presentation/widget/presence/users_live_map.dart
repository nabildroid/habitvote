import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habitvote/features/user/application/cubits/presence_cubit.dart';
import 'package:latlong2/latlong.dart';

class UsersLiveMap extends StatelessWidget {
  const UsersLiveMap({super.key});

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<PresenceCubit>().state.coordinates;
    return _UsersLiveMap(
      locations: locations,
    );
  }
}

class _UsersLiveMap extends StatefulWidget {
  const _UsersLiveMap({super.key, required this.locations});

  final List<LatLng> locations;

  @override
  State<_UsersLiveMap> createState() => _UsersLiveMapState();
}

class _UsersLiveMapState extends State<_UsersLiveMap> {
  final GlobalKey _svgKey = GlobalKey();
  Size _svgSize = Size.zero;
  Timer? _sizeCheckTimer;

  final List<Offset> _fractionalDotPositions = [];

  // --- FINAL CALIBRATION CONSTANTS ---
  // Tweak these values to achieve pixel-perfect alignment on YOUR specific SVG.

  // 1. Vertical Calibration (adjusts for padding/scaling within the SVG)
  static const double _mapTopFraction = 0.045;
  static const double _mapBottomFraction = 0.989;

  // 2. Horizontal Calibration (adjusts for horizontal compression/stretching in the SVG)
  // Since your dots are too far apart, we need to squeeze them. Use a value < 1.0.
  // A good starting guess is 0.9.
  static const double _horizontalScale = 0.98;
  static const double _horizontalOffset =
      -0.008; // Shifts all points slightly left.

  // Robinson projection coefficients
  static const List<double> ROBINSON_X = [
    1.0000,
    0.9986,
    0.9954,
    0.9900,
    0.9822,
    0.9730,
    0.9600,
    0.9427,
    0.9216,
    0.8962,
    0.8679,
    0.8350,
    0.7986,
    0.7597,
    0.7186,
    0.6732,
    0.6213,
    0.5722,
    0.5322
  ];
  static const List<double> ROBINSON_Y = [
    0.0000,
    0.0620,
    0.1240,
    0.1860,
    0.2480,
    0.3100,
    0.3720,
    0.4340,
    0.4958,
    0.5571,
    0.6176,
    0.6769,
    0.7346,
    0.7903,
    0.8435,
    0.8936,
    0.9394,
    0.9761,
    1.0000
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSizeCheck());
  }

  @override
  void didUpdateWidget(_UsersLiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.locations != oldWidget.locations) {
      if (_svgSize != Size.zero) {
        setState(() {
          _generateDotPositions();
        });
      }
    }
  }

  @override
  void dispose() {
    _sizeCheckTimer?.cancel();
    super.dispose();
  }

  void _startSizeCheck() {
    _sizeCheckTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final RenderBox? renderBox =
          _svgKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null &&
          renderBox.hasSize &&
          renderBox.size != Size.zero) {
        timer.cancel();
        // Check if mounted before calling setState
        if (!mounted) return;
        if (_svgSize != renderBox.size) {
          setState(() {
            _svgSize = renderBox.size;
            _generateDotPositions();
          });
        }
      }
    });
  }

  double _interpolate(double value, List<double> table) {
    double pos = value.abs() / 5.0;
    int i = pos.floor();
    if (i >= table.length - 1) return table.last;
    double fraction = pos - i;
    return table[i] * (1 - fraction) + table[i + 1] * fraction;
  }

  /// **FINAL, SIMPLIFIED CORE LOGIC**
  Offset _latLonToFractionalOffset(double lat, double lon) {
    final double yFactor = _interpolate(lat, ROBINSON_Y);
    final double xFactor = _interpolate(lat, ROBINSON_X);

    // --- Vertical Calculation (Calibrated) ---
    double rawDy = 0.5 - (yFactor / 2.0) * lat.sign;
    final double mapHeightFraction = _mapBottomFraction - _mapTopFraction;
    final double calibratedDy = _mapTopFraction + (rawDy * mapHeightFraction);

    // --- Horizontal Calculation (Calibrated) ---
    // The offset from the center (0.5) is scaled by our simple horizontal factor.
    final double calibratedDx = 0.5 +
        (lon / 360.0) * xFactor * _horizontalScale +
        _horizontalOffset; // Apply the final shift

    return Offset(calibratedDx, calibratedDy);
  }

  void _generateDotPositions() {
    _fractionalDotPositions.clear();
    for (final location in widget.locations) {
      final fractionalOffset =
          _latLonToFractionalOffset(location.latitude, location.longitude);
      _fractionalDotPositions.add(fractionalOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white.withOpacity(0.0)],
              stops: const [0.0, 0.05],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstOut,
          child: SvgPicture.asset(
            'assets/world.svg',
            key: _svgKey,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade300.withAlpha(200),
              BlendMode.srcIn,
            ),
          ),
        ),
        if (_svgSize != Size.zero)
          ..._fractionalDotPositions.map((fractionalOffset) {
            return Positioned(
              left: fractionalOffset.dx * _svgSize.width,
              top: fractionalOffset.dy * _svgSize.height,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.teal.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
