import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/core/network/authorized_dio.dart';
import 'package:habitvote/features/user/data/auth_service.dart';
import 'package:habitvote/services/firebase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitvote/services/kv_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationChannelType { reminder, vote, overview }

class NotificationService extends AuthorizedDio {
  NotificationService() : super(rawHttp: AuthorizedDio.defaultHttp) {
    locator.get<AuthService>().subscribeToToken(this);
  }

  late final FirebaseMessaging fcm;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final kv = locator.get<KvService>();

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

  Future<bool> preRegisterDevice() async {
    final settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> isNotificationEnabled() async {
    return await kv.timeToEnableNotification();
  }

  Future<void> registerDevice() async {
    if (!await preRegisterDevice()) return;

    final token = await fcm.getToken();
    await (await http)
        .post("/user/notifications/register", data: {"token": token});
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
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }
}

extension on KvService {
  /// Gets the last notification permission request date.
  /// Returns null on first call and sets the current date.
  Future<bool> timeToEnableNotification() async {
    const key = 'last_notification_request_date2';
    final storedDate = await getString(key);

    if (storedDate == null) {
      // First time - store current date and return null
      final now = DateTime.now().add(const Duration(minutes: 5));
      await setString(key, now.toIso8601String());
      return true;
    } else {
      // Parse the stored date
      final date = DateTime.parse(storedDate);
      final now = DateTime.now();

      // If date is in the past, update it to now + 5 minutes
      if (date.isBefore(now)) {
        final newDate = now.add(const Duration(minutes: 5));
        await setString(key, newDate.toIso8601String());
        return true;
      }
    }

    // Return the stored date
    return false;
  }
}
