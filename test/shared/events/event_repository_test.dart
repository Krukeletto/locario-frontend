import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/l10n/app_localizations_en.dart';
import 'package:locario/shared/events/event_repository.dart';

void main() {
  group('HttpEventRepository', () {
    final l10n = AppLocalizationsEn();

    test('fetchEvents maps backend response', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async {
          expect(request.url.path, '/api/events');
          return http.Response(
            jsonEncode([
              {
                'id': '11111111-1111-1111-1111-111111111111',
                'title': 'Live music',
                'description': 'Open-air concert',
                'latitude': 51.7592,
                'longitude': 19.4550,
                'address': 'Piotrkowska 10, Lodz',
                'startDate': '2026-04-12T19:00:00Z',
                'categoryName': 'music',
              },
            ]),
            200,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final events = await repository.fetchEvents(l10n);

      expect(events, hasLength(1));
      expect(events.first.title, 'Live music');
      expect(events.first.category, ExploreCategory.music);
      expect(events.first.address, 'Piotrkowska 10, Lodz');
    });

    test(
      'fetchEvents falls back to coordinates when backend address is null',
      () async {
        final repository = HttpEventRepository(
          client: MockClient((request) async {
            return http.Response(
              jsonEncode([
                {
                  'id': '11111111-1111-1111-1111-111111111111',
                  'title': 'Live music',
                  'latitude': 51.7592,
                  'longitude': 19.4550,
                  'address': null,
                  'startDate': '2026-04-12T19:00:00Z',
                },
              ]),
              200,
            );
          }),
          baseUrl: 'http://example.com',
        );

        final events = await repository.fetchEvents(l10n);

        expect(events.first.venue, '51.7592, 19.4550');
      },
    );

    test('fetchEvents maps missing category to all instead of music', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'id': '11111111-1111-1111-1111-111111111111',
                'title': 'Live music',
                'latitude': 51.7592,
                'longitude': 19.4550,
                'address': 'Piotrkowska 10, Lodz',
                'startDate': '2026-04-12T19:00:00Z',
                'categoryId': null,
                'categoryName': null,
              },
            ]),
            200,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final events = await repository.fetchEvents(l10n);

      expect(events.first.category, ExploreCategory.all);
    });

    test('fetchEvent throws on non-200', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async => http.Response('', 500)),
        baseUrl: 'http://example.com',
      );

      expect(
        repository.fetchEvent('id', l10n),
        throwsA(isA<EventRepositoryException>()),
      );
    });

    test('createEvent sends contract payload', () async {
      late Map<String, dynamic> body;
      final repository = HttpEventRepository(
        client: MockClient((request) async {
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'id': '11111111-1111-1111-1111-111111111111',
              'title': 'Created event',
              'latitude': 51.7592,
              'longitude': 19.4550,
              'startDate': '2026-04-12T19:00:00Z',
            }),
            201,
          );
        }),
        baseUrl: 'http://example.com',
      );

      await repository.createEvent(
        CreateEventInput(
          title: 'Created event',
          description: 'Open-air concert',
          location: const LatLng(51.7592, 19.4550),
          startDate: DateTime.utc(2026, 4, 12, 19),
          address: 'Piotrkowska 10, Lodz',
        ),
        l10n,
      );

      expect(body['title'], 'Created event');
      expect(body['description'], 'Open-air concert');
      expect(body['latitude'], 51.7592);
      expect(body['longitude'], 19.455);
      expect(body['address'], 'Piotrkowska 10, Lodz');
      expect(body['startDate'], '2026-04-12T19:00:00.000Z');
    });
  });
}
