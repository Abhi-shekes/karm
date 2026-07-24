import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../tasks/domain/task_tile_data.dart';

/// Bridges the "Today" home screen widget (Jetpack Glance, see
/// android/app/src/main/kotlin/com/karm/app/widget/TodayWidget.kt) with
/// the app's data. The widget process can't reach the Drift database
/// directly, so it works off a small JSON snapshot in shared prefs and
/// queues taps for the app to apply for real next time it's opened.
class HomeWidgetService {
  static const _todayTasksKey = 'today_tasks';
  static const _pendingTogglesKey = 'pending_toggles';
  static const _androidWidgetReceiver = 'TodayWidgetReceiver';
  static const _maxTasks = 4;

  Future<void> pushTodayTasks(List<TaskTileData> tasks) async {
    final payload = tasks
        .take(_maxTasks)
        .map((t) => {'id': t.id, 'title': t.title, 'done': t.done})
        .toList();
    await HomeWidget.saveWidgetData<String>(_todayTasksKey, jsonEncode(payload));
    await HomeWidget.updateWidget(androidName: _androidWidgetReceiver);
  }

  /// Returns task ids toggled directly on the widget while the app wasn't
  /// open, then clears the queue.
  Future<List<String>> drainPendingToggles() async {
    final raw = await HomeWidget.getWidgetData<String>(_pendingTogglesKey, defaultValue: '[]');
    await HomeWidget.saveWidgetData<String>(_pendingTogglesKey, '[]');
    return (jsonDecode(raw ?? '[]') as List).cast<String>();
  }
}
