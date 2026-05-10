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
          body: EventDetailsInfo(
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
    );

    expect(find.text('Show on map'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);

    await tester.tap(find.text('Show on map'));
    await tester.pump();
    expect(mapPressed, isTrue);

    await tester.tap(find.text('Join'));
    await tester.pump();
    expect(joinPressed, isTrue);
  });
}

final _event = ExploreEvent(
  id: '11111111-1111-1111-1111-111111111111',
  title: 'Jazz Evening',
  categories: [Category(id: 'music', name: 'Music', slug: 'music')],
  startsAt: DateTime.utc(2026, 4, 12, 19),
  venue: 'Piotrkowska 10, Lodz',
  location: LatLng(51.7592, 19.4550),
  description: 'Live music and open-air atmosphere.',
  address: 'Piotrkowska 10, Lodz',
);
