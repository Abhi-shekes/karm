import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../../core/design/karm_checkbox.dart';
import '../domain/task_tile_data.dart';

class TaskTile extends StatelessWidget {
  final TaskTileData task;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;

  const TaskTile({super.key, required this.task, required this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    final tags = task.tags;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KarmCheckbox(value: task.done, onChanged: onToggle),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.priority > 0) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 2, right: 4),
                            child: Icon(Icons.bookmark, size: 14, color: colors.amber),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            task.title,
                            style: task.done ? type.taskTitleDone : type.taskTitle,
                          ),
                        ),
                      ],
                    ),
                    if (task.notes != null && task.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(task.notes!, style: type.taskNotes),
                    ],
                    if (task.dueDate != null || tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (task.dueDate != null)
                            _DueDateBadge(dueDate: task.dueDate!, done: task.done),
                          for (final tag in tags) _TagChip(label: tag),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool done;

  const _DueDateBadge({required this.dueDate, required this.done});

  bool get _isOverdue {
    final today = DateTime.now();
    final startToday = DateTime(today.year, today.month, today.day);
    return !done && dueDate.isBefore(startToday);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    final color = _isOverdue ? colors.clay : colors.inkMuted;
    final label = DateFormat('MMM d').format(dueDate);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isOverdue ? Icons.error_outline : Icons.event_outlined,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(label.toUpperCase(), style: type.caption.copyWith(color: color)),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: type.caption),
    );
  }
}
