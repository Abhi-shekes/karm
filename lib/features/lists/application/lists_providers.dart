import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../data/lists_repository.dart';
import '../data/shared_list_repository.dart';
import '../data/shared_models.dart';

part 'lists_providers.g.dart';

@Riverpod(keepAlive: true)
ListsRepository listsRepository(Ref ref) {
  return ListsRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
SharedListRepository sharedListRepository(Ref ref) {
  return SharedListRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<TaskList>> allLists(Ref ref) {
  return ref.watch(listsRepositoryProvider).watchAllLists();
}

@riverpod
Stream<TaskList?> listById(Ref ref, String listId) {
  return ref
      .watch(listsRepositoryProvider)
      .watchAllLists()
      .map((lists) => lists.where((l) => l.id == listId).firstOrNull);
}

@riverpod
Stream<List<SharedTask>> sharedTasksForList(Ref ref, String listId) {
  return ref.watch(sharedListRepositoryProvider).watchTasks(listId);
}

@riverpod
Stream<List<ListMember>> listMembers(Ref ref, String listId) {
  return ref.watch(sharedListRepositoryProvider).watchMembers(listId);
}

@riverpod
Stream<List<SharedListSummary>> listsSharedWithMe(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(sharedListRepositoryProvider).watchListsSharedWithMe(uid);
}
