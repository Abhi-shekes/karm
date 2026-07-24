import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../auth/application/auth_providers.dart';
import '../application/friends_providers.dart';
import '../data/friends_repository.dart';

Future<void> showAddFriendSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddFriendSheet(),
  );
}

class AddFriendSheet extends ConsumerStatefulWidget {
  const AddFriendSheet({super.key});

  @override
  ConsumerState<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<AddFriendSheet> {
  final _emailController = TextEditingController();
  bool _sending = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    final myUid = ref.read(authStateChangesProvider).value?.uid;
    if (email.isEmpty || myUid == null || _sending) return;

    setState(() {
      _sending = true;
      _message = null;
    });

    final result = await ref
        .read(friendsRepositoryProvider)
        .sendRequest(myUid: myUid, toEmail: email);

    if (!mounted) return;
    setState(() {
      _sending = false;
      _isError = result != SendFriendRequestResult.sent;
      _message = switch (result) {
        SendFriendRequestResult.sent => 'Friend request sent.',
        SendFriendRequestResult.notFound => "No one at that email has opened Karm yet.",
        SendFriendRequestResult.isSelf => "That's your own email.",
        SendFriendRequestResult.alreadyFriends => "You're already friends.",
        SendFriendRequestResult.alreadyPending => 'A request is already pending.',
      };
    });
    if (result == SendFriendRequestResult.sent) _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.paper,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: colors.hairline),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add a friend', style: type.sectionTitle),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              autofocus: true,
              style: type.taskNotes,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Their email'),
              onSubmitted: (_) => _send(),
            ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(
                _message!,
                style: type.taskNotes.copyWith(color: _isError ? colors.clay : colors.sage),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Sending…' : 'Send request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
