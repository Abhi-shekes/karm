import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../auth/application/auth_providers.dart';
import '../../lists/application/lists_providers.dart';
import '../../recurring/recurrence.dart';
import '../application/tasks_providers.dart';

Future<void> showAddTaskSheet(BuildContext context, {String? initialListId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddTaskSheet(initialListId: initialListId),
  );
}

class AddTaskSheet extends ConsumerStatefulWidget {
  final String? initialListId;

  const AddTaskSheet({super.key, this.initialListId});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _listId;
  DateTime? _dueDate;
  bool _flagged = false;
  RecurrenceRule? _recurrence;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _listId = widget.initialListId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
    );
    if (!mounted) return;

    setState(() {
      _dueDate = time == null
          ? date
          : DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final listId = _listId;
    if (title.isEmpty || listId == null || _saving) return;

    setState(() => _saving = true);

    final user = ref.read(authStateChangesProvider).value;
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final allLists = ref.read(allListsProvider).value ?? const [];
    final isShared = allLists.firstWhereOrNull((l) => l.id == listId)?.isShared ?? false;

    if (isShared) {
      await ref.read(sharedListRepositoryProvider).addTask(
            listId: listId,
            title: title,
            createdBy: user?.uid ?? 'local',
            notes: null,
            dueDate: _dueDate,
            flagged: _flagged,
            tags: tags,
            recurrenceRule: _recurrence?.storageValue,
          );
    } else {
      await ref.read(tasksControllerProvider.notifier).addTask(
            listId: listId,
            title: title,
            createdBy: user?.uid ?? 'local',
            dueDate: _dueDate,
            flagged: _flagged,
            tags: tags,
            recurrence: _recurrence,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    final lists = ref.watch(allListsProvider);

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
              Text('New task', style: type.sectionTitle),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                autofocus: true,
                style: type.taskTitle,
                decoration: const InputDecoration(hintText: 'What needs doing?'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              lists.when(
                data: (allLists) {
                  if (allLists.isEmpty) return const SizedBox.shrink();
                  if (_listId == null ||
                      !allLists.any((list) => list.id == _listId)) {
                    _listId = allLists.first.id;
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _listId,
                    items: [
                      for (final list in allLists)
                        DropdownMenuItem(value: list.id, child: Text(list.title)),
                    ],
                    onChanged: (value) => setState(() => _listId = value),
                    decoration: const InputDecoration(labelText: 'List'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                style: type.taskNotes,
                decoration: const InputDecoration(hintText: 'Tags, comma separated'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: Icon(Icons.event_outlined, size: 16, color: colors.ink),
                    label: Text(
                      _dueDate == null
                          ? 'Add due date'
                          : DateFormat('MMM d, h:mm a').format(_dueDate!),
                    ),
                    onPressed: _pickDueDate,
                  ),
                  FilterChip(
                    avatar: Icon(Icons.bookmark_outline, size: 16, color: colors.amber),
                    label: const Text('Flag'),
                    selected: _flagged,
                    onSelected: (value) => setState(() => _flagged = value),
                  ),
                  for (final rule in RecurrenceRule.values)
                    FilterChip(
                      label: Text(rule.label),
                      selected: _recurrence == rule,
                      onSelected: (selected) {
                        setState(() => _recurrence = selected ? rule : null);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Add task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
