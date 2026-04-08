import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF2E7D32);
  const secondary = Color(0xFF607F5B);
  const tertiary = Color(0xFFB14B6F);

  const surface = Color(0xFFF8F9F5);
  const surfaceTint = Color(0xFF2E7D32);
  const outline = Color(0xFF747970);
  const onSurface = Color(0xFF1A1C19);

  final colorScheme = const ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    tertiary: tertiary,
    onTertiary: Colors.white,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceTint,
    outline: outline,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    textTheme: Typography.blackMountainView.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    ),
    // Unified segmented-control styling for filter/toggle groups.
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return surfaceTint;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return secondary;
        }),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
    ),
    // Soft cards used by feature surfaces across the app.
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.82),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: EdgeInsets.zero,
    ),
  );
}
