import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus { pending, accepted, declined }

class FriendRequest {
  final String id;
  final String fromUid;
  final String toUid;
  final FriendRequestStatus status;
  final DateTime? createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FriendRequest(
      id: doc.id,
      fromUid: data['fromUid'] as String? ?? '',
      toUid: data['toUid'] as String? ?? '',
      status: FriendRequestStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// A friend or pending-request counterpart, joined with their public
/// profile for display.
class FriendProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const FriendProfile({required this.uid, this.displayName, this.email, this.photoUrl});

  String get label => displayName ?? email ?? uid;
}
