import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:habitvote/core/locator.dart';
import 'package:habitvote/features/habit/data/models/notifications/notification_config_model.dart';
import 'package:habitvote/features/habit/data/models/notifications/notification_model.dart';
import 'package:habitvote/services/kv_service.dart';
import 'package:habitvote/services/notification_service.dart';
import 'package:habitvote/shared/dates_utils.dart';
import 'package:habitvote/features/habit/application/cubits/habit_tracker_cubit.dart';

extension HabitNotificationsExtension on HabitTrackerCubit {
  static final _noti = locator.get<NotificationService>();
  static final _kv = locator.get<KvService>();

  Future<bool> isNotificationScheduled() async {
    final schedule = await _getSavedNotificationSchedule();
    return schedule.isNotEmpty;
  }

  void rescheduleNotifcations() async {
    final oldSchedule = await _getSavedNotificationSchedule();
    await Future.wait(oldSchedule.map((h) => _noti.cancelById(h.id)));
    final schedule = await _generateRandomSchedule();

    await _saveNotificationSchedule(schedule);

    for (final noti in schedule) {
      if (!noti.dateTime.isAfter(DateTime.now()))
        continue; // todo, this is a bug,/ skip past notifications

      await _noti.scheduleNotification(
        NotificationChannelType.reminder,
        id: noti.id,
        title: noti.title(state.habit!),
        body: noti.description(state.habit!),
        scheduledDate: noti.dateTime,
      );
    }
  }

  Future<List<HabitNotificationModel>> _generateRandomSchedule() async {
    final config = await getNotificationConfig();
    final habit = state.habit!;

    const daysAhead =
        3; // we schedule for 3 days ahead of notifications then we stop

    final schedule = <HabitNotificationModel>[];

    final isTodayChecked = state.todayCheckin != null;

    // todo make sure to remove the notifications from today if the window is aready closed

    final open = habit.checkinOpenWindow;

    for (int i = isTodayChecked ? 1 : 0; i < daysAhead; i++) {
      final date = DateTime.now().add(Duration(days: i));

      if (config.before5Minutes) {
        final before5Min =
            open.toDateTime(date).subtract(const Duration(minutes: 5));

        schedule.add(Before5MinHabitNotificationModel(before5Min));
      }

      if (config.randomInWindown) {
        final iterations = Random().nextInt(3) + 1; // 1 to 3 iterations

        final openDate = open.toDateTime(date);
        final closeDate = habit.checkinCloseWindow.toDateTime(date);

        for (int j = 0; j < iterations; j++) {
          final randomMinutes =
              Random().nextInt(closeDate.difference(openDate).inMinutes);

          final randomTime = openDate.add(Duration(minutes: randomMinutes));
          schedule.add(RandomWindownHabitNotificationModel(randomTime));
        }
      }
    }
    return schedule;
  }

  Future<List<HabitNotificationModel>> _getSavedNotificationSchedule() async {
    final data = await _kv.getString("habit_notification_schedule");
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((json) => HabitNotificationModel.fromJson(json))
        .toList();
  }

  // save
  Future<void> _saveNotificationSchedule(
      List<HabitNotificationModel> schedule) async {
    final encodedSchedule = schedule.map((e) => e.toJson()).toList();
    await _kv.setString(
      "habit_notification_schedule",
      jsonEncode(encodedSchedule),
    );
  }

  Future<HabitNotificationConfigModel> getNotificationConfig() async {
    final data = await _kv.getString("habit_notification_config");

    if (data == null) {
      return HabitNotificationConfigModel.defaultConfig();
    } else {
      return HabitNotificationConfigModel.fromJson(jsonDecode(data));
    }
  }

  Future<void> saveNotificationConfig(
      HabitNotificationConfigModel config) async {
    await _kv.setString(
      "habit_notification_config",
      jsonEncode(config.toJson()),
    );
  }
}
