import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/events/widgets/info/event_details_info.dart';
import 'package:locario/features/explore/models.dart';

import '../../../../test_helpers/test_app.dart';

void main() {
  testWidgets('renders map action above join button', (tester) async {
    var mapPressed = false;
    var joinPressed = false;

    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventDetailsInfo(
              event: _event,
              overlap: 12,
              onShowOnMapPressed: () {
                mapPressed = true;
              },
              onSavePressed: () {},
              isSaved: false,
              isJoined: false,
              onJoinPressed: () {
                joinPressed = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Show on map'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);

    await tester.tap(find.text('Show on map'));
    await tester.pump();
    expect(mapPressed, isTrue);

    await tester.ensureVisible(find.text('Join'));
    await tester.tap(find.text('Join'));
    await tester.pump();
    expect(joinPressed, isTrue);
  });

  testWidgets('shows separate start and end time labels', (tester) async {
    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventDetailsInfo(
              event: _event,
              overlap: 12,
              onShowOnMapPressed: () {},
              onSavePressed: () {},
              isSaved: false,
              isJoined: false,
              onJoinPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Time'), findsNothing);
  });

  testWidgets('shows end date for multi day events', (tester) async {
    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventDetailsInfo(
              event: _multiDayEvent,
              overlap: 12,
              onShowOnMapPressed: () {},
              onSavePressed: () {},
              isSaved: false,
              isJoined: false,
              onJoinPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('End date'), findsOneWidget);
  });

  testWidgets('hides save and join actions for ended events', (tester) async {
    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventDetailsInfo(
              event: _endedEvent,
              overlap: 12,
              onShowOnMapPressed: () {},
              onSavePressed: () {},
              isSaved: false,
              isJoined: true,
              onJoinPressed: () {},
              onLeavePressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Save event'), findsNothing);
    expect(find.text('Join'), findsNothing);
    expect(find.text('Leave event'), findsNothing);
    expect(find.text('Show on map'), findsOneWidget);
  });

  testWidgets('hides ticket section for invalid ticket urls', (tester) async {
    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EventDetailsInfo(
              event: _eventWithInvalidTicket,
              overlap: 12,
              onShowOnMapPressed: () {},
              onSavePressed: () {},
              isSaved: false,
              isJoined: false,
              onJoinPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tickets'), findsNothing);
    expect(find.text('np.'), findsNothing);
  });
}

final _event = ExploreEvent(
  id: '11111111-1111-1111-1111-111111111111',
  title: 'Jazz Evening',
  categories: [const Category(id: 'music', name: 'Music', slug: 'music')],
  startsAt: DateTime.utc(2026, 6, 12, 19),
  endsAt: DateTime.utc(2026, 6, 12, 21, 30),
  venue: 'Piotrkowska 10, Lodz',
  location: const LatLng(51.7592, 19.4550),
  description: 'Live music and open-air atmosphere.',
  address: 'Piotrkowska 10, Lodz',
);

final _eventWithInvalidTicket = ExploreEvent(
  id: '33333333-3333-3333-3333-333333333333',
  title: 'Jazz Evening',
  categories: [const Category(id: 'music', name: 'Music', slug: 'music')],
  startsAt: DateTime.utc(2026, 6, 12, 19),
  endsAt: DateTime.utc(2026, 6, 12, 21, 30),
  venue: 'Piotrkowska 10, Lodz',
  location: const LatLng(51.7592, 19.4550),
  description: 'Live music and open-air atmosphere.',
  address: 'Piotrkowska 10, Lodz',
  ticketUrl: 'np.',
);

final _multiDayEvent = ExploreEvent(
  id: '44444444-4444-4444-4444-444444444444',
  title: 'Jazz Weekend',
  categories: [const Category(id: 'music', name: 'Music', slug: 'music')],
  startsAt: DateTime.utc(2026, 6, 12, 19),
  endsAt: DateTime.utc(2026, 6, 13, 21, 30),
  venue: 'Piotrkowska 10, Lodz',
  location: const LatLng(51.7592, 19.4550),
  description: 'Live music and open-air atmosphere.',
  address: 'Piotrkowska 10, Lodz',
);

final _endedEvent = ExploreEvent(
  id: '22222222-2222-2222-2222-222222222222',
  title: 'Past Jazz Evening',
  categories: [const Category(id: 'music', name: 'Music', slug: 'music')],
  startsAt: DateTime.utc(2020, 4, 12, 19),
  endsAt: DateTime.utc(2020, 4, 12, 22),
  venue: 'Piotrkowska 10, Lodz',
  location: const LatLng(51.7592, 19.4550),
  description: 'Live music and open-air atmosphere.',
  address: 'Piotrkowska 10, Lodz',
);
