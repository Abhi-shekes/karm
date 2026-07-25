import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../tasks/application/tasks_providers.dart';

part 'profile_stats_provider.g.dart';

@immutable
class ProfileStats {
  final int todayCompleted;
  final int todayTotal;
  final int streak;
  final int allTimeCompleted;

  const ProfileStats({
    required this.todayCompleted,
    required this.todayTotal,
    required this.streak,
    required this.allTimeCompleted,
  });
}

@riverpod
Future<ProfileStats> profileStats(Ref ref) async {
  final tasks = await ref.watch(todayTasksProvider.future);
  final repo = ref.watch(tasksRepositoryProvider);

  final allTimeCompleted = await repo.countAllCompleted();
  final completedDates = await repo.completedDates();

  return ProfileStats(
    todayCompleted: tasks.where((t) => t.done).length,
    todayTotal: tasks.length,
    streak: streakFromCompletedDates(completedDates),
    allTimeCompleted: allTimeCompleted,
  );
}

/// [datesDesc] is distinct completion days, most recent first. Counts
/// consecutive days ending today (or yesterday, so a streak survives
/// until the current day is missed rather than expiring at midnight
/// before today's tasks are even done).
int streakFromCompletedDates(List<DateTime> datesDesc) {
  if (datesDesc.isEmpty) return 0;

  final days = datesDesc.toSet();
  final now = DateTime.now();
  var cursor = DateTime(now.year, now.month, now.day);

  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
