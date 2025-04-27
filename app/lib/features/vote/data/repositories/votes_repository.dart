import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:habitvote/features/vote/data/sources/votes_cache.dart';
import 'package:habitvote/features/vote/data/sources/votes_remote.dart';
import 'package:rxdart/rxdart.dart';

class VotesRepo {
  final VotesCache cache;
  final VotesRemote remote;

  final isOnline = BehaviorSubject<bool>.seeded(false);
  VotesRepo({required this.cache, required this.remote}) {
    // locator.get<UserRepository>().subscribeToToken(this);

    Connectivity().onConnectivityChanged.listen((status) => isOnline.add(
          !status.contains(ConnectivityResult.none),
        ));
  }
}
