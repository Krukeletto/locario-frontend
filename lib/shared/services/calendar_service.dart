import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/explore/models.dart';

class CalendarService {
  CalendarService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'locario/device_calendar';

  final MethodChannel _channel;

  Future<bool> addEvent(ExploreEvent event) async {
    if (kIsWeb) {
      return false;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    final draft = CalendarEventDraft.fromEvent(event);
    try {
      final result = await _channel.invokeMethod<bool>(
        'createEvent',
        draft.toMethodArguments(),
      );
      return result ?? false;
    } on MissingPluginException catch (error) {
      debugPrint('Calendar integration unavailable: $error');
      return false;
    } on PlatformException catch (error) {
      debugPrint('Calendar integration failed: ${error.message}');
      return false;
    }
  }
}

class CalendarEventDraft {
  const CalendarEventDraft({
    required this.title,
    required this.startAt,
    required this.endAt,
    this.description,
    this.location,
  });

  factory CalendarEventDraft.fromEvent(ExploreEvent event) {
    final startAt = event.startsAt.toLocal();
    final endAt = event.endsAt?.toLocal();
    final effectiveEndAt = endAt != null && endAt.isAfter(startAt)
        ? endAt
        : startAt.add(const Duration(hours: 1));

    final location = event.address?.trim().isNotEmpty == true
        ? event.address!.trim()
        : event.venue.trim();

    return CalendarEventDraft(
      title: event.title.trim(),
      startAt: startAt,
      endAt: effectiveEndAt,
      description: _descriptionFor(event),
      location: location.isEmpty ? null : location,
    );
  }

  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String? description;
  final String? location;

  Map<String, Object?> toMethodArguments() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'startMillis': startAt.millisecondsSinceEpoch,
      'endMillis': endAt.millisecondsSinceEpoch,
    };
  }

  static String? _descriptionFor(ExploreEvent event) {
    final parts = <String>[];

    final description = event.description?.trim();
    if (description != null && description.isNotEmpty) {
      parts.add(description);
    }

    parts.add('https://locario-events.web.app/events/${event.id}');

    return parts.join('\n\n');
  }
}
