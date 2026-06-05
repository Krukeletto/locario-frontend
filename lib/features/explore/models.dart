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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type.toJson(),
      'sortOrder': sortOrder,
    };
  }
}

class EventGroupSummary {
  const EventGroupSummary({
    required this.id,
    required this.name,
    this.iconUrl,
    this.mapPinIconUrl,
    this.mapPinStyle,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final String? mapPinIconUrl;
  final String? mapPinStyle;

  factory EventGroupSummary.fromJson(Map<String, dynamic> json) {
    return EventGroupSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      mapPinIconUrl: json['mapPinIconUrl'] as String?,
      mapPinStyle: json['mapPinStyle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'mapPinIconUrl': mapPinIconUrl,
      'mapPinStyle': mapPinStyle,
    };
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
    this.tags = const [],
    this.status = EventStatus.published,
    this.slotLimit,
    this.ticketUrl,
    this.organizers = const [],
    this.organizerId,
    this.organizerUsername,
    this.createdAt,
    this.updatedAt,
    this.groupIds = const [],
    this.groups = const [],
    this.publicEvent = true,
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
  final List<String> tags;
  final EventStatus status;
  final int? slotLimit;
  final String? ticketUrl;
  final List<String> organizers;
  final String? organizerId;
  final String? organizerUsername;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> groupIds;
  final List<EventGroupSummary> groups;
  final bool publicEvent;

  factory ExploreEvent.fromJson(
    Map<String, dynamic> json, {
    String? fallbackTitle,
    String? fallbackVenue,
  }) {
    final title =
        _normalizedString(json['name']) ?? _normalizedString(json['title']);
    final address = _normalizedString(json['address']);
    final description = _normalizedString(json['description']);
    final startsAtRaw =
        _normalizedString(json['startAt']) ??
        _normalizedString(json['startDate']);
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();
    final location = LatLng(latitude ?? 0, longitude ?? 0);

    return ExploreEvent(
      id: _normalizedString(json['id']) ?? '',
      title: title == null || title.isEmpty
          ? (fallbackTitle ?? 'Unknown event')
          : title,
      categories: _categoriesFromJson(json['categories']),
      media: _mediaFromJson(json['media']),
      thumbnailUrl: _normalizedString(json['thumbnailUrl']),
      startsAt: DateTime.tryParse(startsAtRaw ?? '') ?? DateTime.now().toUtc(),
      endsAt: _parseDateTime(json['endAt']) ?? _parseDateTime(json['endDate']),
      trendingScore: json['trendingScore'] as int? ?? 0,
      venue: address == null || address.isEmpty
          ? (fallbackVenue ?? _formatCoordinates(location))
          : address,
      location: location,
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      eventType: _normalizedString(json['eventType']),
      eventSource: _normalizedString(json['eventSource']),
      description: description,
      address: address,
      tags: _tagsFromJson(json['tags']),
      status: EventStatus.fromString(json['status'] as String?),
      slotLimit: json['slotLimit'] as int?,
      ticketUrl: _normalizedString(json['ticketUrl']),
      organizers: _organizersFromJson(json['organizers']),
      organizerId: _primaryOrganizerIdFromJson(json['organizers']),
      organizerUsername: _primaryOrganizerUsernameFromJson(json['organizers']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      groupIds: _stringListFromJson(json['groupIds']),
      groups: _groupSummariesFromJson(json['groups']),
      publicEvent: json['publicEvent'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': title,
      'startsAt': startsAt.toUtc().toIso8601String(),
      if (endsAt != null) 'endAt': endsAt!.toUtc().toIso8601String(),
      'trendingScore': trendingScore,
      'venue': venue,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'categories': categories.map((category) => category.toJson()).toList(),
      'media': media.map((item) => item.toJson()).toList(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (minAge != null) 'minAge': minAge,
      if (maxAge != null) 'maxAge': maxAge,
      if (eventType != null) 'eventType': eventType,
      if (eventSource != null) 'eventSource': eventSource,
      if (description != null) 'description': description,
      'status': status.toJson(),
      if (slotLimit != null) 'slotLimit': slotLimit,
      if (ticketUrl != null) 'ticketUrl': ticketUrl,
      'organizers': organizers,
      if (organizerId != null || organizerUsername != null)
        'organizer': {
          if (organizerId != null) 'userId': organizerId,
          if (organizerUsername != null) 'username': organizerUsername,
        },
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
      if (groupIds.isNotEmpty) 'groupIds': groupIds,
      if (groups.isNotEmpty)
        'groups': groups.map((group) => group.toJson()).toList(),
      'publicEvent': publicEvent,
      'tags': tags,
    };
  }

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

  bool get hasEnded =>
      !((endsAt ?? startsAt).toLocal().isAfter(DateTime.now().toLocal()));
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _normalizedString(dynamic value) {
  final stringValue = value as String?;
  final trimmed = stringValue?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

DateTime? _parseDateTime(dynamic value) {
  final raw = _normalizedString(value);
  if (raw == null) {
    return null;
  }
  return DateTime.tryParse(raw);
}

List<Category> _categoriesFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .map(Category.fromJson)
      .toList(growable: false);
}

List<EventMedia> _mediaFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .map(EventMedia.fromJson)
      .toList(growable: false);
}

List<String> _tagsFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) {
        if (item is String) {
          return item.trim();
        }
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          return _normalizedString(map['name']) ??
              _normalizedString(map['label']) ??
              _normalizedString(map['slug']) ??
              _normalizedString(map['value']) ??
              '';
        }
        return '';
      })
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

List<String> _stringListFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) {
        if (item is String) {
          return item.trim();
        }
        return item?.toString().trim() ?? '';
      })
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

List<String> _organizersFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) {
        if (item is String) {
          return item.trim();
        }
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          return _normalizedString(map['username']) ??
              _normalizedString(map['userId']) ??
              '';
        }
        return '';
      })
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

String? _primaryOrganizerIdFromJson(dynamic value) {
  if (value is! List || value.isEmpty) {
    return null;
  }

  final first = _asMap(value.first);
  return first == null ? null : _normalizedString(first['userId']);
}

String? _primaryOrganizerUsernameFromJson(dynamic value) {
  if (value is! List || value.isEmpty) {
    return null;
  }

  final first = _asMap(value.first);
  return first == null ? null : _normalizedString(first['username']);
}

List<EventGroupSummary> _groupSummariesFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .map(EventGroupSummary.fromJson)
      .toList(growable: false);
}

String _formatCoordinates(LatLng location) {
  final lat = location.latitude.toStringAsFixed(4);
  final lon = location.longitude.toStringAsFixed(4);
  return '$lat, $lon';
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
    this.showPastEvents = false,
  });

  final ExploreDistanceFilter distanceFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? ageFrom;
  final int? ageTo;
  final String? eventType;
  final String? eventSource;
  final bool showPastEvents;

  static const defaults = ExploreAdvancedFilters();

  ExploreAdvancedFilters copyWith({
    ExploreDistanceFilter? distanceFilter,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
    int? Function()? ageFrom,
    int? Function()? ageTo,
    String? Function()? eventType,
    String? Function()? eventSource,
    bool? showPastEvents,
  }) {
    return ExploreAdvancedFilters(
      distanceFilter: distanceFilter ?? this.distanceFilter,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      ageFrom: ageFrom != null ? ageFrom() : this.ageFrom,
      ageTo: ageTo != null ? ageTo() : this.ageTo,
      eventType: eventType != null ? eventType() : this.eventType,
      eventSource: eventSource != null ? eventSource() : this.eventSource,
      showPastEvents: showPastEvents ?? this.showPastEvents,
    );
  }

  bool get hasActiveFilters => activeFiltersCount > 0;

  int get activeFiltersCount {
    int count = 0;
    if (distanceFilter != defaults.distanceFilter) count++;
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
        other.eventSource == eventSource &&
        other.showPastEvents == showPastEvents;
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
    showPastEvents,
  );

  Map<String, dynamic> toJson() {
    return {
      'distanceFilter': distanceFilter.name,
      if (dateFrom != null) 'dateFrom': dateFrom!.toUtc().toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo!.toUtc().toIso8601String(),
      if (ageFrom != null) 'ageFrom': ageFrom,
      if (ageTo != null) 'ageTo': ageTo,
      if (eventType != null) 'eventType': eventType,
      if (eventSource != null) 'eventSource': eventSource,
      'showPastEvents': showPastEvents,
    };
  }

  factory ExploreAdvancedFilters.fromJson(Map<String, dynamic> json) {
    return ExploreAdvancedFilters(
      distanceFilter: ExploreDistanceFilter.values.firstWhere(
        (f) => f.name == json['distanceFilter'],
        orElse: () => ExploreDistanceFilter.within10Km,
      ),
      dateFrom: json['dateFrom'] != null
          ? DateTime.tryParse(json['dateFrom'] as String)
          : null,
      dateTo: json['dateTo'] != null
          ? DateTime.tryParse(json['dateTo'] as String)
          : null,
      ageFrom: json['ageFrom'] as int?,
      ageTo: json['ageTo'] as int?,
      eventType: json['eventType'] as String?,
      eventSource: json['eventSource'] as String?,
      showPastEvents: json['showPastEvents'] as bool? ?? false,
    );
  }

  String toShortSummary(AppLocalizations l10n) {
    final parts = <String>[
      l10n.distanceFilterWithinKm(
        (distanceFilter.maxDistanceMeters / 1000).round(),
      ),
    ];
    if (dateFrom != null || dateTo != null) {
      if (dateFrom != null && dateTo != null) {
        final sameDay =
            dateFrom!.year == dateTo!.year &&
            dateFrom!.month == dateTo!.month &&
            dateFrom!.day == dateTo!.day;
        parts.add(
          sameDay
              ? '${dateFrom!.day}.${dateFrom!.month}'
              : '${dateFrom!.day}.${dateFrom!.month}-${dateTo!.day}.${dateTo!.month}',
        );
      } else if (dateFrom != null) {
        parts.add(
          '${l10n.filterAdvancedDateFrom} ${dateFrom!.day}.${dateFrom!.month}',
        );
      } else if (dateTo != null) {
        parts.add(
          '${l10n.filterAdvancedDateTo} ${dateTo!.day}.${dateTo!.month}',
        );
      }
    }
    if (ageFrom != null || ageTo != null) {
      if (ageFrom != null && ageTo != null) {
        parts.add('$ageFrom-$ageTo');
      } else if (ageFrom != null) {
        parts.add('$ageFrom+');
      } else if (ageTo != null) {
        parts.add('-$ageTo');
      }
    }
    if (showPastEvents) {
      parts.add(l10n.savedShowPastEvents);
    }
    return parts.join(' | ');
  }
}
