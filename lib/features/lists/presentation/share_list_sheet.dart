import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../auth/application/auth_providers.dart';
import '../../friends/application/friends_providers.dart';
import '../../friends/data/friend_models.dart';
import '../../tasks/application/tasks_providers.dart';
import '../application/lists_providers.dart';

Future<void> showShareListSheet(BuildContext context, TaskList list) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareListSheet(list: list),
  );
}

class ShareListSheet extends ConsumerStatefulWidget {
  final TaskList list;

  const ShareListSheet({super.key, required this.list});

  @override
  ConsumerState<ShareListSheet> createState() => _ShareListSheetState();
}

class _ShareListSheetState extends ConsumerState<ShareListSheet> {
  final _emailController = TextEditingController();
  String _role = 'editor';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final tasks = await ref.read(tasksRepositoryProvider).getTasksForList(widget.list.id);
      await ref.read(sharedListRepositoryProvider).publishList(
            listId: widget.list.id,
            title: widget.list.title,
            colorHex: widget.list.colorHex,
            icon: widget.list.icon,
            ownerId: widget.list.ownerId,
            tasks: tasks,
          );
      await ref.read(listsRepositoryProvider).markShared(widget.list.id);
    } catch (_) {
      if (mounted) setState(() => _error = "Couldn't share this list. Try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final found = await ref.read(sharedListRepositoryProvider).inviteByEmail(
            listId: widget.list.id,
            email: email,
            role: _role,
          );
      if (!found) {
        setState(() => _error = 'No one at that email has opened Karm yet.');
      } else {
        _emailController.clear();
      }
    } catch (_) {
      setState(() => _error = "Couldn't send that invite. Try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _inviteFriend(FriendProfile friend) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sharedListRepositoryProvider).inviteByUid(
            listId: widget.list.id,
            uid: friend.uid,
            role: _role,
          );
    } catch (_) {
      setState(() => _error = "Couldn't add ${friend.label}. Try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid;
    final isOwner = widget.list.ownerId == currentUserId;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.paper,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: colors.hairline),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share "${widget.list.title}"', style: type.sectionTitle),
              const SizedBox(height: 16),
              if (!widget.list.isShared) ...[
                Text(
                  'Sharing copies this list to the cloud so others can see and edit it in real time.',
                  style: type.taskNotes,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _publish,
                    child: Text(_busy ? 'Sharing…' : 'Share this list'),
                  ),
                ),
              ] else ...[
                _MembersList(listId: widget.list.id),
                if (isOwner) ...[
                  const SizedBox(height: 20),
                  Divider(color: colors.hairline),
                  const SizedBox(height: 16),
                  Text('Invite someone', style: type.sectionTitle),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Can edit'),
                        selected: _role == 'editor',
                        onSelected: (_) => setState(() => _role = 'editor'),
                      ),
                      ChoiceChip(
                        label: const Text('Can view'),
                        selected: _role == 'viewer',
                        onSelected: (_) => setState(() => _role = 'viewer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FriendsPicker(
                    listId: widget.list.id,
                    busy: _busy,
                    onPick: _inviteFriend,
                  ),
                  const SizedBox(height: 14),
                  Text('Or invite by email', style: type.taskNotes),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: type.taskNotes,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Their email'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _invite,
                      child: Text(_busy ? 'Sending…' : 'Send invite'),
                    ),
                  ),
                ],
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: type.taskNotes.copyWith(color: colors.clay)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendsPicker extends ConsumerWidget {
  final String listId;
  final bool busy;
  final ValueChanged<FriendProfile> onPick;

  const _FriendsPicker({required this.listId, required this.busy, required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.textStyles;
    final colors = context.colors;
    final friendsAsync = ref.watch(friendsProvider);
    final membersAsync = ref.watch(listMembersProvider(listId));

    return friendsAsync.when(
      data: (friends) {
        final memberIds = membersAsync.valueOrNull?.map((m) => m.uid).toSet() ?? const {};
        final pickable = friends.where((f) => !memberIds.contains(f.uid)).toList();
        if (pickable.isEmpty) {
          return Text(
            friends.isEmpty
                ? 'No friends yet — add some from Settings, or invite by email below.'
                : 'All your friends are already on this list.',
            style: type.taskNotes,
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final friend in pickable)
              ActionChip(
                avatar: CircleAvatar(
                  radius: 10,
                  backgroundColor: colors.hairline,
                  backgroundImage:
                      friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
                  child: friend.photoUrl == null
                      ? Text(friend.label.substring(0, 1).toUpperCase(),
                          style: type.caption.copyWith(fontSize: 9))
                      : null,
                ),
                label: Text(friend.label),
                onPressed: busy ? null : () => onPick(friend),
              ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 24,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MembersList extends ConsumerWidget {
  final String listId;

  const _MembersList({required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.textStyles;
    final colors = context.colors;
    final membersAsync = ref.watch(listMembersProvider(listId));

    return membersAsync.when(
      data: (members) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members', style: type.sectionTitle),
          const SizedBox(height: 8),
          for (final member in members)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: colors.hairline,
                    backgroundImage:
                        member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
                    child: member.photoUrl == null
                        ? Text(
                            (member.displayName ?? member.email ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: type.caption,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      member.displayName ?? member.email ?? member.uid,
                      style: type.taskTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(member.role, style: type.caption),
                ],
              ),
            ),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Something went wrong: $error', style: type.taskNotes),
    );
  }
}
