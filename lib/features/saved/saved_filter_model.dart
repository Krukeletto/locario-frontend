import 'package:latlong2/latlong.dart';
import '../explore/models.dart';

class SavedFilter {
  const SavedFilter({
    required this.id,
    required this.name,
    required this.filters,
    this.location,
    this.useCurrentLocation = true,
    this.notificationsEnabled = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final ExploreAdvancedFilters filters;
  final LatLng? location;
  final bool useCurrentLocation;
  final bool notificationsEnabled;
  final DateTime createdAt;

  SavedFilter copyWith({
    String? id,
    String? name,
    ExploreAdvancedFilters? filters,
    LatLng? Function()? location,
    bool? useCurrentLocation,
    bool? notificationsEnabled,
    DateTime? createdAt,
  }) {
    return SavedFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      filters: filters ?? this.filters,
      location: location != null ? location() : this.location,
      useCurrentLocation: useCurrentLocation ?? this.useCurrentLocation,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filters': filters.toJson(),
      if (location != null)
        'location': {'lat': location!.latitude, 'lng': location!.longitude},
      'useCurrentLocation': useCurrentLocation,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory SavedFilter.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    final locationJson = json['location'] as Map<String, dynamic>?;
    if (locationJson != null) {
      final lat = (locationJson['lat'] as num).toDouble();
      final lng = (locationJson['lng'] as num).toDouble();
      location = LatLng(lat, lng);
    }

    return SavedFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      filters: ExploreAdvancedFilters.fromJson(
        Map<String, dynamic>.from(json['filters'] as Map),
      ),
      location: location,
      useCurrentLocation: json['useCurrentLocation'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}
