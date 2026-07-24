import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Three deliberate type roles, per the design plan:
/// - Fraunces (display) for greetings/section titles — the app's human voice
/// - Manrope (UI/body) for task content, buttons, nav
/// - IBM Plex Mono (utility) for dates, counters, timer digits — the stamped-ticket feel
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle greeting;
  final TextStyle sectionTitle;
  final TextStyle taskTitle;
  final TextStyle taskTitleDone;
  final TextStyle taskNotes;
  final TextStyle button;
  final TextStyle dateStamp;
  final TextStyle timerDigits;
  final TextStyle caption;

  const AppTextStyles({
    required this.greeting,
    required this.sectionTitle,
    required this.taskTitle,
    required this.taskTitleDone,
    required this.taskNotes,
    required this.button,
    required this.dateStamp,
    required this.timerDigits,
    required this.caption,
  });

  factory AppTextStyles.build({required Color ink, required Color inkMuted}) {
    return AppTextStyles(
      greeting: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 1.15,
        color: ink,
      ),
      sectionTitle: GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: ink,
      ),
      taskTitle: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: ink,
      ),
      taskTitleDone: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: inkMuted,
        decoration: TextDecoration.lineThrough,
        decorationColor: inkMuted,
      ),
      taskNotes: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.4,
        color: inkMuted,
      ),
      button: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      dateStamp: GoogleFonts.ibmPlexMono(
        fontSize: 13,
        letterSpacing: 0.3,
        color: inkMuted,
      ),
      timerDigits: GoogleFonts.ibmPlexMono(
        fontSize: 56,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        color: ink,
      ),
      caption: GoogleFonts.ibmPlexMono(
        fontSize: 11,
        letterSpacing: 0.4,
        color: inkMuted,
      ),
    );
  }

  @override
  AppTextStyles copyWith({
    TextStyle? greeting,
    TextStyle? sectionTitle,
    TextStyle? taskTitle,
    TextStyle? taskTitleDone,
    TextStyle? taskNotes,
    TextStyle? button,
    TextStyle? dateStamp,
    TextStyle? timerDigits,
    TextStyle? caption,
  }) {
    return AppTextStyles(
      greeting: greeting ?? this.greeting,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      taskTitle: taskTitle ?? this.taskTitle,
      taskTitleDone: taskTitleDone ?? this.taskTitleDone,
      taskNotes: taskNotes ?? this.taskNotes,
      button: button ?? this.button,
      dateStamp: dateStamp ?? this.dateStamp,
      timerDigits: timerDigits ?? this.timerDigits,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      greeting: TextStyle.lerp(greeting, other.greeting, t)!,
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      taskTitle: TextStyle.lerp(taskTitle, other.taskTitle, t)!,
      taskTitleDone: TextStyle.lerp(taskTitleDone, other.taskTitleDone, t)!,
      taskNotes: TextStyle.lerp(taskNotes, other.taskNotes, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      dateStamp: TextStyle.lerp(dateStamp, other.dateStamp, t)!,
      timerDigits: TextStyle.lerp(timerDigits, other.timerDigits, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

extension AppTextStylesContext on BuildContext {
  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
