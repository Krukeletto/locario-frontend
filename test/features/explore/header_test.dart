import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/explore/widgets/header.dart';

import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('selecting search result calls callback with tapped event', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'jazz');
    final focusNode = FocusNode();
    ExploreEvent? selectedEvent;
    final event = ExploreEvent(
      id: '1',
      title: 'Jazz Evening',
      categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
      startsAt: DateTime.utc(2026, 4, 12, 19),
      trendingScore: 1,
      venue: 'Piotrkowska 10, Lodz',
      location: const LatLng(51.7592, 19.4550),
      address: 'Piotrkowska 10, Lodz',
    );

    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: Scaffold(
          appBar: ExploreHeader(
            searchController: controller,
            searchFocusNode: focusNode,
            onFilterPressed: () {},
            includeTopInset: false,
            searchResults: [event],
            onSearchResultSelected: (value) => selectedEvent = value,
            selectedFilterIndices: const {},
            onFilterToggled: (_) {},
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(find.text('Jazz Evening'), findsOneWidget);
    await tester.tap(find.text('Jazz Evening'));
    await tester.pumpAndSettle();

    expect(selectedEvent?.id, event.id);
  });
}
