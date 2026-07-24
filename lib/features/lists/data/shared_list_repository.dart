import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/db/app_database.dart';
import 'shared_models.dart';

/// Firestore-backed CRUD for shared lists — the collaboration counterpart
/// to [TasksRepository]/[ListsRepository], which stay Drift-only. A list
/// becomes Firestore-backed once [publishList] is called on it; its
/// Firestore document reuses the same id as the local Drift row.
class SharedListRepository {
  SharedListRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _lists => _firestore.collection('lists');

  Future<void> publishList({
    required String listId,
    required String title,
    required String colorHex,
    required String icon,
    required String ownerId,
    required List<Task> tasks,
  }) async {
    final listRef = _lists.doc(listId);
    final batch = _firestore.batch();

    batch.set(listRef, {
      'ownerId': ownerId,
      'title': title,
      'colorHex': colorHex,
      'icon': icon,
      'createdAt': FieldValue.serverTimestamp(),
      'memberIds': [ownerId],
    });
    batch.set(listRef.collection('members').doc(ownerId), {
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    for (final task in tasks) {
      batch.set(listRef.collection('tasks').doc(task.id), {
        'title': task.title,
        'notes': task.notes,
        'dueDate': task.dueDate == null ? null : Timestamp.fromDate(task.dueDate!),
        'priority': task.priority,
        'tags': task.tags.split(',').where((t) => t.isNotEmpty).toList(),
        'assigneeId': null,
        'done': task.done,
        'recurrenceRule': task.recurrenceRule,
        'createdBy': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
        'sortOrder': task.sortOrder,
      });
    }
    await batch.commit();
  }

  /// Lists you're a member of but don't own — for someone who's shared a
  /// list with you, this is how it surfaces before you've opened it once
  /// locally. Owned shared lists already show up via the local database.
  Stream<List<SharedListSummary>> watchListsSharedWithMe(String uid) {
    return _lists.where('memberIds', arrayContains: uid).snapshots().map(
          (snap) => snap.docs
              .map(SharedListSummary.fromDoc)
              .where((list) => list.ownerId != uid)
              .toList(),
        );
  }

  Stream<List<SharedTask>> watchTasks(String listId) {
    return _lists.doc(listId).collection('tasks').snapshots().map(
          (snap) => snap.docs.map(SharedTask.fromDoc).toList(),
        );
  }

  Stream<List<ListMember>> watchMembers(String listId) {
    return _lists.doc(listId).collection('members').snapshots().asyncMap((snap) async {
      final members = <ListMember>[];
      for (final doc in snap.docs) {
        final userDoc = await _firestore.collection('users').doc(doc.id).get();
        final userData = userDoc.data();
        members.add(ListMember(
          uid: doc.id,
          role: doc.data()['role'] as String? ?? 'viewer',
          displayName: userData?['displayName'] as String?,
          email: userData?['email'] as String?,
          photoUrl: userData?['photoUrl'] as String?,
        ));
      }
      return members;
    });
  }

  Future<void> addTask({
    required String listId,
    required String title,
    required String createdBy,
    String? notes,
    DateTime? dueDate,
    bool flagged = false,
    List<String> tags = const [],
    String? recurrenceRule,
  }) {
    return _lists.doc(listId).collection('tasks').add({
      'title': title,
      'notes': notes,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'priority': flagged ? 1 : 0,
      'tags': tags,
      'assigneeId': null,
      'done': false,
      'recurrenceRule': recurrenceRule,
      'createdBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'sortOrder': 0,
    });
  }

  Future<void> toggleDone(String listId, SharedTask task) {
    return _lists.doc(listId).collection('tasks').doc(task.id).update({
      'done': !task.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignTask(String listId, String taskId, String? assigneeId) {
    return _lists.doc(listId).collection('tasks').doc(taskId).update({
      'assigneeId': assigneeId,
    });
  }

  /// Looks up a user by email and adds them as a member. Returns false if
  /// no one has signed into Karm with that email yet.
  Future<bool> inviteByEmail({
    required String listId,
    required String email,
    required String role,
  }) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return false;

    await inviteByUid(listId: listId, uid: query.docs.first.id, role: role);
    return true;
  }

  /// Adds a known user (e.g. picked from your friends list) directly,
  /// without an email lookup.
  Future<void> inviteByUid({
    required String listId,
    required String uid,
    required String role,
  }) async {
    final listRef = _lists.doc(listId);
    final batch = _firestore.batch()
      ..set(listRef.collection('members').doc(uid), {
        'role': role,
        'joinedAt': FieldValue.serverTimestamp(),
      })
      ..update(listRef, {
        'memberIds': FieldValue.arrayUnion([uid]),
      });
    await batch.commit();
  }

  Future<void> updateMemberRole(String listId, String uid, String role) {
    return _lists.doc(listId).collection('members').doc(uid).update({'role': role});
  }

  Future<void> removeMember(String listId, String uid) async {
    final listRef = _lists.doc(listId);
    final batch = _firestore.batch()
      ..delete(listRef.collection('members').doc(uid))
      ..update(listRef, {
        'memberIds': FieldValue.arrayRemove([uid]),
      });
    await batch.commit();
  }
}
