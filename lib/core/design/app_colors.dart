import 'package:flutter/material.dart';

/// Karm's named color tokens — a warm "paper & ink" palette rather than
/// generic Material roles. See /plans design tokens table for rationale.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color paper;
  final Color ink;
  final Color inkMuted;
  final Color indigo;
  final Color amber;
  final Color sage;
  final Color clay;
  final Color hairline;

  const AppColors({
    required this.paper,
    required this.ink,
    required this.inkMuted,
    required this.indigo,
    required this.amber,
    required this.sage,
    required this.clay,
    required this.hairline,
  });

  static const light = AppColors(
    paper: Color(0xFFFAF8F4),
    ink: Color(0xFF1E1B16),
    inkMuted: Color(0xFF6B6459),
    indigo: Color(0xFF33367D),
    amber: Color(0xFFB9873A),
    sage: Color(0xFF5E7D5A),
    clay: Color(0xFFAE5A3E),
    hairline: Color(0xFFE7E1D4),
  );

  static const dark = AppColors(
    paper: Color(0xFF1E1B16),
    ink: Color(0xFFF3EFE7),
    inkMuted: Color(0xFFB4AC9E),
    indigo: Color(0xFF8A8DD8),
    amber: Color(0xFFD9A85C),
    sage: Color(0xFF8FAF89),
    clay: Color(0xFFD0826A),
    hairline: Color(0xFF332F27),
  );

  @override
  AppColors copyWith({
    Color? paper,
    Color? ink,
    Color? inkMuted,
    Color? indigo,
    Color? amber,
    Color? sage,
    Color? clay,
    Color? hairline,
  }) {
    return AppColors(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      indigo: indigo ?? this.indigo,
      amber: amber ?? this.amber,
      sage: sage ?? this.sage,
      clay: clay ?? this.clay,
      hairline: hairline ?? this.hairline,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      indigo: Color.lerp(indigo, other.indigo, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      clay: Color.lerp(clay, other.clay, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
