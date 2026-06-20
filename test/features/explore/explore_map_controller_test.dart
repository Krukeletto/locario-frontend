import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/map_view_model.dart';

import '../../test_helpers/fake_location_service.dart';

void main() {
  group('ExploreMapViewModel', () {
    test('starts in ready state and locates in the background', () {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(),
        fallbackCenter: const LatLng(0, 0),
      );

      expect(controller.status, ExploreMapStatus.ready);
      expect(controller.currentLocation, isNull);
      expect(controller.mapCenter, controller.fallbackCenter);
      expect(controller.isLocating, isFalse);
    });

    test('does not request permission during initial location load', () async {
      final service = FakeLocationService(
        serviceEnabled: true,
        checkPermissionResult: LocationPermission.denied,
        requestPermissionResult: LocationPermission.denied,
      );
      final controller = ExploreMapViewModel(
        locationService: service,
        fallbackCenter: const LatLng(0, 0),
      );

      await controller.loadInitialLocation();

      expect(controller.status, ExploreMapStatus.permissionDenied);
      expect(controller.currentLocation, isNull);
      expect(controller.mapCenter, controller.fallbackCenter);
      expect(controller.isLocating, isFalse);
      expect(service.requestPermissionCallCount, 0);
    });

    test('requests permission only when explicitly asked', () async {
      final service = FakeLocationService(
        serviceEnabled: true,
        checkPermissionResult: LocationPermission.denied,
        requestPermissionResult: LocationPermission.whileInUse,
        currentLocation: const LatLng(52.2297, 21.0122),
      );
      final controller = ExploreMapViewModel(
        locationService: service,
        fallbackCenter: const LatLng(0, 0),
      );

      await controller.requestLocationPermission();

      expect(controller.status, ExploreMapStatus.ready);
      expect(controller.currentLocation, const LatLng(52.2297, 21.0122));
      expect(service.requestPermissionCallCount, 1);
    });

    test('sets serviceDisabled when location service is unavailable', () async {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(serviceEnabled: false),
        fallbackCenter: const LatLng(0, 0),
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
        fallbackCenter: const LatLng(0, 0),
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
        fallbackCenter: const LatLng(0, 0),
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
          fallbackCenter: const LatLng(0, 0),
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
      final controller = ExploreMapViewModel(
        locationService: service,
        fallbackCenter: const LatLng(0, 0),
      );

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
          fallbackCenter: const LatLng(0, 0),
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
