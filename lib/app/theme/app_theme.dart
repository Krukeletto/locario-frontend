import 'package:flutter/material.dart';

ThemeData buildLightAppTheme() {
  const primary = Color(0xFF2E7D32);
  const secondary = Color(0xFF607F5B);
  const tertiary = Color(0xFFB14B6F);

  const surface = Color(0xFFF8F9F5);
  const surfaceDim = Color(0xFFE4E8DE);
  const surfaceBright = Color(0xFFFFFFFF);
  const surfaceContainerLowest = Color(0xFFFFFFFF);
  const surfaceContainerLow = Color(0xFFF2F5EC);
  const surfaceContainer = Color(0xFFEBEFE5);
  const surfaceContainerHigh = Color(0xFFE5EADF);
  const surfaceContainerHighest = Color(0xFFDDE4D7);
  const outline = Color(0xFF747970);
  const outlineVariant = Color(0xFFC5CBC1);
  const onSurface = Color(0xFF1A1C19);

  final colorScheme = const ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCEECCB),
    onPrimaryContainer: Color(0xFF123617),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDCE9D7),
    onSecondaryContainer: Color(0xFF1B271A),
    tertiary: tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF8D8E1),
    onTertiaryContainer: Color(0xFF47202D),
    surface: surface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurface: onSurface,
    outline: outline,
    outlineVariant: outlineVariant,
  );

  return _buildTheme(colorScheme, surface, onSurface, Brightness.light);
}

ThemeData buildDarkAppTheme() {
  const primary = Color(0xFF7BC47F);
  const secondary = Color(0xFFA8C3A2);
  const tertiary = Color(0xFFE3A4B8);

  const surface = Color(0xFF050705);
  const surfaceDim = Color(0xFF040604);
  const surfaceBright = Color(0xFF181E18);
  const surfaceContainerLowest = Color(0xFF010201);
  const surfaceContainerLow = Color(0xFF0A0D0A);
  const surfaceContainer = Color(0xFF0E120E);
  const surfaceContainerHigh = Color(0xFF141A14);
  const surfaceContainerHighest = Color(0xFF1A211A);
  const outline = Color(0xFF8A9388);
  const outlineVariant = Color(0xFF2A322A);
  const onSurface = Color(0xFFE7ECE4);

  final colorScheme = const ColorScheme.dark(
    primary: primary,
    onPrimary: Color(0xFF0F2A11),
    primaryContainer: Color(0xFF19361D),
    onPrimaryContainer: Color(0xFFB4E9B4),
    secondary: secondary,
    onSecondary: Color(0xFF172218),
    secondaryContainer: Color(0xFF202B20),
    onSecondaryContainer: Color(0xFFD4E8CF),
    tertiary: tertiary,
    onTertiary: Color(0xFF331621),
    tertiaryContainer: Color(0xFF472330),
    onTertiaryContainer: Color(0xFFFFD8E4),
    surface: surface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurface: onSurface,
    outline: outline,
    outlineVariant: outlineVariant,
  );

  return _buildTheme(colorScheme, surface, onSurface, Brightness.dark);
}

ThemeData _buildTheme(
  ColorScheme colorScheme,
  Color scaffoldBackgroundColor,
  Color textColor,
  Brightness brightness,
) {
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    canvasColor: colorScheme.surfaceContainerHigh,
    dividerColor: colorScheme.outlineVariant,
    shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    textTheme:
        (isDark ? Typography.whiteMountainView : Typography.blackMountainView)
            .apply(bodyColor: textColor, displayColor: textColor),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHigh;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.secondary;
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
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow.withValues(
        alpha: isDark ? 0.96 : 0.92,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: EdgeInsets.zero,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
