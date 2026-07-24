import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../application/friends_providers.dart';
import '../data/friend_models.dart';
import 'add_friend_sheet.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final friendsAsync = ref.watch(friendsProvider);
    final incomingAsync = ref.watch(incomingFriendRequestsProvider);
    final outgoingAsync = ref.watch(outgoingFriendRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          incomingAsync.when(
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return _Section(
                title: 'Requests',
                type: type,
                children: [
                  for (final request in requests) _IncomingRequestTile(request: request),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          outgoingAsync.when(
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return _Section(
                title: 'Sent',
                type: type,
                children: [
                  for (final request in requests) _OutgoingRequestTile(request: request),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          _Section(
            title: 'Friends',
            type: type,
            children: [
              friendsAsync.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No friends yet — add one to start sharing lists.',
                        style: type.taskNotes,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final friend in friends)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: colors.hairline,
                            backgroundImage:
                                friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
                            child: friend.photoUrl == null
                                ? Text(friend.label.substring(0, 1).toUpperCase(),
                                    style: type.caption)
                                : null,
                          ),
                          title: Text(friend.label, style: type.taskTitle),
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) =>
                    Text('Something went wrong: $error', style: type.taskNotes),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddFriendSheet(context),
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AppTextStyles type;
  final List<Widget> children;

  const _Section({required this.title, required this.type, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: type.dateStamp),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _IncomingRequestTile extends ConsumerWidget {
  final FriendRequest request;

  const _IncomingRequestTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.textStyles;
    final profileAsync = ref.watch(friendProfileProvider(request.fromUid));

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        profileAsync.valueOrNull?.label ?? request.fromUid,
        style: type.taskTitle,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () =>
                ref.read(friendsRepositoryProvider).respond(requestId: request.id, accept: true),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                ref.read(friendsRepositoryProvider).respond(requestId: request.id, accept: false),
          ),
        ],
      ),
    );
  }
}

class _OutgoingRequestTile extends ConsumerWidget {
  final FriendRequest request;

  const _OutgoingRequestTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.textStyles;
    final colors = context.colors;
    final profileAsync = ref.watch(friendProfileProvider(request.toUid));

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        profileAsync.valueOrNull?.label ?? request.toUid,
        style: type.taskTitle,
      ),
      subtitle: Text('Pending', style: type.caption),
      trailing: IconButton(
        icon: Icon(Icons.close, color: colors.inkMuted),
        onPressed: () => ref.read(friendsRepositoryProvider).cancel(request.id),
      ),
    );
  }
}
