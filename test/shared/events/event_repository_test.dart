import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:locario/l10n/app_localizations_en.dart';
import 'package:locario/shared/events/event_repository.dart';
import 'package:locario/shared/services/l10n_service.dart';

void main() {
  // Initialize L10nService for tests
  L10nService.init(AppLocalizationsEn());

  group('HttpEventRepository', () {
    test('fetchEvents maps backend response', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async {
          expect(request.url.path, '/api/events');
          return http.Response(
            jsonEncode([
              {
                'id': '11111111-1111-1111-1111-111111111111',
                'name': 'Live music',
                'description': 'Open-air concert',
                'latitude': 51.7592,
                'longitude': 19.4550,
                'address': 'Piotrkowska 10, Lodz',
                'startAt': '2026-04-12T19:00:00Z',
                'categories': [
                  {'id': 'music', 'name': 'music', 'slug': 'music'},
                ],
              },
            ]),
            200,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final events = await repository.fetchEvents();

      expect(events, hasLength(1));
      expect(events.first.title, 'Live music');
      expect(events.first.categories.first.id, 'music');
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
                  'name': 'Live music',
                  'latitude': 51.7592,
                  'longitude': 19.4550,
                  'address': null,
                  'startAt': '2026-04-12T19:00:00Z',
                },
              ]),
              200,
            );
          }),
          baseUrl: 'http://example.com',
        );

        final events = await repository.fetchEvents();

        expect(events.first.venue, '51.7592, 19.4550');
      },
    );

    test('fetchEvents maps missing categories to empty list', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'id': '11111111-1111-1111-1111-111111111111',
                'name': 'Live music',
                'latitude': 51.7592,
                'longitude': 19.4550,
                'address': 'Piotrkowska 10, Lodz',
                'startAt': '2026-04-12T19:00:00Z',
                'categories': null,
              },
            ]),
            200,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final events = await repository.fetchEvents();

      expect(events.first.categories, isEmpty);
    });

    test('fetchEvent throws on non-200', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async => http.Response('', 500)),
        baseUrl: 'http://example.com',
      );

      expect(
        repository.fetchEvent('id'),
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
              'name': 'Created event',
              'latitude': 51.7592,
              'longitude': 19.4550,
              'startAt': '2026-04-12T19:00:00Z',
            }),
            201,
          );
        }),
        baseUrl: 'http://example.com',
      );

      await repository.createEvent(
        EventRequest(
          name: 'Created event',
          description: 'Open-air concert',
          latitude: 51.7592,
          longitude: 19.4550,
          startAt: DateTime.utc(2026, 4, 12, 19),
          address: 'Piotrkowska 10, Lodz',
        ),
        accessToken: 'access-token',
      );

      expect(body['name'], 'Created event');
      expect(body['description'], 'Open-air concert');
      expect(body['latitude'], 51.7592);
      expect(body['longitude'], 19.455);
      expect(body['address'], 'Piotrkowska 10, Lodz');
      expect(body['startAt'], '2026-04-12T19:00:00.000Z');
    });

    test(
      'setEventThumbnail uses the documented media thumbnail endpoint',
      () async {
        late http.Request capturedRequest;
        final repository = HttpEventRepository(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response('', 204);
          }),
          baseUrl: 'http://example.com',
        );

        await repository.setEventThumbnail(
          '11111111-1111-1111-1111-111111111111',
          '22222222-2222-2222-2222-222222222222',
          accessToken: 'access-token',
        );

        expect(capturedRequest.method, 'PUT');
        expect(
          capturedRequest.url.path,
          '/api/events/11111111-1111-1111-1111-111111111111/media/22222222-2222-2222-2222-222222222222/thumbnail',
        );
      },
    );

    test('fetchEvent maps organizer usernames from backend objects', () async {
      final repository = HttpEventRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'id': '11111111-1111-1111-1111-111111111111',
              'name': 'Created event',
              'latitude': 51.7592,
              'longitude': 19.4550,
              'startAt': '2026-04-12T19:00:00Z',
              'organizers': [
                {
                  'userId': '33333333-3333-3333-3333-333333333333',
                  'username': 'alice',
                },
              ],
            }),
            200,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final event = await repository.fetchEvent(
        '11111111-1111-1111-1111-111111111111',
      );

      expect(event.organizers, ['alice']);
    });
  });
}
