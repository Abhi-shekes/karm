import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../recurring/recurrence.dart';

class TasksRepository {
  TasksRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Task>> watchTasksForList(String listId) {
    final query = _db.select(_db.tasks)
      ..where((t) => t.listId.equals(listId) & t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.watch();
  }

  /// One-shot fetch used when publishing a local list to Firestore for
  /// sharing — the caller needs a snapshot, not a live stream.
  Future<List<Task>> getTasksForList(String listId) {
    final query = _db.select(_db.tasks)
      ..where((t) => t.listId.equals(listId) & t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    return query.get();
  }

  /// Today = due today or earlier (overdue), whether done or not — a
  /// completed task stays visible (struck through) until it scrolls off
  /// the day, matching the calm "nothing vanishes on you" feel of the app.
  /// Tasks with no due date have no natural home elsewhere, so they default
  /// into Today too and stay there until marked done.
  Stream<List<Task>> watchTodayAndOverdue() {
    final tomorrowStart = _startOfDay(DateTime.now().add(const Duration(days: 1)));
    final query = _db.select(_db.tasks)
      ..where((t) =>
          t.isDeleted.equals(false) &
          (t.dueDate.isSmallerThanValue(tomorrowStart) | t.dueDate.isNull()))
      ..orderBy([
        (t) => OrderingTerm(expression: t.done),
        (t) => OrderingTerm(expression: t.dueDate),
      ]);
    return query.watch();
  }

  /// All tasks with a due date, across every list — feeds the calendar's
  /// month markers and per-day agenda.
  Stream<List<Task>> watchAllTasksWithDueDates() {
    final query = _db.select(_db.tasks)
      ..where((t) => t.isDeleted.equals(false) & t.dueDate.isNotNull());
    return query.watch();
  }

  Stream<List<Task>> watchUpcoming() {
    final tomorrowStart = _startOfDay(DateTime.now().add(const Duration(days: 1)));
    final query = _db.select(_db.tasks)
      ..where((t) =>
          t.isDeleted.equals(false) &
          t.done.equals(false) &
          t.dueDate.isBiggerOrEqualValue(tomorrowStart))
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]);
    return query.watch();
  }

  Stream<List<Subtask>> watchSubtasks(String taskId) {
    final query = _db.select(_db.subtasks)
      ..where((s) => s.taskId.equals(taskId) & s.isDeleted.equals(false))
      ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]);
    return query.watch();
  }

  Future<String> addTask({
    required String listId,
    required String title,
    required String createdBy,
    String? notes,
    DateTime? dueDate,
    bool flagged = false,
    List<String> tags = const [],
    String? recurrenceRule,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            id: id,
            listId: listId,
            title: title,
            notes: Value(notes),
            dueDate: Value(dueDate),
            priority: Value(flagged ? 1 : 0),
            tags: Value(tags.join(',')),
            recurrenceRule: Value(recurrenceRule),
            createdBy: createdBy,
            updatedAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> updateTask(
    String id, {
    Value<String> title = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<int> priority = const Value.absent(),
    Value<String> tags = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
  }) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: title,
        notes: notes,
        dueDate: dueDate,
        priority: priority,
        tags: tags,
        recurrenceRule: recurrenceRule,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggles completion. If the task is recurring and is being marked
  /// done, inserts the next occurrence and returns it so the caller can
  /// schedule its reminder.
  Future<Task?> toggleDone(Task task) async {
    final isNowDone = !task.done;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(done: Value(isNowDone), updatedAt: Value(DateTime.now())),
    );

    if (!isNowDone) return null;
    final rule = RecurrenceRule.fromStorage(task.recurrenceRule);
    if (rule == null) return null;

    final nextId = _uuid.v4();
    final next = TasksCompanion.insert(
      id: nextId,
      listId: task.listId,
      title: task.title,
      notes: Value(task.notes),
      dueDate: Value(nextDueDateFor(rule, task.dueDate)),
      priority: Value(task.priority),
      tags: Value(task.tags),
      recurrenceRule: Value(task.recurrenceRule),
      createdBy: task.createdBy,
      updatedAt: DateTime.now(),
    );
    await _db.into(_db.tasks).insert(next);
    return getById(nextId);
  }

  Future<Task?> getById(String id) {
    return (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> deleteTask(String id) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id)))
        .write(const TasksCompanion(isDeleted: Value(true)));
  }

  Future<void> addSubtask(String taskId, String title) async {
    await _db.into(_db.subtasks).insert(
          SubtasksCompanion.insert(id: _uuid.v4(), taskId: taskId, title: title),
        );
  }

  Future<void> toggleSubtaskDone(Subtask subtask) {
    return (_db.update(_db.subtasks)..where((s) => s.id.equals(subtask.id)))
        .write(SubtasksCompanion(done: Value(!subtask.done)));
  }

  DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
