import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/db/app_database.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/presentation/task_detail_sheet.dart';
import '../../tasks/domain/task_tile_data.dart';
import '../../tasks/presentation/add_task_sheet.dart';
import '../../tasks/presentation/task_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.textStyles;
    final tasksAsync = ref.watch(allTasksWithDueDatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: tasksAsync.when(
        data: (tasks) {
          final byDay = groupBy(tasks, (Task t) => _dayKey(t.dueDate!));
          final selectedTasks = byDay[_dayKey(_selectedDay)] ?? const <Task>[];

          return Column(
            children: [
              TableCalendar<Task>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                currentDay: DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => byDay[_dayKey(day)] ?? const [],
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (focused) => _focusedDay = focused,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: type.sectionTitle,
                  leftChevronIcon: Icon(Icons.chevron_left, color: colors.inkMuted),
                  rightChevronIcon: Icon(Icons.chevron_right, color: colors.inkMuted),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: type.caption,
                  weekendStyle: type.caption,
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: type.taskTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                  weekendTextStyle: type.taskTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                  todayDecoration: BoxDecoration(
                    color: colors.indigo.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: type.taskTitle.copyWith(fontSize: 14, color: colors.indigo),
                  selectedDecoration: BoxDecoration(color: colors.indigo, shape: BoxShape.circle),
                  selectedTextStyle: type.taskTitle.copyWith(fontSize: 14, color: colors.paper),
                  markerDecoration: BoxDecoration(color: colors.amber, shape: BoxShape.circle),
                  markersMaxCount: 1,
                ),
              ),
              Divider(height: 1, color: colors.hairline),
              Expanded(
                child: selectedTasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Nothing due this day.', style: type.taskNotes),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        itemCount: selectedTasks.length,
                        separatorBuilder: (_, _) => Divider(height: 1, color: colors.hairline),
                        itemBuilder: (context, index) {
                          final task = selectedTasks[index];
                          return TaskTile(
                            task: task.toTileData(),
                            onToggle: (_) => ref
                                .read(tasksControllerProvider.notifier)
                                .toggleDone(task),
                            onTap: () => showTaskDetailSheet(context, task.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
