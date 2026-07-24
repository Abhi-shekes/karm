import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../auth/application/auth_providers.dart';
import '../application/lists_providers.dart';

const _paletteHex = ['33367D', 'B9873A', '5E7D5A', 'AE5A3E'];

Future<void> showCreateListSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateListSheet(),
  );
}

class CreateListSheet extends ConsumerStatefulWidget {
  const CreateListSheet({super.key});

  @override
  ConsumerState<CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends ConsumerState<CreateListSheet> {
  final _titleController = TextEditingController();
  String _colorHex = _paletteHex.first;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _saving) return;

    setState(() => _saving = true);
    final user = ref.read(authStateChangesProvider).value;
    await ref.read(listsRepositoryProvider).createList(
          title: title,
          colorHex: _colorHex,
          icon: 'list',
          ownerId: user?.uid ?? 'local',
        );

    if (mounted) Navigator.of(context).pop();
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
            Text('New list', style: type.sectionTitle),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: type.taskTitle,
              decoration: const InputDecoration(hintText: 'List name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final hex in _paletteHex)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(int.parse('FF$hex', radix: 16)),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _colorHex == hex ? colors.ink : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Create list'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
