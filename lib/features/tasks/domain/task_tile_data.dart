import 'package:flutter/foundation.dart';

import '../../../core/db/app_database.dart';

/// The subset of task fields [TaskTile] needs to render — shared between
/// local Drift-backed tasks and Firestore-backed shared-list tasks so the
/// same row widget can display either.
@immutable
class TaskTileData {
  final String id;
  final String title;
  final String? notes;
  final DateTime? dueDate;
  final int priority;
  final List<String> tags;
  final bool done;

  const TaskTileData({
    required this.id,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.priority,
    required this.tags,
    required this.done,
  });
}

extension TaskTileDataFromDrift on Task {
  TaskTileData toTileData() => TaskTileData(
        id: id,
        title: title,
        notes: notes,
        dueDate: dueDate,
        priority: priority,
        tags: tags.split(',').where((t) => t.isNotEmpty).toList(),
        done: done,
      );
}
