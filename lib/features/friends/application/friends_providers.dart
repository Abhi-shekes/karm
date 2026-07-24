import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_providers.dart';
import '../data/friend_models.dart';
import '../data/friends_repository.dart';

part 'friends_providers.g.dart';

@Riverpod(keepAlive: true)
FriendsRepository friendsRepository(Ref ref) {
  return FriendsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<FriendProfile>> friends(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(friendsRepositoryProvider).watchFriends(uid);
}

@riverpod
Stream<List<FriendRequest>> incomingFriendRequests(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(friendsRepositoryProvider).watchIncomingRequests(uid);
}

@riverpod
Stream<List<FriendRequest>> outgoingFriendRequests(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(friendsRepositoryProvider).watchOutgoingRequests(uid);
}

@riverpod
Future<FriendProfile?> friendProfile(Ref ref, String uid) {
  return ref.watch(friendsRepositoryProvider).profileFor(uid);
}
