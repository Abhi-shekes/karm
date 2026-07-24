import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules local reminder notifications for tasks with a due date.
/// Uses inexact scheduling to avoid requiring the SCHEDULE_EXACT_ALARM
/// permission — reminders may fire a few minutes late, which is an
/// acceptable trade-off for a personal todo app.
class ReminderService {
  ReminderService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channelId = 'task_reminders';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('ic_stat_karm');
    await _plugin.initialize(const InitializationSettings(android: androidInit));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            'Task reminders',
            description: 'Reminders for tasks with a due date',
            importance: Importance.high,
          ),
        );
  }

  int _notificationIdFor(String taskId) => taskId.hashCode & 0x7fffffff;

  Future<void> scheduleReminder({
    required String taskId,
    required String title,
    required DateTime dueDate,
  }) async {
    final scheduled = tz.TZDateTime.from(dueDate, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _notificationIdFor(taskId),
      title,
      'Due now',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Task reminders',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String taskId) =>
      _plugin.cancel(_notificationIdFor(taskId));
}
