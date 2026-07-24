import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../tasks/application/tasks_providers.dart';
import '../tasks/domain/task_tile_data.dart';
import 'home_widget_service.dart';

part 'home_widget_provider.g.dart';

@Riverpod(keepAlive: true)
HomeWidgetService homeWidgetService(Ref ref) => HomeWidgetService();

/// Keeps the home screen widget's task snapshot fresh by pushing to it
/// every time [todayTasksProvider] changes, for as long as the app is
/// running. Activated once from [appInitialization] by reading it.
@Riverpod(keepAlive: true)
class HomeWidgetSync extends _$HomeWidgetSync {
  @override
  void build() {
    ref.listen(todayTasksProvider, (previous, next) {
      next.whenData((tasks) {
        ref.read(homeWidgetServiceProvider).pushTodayTasks(
              tasks.map((t) => t.toTileData()).toList(),
            );
      });
    });
  }
}
