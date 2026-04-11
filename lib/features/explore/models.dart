import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

enum ExploreContentView { map, list }

enum ExploreSortOption { distance, soonest, trending }

enum ExploreCategory { all, music, art, workshops, food }

final _sampleExploreBaseDate = DateTime.utc(2026, 4, 11);

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

class ExploreAreaSelection {
  const ExploreAreaSelection({
    required this.label,
    required this.description,
    required this.icon,
    this.center,
  });

  final String label;
  final String description;
  final IconData icon;
  final LatLng? center;
}

class ExploreEvent {
  const ExploreEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.trendingScore,
    required this.venue,
    required this.location,
    required this.accentColor,
    required this.icon,
  });

  final String id;
  final String title;
  final ExploreCategory category;
  final DateTime startsAt;
  final int trendingScore;
  final String venue;
  final LatLng location;
  final Color accentColor;
  final IconData icon;

  static const Distance _distance = Distance();

  int distanceMetersFrom(LatLng referenceLocation) {
    return _distance.as(LengthUnit.Meter, referenceLocation, location).round();
  }

  String distanceLabel(AppLocalizations l10n, LatLng referenceLocation) {
    final distanceMeters = distanceMetersFrom(referenceLocation);
    if (distanceMeters < 1000) {
      return l10n.distanceMeters(distanceMeters);
    }

    return l10n.distanceKilometers((distanceMeters / 1000).toStringAsFixed(1));
  }

  String categoryLabel(AppLocalizations l10n) {
    return switch (category) {
      ExploreCategory.all => l10n.filterAll,
      ExploreCategory.music => l10n.filterMusic,
      ExploreCategory.art => l10n.filterArt,
      ExploreCategory.workshops => l10n.filterWorkshops,
      ExploreCategory.food => l10n.filterFood,
    };
  }

  String timeLabel(AppLocalizations l10n) {
    final dayDifference = startsAt.difference(_sampleExploreBaseDate).inDays;
    final hour = startsAt.hour;
    final minute = startsAt.minute;

    if (dayDifference == 0 && hour == 20 && minute == 30) {
      return l10n.eventToday2030;
    }
    if (dayDifference == 0 && hour == 19 && minute == 0) {
      return l10n.eventToday1900;
    }
    if (dayDifference == 1 && hour == 8 && minute == 0) {
      return l10n.eventTomorrow0800;
    }
    if (dayDifference == 1 && hour == 12 && minute == 0) {
      return l10n.eventTomorrow1200;
    }

    final date = startsAt;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$day.$month, $hours:$minutes';
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

ExploreAreaSelection buildCurrentLocationAreaSelection(AppLocalizations l10n) {
  return ExploreAreaSelection(
    label: l10n.areaMyLocation,
    description: l10n.areaMyLocationDescription,
    icon: Icons.my_location_rounded,
  );
}

ExploreAreaSelection buildTypedAddressAreaSelection(
  AppLocalizations l10n, {
  required String address,
  LatLng? center,
}) {
  return ExploreAreaSelection(
    label: address,
    description: l10n.areaTypedAddressDescription,
    icon: Icons.search_rounded,
    center: center,
  );
}

ExploreAreaSelection buildPinnedAreaSelection(
  AppLocalizations l10n, {
  required LatLng center,
}) {
  final lat = center.latitude.toStringAsFixed(4);
  final lon = center.longitude.toStringAsFixed(4);
  return ExploreAreaSelection(
    label: l10n.areaPinnedOnMap,
    description: l10n.areaPinnedCoordinates(lat, lon),
    icon: Icons.place_rounded,
    center: center,
  );
}

List<ExploreEvent> buildExploreEvents(AppLocalizations l10n) {
  return [
    ExploreEvent(
      id: 'jazz-botanical-garden',
      title: l10n.eventJazzTitle,
      category: ExploreCategory.music,
      startsAt: DateTime.utc(2026, 4, 11, 20, 30),
      trendingScore: 96,
      venue: l10n.venueBotanicalGarden,
      location: const LatLng(51.703038, 19.417220),
      accentColor: const Color(0xFFB14B6F),
      icon: Icons.music_note_rounded,
    ),
    ExploreEvent(
      id: 'night-sketching-vistula',
      title: l10n.eventSketchingTitle,
      category: ExploreCategory.art,
      startsAt: DateTime.utc(2026, 4, 11, 19, 0),
      trendingScore: 84,
      venue: l10n.venueVistulaBoulevards,
      location: const LatLng(51.695664, 19.416611),
      accentColor: const Color(0xFF607F5B),
      icon: Icons.palette_outlined,
    ),
    ExploreEvent(
      id: 'run-club-coffee-stop',
      title: l10n.eventRunClubTitle,
      category: ExploreCategory.workshops,
      startsAt: DateTime.utc(2026, 4, 12, 8, 0),
      trendingScore: 73,
      venue: l10n.venuePoleMokotowskie,
      location: const LatLng(51.695664, 19.416611),
      accentColor: const Color(0xFF2E7D32),
      icon: Icons.directions_run_rounded,
    ),
    ExploreEvent(
      id: 'street-food-vinyl-market',
      title: l10n.eventStreetFoodTitle,
      category: ExploreCategory.food,
      startsAt: DateTime.utc(2026, 4, 12, 12, 0),
      trendingScore: 88,
      venue: l10n.venueHalaKoszyki,
      location: const LatLng(51.695664, 19.416611),
      accentColor: const Color(0xFF8E6B3A),
      icon: Icons.restaurant_rounded,
    ),
  ];
}
