import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';

class TodayVotersOverview extends StatelessWidget {
  final int? resultMin;
  final int activePeople;
  const TodayVotersOverview({
    super.key,
    this.resultMin,
    required this.activePeople,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watchVoteState;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${(state.today?.total ?? 0)} Votes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (resultMin != null && resultMin! > 0)
              Text(
                resultMin! > 60
                    ? 'Result in ${(resultMin! / 60).floor()} hours'
                    : 'Result in ${resultMin} minutes',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVoteItem(
              'believe on you',
              state.today?.up ?? 0,
              blur: !state.showTodayResults,
            ),
            const SizedBox(height: 4),
            _buildVoteItem(
              'Challenge you',
              state.today?.down ?? 0,
              blur: !state.showTodayResults,
            ),
            const SizedBox(height: 4),
            _buildVoteItem(
              'Here Today',
              activePeople,
              blur: false,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoteItem(String text, int value,
      {bool blur = true, Color? color}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 4,
          backgroundColor: color ?? Colors.black,
        ),
        SizedBox(width: 4),
        ImageFiltered(
          enabled: blur,
          imageFilter: ImageFilter.compose(
              outer: ImageFilter.erode(
                radiusX: 2,
                radiusY: 0.5,
              ),
              inner: ImageFilter.blur(sigmaX: 2, sigmaY: 4)),
          child: Text(
            value.toString().padLeft(2, "0"),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }
}
