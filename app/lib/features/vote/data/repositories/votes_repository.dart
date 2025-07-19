import 'package:habitvote/core/network/connectivity.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';
import 'package:habitvote/features/vote/data/sources/votes_cache.dart';
import 'package:habitvote/features/vote/data/sources/votes_remote.dart';

class VotesRepo {
  final VotesCache cache;
  final VotesRemote remote;

  VotesRepo({required this.cache, required this.remote});

  Future<VoteModel?> getTodayVoteByHabitId(String habitId) async {
    if (isOnline.value) {
      final remoteVote = await remote.get();

      if (remoteVote != null) {
        await cache.put(remoteVote);
      }

      return remoteVote;
    }

    return await cache.getToday();
  }
}
