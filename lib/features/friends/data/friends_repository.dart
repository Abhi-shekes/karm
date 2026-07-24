import 'package:cloud_firestore/cloud_firestore.dart';

import 'friend_models.dart';

enum SendFriendRequestResult { sent, notFound, isSelf, alreadyFriends, alreadyPending }

class FriendsRepository {
  FriendsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('friendRequests');

  Future<SendFriendRequestResult> sendRequest({
    required String myUid,
    required String toEmail,
  }) async {
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: toEmail.trim().toLowerCase())
        .limit(1)
        .get();
    if (userQuery.docs.isEmpty) return SendFriendRequestResult.notFound;

    final toUid = userQuery.docs.first.id;
    if (toUid == myUid) return SendFriendRequestResult.isSelf;

    final existing = await _requests.where('participants', arrayContains: myUid).get();
    for (final doc in existing.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] as List? ?? const []);
      if (!participants.contains(toUid)) continue;
      if (data['status'] == 'accepted') return SendFriendRequestResult.alreadyFriends;
      if (data['status'] == 'pending') return SendFriendRequestResult.alreadyPending;
    }

    await _requests.add({
      'fromUid': myUid,
      'toUid': toUid,
      'participants': [myUid, toUid],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return SendFriendRequestResult.sent;
  }

  Future<void> respond({required String requestId, required bool accept}) {
    return _requests.doc(requestId).update({
      'status': accept ? 'accepted' : 'declined',
    });
  }

  Future<void> cancel(String requestId) {
    return _requests.doc(requestId).delete();
  }

  Stream<List<FriendRequest>> watchIncomingRequests(String myUid) {
    return _requests
        .where('toUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FriendRequest.fromDoc).toList());
  }

  Stream<List<FriendRequest>> watchOutgoingRequests(String myUid) {
    return _requests
        .where('fromUid', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FriendRequest.fromDoc).toList());
  }

  Stream<List<FriendProfile>> watchFriends(String myUid) {
    return _requests
        .where('participants', arrayContains: myUid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snap) async {
      final friends = <FriendProfile>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] as List? ?? const []);
        final friendUid = participants.firstWhere((uid) => uid != myUid, orElse: () => '');
        if (friendUid.isEmpty) continue;
        final userDoc = await _firestore.collection('users').doc(friendUid).get();
        final userData = userDoc.data();
        friends.add(FriendProfile(
          uid: friendUid,
          displayName: userData?['displayName'] as String?,
          email: userData?['email'] as String?,
          photoUrl: userData?['photoUrl'] as String?,
        ));
      }
      return friends;
    });
  }

  Future<FriendProfile?> profileFor(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return FriendProfile(
      uid: uid,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }
}
