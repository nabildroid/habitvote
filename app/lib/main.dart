import 'dart:io';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:habitvote/core/network/connectivity.dart';
import 'package:habitvote/services/firebase_service.dart';
import 'package:habitvote/services/notification_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:habitvote/app.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/services/kv_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await setUpSplashScreen(widgetsBinding);

  await setUpErrorHandling();
  await setupAnalytics();

  initConnectivity();

  final db = await setUpStorage();
  await setUpLocator(sembastInstance: db);

  /////
  await initializeDateFormatting(Platform.localeName);
  tz.initializeTimeZones();

  await initNotification();
  runApp(const HabitVoteApp());
}

Future<Database> setUpStorage() async {
  /// Initialize the Storages
  final dir = await getApplicationDocumentsDirectory();
  await dir.create(recursive: true);

  PreferenceExtension.globalPrefix = "22";
  final db = await databaseFactoryIo.openDatabase(
    join(dir.path, 'habitVote_v${PreferenceExtension.globalPrefix}.db'),
  );

  final blocHydartionPath = Directory(
    join(dir.path, 'hydrated_bloc${PreferenceExtension.globalPrefix}'),
  )..create(recursive: true);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: blocHydartionPath,
  );

  EquatableConfig.stringify = true;

  return db;
}

Future<void> setupAnalytics() async {
  if (Platform.isAndroid) {
    // final config =
    //     PostHogConfig('phc_qKJNHn1RX2l75TYuzvr2zbToLu2ilYTI1n8k6lTqXIK');
    // // config.debug = true;
    // config.captureApplicationLifecycleEvents = true;
    // config.debug = !kReleaseMode;
    // config.host = 'https://eu.i.posthog.com';

    // await Posthog().setup(config);
  }
}

Future<void> setUpErrorHandling() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // Sentry.captureException(error, stackTrace: stack);
    return true;
  };
}

Future<void> setUpSplashScreen(WidgetsBinding widgetsBinding) async {
  if (Platform.isAndroid) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    Future.delayed(const Duration(seconds: 2), () {
      FlutterNativeSplash.remove();
    });
  }
}

Future<void> initNotification() async {
  final firebaseService = locator<FirebaseService>();
  await firebaseService.init();
  final notificationService = locator<NotificationService>();
  await notificationService.init();
}
