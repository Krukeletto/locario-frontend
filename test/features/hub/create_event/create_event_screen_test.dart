import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/hub/create_event/create_event_screen.dart';
import 'package:locario/shared/events/category_controller.dart';
import 'package:locario/shared/events/category_scope.dart';

import '../../../test_helpers/fake_event_repository.dart';
import '../../../test_helpers/fake_location_service.dart';
import '../../../test_helpers/test_app.dart';

const List<int> _transparentImageBytes = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0x00,
  0x00,
  0x03,
  0x01,
  0x01,
  0x00,
  0x18,
  0xDD,
  0x8D,
  0xB1,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

Future<void> _pumpCreateEventScreen(
  WidgetTester tester, {
  FakeEventRepository? repository,
  FakeLocationService? locationService,
  Future<CreateEventPickedFile?> Function()? pickImageFile,
  bool canSubmit = true,
}) async {
  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Pre-load a CategoryController with PL-named categories matching test assertions.
  final fakeRepo = FakeEventRepository(
    categories: const [
      Category(id: 'music', name: 'Muzyka', slug: 'music'),
      Category(id: 'workshops', name: 'Warsztaty', slug: 'workshops'),
    ],
  );
  final categoryController = CategoryController(eventRepository: fakeRepo);
  await categoryController.loadCategories();

  await tester.pumpWidget(
    buildLocalizedTestApp(
      locale: const Locale('pl'),
      home: CategoryScope(
        controller: categoryController,
        child: CreateEventScreen(
          eventRepository: repository ?? FakeEventRepository(),
          locationService: locationService ?? FakeLocationService(),
          pickImageFile: pickImageFile,
          canSubmit: canSubmit,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CreateEventScreen', () {
    testWidgets('renders core create event sections', (tester) async {
      await _pumpCreateEventScreen(tester);

      expect(find.text('Dodaj zdjęcie główne'), findsOneWidget);
      expect(find.text('Sugerowany rozmiar: 1600 x 900 px'), findsOneWidget);
      expect(find.text('Nazwa wydarzenia'), findsOneWidget);
      expect(find.text('Kategoria'), findsOneWidget);
      expect(find.text('Bilety i wstęp'), findsOneWidget);
      expect(
        find.byKey(const Key('create-event-location-button')),
        findsOneWidget,
      );
    });

    testWidgets('disables submit when auth guard is off', (tester) async {
      await _pumpCreateEventScreen(tester, canSubmit: false);

      final button = tester.widget<FilledButton>(
        find.byType(FilledButton).last,
      );

      expect(button.onPressed, isNull);
      expect(
        find.text(
          'Tworzenie wydarzeń jest tymczasowo wyłączone, dopóki logowanie nie zostanie podpięte w aplikacji.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens location picker options', (tester) async {
      await _pumpCreateEventScreen(tester);

      await tester.tap(find.byKey(const Key('create-event-location-button')));
      await tester.pumpAndSettle();

      expect(find.text('Moja lokalizacja'), findsWidgets);
      expect(find.text('Wpisz adres'), findsOneWidget);
      expect(find.text('Wskaż na mapie'), findsOneWidget);
    });

    testWidgets('shows selected current location after picking it', (
      tester,
    ) async {
      await _pumpCreateEventScreen(
        tester,
        locationService: FakeLocationService(
          currentLocation: const LatLng(51.7592, 19.4550),
        ),
      );

      await tester.tap(find.byKey(const Key('create-event-location-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moja lokalizacja').first);
      await tester.pumpAndSettle();

      expect(find.text('Moja lokalizacja'), findsOneWidget);
      expect(find.textContaining('51.7592'), findsOneWidget);
      expect(find.textContaining('19.4550'), findsOneWidget);
    });

    testWidgets(
      'shows loading state while current location is being resolved',
      (tester) async {
        await _pumpCreateEventScreen(
          tester,
          locationService: FakeLocationService(
            currentLocation: const LatLng(51.7592, 19.4550),
            currentLocationDelay: const Duration(milliseconds: 300),
          ),
        );

        await tester.tap(find.byKey(const Key('create-event-location-button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Moja lokalizacja').first);
        await tester.pump();

        expect(find.text('Pobieramy Twoją lokalizację'), findsOneWidget);
        expect(find.text('To może potrwać chwilę.'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('Moja lokalizacja'), findsOneWidget);
      },
    );

    testWidgets(
      'shows location validation when submit without choosing location',
      (tester) async {
        await _pumpCreateEventScreen(tester);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Wieczór planszówek',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Spotykamy się na wspólne granie i integrację.',
        );

        await _pickDate(tester);
        await _pickTime(tester);
        await tester.tap(find.text('Muzyka'));
        await tester.pumpAndSettle();

        final submitButton = find.text('Stwórz wydarzenie');
        await tester.tap(submitButton.first);
        await tester.pump();

        expect(find.text('Wybierz lokalizację wydarzenia.'), findsOneWidget);
      },
    );

    testWidgets(
      'shows category validation when submit without choosing category',
      (tester) async {
        await _pumpCreateEventScreen(
          tester,
          locationService: FakeLocationService(
            currentLocation: const LatLng(51.7592, 19.4550),
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Wieczór planszówek',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Spotykamy się na wspólne granie i integrację.',
        );

        await _pickDate(tester);
        await _pickTime(tester);

        await tester.tap(find.byKey(const Key('create-event-location-button')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Moja lokalizacja').first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Stwórz wydarzenie').first);
        await tester.pump();

        expect(
          find.text('Wybierz co najmniej jedną kategorię.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('creates event with current location', (tester) async {
      final repository = FakeEventRepository();
      await _pumpCreateEventScreen(
        tester,
        repository: repository,
        locationService: FakeLocationService(
          currentLocation: const LatLng(51.7592, 19.4550),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Koncert');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Wieczorny koncert i spotkanie społeczności.',
      );

      await _pickDate(tester);
      await _pickTime(tester);
      await tester.tap(find.text('Warsztaty'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('create-event-location-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moja lokalizacja').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stwórz wydarzenie').first);
      await tester.pump();

      expect(repository.lastCreateInput, isNotNull);
      expect(repository.lastCreateInput!.name, 'Koncert');
      expect(repository.lastCreateInput!.latitude, closeTo(51.7592, 0.0001));
      expect(repository.lastCreateInput!.categoryIds, ['workshops']);
    });

    testWidgets('uploads selected image after creating the event', (
      tester,
    ) async {
      final repository = FakeEventRepository();
      await _pumpCreateEventScreen(
        tester,
        repository: repository,
        locationService: FakeLocationService(
          currentLocation: const LatLng(51.7592, 19.4550),
        ),
        pickImageFile: () async => const CreateEventPickedFile(
          bytes: _transparentImageBytes,
          fileName: 'poster.jpg',
        ),
      );

      await tester.tap(find.byKey(const Key('create-event-image-picker')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Koncert');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Wieczorny koncert i spotkanie społeczności.',
      );

      await _pickDate(tester);
      await _pickTime(tester);
      await tester.tap(find.text('Warsztaty'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('create-event-location-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moja lokalizacja').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stwórz wydarzenie').first);
      await tester.pump();

      expect(repository.lastUploadedEventId, repository.eventDetails.id);
      expect(repository.lastUploadedFileName, 'poster.jpg');
      expect(repository.lastUploadedBytes, _transparentImageBytes);
    });
  });
}

Future<void> _pickDate(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('create-event-date-picker')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _pickTime(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('create-event-time-picker')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}
