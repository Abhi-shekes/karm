import 'package:cloud_firestore/cloud_firestore.dart';

import '../../tasks/domain/task_tile_data.dart';

/// A task belonging to a shared (Firestore-backed) list.
class SharedTask {
  final String id;
  final String title;
  final String? notes;
  final DateTime? dueDate;
  final int priority;
  final List<String> tags;
  final String? assigneeId;
  final bool done;
  final String? recurrenceRule;
  final String createdBy;

  const SharedTask({
    required this.id,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.priority,
    required this.tags,
    required this.assigneeId,
    required this.done,
    required this.recurrenceRule,
    required this.createdBy,
  });

  factory SharedTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SharedTask(
      id: doc.id,
      title: data['title'] as String? ?? '',
      notes: data['notes'] as String?,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      priority: (data['priority'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(data['tags'] as List? ?? const []),
      assigneeId: data['assigneeId'] as String?,
      done: data['done'] as bool? ?? false,
      recurrenceRule: data['recurrenceRule'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }
}

extension SharedTaskTileData on SharedTask {
  TaskTileData toTileData() => TaskTileData(
        id: id,
        title: title,
        notes: notes,
        dueDate: dueDate,
        priority: priority,
        tags: tags,
        done: done,
      );
}

/// A shared list you've been invited to but haven't opened yet — just
/// enough to show it in the "Shared with you" section before it's
/// adopted into the local database.
class SharedListSummary {
  final String id;
  final String title;
  final String colorHex;
  final String icon;
  final String ownerId;

  const SharedListSummary({
    required this.id,
    required this.title,
    required this.colorHex,
    required this.icon,
    required this.ownerId,
  });

  factory SharedListSummary.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SharedListSummary(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled list',
      colorHex: data['colorHex'] as String? ?? '33367D',
      icon: data['icon'] as String? ?? 'list',
      ownerId: data['ownerId'] as String? ?? '',
    );
  }
}

/// A member of a shared list, joined with their public profile.
class ListMember {
  final String uid;
  final String role;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const ListMember({
    required this.uid,
    required this.role,
    this.displayName,
    this.email,
    this.photoUrl,
  });
}
