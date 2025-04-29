import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/services/firebase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationChannelType { reminder, vote, overview }

class NotificationService {
  late final FirebaseMessaging fcm;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Define all channels in one static map
  static const Map<NotificationChannelType, AndroidNotificationChannel>
      _channels = {
    NotificationChannelType.reminder: AndroidNotificationChannel(
      'reminder_channel',
      'Habit Reminders',
      description: 'Reminder to check your habits regularly',
      importance: Importance.high,
    ),
    NotificationChannelType.vote: AndroidNotificationChannel(
      'vote_channel',
      'Vote Alerts',
      description: 'Notifications when someone votes for you',
      importance: Importance.defaultImportance,
    ),
    NotificationChannelType.overview: AndroidNotificationChannel(
      'overview_channel',
      'Vote Overview',
      description: 'Summary of votes you have received',
      importance: Importance.low,
    ),
  };

  Future<void> init() async {
    fcm = FirebaseMessaging.instance;

    // initialize local notifications
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _localNotificationsPlugin.initialize(initSettings);

    // initialize timezone database
    tz.initializeTimeZones();

    await _createNotificationChannels();
  }

  Future<void> requestPremission() async {
    final settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      locator<FirebaseService>().init();
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      // FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidPlatform =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // 2. Iterate and create each channel
    for (final channel in _channels.values) {
      await androidPlatform?.createNotificationChannel(channel);
    }
  }

  Future<void> sendNotification(
    NotificationChannelType channelType, {
    required String title,
    required String body,
  }) async {
    // 3. Pull channel metadata directly from the map
    final channel = _channels[channelType]!;
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
    );
    final details = NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Schedule a notification at a specific [scheduledDate].
  Future<void> scheduleNotification(
    NotificationChannelType channelType, {
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final channel = _channels[channelType]!;
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
    );
    final details = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
