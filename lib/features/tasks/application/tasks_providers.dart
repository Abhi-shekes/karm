import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../notifications/reminder_service_provider.dart';
import '../../recurring/recurrence.dart';
import '../data/tasks_repository.dart';

part 'tasks_providers.g.dart';

@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) {
  return TasksRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<Task>> todayTasks(Ref ref) {
  return ref.watch(tasksRepositoryProvider).watchTodayAndOverdue();
}

@riverpod
Stream<List<Task>> upcomingTasks(Ref ref) {
  return ref.watch(tasksRepositoryProvider).watchUpcoming();
}

@riverpod
Stream<List<Task>> tasksForList(Ref ref, String listId) {
  return ref.watch(tasksRepositoryProvider).watchTasksForList(listId);
}

@riverpod
Stream<List<Task>> allTasksWithDueDates(Ref ref) {
  return ref.watch(tasksRepositoryProvider).watchAllTasksWithDueDates();
}

@riverpod
Stream<List<Subtask>> subtasksForTask(Ref ref, String taskId) {
  return ref.watch(tasksRepositoryProvider).watchSubtasks(taskId);
}

@riverpod
class TasksController extends _$TasksController {
  @override
  void build() {}

  Future<void> addTask({
    required String listId,
    required String title,
    required String createdBy,
    String? notes,
    DateTime? dueDate,
    bool flagged = false,
    List<String> tags = const [],
    RecurrenceRule? recurrence,
  }) async {
    final repo = ref.read(tasksRepositoryProvider);
    final id = await repo.addTask(
      listId: listId,
      title: title,
      createdBy: createdBy,
      notes: notes,
      dueDate: dueDate,
      flagged: flagged,
      tags: tags,
      recurrenceRule: recurrence?.storageValue,
    );
    if (dueDate != null) {
      await ref.read(reminderServiceProvider).scheduleReminder(
            taskId: id,
            title: title,
            dueDate: dueDate,
          );
    }
  }

  Future<void> toggleDone(Task task) async {
    final repo = ref.read(tasksRepositoryProvider);
    final reminders = ref.read(reminderServiceProvider);
    final next = await repo.toggleDone(task);

    await reminders.cancelReminder(task.id);
    if (next != null && next.dueDate != null) {
      await reminders.scheduleReminder(
        taskId: next.id,
        title: next.title,
        dueDate: next.dueDate!,
      );
    }
  }

  /// Applies edits from the task detail sheet and keeps the task's reminder
  /// in step with its new due date — clearing it when the date is removed.
  Future<void> updateTask(
    Task task, {
    required String title,
    String? notes,
    DateTime? dueDate,
    bool flagged = false,
    List<String> tags = const [],
  }) async {
    await ref.read(tasksRepositoryProvider).updateTask(
          task.id,
          title: Value(title),
          notes: Value(notes),
          dueDate: Value(dueDate),
          priority: Value(flagged ? 1 : 0),
          tags: Value(tags.join(',')),
        );

    final reminders = ref.read(reminderServiceProvider);
    await reminders.cancelReminder(task.id);
    if (dueDate != null && !task.done) {
      await reminders.scheduleReminder(
        taskId: task.id,
        title: title,
        dueDate: dueDate,
      );
    }
  }

  Future<void> deleteTask(Task task) async {
    await ref.read(tasksRepositoryProvider).deleteTask(task.id);
    await ref.read(reminderServiceProvider).cancelReminder(task.id);
  }

  Future<void> addSubtask(String taskId, String title) {
    return ref.read(tasksRepositoryProvider).addSubtask(taskId, title);
  }

  Future<void> toggleSubtaskDone(Subtask subtask) {
    return ref.read(tasksRepositoryProvider).toggleSubtaskDone(subtask);
  }
}
