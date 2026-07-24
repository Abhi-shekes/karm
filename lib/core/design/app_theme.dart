import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds Karm's light/dark ThemeData from the AppColors/AppTextStyles
/// design tokens. Depth comes from hairline dividers + a single elevation
/// level, not layered shadows — see design plan.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final textStyles = AppTextStyles.build(
      ink: colors.ink,
      inkMuted: colors.inkMuted,
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.indigo,
      onPrimary: colors.paper,
      secondary: colors.amber,
      onSecondary: colors.ink,
      tertiary: colors.sage,
      onTertiary: colors.paper,
      error: colors.clay,
      onError: colors.paper,
      surface: colors.paper,
      onSurface: colors.ink,
      outline: colors.hairline,
    );

    final baseTextTheme = GoogleFonts.manropeTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme,
    ).apply(bodyColor: colors.ink, displayColor: colors.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.paper,
      textTheme: baseTextTheme,
      dividerColor: colors.hairline,
      dividerTheme: DividerThemeData(color: colors.hairline, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.paper,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textStyles.sectionTitle,
      ),
      cardTheme: CardThemeData(
        color: colors.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.indigo,
          foregroundColor: colors.paper,
          textStyle: textStyles.button,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: colors.indigo.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? colors.indigo : colors.inkMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textStyles.caption.copyWith(
            fontSize: 12,
            color: selected ? colors.indigo : colors.inkMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.paper,
        hintStyle: textStyles.taskNotes,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.indigo, width: 1.5),
        ),
      ),
      extensions: [colors, textStyles],
    );
  }
}
