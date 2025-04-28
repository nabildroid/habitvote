import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:habitvote/features/vote/data/models/vote_model.dart';
import 'package:habitvote/features/vote/data/sources/votes_cache.dart';
import 'package:habitvote/features/vote/data/sources/votes_remote.dart';
import 'package:rxdart/rxdart.dart';

class VotesRepo {
  final VotesCache cache;
  final VotesRemote remote;

  final isOnline = BehaviorSubject<bool>.seeded(false);
  VotesRepo({required this.cache, required this.remote}) {
    Connectivity().onConnectivityChanged.listen((status) => isOnline.add(
          !status.contains(ConnectivityResult.none),
        ));
  }

  Future<List<VoteModel>> getVotesByHabitId(String habitId) async {
    if (isOnline.value) {
      final remoteVotes = await remote.getByHabitId(habitId);
      await cache.clear();
      for (final record in remoteVotes) {
        await cache.put(record);
      }

      return remoteVotes;
    }

    return await cache.getByHabitId(habitId);
  }
}
