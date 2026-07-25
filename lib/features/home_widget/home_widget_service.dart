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
  static const _lastUpdatedKey = 'last_updated';
  static const _streakKey = 'streak';
  static const _pendingTogglesKey = 'pending_toggles';
  static const _pendingFocusActionKey = 'pending_focus_action';
  static const _focusStateKey = 'focus_state';
  // `HomeWidget.updateWidget`'s `androidName` is naively prefixed with just
  // the package name (`context.packageName + "." + androidName`), which
  // can't reach receivers in a subpackage — these classes live under
  // `com.karm.app.widget`, so the fully-qualified name has to be passed via
  // `qualifiedAndroidName` instead, or the update silently no-ops with a
  // ClassNotFoundException.
  static const _todayAndroidWidgetReceiver = 'com.karm.app.widget.TodayWidgetReceiver';
  static const _statsAndroidWidgetReceiver = 'com.karm.app.widget.StatsWidgetReceiver';
  static const _focusAndroidWidgetReceiver = 'com.karm.app.widget.FocusWidgetReceiver';
  static const _maxTasks = 8;

  Future<void> pushTodayTasks(List<TaskTileData> tasks) async {
    final payload = tasks
        .take(_maxTasks)
        .map((t) => {'id': t.id, 'title': t.title, 'done': t.done})
        .toList();
    await HomeWidget.saveWidgetData<String>(_todayTasksKey, jsonEncode(payload));
    await HomeWidget.saveWidgetData<int>(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
    await HomeWidget.updateWidget(qualifiedAndroidName: _todayAndroidWidgetReceiver);
    await HomeWidget.updateWidget(qualifiedAndroidName: _statsAndroidWidgetReceiver);
  }

  /// Pushed alongside today's tasks so the Stats widget can show a
  /// streak without duplicating the Drift queries in Kotlin.
  Future<void> pushStreak(int streak) async {
    await HomeWidget.saveWidgetData<int>(_streakKey, streak);
    await HomeWidget.updateWidget(qualifiedAndroidName: _statsAndroidWidgetReceiver);
  }

  /// Pushes the focus timer's state so the Focus widget can show the
  /// current phase and derive remaining time from [endTime] the same way
  /// [FocusTimerController] does in-app — the widget can't tick every
  /// second, but recomputes this on each periodic redraw.
  Future<void> pushFocusState({
    required String phaseLabel,
    required bool isRunning,
    required int remainingSeconds,
    DateTime? endTime,
  }) async {
    final payload = {
      'phaseLabel': phaseLabel,
      'isRunning': isRunning,
      'remainingSeconds': remainingSeconds,
      'endTime': endTime?.millisecondsSinceEpoch,
    };
    await HomeWidget.saveWidgetData<String>(_focusStateKey, jsonEncode(payload));
    await HomeWidget.updateWidget(qualifiedAndroidName: _focusAndroidWidgetReceiver);
  }

  /// Returns task ids toggled directly on the widget while the app wasn't
  /// open, then clears the queue.
  Future<List<String>> drainPendingToggles() async {
    final raw = await HomeWidget.getWidgetData<String>(_pendingTogglesKey, defaultValue: '[]');
    await HomeWidget.saveWidgetData<String>(_pendingTogglesKey, '[]');
    return (jsonDecode(raw ?? '[]') as List).cast<String>();
  }

  /// Returns "start"/"pause" if the Focus widget's button was tapped
  /// while the app wasn't open, then clears it, so the real
  /// [FocusTimerController] can be brought in sync.
  Future<String?> drainPendingFocusAction() async {
    final action = await HomeWidget.getWidgetData<String>(_pendingFocusActionKey);
    if (action == null) return null;
    await HomeWidget.saveWidgetData<String>(_pendingFocusActionKey, null);
    return action;
  }
}
