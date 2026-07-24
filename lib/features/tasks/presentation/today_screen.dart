import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../ai_quick_add/plan_my_day_sheet.dart';
import '../application/tasks_providers.dart';
import '../domain/task_tile_data.dart';
import 'add_task_sheet.dart';
import 'task_tile.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final tasksAsync = ref.watch(todayTasksProvider);
    final dateLabel = DateFormat('EEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: tasksAsync.when(
          data: (tasks) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(), style: type.greeting),
                        const SizedBox(height: 4),
                        Text(dateLabel.toUpperCase(), style: type.dateStamp),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/focus-timer'),
                    icon: Icon(Icons.timer_outlined, color: colors.inkMuted),
                    tooltip: 'Focus timer',
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: Icon(Icons.settings_outlined, color: colors.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (tasks.isNotEmpty) ...[
                OutlinedButton.icon(
                  onPressed: () => showPlanMyDaySheet(
                    context,
                    tasks.map((t) => t.toTileData()).toList(),
                  ),
                  icon: Icon(Icons.auto_awesome, size: 16, color: colors.indigo),
                  label: const Text('Plan my day'),
                ),
                const SizedBox(height: 16),
              ],
              if (tasks.isEmpty)
                _EmptyState(type: type)
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.hairline),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < tasks.length; i++) ...[
                        if (i != 0) Divider(height: 1, color: colors.hairline),
                        TaskTile(
                          task: tasks[i].toTileData(),
                          onToggle: (_) => ref
                              .read(tasksControllerProvider.notifier)
                              .toggleDone(tasks[i]),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Something went wrong: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppTextStyles type;

  const _EmptyState({required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nothing due today', style: type.sectionTitle),
          const SizedBox(height: 6),
          Text(
            'Tap the + button to add your first task.',
            style: type.taskNotes,
          ),
        ],
      ),
    );
  }
}
