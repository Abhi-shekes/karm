import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/presentation/task_detail_sheet.dart';
import '../../tasks/domain/task_tile_data.dart';
import '../../tasks/presentation/add_task_sheet.dart';
import '../../tasks/presentation/task_tile.dart';
import '../application/lists_providers.dart';
import '../data/shared_models.dart';
import 'share_list_sheet.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(listByIdProvider(listId));

    return listAsync.when(
      data: (list) {
        if (list == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This list no longer exists.')),
          );
        }
        return list.isShared ? _SharedListBody(list: list) : _LocalListBody(list: list);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Something went wrong: $error'))),
    );
  }
}

class _LocalListBody extends ConsumerWidget {
  final TaskList list;

  const _LocalListBody({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final tasksAsync = ref.watch(tasksForListProvider(list.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(list.title),
        actions: [
          IconButton(
            onPressed: () => showShareListSheet(context, list),
            icon: const Icon(Icons.people_outline),
            tooltip: 'Share list',
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No tasks yet. Tap + to add one.', style: type.taskNotes),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: colors.hairline),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task.toTileData(),
                onToggle: (_) =>
                    ref.read(tasksControllerProvider.notifier).toggleDone(task),
                onTap: () => showTaskDetailSheet(context, task.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(context, initialListId: list.id),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SharedListBody extends ConsumerWidget {
  final TaskList list;

  const _SharedListBody({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final tasksAsync = ref.watch(sharedTasksForListProvider(list.id));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(list.title, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Icon(Icons.people, size: 16, color: colors.indigo),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showShareListSheet(context, list),
            icon: const Icon(Icons.people_outline),
            tooltip: 'Manage members',
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No tasks yet. Tap + to add one.', style: type.taskNotes),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: colors.hairline),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task.toTileData(),
                onToggle: (_) => ref
                    .read(sharedListRepositoryProvider)
                    .toggleDone(list.id, task),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(context, initialListId: list.id),
        child: const Icon(Icons.add),
      ),
    );
  }
}
