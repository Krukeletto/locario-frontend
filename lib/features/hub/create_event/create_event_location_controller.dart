import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/location/location_service.dart';
import '../../../shared/services/l10n_service.dart';

typedef CreateEventGeocoder = Future<List<Location>> Function(String address);

enum CreateEventLocationSource { currentLocation, typedAddress, pinnedOnMap }

enum CreateEventLocationLookupStatus { success, notFound, error }

class CreateEventLocationLookupResult {
  const CreateEventLocationLookupResult._({required this.status});

  const CreateEventLocationLookupResult.success()
    : this._(status: CreateEventLocationLookupStatus.success);

  const CreateEventLocationLookupResult.notFound()
    : this._(status: CreateEventLocationLookupStatus.notFound);

  const CreateEventLocationLookupResult.error()
    : this._(status: CreateEventLocationLookupStatus.error);

  final CreateEventLocationLookupStatus status;
}

class CreateEventLocationSelection {
  const CreateEventLocationSelection({
    required this.label,
    required this.description,
    required this.coordinates,
    required this.source,
    required this.icon,
    this.address,
  });

  final String label;
  final String description;
  final LatLng coordinates;
  final CreateEventLocationSource source;
  final IconData icon;
  final String? address;
}

class CreateEventLocationController extends ChangeNotifier {
  CreateEventLocationController({
    required LocationService locationService,
    CreateEventGeocoder? geocoder,
  }) : _locationService = locationService,
       _geocoder = geocoder ?? locationFromAddress;

  final LocationService _locationService;
  final CreateEventGeocoder _geocoder;

  CreateEventLocationSelection? _selection;
  bool _isResolvingSelection = false;

  CreateEventLocationSelection? get selection => _selection;
  bool get isResolvingSelection => _isResolvingSelection;

  Future<CreateEventLocationLookupResult> useCurrentLocation() async {
    final l10n = L10nService.l10n;
    _isResolvingSelection = true;
    _selection = null;
    notifyListeners();

    try {
      final location =
          await _locationService.getCurrentLocation() ??
          await _locationService.getLastKnownLocation();
      if (location == null) {
        return const CreateEventLocationLookupResult.notFound();
      }

      final lat = location.latitude.toStringAsFixed(4);
      final lon = location.longitude.toStringAsFixed(4);
      _selection = CreateEventLocationSelection(
        label: l10n.areaMyLocation,
        description: l10n.areaPinnedCoordinates(lat, lon),
        coordinates: location,
        source: CreateEventLocationSource.currentLocation,
        icon: Icons.my_location_rounded,
      );
      notifyListeners();
      return const CreateEventLocationLookupResult.success();
    } catch (_) {
      return const CreateEventLocationLookupResult.error();
    } finally {
      _isResolvingSelection = false;
      notifyListeners();
    }
  }

  Future<CreateEventLocationLookupResult> selectAddress(String address) async {
    final l10n = L10nService.l10n;
    _selection = null;
    try {
      final locations = await _geocoder(address);
      if (locations.isEmpty) {
        return const CreateEventLocationLookupResult.notFound();
      }

      final firstLocation = locations.first;
      final latLng = LatLng(firstLocation.latitude, firstLocation.longitude);
      final lat = latLng.latitude.toStringAsFixed(4);
      final lon = latLng.longitude.toStringAsFixed(4);
      _selection = CreateEventLocationSelection(
        label: address,
        description: l10n.areaPinnedCoordinates(lat, lon),
        coordinates: latLng,
        source: CreateEventLocationSource.typedAddress,
        icon: Icons.search_rounded,
        address: address,
      );
      notifyListeners();
      return const CreateEventLocationLookupResult.success();
    } catch (_) {
      return const CreateEventLocationLookupResult.error();
    }
  }

  void selectPinnedLocation(LatLng location) {
    final l10n = L10nService.l10n;
    final lat = location.latitude.toStringAsFixed(4);
    final lon = location.longitude.toStringAsFixed(4);
    _selection = CreateEventLocationSelection(
      label: l10n.areaPinnedOnMap,
      description: l10n.areaPinnedCoordinates(lat, lon),
      coordinates: location,
      source: CreateEventLocationSource.pinnedOnMap,
      icon: Icons.place_rounded,
    );
    notifyListeners();
  }

  void setSelectionFromCoordinates({
    required String label,
    required LatLng coordinates,
  }) {
    final l10n = L10nService.l10n;
    final lat = coordinates.latitude.toStringAsFixed(4);
    final lon = coordinates.longitude.toStringAsFixed(4);
    _selection = CreateEventLocationSelection(
      label: label,
      description: l10n.areaPinnedCoordinates(lat, lon),
      coordinates: coordinates,
      source: CreateEventLocationSource.pinnedOnMap,
      icon: Icons.place_rounded,
      address: label,
    );
    notifyListeners();
  }
}
