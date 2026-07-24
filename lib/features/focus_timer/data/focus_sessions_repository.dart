import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';

class FocusSessionsRepository {
  FocusSessionsRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<FocusSession>> watchToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final query = _db.select(_db.focusSessions)
      ..where((s) => s.startedAt.isBiggerOrEqualValue(startOfDay) & s.completed.equals(true))
      ..orderBy([(s) => OrderingTerm(expression: s.startedAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<void> recordSession({
    required DateTime startedAt,
    required int durationMin,
    required String type,
  }) {
    return _db.into(_db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            id: _uuid.v4(),
            startedAt: startedAt,
            durationMin: durationMin,
            type: Value(type),
            completed: const Value(true),
          ),
        );
  }
}
