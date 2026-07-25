import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karm/core/db/app_database.dart';
import 'package:karm/features/tasks/data/tasks_repository.dart';
import 'package:sqlite3/open.dart';

void main() {
  // This host's libsqlite3 isn't exposed under the unversioned soname
  // dart:ffi looks for by default (only `sqlite3_flutter_libs`' bundled
  // build is, on a real device) — point it at the versioned one so these
  // tests can run against a real in-memory database on this machine.
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
    }
  });

  late AppDatabase db;
  late TasksRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TasksRepository(db);
    await db.into(db.taskLists).insert(
          TaskListsCompanion.insert(
            id: 'list-1',
            title: 'Inbox',
            colorHex: '#000000',
            icon: 'inbox',
            ownerId: 'user-1',
            createdAt: DateTime.now(),
          ),
        );
  });

  tearDown(() => db.close());

  Future<String> addTask({required bool done, required DateTime updatedAt}) async {
    final id = await repo.addTask(listId: 'list-1', title: 'Task', createdBy: 'user-1');
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(done: Value(done), updatedAt: Value(updatedAt)),
    );
    return id;
  }

  group('countAllCompleted', () {
    test('counts only done, non-deleted tasks', () async {
      await addTask(done: true, updatedAt: DateTime.now());
      await addTask(done: true, updatedAt: DateTime.now());
      await addTask(done: false, updatedAt: DateTime.now());

      expect(await repo.countAllCompleted(), 2);
    });
  });

  group('completedDates', () {
    test('returns distinct calendar days for completed tasks', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await addTask(done: true, updatedAt: today);
      await addTask(done: true, updatedAt: DateTime(today.year, today.month, today.day, 23, 0));
      await addTask(done: true, updatedAt: yesterday);
      await addTask(done: false, updatedAt: today);

      final dates = await repo.completedDates();

      expect(dates.length, 2);
      expect(dates, contains(DateTime(today.year, today.month, today.day)));
      expect(dates, contains(DateTime(yesterday.year, yesterday.month, yesterday.day)));
    });
  });
}
