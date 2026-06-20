import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/map_view_model.dart';
import 'package:locario/features/explore/widgets/map_widget.dart';
import 'package:locario/shared/map/style_repository.dart';

import '../../test_helpers/fake_location_service.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('MapWidget', () {
    testWidgets(
      'does not show an error banner while location is still resolving',
      (tester) async {
        final currentLocationCompleter = Completer<LatLng?>();
        final controller = ExploreMapViewModel(
          locationService: FakeLocationService(
            currentLocationCompleter: currentLocationCompleter,
          ),
          fallbackCenter: const LatLng(0, 0),
        );

        final loadFuture = controller.loadInitialLocation();
        await tester.pumpWidget(_buildTestApp(controller));
        await tester.pump();

        expect(find.byKey(const Key('map-startup-loading')), findsOneWidget);

        currentLocationCompleter.complete(const LatLng(52.2297, 21.0122));
        await loadFuture;
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('map-startup-loading')), findsNothing);
        expect(find.byType(MapWidget), findsOneWidget);
        expect(find.byKey(const Key('map-message-banner')), findsNothing);
      },
    );

    testWidgets('shows empty map state when location service is disabled', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(serviceEnabled: false),
        fallbackCenter: const LatLng(0, 0),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byKey(const Key('map-message-banner')), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(
        find.text('Enable location services to see your position.'),
        findsOneWidget,
      );
      expect(find.text('Location settings'), findsOneWidget);
    });

    testWidgets('renders fallback map when location is optional', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(serviceEnabled: false),
        fallbackCenter: const LatLng(51.7592, 19.4550),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(
        _buildTestApp(controller, requireLocation: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('The map needs location'), findsNothing);
      expect(find.byKey(const Key('map-message-banner')), findsNothing);
      expect(find.byType(MapWidget), findsOneWidget);
      expect(controller.mapCenter, const LatLng(51.7592, 19.4550));
    });

    testWidgets('renders without crash when current location exists', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: const LatLng(52.2297, 21.0122),
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byType(MapWidget), findsOneWidget);
      expect(find.byKey(const Key('map-message-banner')), findsNothing);
    });

    testWidgets('follows the resolved current location on startup', (
      tester,
    ) async {
      const currentLocation = LatLng(52.2297, 21.0122);
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: currentLocation,
          currentLocationDelay: const Duration(seconds: 1),
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      final loadFuture = controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(controller.currentLocation, isNull);
      expect(controller.mapCenter, controller.fallbackCenter);

      await tester.pump(const Duration(seconds: 1));
      await loadFuture;
      await tester.pumpAndSettle();

      expect(controller.currentLocation, currentLocation);
      expect(controller.mapCenter, currentLocation);
    });

    testWidgets('does not show startup loading after map has rendered once', (
      tester,
    ) async {
      const currentLocation = LatLng(52.2297, 21.0122);
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: currentLocation,
          currentLocationDelay: const Duration(seconds: 1),
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      final loadFuture = controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byKey(const Key('map-startup-loading')), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await loadFuture;
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map-startup-loading')), findsNothing);

      final refreshFuture = controller.refreshLocation();
      await tester.pump();

      expect(controller.isLocating, isTrue);
      expect(find.byKey(const Key('map-startup-loading')), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await refreshFuture;
    });
  });
}

Widget _buildTestApp(
  ExploreMapViewModel controller, {
  bool requireLocation = true,
}) {
  return buildLocalizedTestApp(
    home: Scaffold(
      body: MapWidget(
        events: const [],
        controller: controller,
        onEventTap: (_) {},
        styleRepository: const MapStyleRepository(
          inlineStyleJson: _testStyleJson,
        ),
        overlayPadding: const EdgeInsets.only(top: 12, bottom: 24),
        requireLocation: requireLocation,
      ),
    ),
  );
}

const _testStyleJson = '''
{
  "version": 8,
  "name": "test-style",
  "sources": {},
  "layers": [
    {
      "id": "background",
      "type": "background",
      "paint": {
        "background-color": "#ffffff"
      }
    }
  ]
}
''';
