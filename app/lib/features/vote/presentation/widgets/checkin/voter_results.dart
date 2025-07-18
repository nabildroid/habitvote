import 'dart:ui';

import 'package:flutter/material.dart';

class VoterResults extends StatelessWidget {
  final bool blur;
  const VoterResults({
    super.key,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            ImageFiltered(
              enabled: blur,
              imageFilter: ImageFilter.compose(
                outer: ImageFilter.erode(
                  radiusX: .1,
                  radiusY: 0.3,
                ),
                inner: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              ),
              child: Text(
                "15",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 2),
            Text(
              "Believers",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
        Text("30 Votes"),
        Column(
          children: [
            ImageFiltered(
              enabled: blur,
              imageFilter: ImageFilter.compose(
                outer: ImageFilter.erode(
                  radiusX: .1,
                  radiusY: 0.3,
                ),
                inner: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              ),
              child: Text(
                "15",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 2),
            Text(
              "Challengers",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
