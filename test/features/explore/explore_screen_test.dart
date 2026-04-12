import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_screen.dart';
import 'package:locario/features/explore/map_view_model.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/shared/events/event_repository.dart';
import 'package:locario/shared/events/event_refresh_signal.dart';
import 'package:locario/shared/map/style_repository.dart';

import '../../test_helpers/fake_event_repository.dart';
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
          eventRepository: FakeEventRepository(),
        ),
      );
      await tester.pump();
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
        _buildScreen(
          locationService: FakeLocationService(),
          eventRepository: FakeEventRepository(),
        ),
      );
      await tester.pump();
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
        _buildScreen(
          locationService: FakeLocationService(),
          eventRepository: FakeEventRepository(),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('explore-area-button')));
      await tester.pumpAndSettle();

      expect(find.text('Moja lokalizacja'), findsWidgets);
      expect(find.text('Wpisz adres'), findsOneWidget);
      expect(find.text('Wskaż na mapie'), findsOneWidget);
    });

    testWidgets('shows loading state while events are fetched', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          locationService: FakeLocationService(),
          eventRepository: FakeEventRepository(),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('explore-loading-state')),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when backend returns no events', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildScreen(
          locationService: FakeLocationService(),
          eventRepository: FakeEventRepository(events: const []),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const ValueKey('explore-map-view')), findsOneWidget);

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('explore-empty-state')), findsOneWidget);
    });

    testWidgets('shows error state when backend fetch fails', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          locationService: FakeLocationService(),
          eventRepository: FakeEventRepository(
            fetchEventsError: const EventRepositoryException('boom'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const ValueKey('explore-error-state')), findsOneWidget);
    });

    testWidgets('reloads events when event refresh signal is emitted', (
      tester,
    ) async {
      final refreshSignal = EventRefreshSignal();
      final repository = _SequencedEventRepository(
        responses: [
          [
            _event(
              id: 'first',
              title: 'Pierwszy event',
              location: const LatLng(51.7592, 19.4550),
            ),
          ],
          [
            _event(
              id: 'second',
              title: 'Nowy event po create',
              location: const LatLng(51.76, 19.46),
            ),
          ],
        ],
      );

      await tester.pumpWidget(
        _buildScreen(
          locationService: FakeLocationService(),
          eventRepository: repository,
          eventRefreshSignal: refreshSignal,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      expect(find.text('Pierwszy event'), findsOneWidget);
      expect(find.text('Nowy event po create'), findsNothing);

      refreshSignal.notifyChanged();
      await tester.pump();
      await tester.pump();

      expect(repository.fetchEventsCallCount, 2);
      expect(find.text('Nowy event po create'), findsOneWidget);
    });

    testWidgets(
      'auto refresh reloads events on interval when explore is active',
      (tester) async {
        final repository = _SequencedEventRepository(
          responses: [
            [
              _event(
                id: 'first',
                title: 'Pierwszy event',
                location: const LatLng(51.7592, 19.4550),
              ),
            ],
            [
              _event(
                id: 'second',
                title: 'Event z auto refreshu',
                location: const LatLng(51.7600, 19.4550),
              ),
            ],
          ],
        );

        await tester.pumpWidget(
          _buildScreen(
            locationService: FakeLocationService(),
            eventRepository: repository,
            autoRefreshInterval: const Duration(seconds: 1),
          ),
        );
        await tester.pump();
        await tester.pump();

        await tester.tap(find.text('Lista'));
        await tester.pumpAndSettle();

        expect(find.text('Pierwszy event'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1, milliseconds: 50));
        await tester.pump();

        expect(repository.fetchEventsCallCount, greaterThanOrEqualTo(2));
        expect(find.text('Event z auto refreshu'), findsOneWidget);
      },
    );

    testWidgets('list distance filter narrows visible events', (tester) async {
      final repository = FakeEventRepository(
        events: [
          _event(
            id: 'near',
            title: 'Blisko',
            location: const LatLng(51.7592, 19.4550),
          ),
          _event(
            id: 'far',
            title: 'Daleko',
            location: const LatLng(51.9000, 19.4550),
          ),
        ],
      );

      await tester.pumpWidget(
        _buildScreen(
          locationService: FakeLocationService(
            currentLocation: const LatLng(51.7592, 19.4550),
          ),
          eventRepository: repository,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      expect(find.text('Blisko'), findsOneWidget);
      expect(find.text('Daleko'), findsOneWidget);

      await tester.tap(find.byKey(const Key('explore-distance-filter-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Do 1 km').last);
      await tester.pumpAndSettle();

      expect(find.text('Blisko'), findsOneWidget);
      expect(find.text('Daleko'), findsNothing);
    });
  });
}

Widget _buildScreen({
  required FakeLocationService locationService,
  required EventRepository eventRepository,
  EventRefreshSignal? eventRefreshSignal,
  Duration? autoRefreshInterval,
}) {
  final controller = ExploreMapViewModel(locationService: locationService);

  return buildLocalizedTestApp(
    home: ExploreScreen(
      controller: controller,
      eventRepository: eventRepository,
      eventRefreshSignal: eventRefreshSignal,
      autoRefreshInterval: autoRefreshInterval,
      styleRepository: const MapStyleRepository(
        inlineStyleJson: _testStyleJson,
      ),
    ),
  );
}

class _SequencedEventRepository implements EventRepository {
  _SequencedEventRepository({required this.responses});

  final List<List<ExploreEvent>> responses;
  int fetchEventsCallCount = 0;

  @override
  Future<ExploreEvent> createEvent(input, l10n) {
    throw UnimplementedError();
  }

  @override
  Future<ExploreEvent> fetchEvent(String id, l10n) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchEvents(l10n) async {
    final index = fetchEventsCallCount < responses.length
        ? fetchEventsCallCount
        : responses.length - 1;
    fetchEventsCallCount += 1;
    return responses[index];
  }
}

ExploreEvent _event({
  required String id,
  required String title,
  required LatLng location,
}) {
  return ExploreEvent(
    id: id,
    title: title,
    category: ExploreCategory.music,
    startsAt: DateTime.utc(2026, 4, 12, 19),
    trendingScore: 1,
    venue: 'Piotrkowska 10, Lodz',
    location: location,
    address: 'Piotrkowska 10, Lodz',
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
