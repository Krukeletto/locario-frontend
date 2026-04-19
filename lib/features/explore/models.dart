import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

enum ExploreContentView { map, list }

enum ExploreSortOption { distance, soonest, trending }

enum ExploreDistanceFilter {
  within1Km(1000),
  within3Km(3000),
  within5Km(5000),
  within10Km(10000),
  within25Km(25000);

  const ExploreDistanceFilter(this.maxDistanceMeters);

  final int maxDistanceMeters;
}

enum ExploreCategory { all, music, art, workshops, food }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      parentId: json['parentId'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'parentId': parentId,
      'sortOrder': sortOrder,
    };
  }
}

enum EventStatus {
  draft,
  published;

  static EventStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'draft' => EventStatus.draft,
      'published' => EventStatus.published,
      _ => EventStatus.draft,
    };
  }

  String toJson() => name;
}

enum MediaType {
  image,
  video;

  static MediaType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'video' => MediaType.video,
      _ => MediaType.image,
    };
  }

  String toJson() => name;
}

class EventMedia {
  const EventMedia({
    required this.id,
    required this.url,
    required this.type,
    this.sortOrder = 0,
  });

  final String id;
  final String url;
  final MediaType type;
  final int sortOrder;

  factory EventMedia.fromJson(Map<String, dynamic> json) {
    return EventMedia(
      id: json['id'] as String,
      url: json['url'] as String,
      type: MediaType.fromString(json['type'] as String?),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

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
    required this.startsAt,
    required this.venue,
    required this.location,
    this.categories = const [],
    this.media = const [],
    this.thumbnailUrl,
    this.endsAt,
    this.minAge,
    this.maxAge,
    this.eventType,
    this.eventSource,
    this.description,
    this.address,
    this.status = EventStatus.published,
    this.slotLimit,
    this.ticketUrl,
    this.organizers = const [],
    this.createdAt,
    this.updatedAt,
    this.trendingScore = 0,
  });

  final String id;
  final String title;
  final List<Category> categories;
  final List<EventMedia> media;
  final String? thumbnailUrl;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int trendingScore;
  final String venue;
  final LatLng location;
  final int? minAge;
  final int? maxAge;
  final String? eventType;
  final String? eventSource;
  final String? description;
  final String? address;
  final EventStatus status;
  final int? slotLimit;
  final String? ticketUrl;
  final List<String> organizers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Color get accentColor {
    if (categories.isEmpty) return const Color(0xFF5B6C8F);
    // Use the first category to determine the color for now
    final categoryName = categories.first.name.toLowerCase();
    if (categoryName.contains('music') || categoryName.contains('muzyka')) {
      return const Color(0xFFB14B6F);
    }
    if (categoryName.contains('art') || categoryName.contains('sztuka')) {
      return const Color(0xFF607F5B);
    }
    if (categoryName.contains('workshop') ||
        categoryName.contains('warsztat')) {
      return const Color(0xFF2E7D32);
    }
    if (categoryName.contains('food') || categoryName.contains('jedzenie')) {
      return const Color(0xFF8E6B3A);
    }
    return const Color(0xFF5B6C8F);
  }

  IconData get icon {
    if (categories.isEmpty) return Icons.explore_rounded;
    final categoryName = categories.first.name.toLowerCase();
    if (categoryName.contains('music') || categoryName.contains('muzyka')) {
      return Icons.music_note_rounded;
    }
    if (categoryName.contains('art') || categoryName.contains('sztuka')) {
      return Icons.palette_outlined;
    }
    if (categoryName.contains('workshop') ||
        categoryName.contains('warsztat')) {
      return Icons.lightbulb_outline_rounded;
    }
    if (categoryName.contains('food') || categoryName.contains('jedzenie')) {
      return Icons.restaurant_rounded;
    }
    return Icons.explore_rounded;
  }

  String? get effectiveThumbnailUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return thumbnailUrl;
    }
    final firstImage = media
        .where((m) => m.type == MediaType.image)
        .firstOrNull;
    return firstImage?.url;
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
    if (categories.isEmpty) return l10n.filterAll;
    return categories.map((c) => c.name).join(', ');
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

class ExploreAdvancedFilters {
  const ExploreAdvancedFilters({
    this.distanceFilter = ExploreDistanceFilter.within10Km,
    this.dateFrom,
    this.dateTo,
    this.ageFrom,
    this.ageTo,
    this.eventType,
    this.eventSource,
  });

  final ExploreDistanceFilter distanceFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? ageFrom;
  final int? ageTo;
  final String? eventType;
  final String? eventSource;

  static const defaults = ExploreAdvancedFilters();

  ExploreAdvancedFilters copyWith({
    ExploreDistanceFilter? distanceFilter,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
    int? Function()? ageFrom,
    int? Function()? ageTo,
    String? Function()? eventType,
    String? Function()? eventSource,
  }) {
    return ExploreAdvancedFilters(
      distanceFilter: distanceFilter ?? this.distanceFilter,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      ageFrom: ageFrom != null ? ageFrom() : this.ageFrom,
      ageTo: ageTo != null ? ageTo() : this.ageTo,
      eventType: eventType != null ? eventType() : this.eventType,
      eventSource: eventSource != null ? eventSource() : this.eventSource,
    );
  }

  bool get hasActiveFilters =>
      distanceFilter != ExploreDistanceFilter.within1Km ||
      dateFrom != null ||
      dateTo != null ||
      ageFrom != null ||
      ageTo != null ||
      eventType != null ||
      eventSource != null;

  int get activeFiltersCount {
    int count = 0;
    if (distanceFilter != ExploreDistanceFilter.within1Km) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (ageFrom != null || ageTo != null) count++;
    if (eventType != null) count++;
    if (eventSource != null) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExploreAdvancedFilters &&
        other.distanceFilter == distanceFilter &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo &&
        other.ageFrom == ageFrom &&
        other.ageTo == ageTo &&
        other.eventType == eventType &&
        other.eventSource == eventSource;
  }

  @override
  int get hashCode => Object.hash(
    distanceFilter,
    dateFrom,
    dateTo,
    ageFrom,
    ageTo,
    eventType,
    eventSource,
  );
}
