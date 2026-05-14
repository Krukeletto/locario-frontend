import 'package:flutter/material.dart';

@immutable
class LocarioThemeColors extends ThemeExtension<LocarioThemeColors> {
  const LocarioThemeColors({required this.onScrim});

  final Color onScrim;

  @override
  LocarioThemeColors copyWith({Color? onScrim}) {
    return LocarioThemeColors(onScrim: onScrim ?? this.onScrim);
  }

  @override
  LocarioThemeColors lerp(ThemeExtension<LocarioThemeColors>? other, double t) {
    if (other is! LocarioThemeColors) {
      return this;
    }

    return LocarioThemeColors(
      onScrim: Color.lerp(onScrim, other.onScrim, t) ?? onScrim,
    );
  }
}
