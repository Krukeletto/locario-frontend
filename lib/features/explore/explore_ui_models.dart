import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ExploreContentView { map, list }

enum ExploreSortOption { distance, soonest, trending }

class ExploreFilter {
  const ExploreFilter({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class ExploreAreaOption {
  const ExploreAreaOption({
    required this.label,
    required this.description,
    required this.icon,
    this.center,
    this.usesCurrentLocation = false,
  });

  final String label;
  final String description;
  final IconData icon;
  final LatLng? center;
  final bool usesCurrentLocation;
}

class ExploreEvent {
  const ExploreEvent({
    required this.title,
    required this.category,
    required this.distanceMeters,
    required this.timeLabel,
    required this.venue,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final String category;
  final int distanceMeters;
  final String timeLabel;
  final String venue;
  final Color accentColor;
  final IconData icon;

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '$distanceMeters m';
    }

    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}

const exploreFilters = <ExploreFilter>[
  ExploreFilter(label: 'Wszystkie', icon: Icons.explore_rounded),
  ExploreFilter(label: 'Muzyka', icon: Icons.music_note_rounded),
  ExploreFilter(label: 'Sztuka', icon: Icons.palette_outlined),
  ExploreFilter(label: 'Warsztaty', icon: Icons.lightbulb_outline_rounded),
  ExploreFilter(label: 'Food', icon: Icons.restaurant_rounded),
];

const exploreAreaOptions = <ExploreAreaOption>[
  ExploreAreaOption(
    label: 'Moja lokalizacja',
    description: 'Domyślnie wydarzenia najbliżej Ciebie',
    icon: Icons.my_location_rounded,
    usesCurrentLocation: true,
  ),
  ExploreAreaOption(
    label: 'Centrum Warszawy',
    description: 'Adres lub pin ustawiony ręcznie',
    icon: Icons.place_outlined,
    center: LatLng(52.2298, 21.0118),
  ),
  ExploreAreaOption(
    label: 'Powiśle',
    description: 'Okolice bulwarów i mostu Poniatowskiego',
    icon: Icons.push_pin_outlined,
    center: LatLng(52.2362, 21.0415),
  ),
  ExploreAreaOption(
    label: 'Mokotów',
    description: 'Rejon Pole Mokotowskie i okolice',
    icon: Icons.location_city_outlined,
    center: LatLng(52.2081, 21.0067),
  ),
];

const exploreEvents = <ExploreEvent>[
  ExploreEvent(
    title: 'Jazz w Ogrodzie Botanicznym',
    category: 'Muzyka',
    distanceMeters: 200,
    timeLabel: 'Dziś, 20:30',
    venue: 'Ogród Botaniczny',
    accentColor: Color(0xFFB14B6F),
    icon: Icons.music_note_rounded,
  ),
  ExploreEvent(
    title: 'Noc szkicowania nad Wisłą',
    category: 'Sztuka',
    distanceMeters: 850,
    timeLabel: 'Dziś, 19:00',
    venue: 'Bulwary Wiślane',
    accentColor: Color(0xFF607F5B),
    icon: Icons.palette_outlined,
  ),
  ExploreEvent(
    title: 'Poranny run club i coffee stop',
    category: 'Warsztaty',
    distanceMeters: 1300,
    timeLabel: 'Jutro, 08:00',
    venue: 'Pole Mokotowskie',
    accentColor: Color(0xFF2E7D32),
    icon: Icons.directions_run_rounded,
  ),
  ExploreEvent(
    title: 'Street food i vinyl market',
    category: 'Food',
    distanceMeters: 1600,
    timeLabel: 'Jutro, 12:00',
    venue: 'Hala Koszyki',
    accentColor: Color(0xFF8E6B3A),
    icon: Icons.restaurant_rounded,
  ),
];
