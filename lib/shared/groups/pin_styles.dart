import 'package:flutter/material.dart';

class PredefinedPin {
  const PredefinedPin({
    required this.styleKey,
    required this.icon,
    required this.label,
  });

  final String styleKey;
  final IconData icon;
  final String label;

  static const List<PredefinedPin> all = [
    PredefinedPin(
      styleKey: 'music_note',
      icon: Icons.music_note_rounded,
      label: 'Muzyka',
    ),
    PredefinedPin(styleKey: 'star', icon: Icons.star_rounded, label: 'Gwiazda'),
    PredefinedPin(
      styleKey: 'place',
      icon: Icons.place_rounded,
      label: 'Lokalizacja',
    ),
    PredefinedPin(
      styleKey: 'sports',
      icon: Icons.sports_soccer_rounded,
      label: 'Sport',
    ),
    PredefinedPin(
      styleKey: 'restaurant',
      icon: Icons.restaurant_rounded,
      label: 'Jedzenie',
    ),
    PredefinedPin(
      styleKey: 'palette',
      icon: Icons.palette_rounded,
      label: 'Sztuka',
    ),
    PredefinedPin(
      styleKey: 'computer',
      icon: Icons.computer_rounded,
      label: 'Technologia',
    ),
    PredefinedPin(
      styleKey: 'forest',
      icon: Icons.forest_rounded,
      label: 'Natura',
    ),
    PredefinedPin(
      styleKey: 'school',
      icon: Icons.school_rounded,
      label: 'Edukacja',
    ),
    PredefinedPin(
      styleKey: 'groups',
      icon: Icons.groups_rounded,
      label: 'Spotkania',
    ),
    PredefinedPin(
      styleKey: 'esports',
      icon: Icons.sports_esports_rounded,
      label: 'Gry',
    ),
    PredefinedPin(
      styleKey: 'favorite',
      icon: Icons.favorite_rounded,
      label: 'Ulubione',
    ),
    PredefinedPin(
      styleKey: 'rocket',
      icon: Icons.rocket_launch_rounded,
      label: 'Rakieta',
    ),
    PredefinedPin(
      styleKey: 'diamond',
      icon: Icons.diamond_rounded,
      label: 'Diament',
    ),
    PredefinedPin(
      styleKey: 'celebration',
      icon: Icons.celebration_rounded,
      label: 'Świętowanie',
    ),
  ];

  static PredefinedPin? fromStyleKey(String? key) {
    if (key == null || key.isEmpty) return null;
    try {
      return all.firstWhere((p) => p.styleKey == key);
    } catch (_) {
      return null;
    }
  }
}
