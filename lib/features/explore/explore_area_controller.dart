import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../../shared/services/l10n_service.dart';
import 'models.dart';

typedef ExploreGeocoder = Future<List<Location>> Function(String address);

enum ExploreAddressLookupStatus { success, notFound, error }

enum ExploreAreaSelectionMode { currentLocation, typedAddress, mapPin }

class ExploreAddressLookupResult {
  const ExploreAddressLookupResult._({required this.status, this.center});

  const ExploreAddressLookupResult.success({required LatLng center})
    : this._(status: ExploreAddressLookupStatus.success, center: center);

  const ExploreAddressLookupResult.notFound()
    : this._(status: ExploreAddressLookupStatus.notFound);

  const ExploreAddressLookupResult.error()
    : this._(status: ExploreAddressLookupStatus.error);

  final ExploreAddressLookupStatus status;
  final LatLng? center;
}

class ExploreAreaController extends ChangeNotifier {
  ExploreAreaController({ExploreGeocoder? geocoder})
    : _geocoder = geocoder ?? locationFromAddress;

  final ExploreGeocoder _geocoder;

  String? _typedAreaLabel;
  LatLng? _selectedAreaCenter;
  LatLng? _mapViewportCenter;
  bool _isPickingAreaOnMap = false;

  bool get isPickingAreaOnMap => _isPickingAreaOnMap;
  ExploreAreaSelectionMode get selectionMode {
    if (_typedAreaLabel != null && _typedAreaLabel!.isNotEmpty) {
      return ExploreAreaSelectionMode.typedAddress;
    }
    if (_selectedAreaCenter != null) {
      return ExploreAreaSelectionMode.mapPin;
    }
    return ExploreAreaSelectionMode.currentLocation;
  }

  void selectCurrentLocation() {
    _typedAreaLabel = null;
    _selectedAreaCenter = null;
    _isPickingAreaOnMap = false;
    notifyListeners();
  }

  void startMapPicking() {
    if (_isPickingAreaOnMap) {
      return;
    }

    _isPickingAreaOnMap = true;
    notifyListeners();
  }

  void cancelMapPicking() {
    if (!_isPickingAreaOnMap) {
      return;
    }

    _isPickingAreaOnMap = false;
    notifyListeners();
  }

  void updateViewportCenter(LatLng center) {
    _mapViewportCenter = center;
  }

  void searchInArea(LatLng center) {
    _typedAreaLabel = null;
    _selectedAreaCenter = center;
    _isPickingAreaOnMap = false;
    notifyListeners();
  }

  LatLng confirmMapPicking(LatLng fallbackCenter) {
    final selectedCenter = _mapViewportCenter ?? fallbackCenter;
    _typedAreaLabel = null;
    _selectedAreaCenter = selectedCenter;
    _isPickingAreaOnMap = false;
    notifyListeners();
    return selectedCenter;
  }

  Future<ExploreAddressLookupResult> selectAddress(String address) async {
    try {
      final locations = await _geocoder(address);
      if (locations.isEmpty) {
        return const ExploreAddressLookupResult.notFound();
      }

      final firstLocation = locations.first;
      final center = LatLng(firstLocation.latitude, firstLocation.longitude);
      _typedAreaLabel = address;
      _selectedAreaCenter = center;
      _isPickingAreaOnMap = false;
      notifyListeners();
      return ExploreAddressLookupResult.success(center: center);
    } catch (_) {
      return const ExploreAddressLookupResult.error();
    }
  }

  LatLng referenceLocation({
    required LatLng? currentLocation,
    required LatLng fallbackCenter,
  }) {
    return _selectedAreaCenter ?? currentLocation ?? fallbackCenter;
  }

  ExploreAreaSelection selectedArea() {
    final l10n = L10nService.l10n;
    final typedAreaLabel = _typedAreaLabel;
    if (typedAreaLabel != null && typedAreaLabel.isNotEmpty) {
      return buildTypedAddressAreaSelection(
        l10n,
        address: typedAreaLabel,
        center: _selectedAreaCenter,
      );
    }

    final selectedAreaCenter = _selectedAreaCenter;
    if (selectedAreaCenter != null) {
      return buildPinnedAreaSelection(l10n, center: selectedAreaCenter);
    }

    return buildCurrentLocationAreaSelection(l10n);
  }
}
