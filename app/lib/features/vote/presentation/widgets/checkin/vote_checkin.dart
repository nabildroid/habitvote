import 'package:flutter/material.dart';
import 'package:habitvote/features/vote/presentation/utils/votes_context_extension.dart';
import 'package:habitvote/features/vote/presentation/widgets/checkin/voter_results.dart';
import 'package:habitvote/features/vote/presentation/widgets/condidats_voting.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';

// todo change the name to be something more meanful
class VoteCheckin extends StatelessWidget {
  const VoteCheckin({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watchVoteState;
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: state.showTodayResults ? ViewVotingResult() : VoteOnPeople(),
    );
  }
}

class ViewVotingResult extends StatelessWidget {
  const ViewVotingResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VoterResults(
          blur: false,
        ),
        SizedBox(height: 8),
        BrilliantOkButton(
          text: "Predict People Decipline",
          onPressed: () {
            CondidatsVoting.show(context);
          },
        )
      ],
    );
  }
}

class VoteOnPeople extends StatelessWidget {
  const VoteOnPeople({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VoterResults(
          blur: true,
        ),
        SizedBox(height: 8),
        BrilliantOkButton(
            text: "Vote on 3 People to see Yours",
            onPressed: () {
              CondidatsVoting.show(context);
            })
      ],
    );
  }
}
