import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/map_view_model.dart';
import 'package:locario/features/explore/widgets/map_widget.dart';
import 'package:locario/shared/map/style_repository.dart';
import 'package:locario/shared/location/location_service.dart';

void main() {
  group('MapWidget', () {
    testWidgets(
      'does not show an error banner while location is still resolving',
      (tester) async {
        final controller = ExploreMapViewModel(
          locationService: _WidgetFakeLocationService(
            currentLocationDelay: const Duration(seconds: 1),
          ),
        );

        controller.loadInitialLocation();
        await tester.pumpWidget(_buildTestApp(controller));

        expect(find.byKey(const Key('map-message-banner')), findsNothing);

        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      },
    );

    testWidgets('shows error banner when controller resolves to an error', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: _WidgetFakeLocationService(serviceEnabled: false),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byKey(const Key('map-message-banner')), findsOneWidget);
      expect(
        find.text('Enable location services to see your position.'),
        findsOneWidget,
      );
    });

    testWidgets('shows current location marker only when location exists', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: _WidgetFakeLocationService(
          currentLocation: const LatLng(52.2297, 21.0122),
        ),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byKey(const Key('current-location-marker')), findsOneWidget);
      expect(find.byKey(const Key('map-recenter-button')), findsOneWidget);
    });
  });
}

Widget _buildTestApp(ExploreMapViewModel controller) {
  return MaterialApp(
    home: Scaffold(
      body: MapWidget(
        controller: controller,
        styleRepository: const MapStyleRepository(
          inlineStyleJson: _testStyleJson,
        ),
        overlayPadding: const EdgeInsets.only(top: 12, bottom: 24),
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

class _WidgetFakeLocationService implements LocationService {
  _WidgetFakeLocationService({
    this.serviceEnabled = true,
    this.currentLocation,
    this.currentLocationDelay = Duration.zero,
  });

  final bool serviceEnabled;
  final LatLng? currentLocation;
  final Duration currentLocationDelay;

  @override
  bool get supportsAppSettings => true;

  @override
  bool get supportsLastKnownLocation => false;

  @override
  bool get supportsLocationSettings => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LatLng?> getCurrentLocation() async {
    if (currentLocationDelay > Duration.zero) {
      await Future<void>.delayed(currentLocationDelay);
    }

    return currentLocation;
  }

  @override
  Future<LatLng?> getLastKnownLocation() async => null;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
