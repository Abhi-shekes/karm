import 'package:flutter/foundation.dart';

enum FocusPhase {
  focus(Duration(minutes: 25), 'Focus'),
  shortBreak(Duration(minutes: 5), 'Break');

  const FocusPhase(this.defaultDuration, this.label);
  final Duration defaultDuration;
  final String label;
}

/// The timer's remaining time is always derived from [endTime] rather than
/// decremented tick-by-tick, so it stays correct even if the app was
/// backgrounded and missed ticks — resuming just recomputes the delta.
@immutable
class FocusTimerState {
  final FocusPhase phase;
  final DateTime? endTime;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const FocusTimerState({
    required this.phase,
    required this.endTime,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  factory FocusTimerState.idle(FocusPhase phase) {
    final seconds = phase.defaultDuration.inSeconds;
    return FocusTimerState(
      phase: phase,
      endTime: null,
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: false,
    );
  }

  FocusTimerState copyWith({
    DateTime? endTime,
    bool clearEndTime = false,
    int? remainingSeconds,
    bool? isRunning,
  }) {
    return FocusTimerState(
      phase: phase,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      totalSeconds: totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
