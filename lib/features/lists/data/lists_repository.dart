import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';

class ListsRepository {
  ListsRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<TaskList>> watchAllLists() {
    final query = _db.select(_db.taskLists)
      ..where((l) => l.isDeleted.equals(false))
      ..orderBy([(l) => OrderingTerm(expression: l.createdAt)]);
    return query.watch();
  }

  Future<TaskList?> getById(String id) {
    return (_db.select(_db.taskLists)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  /// Seeds a default "Inbox" list on first launch so a signed-in user
  /// always has somewhere to put a task.
  Future<void> ensureDefaultList(String ownerId) async {
    final existing = await _db.select(_db.taskLists).get();
    if (existing.isNotEmpty) return;
    await createList(
      title: 'Inbox',
      colorHex: '33367D',
      icon: 'inbox',
      ownerId: ownerId,
    );
  }

  Future<String> createList({
    required String title,
    required String colorHex,
    required String icon,
    required String ownerId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.taskLists).insert(
          TaskListsCompanion.insert(
            id: id,
            title: title,
            colorHex: colorHex,
            icon: icon,
            ownerId: ownerId,
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> deleteList(String id) {
    return (_db.update(_db.taskLists)..where((l) => l.id.equals(id)))
        .write(const TaskListsCompanion(isDeleted: Value(true)));
  }

  Future<void> markShared(String id) {
    return (_db.update(_db.taskLists)..where((l) => l.id.equals(id)))
        .write(const TaskListsCompanion(isShared: Value(true)));
  }

  /// Mirrors a list you were invited to into the local database, using the
  /// same id as its Firestore document, so [ListDetailScreen] can treat it
  /// exactly like a list you shared yourself.
  Future<void> adoptSharedList({
    required String id,
    required String title,
    required String colorHex,
    required String icon,
    required String ownerId,
  }) {
    return _db.into(_db.taskLists).insertOnConflictUpdate(
          TaskListsCompanion.insert(
            id: id,
            title: title,
            colorHex: colorHex,
            icon: icon,
            ownerId: ownerId,
            createdAt: DateTime.now(),
            isShared: const Value(true),
          ),
        );
  }
}
