import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';

class VoterResults extends StatelessWidget {
  final bool blur;
  const VoterResults({
    super.key,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watchVoteState;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          hoverColor: Colors.grey.shade50,
          splashColor: Colors.grey.shade100,
          highlightColor: Colors.transparent,
          onTap: () => context.go("/home/votes/today/people"),
          child: Column(
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
                  "${state.today?.up ?? 0}".padLeft(2, '0'),
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
        ),
        InkWell(
          hoverColor: Colors.grey.shade50,
          splashColor: Colors.grey.shade100,
          highlightColor: Colors.transparent,
          onTap: () => context.go("/home/votes/today/people"),
          child: Column(
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
                  "${state.today?.down ?? 0}".padLeft(2, '0'),
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
        ),
      ],
    );
  }
}
