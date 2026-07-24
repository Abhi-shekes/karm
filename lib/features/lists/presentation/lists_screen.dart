import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../application/lists_providers.dart';
import '../data/shared_models.dart';
import 'create_list_sheet.dart';

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final listsAsync = ref.watch(allListsProvider);
    final sharedWithMeAsync = ref.watch(listsSharedWithMeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      body: listsAsync.when(
        data: (lists) {
          final localIds = lists.map((l) => l.id).toSet();
          final notYetAdopted =
              sharedWithMeAsync.valueOrNull?.where((l) => !localIds.contains(l.id)).toList() ??
                  const <SharedListSummary>[];

          if (lists.isEmpty && notYetAdopted.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Create your first list to start adding tasks.',
                  style: type.taskNotes),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              if (notYetAdopted.isNotEmpty) ...[
                Text('SHARED WITH YOU', style: type.dateStamp),
                const SizedBox(height: 8),
                for (final shared in notYetAdopted)
                  _SharedListTile(list: shared, colors: colors, type: type),
                const SizedBox(height: 20),
              ],
              if (lists.isNotEmpty) ...[
                if (notYetAdopted.isNotEmpty) ...[
                  Text('YOUR LISTS', style: type.dateStamp),
                  const SizedBox(height: 8),
                ],
                for (var i = 0; i < lists.length; i++) ...[
                  if (i != 0) Divider(height: 1, color: colors.hairline),
                  Builder(builder: (context) {
                    final list = lists[i];
                    final color = Color(int.parse('FF${list.colorHex}', radix: 16));
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(radius: 8, backgroundColor: color),
                      title: Text(list.title, style: type.taskTitle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (list.isShared)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.people, size: 16, color: colors.indigo),
                            ),
                          Icon(Icons.chevron_right, color: colors.inkMuted),
                        ],
                      ),
                      onTap: () => context.push('/lists/${list.id}'),
                    );
                  }),
                ],
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateListSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SharedListTile extends ConsumerWidget {
  final SharedListSummary list;
  final AppColors colors;
  final AppTextStyles type;

  const _SharedListTile({required this.list, required this.colors, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(int.parse('FF${list.colorHex}', radix: 16));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 8, backgroundColor: color),
      title: Text(list.title, style: type.taskTitle),
      trailing: Icon(Icons.chevron_right, color: colors.inkMuted),
      onTap: () async {
        await ref.read(listsRepositoryProvider).adoptSharedList(
              id: list.id,
              title: list.title,
              colorHex: list.colorHex,
              icon: list.icon,
              ownerId: list.ownerId,
            );
        if (context.mounted) context.push('/lists/${list.id}');
      },
    );
  }
}
