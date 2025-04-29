import 'package:flutter/material.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';
import 'package:habitvote/features/vote/presentation/widgets/vote_summary_bottom_sheet.dart';

extension VotingPopupContextExtension on BuildContext {
  showVoteBottomsheet() {
    if (this.voteState.today?.isActivated == true) return;

    showModalBottomSheet(
      context: this,
      isScrollControlled:
          true, // Allows the sheet to take up more height if needed
      backgroundColor:
          Colors.transparent, // Make background transparent for custom shape
      builder: (context) => VoteSummaryBottomSheet(),
    );
  }
}
