import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_text_styles.dart';
import '../application/focus_timer_providers.dart';
import '../domain/focus_timer_state.dart';

class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  String _format(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.textStyles;
    final state = ref.watch(focusTimerControllerProvider);
    final controller = ref.read(focusTimerControllerProvider.notifier);
    final sessionsToday = ref.watch(todayFocusSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedButton<FocusPhase>(
                segments: [
                  for (final phase in FocusPhase.values)
                    ButtonSegment(value: phase, label: Text(phase.label)),
                ],
                selected: {state.phase},
                onSelectionChanged: state.isRunning
                    ? null
                    : (selection) => controller.switchPhase(selection.first),
              ),
              const SizedBox(height: 48),
              Text(_format(state.remainingSeconds), style: type.timerDigits),
              const SizedBox(height: 8),
              Text(
                state.phase == FocusPhase.focus ? 'FOCUS SESSION' : 'SHORT BREAK',
                style: type.caption,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: controller.reset,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: state.isRunning ? controller.pause : controller.start,
                    child: Text(state.isRunning ? 'Pause' : 'Start'),
                  ),
                ],
              ),
              const SizedBox(height: 56),
              sessionsToday.when(
                data: (sessions) => Text(
                  sessions.isEmpty
                      ? 'No focus sessions yet today'
                      : '${sessions.length} focus ${sessions.length == 1 ? 'session' : 'sessions'} today',
                  style: type.taskNotes,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
