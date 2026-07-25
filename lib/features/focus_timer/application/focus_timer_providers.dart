import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../home_widget/home_widget_provider.dart';
import '../../notifications/reminder_service_provider.dart';
import '../data/focus_sessions_repository.dart';
import '../domain/focus_timer_state.dart';

part 'focus_timer_providers.g.dart';

const _timerNotificationId = 'focus-timer-session';

@Riverpod(keepAlive: true)
FocusSessionsRepository focusSessionsRepository(Ref ref) {
  return FocusSessionsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<FocusSession>> todayFocusSessions(Ref ref) {
  return ref.watch(focusSessionsRepositoryProvider).watchToday();
}

/// Kept alive so a running session survives navigating away from the
/// timer screen — only process death actually stops it (see note below).
@Riverpod(keepAlive: true)
class FocusTimerController extends _$FocusTimerController {
  Timer? _ticker;

  @override
  FocusTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return FocusTimerState.idle(FocusPhase.focus);
  }

  void start() {
    if (state.isRunning) return;

    final remaining = state.remainingSeconds > 0 ? state.remainingSeconds : state.totalSeconds;
    final endTime = DateTime.now().add(Duration(seconds: remaining));

    state = state.copyWith(isRunning: true, endTime: endTime, remainingSeconds: remaining);

    // Fallback alert in case the app is backgrounded long enough that the
    // in-app ticker below gets suspended by the OS.
    ref.read(reminderServiceProvider).scheduleReminder(
          taskId: _timerNotificationId,
          title: state.phase == FocusPhase.focus ? 'Focus session complete' : "Break's over",
          dueDate: endTime,
        );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _pushWidgetState();
  }

  void pause() {
    _ticker?.cancel();
    final remaining = _remainingNow();
    state = state.copyWith(isRunning: false, clearEndTime: true, remainingSeconds: remaining);
    ref.read(reminderServiceProvider).cancelReminder(_timerNotificationId);
    _pushWidgetState();
  }

  void reset() {
    _ticker?.cancel();
    ref.read(reminderServiceProvider).cancelReminder(_timerNotificationId);
    state = FocusTimerState.idle(state.phase);
    _pushWidgetState();
  }

  void switchPhase(FocusPhase phase) {
    _ticker?.cancel();
    ref.read(reminderServiceProvider).cancelReminder(_timerNotificationId);
    state = FocusTimerState.idle(phase);
    _pushWidgetState();
  }

  void _pushWidgetState() {
    ref.read(homeWidgetServiceProvider).pushFocusState(
          phaseLabel: state.phase.label,
          isRunning: state.isRunning,
          remainingSeconds: state.remainingSeconds,
          endTime: state.endTime,
        );
  }

  void _tick() {
    final remaining = _remainingNow();
    if (remaining <= 0) {
      _complete();
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  int _remainingNow() {
    final end = state.endTime;
    if (end == null) return state.remainingSeconds;
    return end.difference(DateTime.now()).inSeconds.clamp(0, state.totalSeconds);
  }

  Future<void> _complete() async {
    _ticker?.cancel();
    final completedPhase = state.phase;

    if (completedPhase == FocusPhase.focus) {
      await ref.read(focusSessionsRepositoryProvider).recordSession(
            startedAt: DateTime.now().subtract(Duration(seconds: state.totalSeconds)),
            durationMin: (state.totalSeconds / 60).round(),
            type: 'pomodoro',
          );
    }

    final nextPhase = completedPhase == FocusPhase.focus ? FocusPhase.shortBreak : FocusPhase.focus;
    state = FocusTimerState.idle(nextPhase);
    _pushWidgetState();
  }
}
