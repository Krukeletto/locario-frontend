import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_map_view_model.dart';
import 'package:locario/features/explore/widgets/map_widget.dart';
import 'package:locario/shared/location/location_service.dart';

void main() {
  group('MapWidget', () {
    testWidgets('shows loading overlay while controller is loading', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: _WidgetFakeLocationService(),
      );

      await tester.pumpWidget(_buildTestApp(controller));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

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
    });
  });
}

Widget _buildTestApp(ExploreMapViewModel controller) {
  return MaterialApp(
    home: Scaffold(body: MapWidget(controller: controller)),
  );
}

class _WidgetFakeLocationService implements LocationService {
  _WidgetFakeLocationService({
    this.serviceEnabled = true,
    this.currentLocation,
  });

  final bool serviceEnabled;
  final LatLng? currentLocation;

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
  Future<LatLng?> getCurrentLocation() async => currentLocation;

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
