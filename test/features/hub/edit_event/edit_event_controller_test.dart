import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/hub/create_event/create_event_state.dart';
import 'package:locario/features/hub/edit_event/edit_event_screen.dart';

import '../../../test_helpers/fake_event_repository.dart';
import '../../../test_helpers/test_app.dart';

void main() {
  group('EditEventController', () {
    testWidgets('hydrates state from fetched event', (tester) async {
      await tester.pumpWidget(buildLocalizedTestApp(home: const SizedBox()));
      await tester.pump();

      final event = _buildEvent(
        id: 'event-1',
        title: 'Workshop',
        description: 'Hands-on workshop for new organizers.',
        ticketUrl: 'https://tickets.example.com',
        slotLimit: 25,
      );
      final repository = FakeEventRepository(eventDetails: event);
      final controller = EditEventController(
        eventRepository: repository,
        eventId: event.id,
      );
      addTearDown(controller.dispose);

      final loaded = await controller.loadEvent();

      expect(loaded, isNotNull);
      expect(controller.state.title, event.title);
      expect(controller.state.description, event.description);
      expect(controller.state.ticketUrl, event.ticketUrl);
      expect(controller.state.slotLimit, event.slotLimit);
      expect(controller.state.selectedCategories, event.categories);
      expect(controller.state.selectedDate, event.startsAt);
      expect(controller.state.selectedTime, event.startsAt);
    });

    testWidgets('submits update and uploads selected images', (tester) async {
      await tester.pumpWidget(buildLocalizedTestApp(home: const SizedBox()));
      await tester.pump();

      final event = _buildEvent(
        id: 'event-2',
        title: 'Jazz Night',
        description: 'Live set with a local band and open jam session.',
        ticketUrl: 'https://tickets.example.com/jazz',
        slotLimit: 100,
      );
      final repository = FakeEventRepository(eventDetails: event);
      final controller = EditEventController(
        eventRepository: repository,
        eventId: event.id,
      );
      addTearDown(controller.dispose);

      await controller.loadEvent();
      controller.addSelectedImages(const [
        CreateEventSelectedImage(bytes: [1, 2, 3], fileName: 'a.png'),
        CreateEventSelectedImage(bytes: [4, 5, 6], fileName: 'b.png'),
      ]);

      await controller.submit();

      expect(repository.lastUpdateEventId, event.id);
      expect(repository.lastUpdateInput, isNotNull);
      expect(repository.lastUpdateInput!.name, event.title);
      expect(repository.lastUpdateInput!.description, event.description);
      expect(repository.lastUpdateInput!.ticketUrl, event.ticketUrl);
      expect(repository.lastUpdateInput!.slotLimit, event.slotLimit);
      expect(repository.lastUpdateInput!.endAt, event.endsAt);
      expect(repository.uploadedEventIds, [event.id, event.id]);
      expect(repository.lastThumbnailEventId, event.id);
      expect(repository.lastThumbnailMediaId, 'media-1');
    });
  });
}

ExploreEvent _buildEvent({
  required String id,
  required String title,
  required String description,
  required String ticketUrl,
  required int slotLimit,
}) {
  final start = DateTime(2026, 5, 24, 18, 0);
  final end = DateTime(2026, 5, 24, 20, 0);
  return ExploreEvent(
    id: id,
    title: title,
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    startsAt: start,
    endsAt: end,
    trendingScore: 1,
    venue: 'Main Hall',
    location: const LatLng(51.7592, 19.4550),
    description: description,
    address: 'Piotrkowska 10, Lodz',
    ticketUrl: ticketUrl,
    slotLimit: slotLimit,
    thumbnailUrl: 'https://example.com/thumb.png',
  );
}
