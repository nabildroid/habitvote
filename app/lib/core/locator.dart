import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:habitvote/features/tracker/data/repositories/habit_tracker_repository.dart';
import 'package:habitvote/features/tracker/data/sources/tracker_cache.dart';
import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:habitvote/features/tracker/data/repositories/habit_repository.dart';
import 'package:habitvote/features/tracker/data/sources/habit_cache.dart';
import 'package:habitvote/services/kv_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setUpLocator({required Database sembastInstance}) async {
  locator.registerSingleton(Logger());
  locator.registerSingleton(sembastInstance);
  locator.registerSingleton(KvService());

  locator.registerFactory(() => HabitRepo(cache: HabitCache()));
  locator.registerFactory(() => HabitTrackerRepo(cache: TrackerCache()));

  locator.registerSingleton(RouteObserver<ModalRoute<dynamic>>());
}
