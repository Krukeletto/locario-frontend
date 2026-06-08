import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_controller.dart';
import 'package:locario/features/explore/explore_state.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/shared/events/event_repository.dart';

void main() {
  group('ExploreController', () {
    test(
      'refresh from empty results keeps map UI instead of full loading',
      () async {
        final repository = _EmptyRepository();
        final controller = ExploreController(eventRepository: repository);
        addTearDown(controller.dispose);

        controller.updateReferenceLocation(const LatLng(51, 19));
        await Future<void>.delayed(Duration.zero);

        expect(controller.state, isA<ExploreEmpty>());

        repository.pauseNextFetch();
        final refresh = controller.loadEvents(forceRefresh: true);

        final loadingState = controller.state;
        expect(loadingState, isA<ExploreDataLoading>());
        expect((loadingState as ExploreDataLoading).previous, isEmpty);

        repository.completeNextFetch();
        await refresh;

        expect(controller.state, isA<ExploreEmpty>());
      },
    );
  });
}

class _EmptyRepository implements EventRepository {
  Completer<void>? _nextFetchGate;

  void pauseNextFetch() {
    _nextFetchGate = Completer<void>();
  }

  void completeNextFetch() {
    _nextFetchGate?.complete();
    _nextFetchGate = null;
  }

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
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final gate = _nextFetchGate;
    if (gate != null) {
      await gate.future;
    }
    return const [];
  }

  @override
  Future<ExploreEvent> fetchEvent(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExploreEvent>> fetchEvents({
    String? accessToken,
    String tokenType = 'Bearer',
  }) {
    return fetchNearbyEvents(latitude: 0, longitude: 0);
  }
}
