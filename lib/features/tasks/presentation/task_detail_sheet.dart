import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/app_database.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../application/tasks_providers.dart';

/// Opens the detail view for a local (Drift-backed) task.
///
/// Shared-list tasks live in Firestore and are edited through
/// [SharedListRepository], so they keep their tap disabled for now.
Future<void> showTaskDetailSheet(BuildContext context, String taskId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TaskDetailSheet(taskId: taskId),
  );
}

/// Edit, subtask and delete surface for one task.
///
/// The repository has carried `updateTask`, `deleteTask` and the subtask
/// calls since the first version, but nothing ever passed [TaskTile.onTap],
/// so a task could only be ticked off — never renamed, rescheduled, broken
/// into steps or removed. This is the screen that reaches them.
class TaskDetailSheet extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailSheet({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _subtaskController = TextEditingController();

  Task? _task;
  DateTime? _dueDate;
  bool _flagged = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final task = await ref.read(tasksRepositoryProvider).getById(widget.taskId);
    if (!mounted) return;
    setState(() {
      _task = task;
      _loading = false;
      if (task != null) {
        _titleController.text = task.title;
        _notesController.text = task.notes ?? '';
        _tagsController.text =
            task.tags.split(',').where((t) => t.isNotEmpty).join(', ');
        _dueDate = task.dueDate;
        _flagged = task.priority > 0;
      }
    });
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
    final task = _task;
    final title = _titleController.text.trim();
    if (task == null || title.isEmpty || _saving) return;

    setState(() => _saving = true);
    final notes = _notesController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    await ref.read(tasksControllerProvider.notifier).updateTask(
          task,
          title: title,
          notes: notes.isEmpty ? null : notes,
          dueDate: _dueDate,
          flagged: _flagged,
          tags: tags,
        );

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final task = _task;
    if (task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('"${task.title}" and its steps will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(tasksControllerProvider.notifier).deleteTask(task);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addSubtask() async {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;
    _subtaskController.clear();
    await ref
        .read(tasksControllerProvider.notifier)
        .addSubtask(widget.taskId, title);
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
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            : _task == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'That task no longer exists.',
                      style: type.taskNotes,
                    ),
                  )
                : _buildForm(colors, type),
      ),
    );
  }

  Widget _buildForm(AppColors colors, AppTextStyles type) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Task', style: type.sectionTitle)),
              IconButton(
                onPressed: _saving ? null : _delete,
                icon: Icon(Icons.delete_outline, color: colors.ink),
                tooltip: 'Delete task',
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _titleController,
            style: type.taskTitle,
            decoration: const InputDecoration(hintText: 'What needs doing?'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            style: type.taskNotes,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(hintText: 'Notes'),
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
              if (_dueDate != null)
                ActionChip(
                  avatar: Icon(Icons.close, size: 16, color: colors.ink),
                  label: const Text('Clear date'),
                  onPressed: () => setState(() => _dueDate = null),
                ),
              FilterChip(
                avatar:
                    Icon(Icons.bookmark_outline, size: 16, color: colors.amber),
                label: const Text('Flag'),
                selected: _flagged,
                onSelected: (value) => setState(() => _flagged = value),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Steps', style: type.sectionTitle),
          const SizedBox(height: 4),
          _SubtaskList(taskId: widget.taskId),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  style: type.taskNotes,
                  decoration: const InputDecoration(hintText: 'Add a step'),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              IconButton(
                onPressed: _addSubtask,
                icon: Icon(Icons.add, color: colors.ink),
                tooltip: 'Add step',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtaskList extends ConsumerWidget {
  final String taskId;

  const _SubtaskList({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasks = ref.watch(subtasksForTaskProvider(taskId));
    final type = context.textStyles;

    return subtasks.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final subtask in items)
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: subtask.done,
                onChanged: (_) => ref
                    .read(tasksControllerProvider.notifier)
                    .toggleSubtaskDone(subtask),
                title: Text(
                  subtask.title,
                  style: type.taskNotes.copyWith(
                    decoration:
                        subtask.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
