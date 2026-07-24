import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'reminder_service.dart';

part 'reminder_service_provider.g.dart';

@Riverpod(keepAlive: true)
ReminderService reminderService(Ref ref) {
  return ReminderService(FlutterLocalNotificationsPlugin());
}
