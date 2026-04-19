import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/hub/create_event/create_event_location_controller.dart';

import '../../../test_helpers/fake_location_service.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  group('CreateEventLocationController', () {
    testWidgets('selectAddress geocodes and stores coordinates', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedTestApp(home: const SizedBox.shrink()),
      );
      await tester.pump(); // Ensure builder runs

      final controller = CreateEventLocationController(
        locationService: FakeLocationService(),
        geocoder: (_) async => [
          Location(
            latitude: 51.7592,
            longitude: 19.4550,
            timestamp: DateTime(2026),
          ),
        ],
      );

      final result = await controller.selectAddress('Piotrkowska 10, Lodz');

      expect(result.status, CreateEventLocationLookupStatus.success);
      expect(controller.selection, isNotNull);
      expect(controller.selection!.coordinates, const LatLng(51.7592, 19.4550));
      expect(controller.selection!.label, 'Piotrkowska 10, Lodz');
    });

    testWidgets('selectPinnedLocation stores pinned point label', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedTestApp(home: const SizedBox.shrink()),
      );
      await tester.pump(); // Ensure builder runs

      final controller = CreateEventLocationController(
        locationService: FakeLocationService(),
      );

      controller.selectPinnedLocation(const LatLng(51.7, 19.4));

      expect(controller.selection, isNotNull);
      expect(
        controller.selection!.source,
        CreateEventLocationSource.pinnedOnMap,
      );
      expect(controller.selection!.coordinates, const LatLng(51.7, 19.4));
    });
  });
}
