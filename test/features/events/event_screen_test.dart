import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/events/event_screen.dart';
import 'package:locario/shared/events/event_repository.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('EventScreen', () {
    testWidgets('renders info cards for loaded event', (tester) async {
      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: EventScreen(
            eventId: '11111111-1111-1111-1111-111111111111',
            eventRepository: FakeEventRepository(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Jazz Evening'), findsOneWidget);
      expect(find.text('Piotrkowska 10, Lodz'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows loading state before fetch completes', (tester) async {
      final repository = _PendingEventRepository();
      await tester.pumpWidget(
        buildLocalizedTestApp(
          locale: const Locale('pl'),
          home: EventScreen(
            eventId: '11111111-1111-1111-1111-111111111111',
            eventRepository: repository,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ładowanie wydarzenia'), findsOneWidget);

      repository.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state when fetch fails', (tester) async {
      await tester.pumpWidget(
        buildLocalizedTestApp(
          locale: const Locale('pl'),
          home: EventScreen(
            eventId: '11111111-1111-1111-1111-111111111111',
            eventRepository: FakeEventRepository(
              fetchEventError: const EventRepositoryException('boom'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Wydarzenie jest niedostępne'), findsOneWidget);
    });
  });
}

class _PendingEventRepository extends FakeEventRepository {
  final Completer<ExploreEvent> _completer = Completer<ExploreEvent>();

  @override
  Future<ExploreEvent> fetchEvent(String id) => _completer.future;

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete(eventDetails);
    }
  }
}
