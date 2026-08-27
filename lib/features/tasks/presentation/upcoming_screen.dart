import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../application/tasks_providers.dart';
import '../domain/task_tile_data.dart';
import 'add_task_sheet.dart';
import 'task_tile.dart';
import 'task_detail_sheet.dart';

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final tasksAsync = ref.watch(upcomingTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming')),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Nothing scheduled ahead. Tasks with a future due date show up here.',
                style: type.taskNotes,
              ),
            );
          }

          final grouped = groupBy(tasks, (task) {
            final due = task.dueDate!;
            return DateTime(due.year, due.month, due.day);
          });
          final days = grouped.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              for (final day in days) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    DateFormat('EEEE, MMM d').format(day).toUpperCase(),
                    style: type.dateStamp,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.hairline),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < grouped[day]!.length; i++) ...[
                        if (i != 0) Divider(height: 1, color: colors.hairline),
                        TaskTile(
                          task: grouped[day]![i].toTileData(),
                          onToggle: (_) => ref
                              .read(tasksControllerProvider.notifier)
                              .toggleDone(grouped[day]![i]),
                          onTap: () => showTaskDetailSheet(
                            context,
                            grouped[day]![i].id,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
