import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_text_styles.dart';
import '../tasks/domain/task_tile_data.dart';
import 'ai_quick_add_provider.dart';

Future<void> showPlanMyDaySheet(BuildContext context, List<TaskTileData> tasks) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PlanMyDaySheet(tasks: tasks),
  );
}

class PlanMyDaySheet extends ConsumerStatefulWidget {
  final List<TaskTileData> tasks;

  const PlanMyDaySheet({super.key, required this.tasks});

  @override
  ConsumerState<PlanMyDaySheet> createState() => _PlanMyDaySheetState();
}

class _PlanMyDaySheetState extends ConsumerState<PlanMyDaySheet> {
  late final Future<String> _plan;

  @override
  void initState() {
    super.initState();
    _plan = ref.read(aiQuickAddServiceProvider).planMyDay(widget.tasks);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;

    return Container(
      decoration: BoxDecoration(
        color: colors.paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: colors.hairline),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: colors.indigo),
              const SizedBox(width: 8),
              Text('Plan my day', style: type.sectionTitle),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: _plan,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  "Couldn't put a plan together right now.",
                  style: type.taskNotes.copyWith(color: colors.clay),
                );
              }
              return Text(
                snapshot.data ?? '',
                style: type.taskNotes.copyWith(fontSize: 15, height: 1.5, color: colors.ink),
              );
            },
          ),
        ],
      ),
    );
  }
}
