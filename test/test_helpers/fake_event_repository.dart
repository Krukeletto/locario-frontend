import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/shared/events/event_repository.dart';

class FakeEventRepository implements EventRepository {
  FakeEventRepository({
    List<ExploreEvent>? events,
    ExploreEvent? eventDetails,
    List<Category>? categories,
    this.fetchEventsError,
    this.fetchEventError,
    this.createEventError,
  }) : events = events ?? _defaultEvents,
       eventDetails = eventDetails ?? _defaultEvents.first,
       categories = categories ?? _defaultCategories;

  final List<ExploreEvent> events;
  final ExploreEvent eventDetails;
  final List<Category> categories;
  final Object? fetchEventsError;
  final Object? fetchEventError;
  final Object? createEventError;

  EventRequest? lastCreateInput;
  String? lastUploadedEventId;
  List<int>? lastUploadedBytes;
  String? lastUploadedFileName;

  @override
  Future<ExploreEvent> createEvent(EventRequest request) async {
    if (createEventError != null) {
      throw createEventError!;
    }

    lastCreateInput = request;
    return eventDetails;
  }

  @override
  Future<ExploreEvent> updateEvent(String id, EventRequest request) async {
    return eventDetails;
  }

  @override
  Future<ExploreEvent> fetchEvent(String id) async {
    if (fetchEventError != null) {
      throw fetchEventError!;
    }

    return eventDetails;
  }

  @override
  Future<List<ExploreEvent>> fetchEvents() async {
    if (fetchEventsError != null) {
      throw fetchEventsError!;
    }

    return events;
  }

  @override
  Future<List<ExploreEvent>> fetchNearbyEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
  }) async {
    return events;
  }

  @override
  Future<List<Category>> fetchCategories() async {
    return categories;
  }

  @override
  Future<void> uploadEventMedia(
    String eventId,
    List<int> bytes,
    String fileName,
  ) async {
    lastUploadedEventId = eventId;
    lastUploadedBytes = bytes;
    lastUploadedFileName = fileName;
  }

  @override
  Future<void> deleteEventMedia(String eventId, String mediaId) async {}

  @override
  Future<void> setEventThumbnail(String eventId, String mediaId) async {}
}

final List<ExploreEvent> _defaultEvents = [
  ExploreEvent(
    id: '11111111-1111-1111-1111-111111111111',
    title: 'Jazz Evening',
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    startsAt: DateTime.utc(2026, 4, 12, 19),
    trendingScore: 50,
    venue: 'Piotrkowska 10, Lodz',
    location: const LatLng(51.7592, 19.4550),
    description: 'Live music and open-air atmosphere.',
    address: 'Piotrkowska 10, Lodz',
  ),
];

final List<Category> _defaultCategories = [
  const Category(id: 'music', name: 'Music', slug: 'music'),
  const Category(id: 'art', name: 'Art', slug: 'art'),
];
