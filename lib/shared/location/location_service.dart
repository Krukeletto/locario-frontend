import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

abstract class LocationService {
  bool get supportsLastKnownLocation;
  bool get supportsAppSettings;
  bool get supportsLocationSettings;

  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<LatLng?> getCurrentLocation();
  Future<LatLng?> getLastKnownLocation();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class GeolocatorLocationService implements LocationService {
  static const _locationTimeout = Duration(seconds: 20);

  @override
  bool get supportsLastKnownLocation => !kIsWeb;

  @override
  bool get supportsAppSettings => !kIsWeb;

  @override
  bool get supportsLocationSettings => !kIsWeb;

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    final position = await GeolocatorPlatform.instance.getCurrentPosition(
      locationSettings: _buildLocationSettings(),
    );

    return _toLatLng(position);
  }

  @override
  Future<LatLng?> getLastKnownLocation() async {
    if (!supportsLastKnownLocation) {
      return null;
    }

    final position = await Geolocator.getLastKnownPosition();
    return _toLatLng(position);
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  LocationSettings _buildLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        timeLimit: _locationTimeout,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        timeLimit: _locationTimeout,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: _locationTimeout,
    );
  }

  LatLng? _toLatLng(Position? position) {
    if (position == null) {
      return null;
    }

    return LatLng(position.latitude, position.longitude);
  }
}
