import 'package:drift/drift.dart';

class TaskLists extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get colorHex => text()();
  TextColumn get icon => text()();
  TextColumn get ownerId => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  // True once this list has been published to Firestore for collaboration;
  // its tasks then live in Firestore instead of the tasks table below.
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text().references(TaskLists, #id)();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  // 0 none, 1 low, 2 medium, 3 high
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get assigneeId => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Subtasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMin => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant('pomodoro'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pending local mutations awaiting push to Firestore — backbone of the
/// local-first, remote-eventual sync engine described in the design plan.
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}
