import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

enum ExploreContentView { map, list }

enum ExploreSortOption { distance, soonest, trending }

enum ExploreCategory { all, music, art, workshops, food }

class ExploreFilter {
  const ExploreFilter({
    required this.category,
    required this.label,
    required this.icon,
  });

  final ExploreCategory category;
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
    required this.categoryLabel,
    required this.distanceMeters,
    required this.timeLabel,
    required this.venue,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final ExploreCategory category;
  final String categoryLabel;
  final int distanceMeters;
  final String timeLabel;
  final String venue;
  final Color accentColor;
  final IconData icon;

  String distanceLabel(AppLocalizations l10n) {
    if (distanceMeters < 1000) {
      return l10n.distanceMeters(distanceMeters);
    }

    return l10n.distanceKilometers((distanceMeters / 1000).toStringAsFixed(1));
  }
}

List<ExploreFilter> buildExploreFilters(AppLocalizations l10n) {
  return [
    ExploreFilter(
      category: ExploreCategory.all,
      label: l10n.filterAll,
      icon: Icons.explore_rounded,
    ),
    ExploreFilter(
      category: ExploreCategory.music,
      label: l10n.filterMusic,
      icon: Icons.music_note_rounded,
    ),
    ExploreFilter(
      category: ExploreCategory.art,
      label: l10n.filterArt,
      icon: Icons.palette_outlined,
    ),
    ExploreFilter(
      category: ExploreCategory.workshops,
      label: l10n.filterWorkshops,
      icon: Icons.lightbulb_outline_rounded,
    ),
    ExploreFilter(
      category: ExploreCategory.food,
      label: l10n.filterFood,
      icon: Icons.restaurant_rounded,
    ),
  ];
}

List<ExploreAreaOption> buildExploreAreaOptions(AppLocalizations l10n) {
  return [
    ExploreAreaOption(
      label: l10n.areaMyLocation,
      description: l10n.areaMyLocationDescription,
      icon: Icons.my_location_rounded,
      usesCurrentLocation: true,
    ),
    ExploreAreaOption(
      label: l10n.areaWarsawCenter,
      description: l10n.areaWarsawCenterDescription,
      icon: Icons.place_outlined,
      center: const LatLng(52.2298, 21.0118),
    ),
    ExploreAreaOption(
      label: l10n.areaPowisle,
      description: l10n.areaPowisleDescription,
      icon: Icons.push_pin_outlined,
      center: const LatLng(52.2362, 21.0415),
    ),
    ExploreAreaOption(
      label: l10n.areaMokotow,
      description: l10n.areaMokotowDescription,
      icon: Icons.location_city_outlined,
      center: const LatLng(52.2081, 21.0067),
    ),
  ];
}

List<ExploreEvent> buildExploreEvents(AppLocalizations l10n) {
  return [
    ExploreEvent(
      title: l10n.eventJazzTitle,
      category: ExploreCategory.music,
      categoryLabel: l10n.filterMusic,
      distanceMeters: 200,
      timeLabel: l10n.eventToday2030,
      venue: l10n.venueBotanicalGarden,
      accentColor: const Color(0xFFB14B6F),
      icon: Icons.music_note_rounded,
    ),
    ExploreEvent(
      title: l10n.eventSketchingTitle,
      category: ExploreCategory.art,
      categoryLabel: l10n.filterArt,
      distanceMeters: 850,
      timeLabel: l10n.eventToday1900,
      venue: l10n.venueVistulaBoulevards,
      accentColor: const Color(0xFF607F5B),
      icon: Icons.palette_outlined,
    ),
    ExploreEvent(
      title: l10n.eventRunClubTitle,
      category: ExploreCategory.workshops,
      categoryLabel: l10n.filterWorkshops,
      distanceMeters: 1300,
      timeLabel: l10n.eventTomorrow0800,
      venue: l10n.venuePoleMokotowskie,
      accentColor: const Color(0xFF2E7D32),
      icon: Icons.directions_run_rounded,
    ),
    ExploreEvent(
      title: l10n.eventStreetFoodTitle,
      category: ExploreCategory.food,
      categoryLabel: l10n.filterFood,
      distanceMeters: 1600,
      timeLabel: l10n.eventTomorrow1200,
      venue: l10n.venueHalaKoszyki,
      accentColor: const Color(0xFF8E6B3A),
      icon: Icons.restaurant_rounded,
    ),
  ];
}
