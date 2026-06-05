import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_area_controller.dart';
import 'package:locario/features/explore/explore_controller.dart';
import 'package:locario/features/explore/explore_screen.dart';
import 'package:locario/features/explore/map_view_model.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/explore/widgets/header.dart';
import 'package:locario/features/explore/widgets/map_widget.dart';
import 'package:locario/shared/events/event_repository.dart';
import 'package:locario/shared/map/style_repository.dart';
import 'package:locario/features/shell/header/header_controller.dart';
import 'package:locario/features/shell/header/header_scope.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/fake_location_service.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('ExploreScreen', () {
    testWidgets('renders map and list view toggle', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          locationService: FakeLocationService(
            currentLocation: const LatLng(0, 0),
          ),
          eventRepository: FakeEventRepository(),
        ),
      );
      await tester.pump();

      expect(find.byType(ExploreScreen), findsOneWidget);
    });

    testWidgets('refreshes events when refresh signal emits', (tester) async {
      final eventRefreshSignal = StreamController<void>.broadcast();
      final responses = [
        [_event(id: '1', title: 'First', location: const LatLng(0, 0))],
        [_event(id: '2', title: 'Second', location: const LatLng(0, 0))],
      ];
      final eventRepository = _SequencedEventRepository(responses: responses);

      await tester.pumpWidget(
        _buildTestApp(
          locationService: FakeLocationService(
            currentLocation: const LatLng(0, 0),
          ),
          eventRepository: eventRepository,
          eventRefreshSignal: eventRefreshSignal.stream,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);

      eventRefreshSignal.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
      await eventRefreshSignal.close();
    });

    testWidgets('keeps map visible when there are no events', (tester) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.map);

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(
              eventRepository: FakeEventRepository(events: const []),
            ),
            mapViewModel: ExploreMapViewModel(
              locationService: FakeLocationService(
                currentLocation: const LatLng(0, 0),
              ),
              fallbackCenter: const LatLng(0, 0),
            ),
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MapWidget), findsOneWidget);
      expect(find.text('No events found'), findsNothing);
    });

    testWidgets('does not show empty notice in list view', (tester) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.list);

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(
              eventRepository: FakeEventRepository(events: const []),
            ),
            mapViewModel: ExploreMapViewModel(
              locationService: FakeLocationService(
                currentLocation: const LatLng(0, 0),
              ),
              fallbackCenter: const LatLng(0, 0),
            ),
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No events found'), findsNothing);
    });

    testWidgets('shows search-this-area button after moving the map', (
      tester,
    ) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.map);

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(
              eventRepository: FakeEventRepository(
                events: [
                  _event(
                    id: '1',
                    title: 'Jazz Evening',
                    location: const LatLng(0, 0),
                  ),
                ],
              ),
            ),
            mapViewModel: ExploreMapViewModel(
              locationService: FakeLocationService(
                currentLocation: const LatLng(0, 0),
              ),
              fallbackCenter: const LatLng(0, 0),
            ),
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Search this area'), findsNothing);

      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      mapWidget.onCameraCenterChanged?.call(const LatLng(0, 0));
      await tester.pump();
      mapWidget.onCameraCenterChanged?.call(const LatLng(0.01, 0.01));
      await tester.pumpAndSettle();

      expect(find.text('Search this area'), findsOneWidget);
    });

    testWidgets('does not show search-this-area button on initial load', (
      tester,
    ) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.map);
      final currentLocationCompleter = Completer<LatLng?>();
      final mapViewModel = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocationCompleter: currentLocationCompleter,
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(
              eventRepository: FakeEventRepository(
                events: [
                  _event(
                    id: '1',
                    title: 'Jazz Evening',
                    location: const LatLng(0, 0),
                  ),
                ],
              ),
            ),
            mapViewModel: mapViewModel,
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Search this area'), findsNothing);

      currentLocationCompleter.complete(const LatLng(51.0, 19.0));
      await tester.pumpAndSettle();

      expect(find.text('Search this area'), findsNothing);
      expect(mapViewModel.mapCenter, const LatLng(51.0, 19.0));
    });

    testWidgets('moving map alone does not refresh events before button tap', (
      tester,
    ) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.map);
      final eventRepository = _SequencedEventRepository(
        responses: [
          [_event(id: '1', title: 'First', location: const LatLng(0, 0))],
          [
            _event(
              id: '2',
              title: 'Second',
              location: const LatLng(0.01, 0.01),
            ),
          ],
        ],
      );
      final mapViewModel = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: const LatLng(0, 0),
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(eventRepository: eventRepository),
            mapViewModel: mapViewModel,
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(eventRepository.fetchEventsCallCount, 1);

      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      mapWidget.onCameraCenterChanged?.call(const LatLng(0, 0));
      await tester.pump();
      mapWidget.onCameraCenterChanged?.call(const LatLng(0.01, 0.01));
      await tester.pumpAndSettle();

      expect(eventRepository.fetchEventsCallCount, 1);
      expect(find.text('Search this area'), findsOneWidget);

      await tester.tap(find.text('Search this area'));
      await tester.pumpAndSettle();

      expect(eventRepository.fetchEventsCallCount, greaterThanOrEqualTo(2));
      expect(find.text('Search this area'), findsNothing);
    });

    testWidgets('search-this-area keeps using the latest visible center', (
      tester,
    ) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.map);
      final eventRepository = _SequencedEventRepository(
        responses: [
          [_event(id: '1', title: 'First', location: const LatLng(0, 0))],
          [_event(id: '2', title: 'Second', location: const LatLng(1, 1))],
          [_event(id: '3', title: 'Third', location: const LatLng(2, 2))],
        ],
      );
      final mapViewModel = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: const LatLng(51.0, 19.0),
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(eventRepository: eventRepository),
            mapViewModel: mapViewModel,
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      mapWidget.onCameraCenterChanged?.call(const LatLng(51.0, 19.0));
      await tester.pump();
      mapWidget.onCameraCenterChanged?.call(const LatLng(51.01, 19.01));
      await tester.pump();
      expect(find.text('Search this area'), findsOneWidget);
      await tester.tap(find.text('Search this area'));
      await tester.pumpAndSettle();

      expect(eventRepository.lastNearbyLatitude, 51.01);
      expect(eventRepository.lastNearbyLongitude, 19.01);
      expect(mapViewModel.mapCenter, const LatLng(51.01, 19.01));

      mapWidget.onCameraCenterChanged?.call(const LatLng(52.0, 20.0));
      await tester.pumpAndSettle();

      expect(find.text('Search this area'), findsOneWidget);
      await tester.tap(find.text('Search this area'));
      await tester.pumpAndSettle();

      expect(eventRepository.lastNearbyLatitude, 52.0);
      expect(eventRepository.lastNearbyLongitude, 20.0);
      expect(mapViewModel.mapCenter, const LatLng(52.0, 20.0));
    });

    testWidgets('keeps map visible while searching again after empty results', (
      tester,
    ) async {
      final headerController = ShellHeaderController()
        ..setSelectedView(ExploreContentView.map);
      final pendingSecondAreaSearch = Completer<void>();
      final eventRepository = _EmptyAreaSearchRepository(
        pendingSecondAreaSearch: pendingSecondAreaSearch,
      );
      final mapViewModel = ExploreMapViewModel(
        locationService: FakeLocationService(
          currentLocation: const LatLng(51.0, 19.0),
        ),
        fallbackCenter: const LatLng(0, 0),
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: ExploreScreen(
            controller: ExploreController(eventRepository: eventRepository),
            mapViewModel: mapViewModel,
            areaController: ExploreAreaController(),
            headerController: headerController,
            styleRepository: const MapStyleRepository(
              inlineStyleJson: _testStyleJson,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      var mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      mapWidget.onCameraCenterChanged?.call(const LatLng(51.0, 19.0));
      await tester.pump();
      mapWidget.onCameraCenterChanged?.call(const LatLng(51.01, 19.01));
      await tester.pump();
      await tester.tap(find.text('Search this area'));
      await tester.pumpAndSettle();

      expect(find.byType(MapWidget), findsOneWidget);

      mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      mapWidget.onCameraCenterChanged?.call(const LatLng(52.0, 20.0));
      await tester.pump();
      expect(find.text('Search this area'), findsOneWidget);

      await tester.tap(find.text('Search this area'));
      await tester.pump();

      expect(find.byType(MapWidget), findsOneWidget);
      expect(find.byKey(const Key('map-startup-loading')), findsNothing);

      pendingSecondAreaSearch.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'does not add status bar gap when rendered below shell header',
      (tester) async {
        final searchController = TextEditingController();
        final focusNode = FocusNode();
        addTearDown(searchController.dispose);
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(top: 24)),
            child: buildLocalizedTestApp(
              home: ShellHeaderScope(
                controller: ShellHeaderController(),
                child: Scaffold(
                  appBar: ExploreHeader(
                    searchController: searchController,
                    searchFocusNode: focusNode,
                    onFilterPressed: () {},
                    includeTopInset: false,
                    selectedFilterIndices: const {},
                    onFilterToggled: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final appBarTop = tester.getTopLeft(find.byType(ExploreHeader)).dy;
        final searchFieldTop = tester.getTopLeft(find.byType(TextField)).dy;
        expect(searchFieldTop - appBarTop, 16);
      },
    );
  });
}

class _EmptyAreaSearchRepository implements EventRepository {
  _EmptyAreaSearchRepository({required this.pendingSecondAreaSearch});

  final Completer<void> pendingSecondAreaSearch;

  @override
  Future<ExploreEvent> createEvent(
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ExploreEvent> updateEvent(
    String id,
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchOrganizerEvents({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<EventMedia> uploadEventMedia(
    String eventId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEventMedia(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setEventThumbnail(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> fetchCategories() {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchNearbyEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
  }) async {
    if ((latitude - 52.0).abs() < 0.001) {
      await pendingSecondAreaSearch.future;
      return const [];
    }

    if ((latitude - 51.01).abs() < 0.001) {
      return const [];
    }

    return [
      _event(id: '1', title: 'First', location: const LatLng(51.0, 19.0)),
    ];
  }

  @override
  Future<ExploreEvent> fetchEvent(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchEvents() async {
    return fetchNearbyEvents(latitude: 51.0, longitude: 19.0);
  }
}

Widget _buildTestApp({
  required FakeLocationService locationService,
  required EventRepository eventRepository,
  Stream<void>? eventRefreshSignal,
  Duration autoRefreshInterval = const Duration(minutes: 5),
}) {
  final mapViewModel = ExploreMapViewModel(
    locationService: locationService,
    fallbackCenter: const LatLng(0, 0),
  );
  final controller = ExploreController(eventRepository: eventRepository);
  final headerController = ShellHeaderController()
    ..setSelectedView(ExploreContentView.list);
  final areaController = ExploreAreaController();

  return buildLocalizedTestApp(
    home: ExploreScreen(
      controller: controller,
      mapViewModel: mapViewModel,
      areaController: areaController,
      headerController: headerController,
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
  double? lastNearbyLatitude;
  double? lastNearbyLongitude;

  @override
  Future<ExploreEvent> createEvent(
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ExploreEvent> updateEvent(
    String id,
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchOrganizerEvents({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<EventMedia> uploadEventMedia(
    String eventId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEventMedia(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setEventThumbnail(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> fetchCategories() {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchNearbyEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
  }) async {
    lastNearbyLatitude = latitude;
    lastNearbyLongitude = longitude;
    final index = fetchEventsCallCount < responses.length
        ? fetchEventsCallCount
        : responses.length - 1;
    fetchEventsCallCount += 1;
    return responses[index];
  }

  @override
  Future<ExploreEvent> fetchEvent(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchEvents() async {
    return fetchNearbyEvents(latitude: 0, longitude: 0);
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
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    startsAt: DateTime.utc(2026, 12, 12, 19),
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
