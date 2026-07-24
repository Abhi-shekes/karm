import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../tasks/presentation/add_task_sheet.dart';

/// Watches for the app being launched (cold-start or already running) by
/// tapping "+ Add" on the Today home screen widget, and opens the add-task
/// sheet once the app's UI is actually ready to show it.
class WidgetLaunchListener {
  WidgetLaunchListener(this._navigatorKey) {
    _init();
  }

  final GlobalKey<NavigatorState> _navigatorKey;

  Future<void> _init() async {
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _handleUri(initialUri);
    HomeWidget.widgetClicked.listen(_handleUri);
  }

  void _handleUri(Uri? uri) {
    if (uri == null || uri.host != 'quick-add') return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context != null) showAddTaskSheet(context);
    });
  }
}
