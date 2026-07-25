import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../settings/application/profile_stats_provider.dart';
import '../tasks/application/tasks_providers.dart';
import '../tasks/domain/task_tile_data.dart';
import 'home_widget_service.dart';

part 'home_widget_provider.g.dart';

@Riverpod(keepAlive: true)
HomeWidgetService homeWidgetService(Ref ref) => HomeWidgetService();

/// Keeps the home screen widgets fresh by pushing to them every time
/// their underlying data changes, for as long as the app is running.
/// Activated once from [appInitialization] by reading it.
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
    ref.listen(profileStatsProvider, (previous, next) {
      next.whenData((stats) {
        ref.read(homeWidgetServiceProvider).pushStreak(stats.streak);
      });
    });
  }
}
