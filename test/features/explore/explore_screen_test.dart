import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/map_view_model.dart';
import 'package:locario/features/explore/explore_screen.dart';
import 'package:locario/shared/map/style_repository.dart';
import 'package:locario/shared/location/location_service.dart';

void main() {
  group('ExploreScreen', () {
    testWidgets('renders search, brand and filters on top of the map', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildScreen(
          locationService: _ScreenFakeLocationService(
            currentLocation: const LatLng(52.2297, 21.0122),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Locario'), findsOneWidget);
      expect(find.byKey(const Key('explore-search-field')), findsOneWidget);
      expect(find.text('Wszystkie'), findsOneWidget);
      expect(find.text('Muzyka'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Lista'), findsOneWidget);
      expect(find.byKey(const Key('explore-area-button')), findsNothing);
    });

    testWidgets('switches from full map view to list view', (tester) async {
      await tester.pumpWidget(
        _buildScreen(locationService: _ScreenFakeLocationService()),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('explore-map-view')), findsOneWidget);

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('explore-list-view')), findsOneWidget);
      expect(find.text('Wydarzenia w pobliżu'), findsOneWidget);
      expect(find.text('Jazz w Ogrodzie Botanicznym'), findsOneWidget);
      expect(find.byKey(const ValueKey('explore-map-view')), findsNothing);
    });

    testWidgets('opens area picker and updates selected area', (tester) async {
      await tester.pumpWidget(
        _buildScreen(locationService: _ScreenFakeLocationService()),
      );
      await tester.pump();

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('explore-area-button')));
      await tester.pumpAndSettle();

      expect(find.text('Powiśle'), findsOneWidget);

      await tester.tap(find.text('Powiśle'));
      await tester.pumpAndSettle();

      expect(find.text('Powiśle'), findsWidgets);
    });
  });
}

Widget _buildScreen({required LocationService locationService}) {
  final controller = ExploreMapViewModel(locationService: locationService);

  return MaterialApp(
    home: ExploreScreen(
      controller: controller,
      styleRepository: const MapStyleRepository(
        inlineStyleJson: _testStyleJson,
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

class _ScreenFakeLocationService implements LocationService {
  _ScreenFakeLocationService({this.currentLocation});

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
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
