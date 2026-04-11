import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/shared/location/location_service.dart';

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.serviceEnabled = true,
    this.checkPermissionResult = LocationPermission.whileInUse,
    LocationPermission? requestPermissionResult,
    this.currentLocation,
    this.currentLocationCompleter,
    this.currentLocationDelay = Duration.zero,
    this.lastKnownLocation,
    this.currentLocationError,
    this.supportsLastKnownLocation = true,
    this.supportsAppSettings = true,
    this.supportsLocationSettings = true,
  }) : requestPermissionResult =
           requestPermissionResult ?? checkPermissionResult;

  final bool serviceEnabled;
  final LocationPermission checkPermissionResult;
  final LocationPermission requestPermissionResult;
  final LatLng? currentLocation;
  final Completer<LatLng?>? currentLocationCompleter;
  final Duration currentLocationDelay;
  final LatLng? lastKnownLocation;
  final Object? currentLocationError;

  @override
  final bool supportsLastKnownLocation;

  @override
  final bool supportsAppSettings;

  @override
  final bool supportsLocationSettings;

  int requestPermissionCallCount = 0;
  int getLastKnownLocationCallCount = 0;

  @override
  Future<LocationPermission> checkPermission() async => checkPermissionResult;

  @override
  Future<LatLng?> getCurrentLocation() async {
    if (currentLocationDelay > Duration.zero) {
      await Future<void>.delayed(currentLocationDelay);
    }

    final currentLocationCompleter = this.currentLocationCompleter;
    if (currentLocationCompleter != null) {
      return currentLocationCompleter.future;
    }

    if (currentLocationError != null) {
      throw currentLocationError!;
    }

    return currentLocation;
  }

  @override
  Future<LatLng?> getLastKnownLocation() async {
    getLastKnownLocationCallCount += 1;
    return lastKnownLocation;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCallCount += 1;
    return requestPermissionResult;
  }
}
