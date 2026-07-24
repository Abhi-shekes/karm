import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mirrors the signed-in user's public profile to Firestore so other
/// members can look them up by email (for invites) and so Cloud Functions
/// can find their FCM tokens to notify them.
class UserProfileRepository {
  UserProfileRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> upsertProfile(User user) {
    return _firestore.collection('users').doc(user.uid).set({
      'displayName': user.displayName,
      'email': user.email?.trim().toLowerCase(),
      'photoUrl': user.photoURL,
    }, SetOptions(merge: true));
  }

  Future<void> addFcmToken(String uid, String token) {
    return _firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }
}
