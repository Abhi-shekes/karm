import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/application/user_profile_providers.dart';
import '../features/home_widget/home_widget_provider.dart';
import '../features/lists/application/lists_providers.dart';
import '../features/notifications/fcm_service_provider.dart';
import '../features/notifications/reminder_service_provider.dart';
import '../features/tasks/application/tasks_providers.dart';

part 'app_initialization.g.dart';

/// Runs once per signed-in user: sets up local notifications, seeds a
/// default list, mirrors the user's profile to Firestore (so others can
/// find them by email to invite to a shared list), registers this device
/// for push notifications, applies any home-widget taps made while the
/// app wasn't open, and starts keeping the widget's data fresh.
@riverpod
Future<void> appInitialization(Ref ref, String userId) async {
  await ref.read(reminderServiceProvider).initialize();
  await ref.read(listsRepositoryProvider).ensureDefaultList(userId);
  await _applyPendingWidgetToggles(ref);
  ref.read(homeWidgetSyncProvider);

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final profiles = ref.read(userProfileRepositoryProvider);
  await profiles.upsertProfile(user);

  final token = await ref.read(fcmServiceProvider).registerAndGetToken();
  if (token != null) {
    await profiles.addFcmToken(user.uid, token);
  }
}

Future<void> _applyPendingWidgetToggles(Ref ref) async {
  final toggledIds = await ref.read(homeWidgetServiceProvider).drainPendingToggles();
  if (toggledIds.isEmpty) return;

  final tasksRepository = ref.read(tasksRepositoryProvider);
  final controller = ref.read(tasksControllerProvider.notifier);
  for (final id in toggledIds) {
    final task = await tasksRepository.getById(id);
    if (task != null) await controller.toggleDone(task);
  }
}
