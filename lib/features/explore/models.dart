import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

enum ExploreContentView { map, list }

enum ExploreSortOption { distance, soonest, trending }

enum ExploreDistanceFilter {
  any(null),
  within1Km(1000),
  within3Km(3000),
  within5Km(5000),
  within10Km(10000),
  within25Km(25000);

  const ExploreDistanceFilter(this.maxDistanceMeters);

  final int? maxDistanceMeters;
}

enum ExploreCategory { all, music, art, workshops, food }

const Map<ExploreCategory, String?> _backendCategoryIds = {
  ExploreCategory.music: null,
  ExploreCategory.art: null,
  ExploreCategory.workshops: null,
  ExploreCategory.food: null,
};

String? backendCategoryIdFor(ExploreCategory category) {
  return _backendCategoryIds[category];
}

ExploreCategory? primaryCategoryForSubmission(
  Iterable<ExploreCategory> categories,
) {
  if (categories.isEmpty) {
    return null;
  }

  return categories.last;
}

ExploreCategory exploreCategoryFromBackend({
  String? categoryId,
  String? categoryName,
}) {
  final normalizedId = categoryId?.trim();
  final normalizedName = categoryName?.trim().toLowerCase();
  if ((normalizedId == null || normalizedId.isEmpty) &&
      (normalizedName == null || normalizedName.isEmpty)) {
    return ExploreCategory.all;
  }

  switch (normalizedName) {
    case 'music':
    case 'muzyka':
      return ExploreCategory.music;
    case 'art':
    case 'sztuka':
      return ExploreCategory.art;
    case 'workshops':
    case 'warsztaty':
      return ExploreCategory.workshops;
    case 'food':
    case 'jedzenie':
      return ExploreCategory.food;
  }

  final entry = _backendCategoryIds.entries.firstWhere(
    (entry) => entry.value != null && entry.value == normalizedId,
    orElse: () =>
        const MapEntry<ExploreCategory, String?>(ExploreCategory.all, null),
  );
  return entry.key;
}

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
    this.description,
    this.address,
    this.categoryId,
    this.categoryName,
  });

  final String id;
  final String title;
  final ExploreCategory category;
  final DateTime startsAt;
  final int trendingScore;
  final String venue;
  final LatLng location;
  final String? description;
  final String? address;
  final String? categoryId;
  final String? categoryName;

  Color get accentColor {
    return switch (category) {
      ExploreCategory.all => const Color(0xFF5B6C8F),
      ExploreCategory.music => const Color(0xFFB14B6F),
      ExploreCategory.art => const Color(0xFF607F5B),
      ExploreCategory.workshops => const Color(0xFF2E7D32),
      ExploreCategory.food => const Color(0xFF8E6B3A),
    };
  }

  IconData get icon {
    return switch (category) {
      ExploreCategory.all => Icons.explore_rounded,
      ExploreCategory.music => Icons.music_note_rounded,
      ExploreCategory.art => Icons.palette_outlined,
      ExploreCategory.workshops => Icons.lightbulb_outline_rounded,
      ExploreCategory.food => Icons.restaurant_rounded,
    };
  }

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

  String locationLabel(AppLocalizations l10n) {
    final normalizedAddress = address?.trim();
    if (normalizedAddress != null && normalizedAddress.isNotEmpty) {
      return normalizedAddress;
    }

    final lat = location.latitude.toStringAsFixed(4);
    final lon = location.longitude.toStringAsFixed(4);
    return l10n.areaPinnedCoordinates(lat, lon);
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
