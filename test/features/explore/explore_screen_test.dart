import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_screen.dart';
import 'package:locario/features/explore/map_view_model.dart';
import 'package:locario/shared/map/style_repository.dart';

import '../../test_helpers/fake_location_service.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('ExploreScreen', () {
    testWidgets('renders search, brand and filters on top of the map', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildScreen(
          locationService: FakeLocationService(
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
        _buildScreen(locationService: FakeLocationService()),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('explore-map-view')), findsOneWidget);

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('explore-list-view')), findsOneWidget);
      expect(find.text('Wydarzenia w pobliżu'), findsOneWidget);
      expect(find.byKey(const Key('explore-event-list')), findsOneWidget);
      expect(find.byKey(const Key('explore-area-button')), findsOneWidget);
      expect(find.byKey(const ValueKey('explore-map-view')), findsNothing);
    });

    testWidgets('opens area picker options from list toolbar', (tester) async {
      await tester.pumpWidget(
        _buildScreen(locationService: FakeLocationService()),
      );
      await tester.pump();

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('explore-area-button')));
      await tester.pumpAndSettle();

      expect(find.text('Moja lokalizacja'), findsWidgets);
      expect(find.text('Wpisz adres'), findsOneWidget);
      expect(find.text('Wskaż na mapie'), findsOneWidget);
    });
  });
}

Widget _buildScreen({required FakeLocationService locationService}) {
  final controller = ExploreMapViewModel(locationService: locationService);

  return buildLocalizedTestApp(
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
