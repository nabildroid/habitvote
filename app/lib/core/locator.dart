import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:habitvote/features/habit/data/repositories/tracker_repository.dart';
import 'package:habitvote/features/habit/data/sources/habit_remote.dart';
import 'package:habitvote/features/habit/data/sources/tracker_cache.dart';
import 'package:habitvote/features/habit/data/sources/tracker_remote.dart';
import 'package:habitvote/features/vote/data/repositories/votes_repository.dart';
import 'package:habitvote/features/vote/data/sources/votes_cache.dart';
import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:habitvote/features/habit/data/repositories/habit_repository.dart';
import 'package:habitvote/features/habit/data/sources/habit_cache.dart';
import 'package:habitvote/services/kv_service.dart';

import '../features/user/data/auth_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setUpLocator({required Database sembastInstance}) async {
  locator.registerSingleton(Logger());
  locator.registerSingleton(sembastInstance);
  locator.registerSingleton(KvService());

  locator.registerFactory(
      () => HabitRepo(cache: HabitCache(), remote: HabitRemote()));
  locator.registerFactory(
      () => TrackerRepo(cache: TrackerCache(), remote: TrackerRemote()));

  locator.registerFactory(() => VotesRepo(cache: VotesCache()));

  locator.registerSingleton(AuthService()..fetch());

  locator.registerSingleton(RouteObserver<ModalRoute<dynamic>>());
}
