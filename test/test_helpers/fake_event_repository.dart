import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/events/event_repository.dart';

class FakeEventRepository implements EventRepository {
  FakeEventRepository({
    List<ExploreEvent>? events,
    ExploreEvent? eventDetails,
    this.fetchEventsError,
    this.fetchEventError,
    this.createEventError,
  }) : events = events ?? _defaultEvents,
       eventDetails = eventDetails ?? _defaultEvents.first;

  final List<ExploreEvent> events;
  final ExploreEvent eventDetails;
  final Object? fetchEventsError;
  final Object? fetchEventError;
  final Object? createEventError;

  CreateEventInput? lastCreateInput;

  @override
  Future<ExploreEvent> createEvent(
    CreateEventInput input,
    AppLocalizations l10n,
  ) async {
    if (createEventError != null) {
      throw createEventError!;
    }

    lastCreateInput = input;
    return eventDetails;
  }

  @override
  Future<ExploreEvent> fetchEvent(String id, AppLocalizations l10n) async {
    if (fetchEventError != null) {
      throw fetchEventError!;
    }

    return eventDetails;
  }

  @override
  Future<List<ExploreEvent>> fetchEvents(AppLocalizations l10n) async {
    if (fetchEventsError != null) {
      throw fetchEventsError!;
    }

    return events;
  }
}

final List<ExploreEvent> _defaultEvents = [
  ExploreEvent(
    id: '11111111-1111-1111-1111-111111111111',
    title: 'Jazz Evening',
    category: ExploreCategory.music,
    startsAt: DateTime.utc(2026, 4, 12, 19),
    trendingScore: 50,
    venue: 'Piotrkowska 10, Lodz',
    location: const LatLng(51.7592, 19.4550),
    description: 'Live music and open-air atmosphere.',
    address: 'Piotrkowska 10, Lodz',
  ),
];
