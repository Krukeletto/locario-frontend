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
        final controller = ExploreMapViewModel(
          locationService: FakeLocationService(
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
        locationService: FakeLocationService(serviceEnabled: false),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byKey(const Key('map-message-banner')), findsOneWidget);
      expect(
        find.text('Włącz usługi lokalizacji, aby zobaczyć swoją pozycję.'),
        findsOneWidget,
      );
    });

    testWidgets('renders without crash when current location exists', (
      tester,
    ) async {
      final controller = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: const LatLng(52.2297, 21.0122),
        ),
      );

      await controller.loadInitialLocation();
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pump();

      expect(find.byType(MapWidget), findsOneWidget);
      expect(find.byKey(const Key('map-message-banner')), findsNothing);
    });
  });
}

Widget _buildTestApp(ExploreMapViewModel controller) {
  return buildLocalizedTestApp(
    home: Scaffold(
      body: MapWidget(
        events: const [],
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
