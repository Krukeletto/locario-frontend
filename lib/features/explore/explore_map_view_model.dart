import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../shared/location/location_service.dart';

enum ExploreMapStatus {
  loading,
  ready,
  permissionDenied,
  serviceDisabled,
  error,
}

enum ExploreMapMessage {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unableDetermineLocation,
  timeout,
  unableLoadLocation,
}

class ExploreMapViewModel extends ChangeNotifier {
  ExploreMapViewModel({
    required LocationService locationService,
    LatLng? fallbackCenter,
  }) : _locationService = locationService,
       fallbackCenter = fallbackCenter ?? _warsawCenter;

  static const LatLng _warsawCenter = LatLng(52.237, 21.017);

  final LocationService _locationService;
  final LatLng fallbackCenter;

  ExploreMapStatus _status = ExploreMapStatus.ready;
  LatLng? _currentLocation;
  LatLng? _preferredMapCenter;
  ExploreMapMessage? _message;
  Future<void>? _pendingLoad;
  bool _hasLoadedInitialLocation = false;
  bool _isLocating = false;

  ExploreMapStatus get status => _status;
  LatLng? get currentLocation => _currentLocation;
  ExploreMapMessage? get message => _message;
  bool get isLocating => _isLocating;
  LatLng get mapCenter =>
      _preferredMapCenter ?? _currentLocation ?? fallbackCenter;
  bool get canOpenAppSettings => _locationService.supportsAppSettings;
  bool get canOpenLocationSettings => _locationService.supportsLocationSettings;

  void setPreferredMapCenter(LatLng? center) {
    if (_preferredMapCenter == center) {
      return;
    }

    _preferredMapCenter = center;
    notifyListeners();
  }

  Future<void> loadInitialLocation() {
    if (_hasLoadedInitialLocation) {
      return _pendingLoad ?? Future.value();
    }

    _hasLoadedInitialLocation = true;
    return refreshLocation();
  }

  Future<void> refreshLocation() {
    final currentLoad = _pendingLoad;
    if (currentLoad != null) {
      return currentLoad;
    }

    final future = _refreshLocationInternal();
    _pendingLoad = future;

    return future.whenComplete(() {
      if (identical(_pendingLoad, future)) {
        _pendingLoad = null;
      }
    });
  }

  Future<void> openAppSettings() async {
    if (!canOpenAppSettings) {
      return;
    }

    await _locationService.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    if (!canOpenLocationSettings) {
      return;
    }

    await _locationService.openLocationSettings();
  }

  Future<void> _refreshLocationInternal() async {
    _setState(status: _status, message: null, isLocating: true);

    try {
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setState(
          status: ExploreMapStatus.serviceDisabled,
          message: ExploreMapMessage.serviceDisabled,
          isLocating: false,
        );
        return;
      }

      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setState(
          status: ExploreMapStatus.permissionDenied,
          message: permission == LocationPermission.deniedForever
              ? ExploreMapMessage.permissionDeniedForever
              : ExploreMapMessage.permissionDenied,
          isLocating: false,
        );
        return;
      }

      final provisionalLocation = await _loadLastKnownLocation();
      if (provisionalLocation != null) {
        _setState(
          status: ExploreMapStatus.ready,
          currentLocation: provisionalLocation,
          message: null,
          isLocating: true,
        );
      }

      final freshLocation = await _locationService.getCurrentLocation();
      if (freshLocation != null) {
        _setState(
          status: ExploreMapStatus.ready,
          currentLocation: freshLocation,
          message: null,
          isLocating: false,
        );
        return;
      }

      if (provisionalLocation != null) {
        _setState(
          status: ExploreMapStatus.ready,
          currentLocation: provisionalLocation,
          message: null,
          isLocating: false,
        );
      } else {
        _setState(
          status: ExploreMapStatus.error,
          message: ExploreMapMessage.unableDetermineLocation,
          isLocating: false,
        );
      }
    } on TimeoutException {
      final fallbackLocation =
          _currentLocation ?? await _loadLastKnownLocation();
      if (fallbackLocation != null) {
        _setState(
          status: ExploreMapStatus.ready,
          currentLocation: fallbackLocation,
          message: null,
          isLocating: false,
        );
        return;
      }

      _setState(
        status: ExploreMapStatus.error,
        message: ExploreMapMessage.timeout,
        isLocating: false,
      );
    } catch (_) {
      _setState(
        status: ExploreMapStatus.error,
        message: ExploreMapMessage.unableLoadLocation,
        isLocating: false,
      );
    }
  }

  Future<LatLng?> _loadLastKnownLocation() async {
    if (!_locationService.supportsLastKnownLocation) {
      return null;
    }

    try {
      return await _locationService.getLastKnownLocation();
    } catch (_) {
      return null;
    }
  }

  void _setState({
    required ExploreMapStatus status,
    LatLng? currentLocation,
    required ExploreMapMessage? message,
    required bool isLocating,
  }) {
    _status = status;
    _currentLocation = currentLocation ?? _currentLocation;
    _message = message;
    _isLocating = isLocating;
    notifyListeners();
  }
}
