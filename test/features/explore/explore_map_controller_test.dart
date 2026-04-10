import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_map_view_model.dart';
import 'package:locario/shared/location/location_service.dart';

void main() {
  group('ExploreMapViewModel', () {
    test('starts in ready state and locates in the background', () {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(),
      );

      expect(controller.status, ExploreMapStatus.ready);
      expect(controller.currentLocation, isNull);
      expect(controller.mapCenter, controller.fallbackCenter);
      expect(controller.isLocating, isFalse);
    });

    test('sets permissionDenied when location permission is denied', () async {
      final service = FakeLocationService(
        serviceEnabled: true,
        checkPermissionResult: LocationPermission.denied,
        requestPermissionResult: LocationPermission.denied,
      );
      final controller = ExploreMapViewModel(locationService: service);

      await controller.loadInitialLocation();

      expect(controller.status, ExploreMapStatus.permissionDenied);
      expect(controller.currentLocation, isNull);
      expect(controller.mapCenter, controller.fallbackCenter);
      expect(controller.isLocating, isFalse);
      expect(service.requestPermissionCallCount, 1);
    });

    test('sets serviceDisabled when location service is unavailable', () async {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(serviceEnabled: false),
      );

      await controller.loadInitialLocation();

      expect(controller.status, ExploreMapStatus.serviceDisabled);
      expect(controller.currentLocation, isNull);
      expect(controller.mapCenter, controller.fallbackCenter);
      expect(controller.isLocating, isFalse);
    });

    test('sets ready when current location is available', () async {
      const currentLocation = LatLng(52.2297, 21.0122);
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(
          serviceEnabled: true,
          checkPermissionResult: LocationPermission.whileInUse,
          currentLocation: currentLocation,
        ),
      );

      await controller.loadInitialLocation();

      expect(controller.status, ExploreMapStatus.ready);
      expect(controller.currentLocation, currentLocation);
      expect(controller.message, isNull);
      expect(controller.isLocating, isFalse);
    });

    test('uses last known location after current location timeout', () async {
      const lastKnownLocation = LatLng(50.0614, 19.9366);
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(
          serviceEnabled: true,
          checkPermissionResult: LocationPermission.whileInUse,
          currentLocationError: TimeoutException('timeout'),
          lastKnownLocation: lastKnownLocation,
        ),
      );

      await controller.loadInitialLocation();

      expect(controller.status, ExploreMapStatus.ready);
      expect(controller.currentLocation, lastKnownLocation);
      expect(controller.isLocating, isFalse);
    });

    test(
      'uses last known location immediately while waiting for fresh GPS',
      () async {
        const lastKnownLocation = LatLng(54.352, 18.6466);
        const freshLocation = LatLng(54.3722, 18.6383);
        final currentLocationCompleter = Completer<LatLng?>();
        final controller = ExploreMapViewModel(
          locationService: FakeLocationService(
            serviceEnabled: true,
            checkPermissionResult: LocationPermission.whileInUse,
            lastKnownLocation: lastKnownLocation,
            currentLocationCompleter: currentLocationCompleter,
          ),
        );

        final loadFuture = controller.loadInitialLocation();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(controller.currentLocation, lastKnownLocation);
        expect(controller.mapCenter, lastKnownLocation);
        expect(controller.isLocating, isTrue);

        currentLocationCompleter.complete(freshLocation);
        await loadFuture;

        expect(controller.currentLocation, freshLocation);
        expect(controller.isLocating, isFalse);
      },
    );

    test('skips last known lookup when platform does not support it', () async {
      final service = FakeLocationService(
        serviceEnabled: true,
        checkPermissionResult: LocationPermission.whileInUse,
        supportsLastKnownLocation: false,
        currentLocationError: TimeoutException('timeout'),
      );
      final controller = ExploreMapViewModel(locationService: service);

      await controller.loadInitialLocation();

      expect(controller.status, ExploreMapStatus.error);
      expect(controller.currentLocation, isNull);
      expect(service.getLastKnownLocationCallCount, 0);
      expect(controller.mapCenter, controller.fallbackCenter);
      expect(controller.isLocating, isFalse);
    });

    test(
      'falls back to default center when no location could be resolved',
      () async {
        final controller = ExploreMapViewModel(
          locationService: FakeLocationService(
            serviceEnabled: true,
            checkPermissionResult: LocationPermission.whileInUse,
          ),
        );

        await controller.loadInitialLocation();

        expect(controller.status, ExploreMapStatus.error);
        expect(controller.currentLocation, isNull);
        expect(controller.mapCenter, controller.fallbackCenter);
        expect(controller.isLocating, isFalse);
      },
    );
  });
}

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.serviceEnabled = true,
    this.checkPermissionResult = LocationPermission.whileInUse,
    LocationPermission? requestPermissionResult,
    this.currentLocation,
    this.currentLocationCompleter,
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
