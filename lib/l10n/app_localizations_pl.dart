// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Locario';

  @override
  String get localeEnglish => 'Angielski';

  @override
  String get localePolish => 'Polski';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabHub => 'Hub';

  @override
  String get tabProfile => 'Profile';

  @override
  String get headerMap => 'Mapa';

  @override
  String get headerList => 'Lista';

  @override
  String get hubTitle => 'Hub';

  @override
  String get hubDescription => 'Skróty do tworzenia i ogarniania Twojej lokalnej społeczności';

  @override
  String get hubCreateEventTitle => 'Create event';

  @override
  String get hubCreateEventSubtitle => 'Start something new';

  @override
  String get hubCommunityTitle => 'Community';

  @override
  String get hubCommunitySubtitle => 'Local updates';

  @override
  String get hubFriendsTitle => 'Friends';

  @override
  String get hubFriendsSubtitle => 'Your network';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDescription => 'Konto, preferencje i zapisane miejsca w jednej spokojniejszej sekcji.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsSubtitle => 'Język, preferencje i podstawy aplikacji';

  @override
  String get settingsScreenTitle => 'Ustawienia';

  @override
  String get settingsScreenDescription => 'Tu możesz ogarnąć podstawy aplikacji, zanim sekcja ustawień bardziej urośnie.';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedSubtitle => 'Miejsca, wydarzenia i listy, do których chcesz wrócić';

  @override
  String get languageSectionTitle => 'Język';

  @override
  String get languageSectionSubtitle => 'Wybierz, w jakim języku aplikacja ma z Tobą rozmawiać';

  @override
  String get exploreSearchHint => 'Szukaj wydarzeń...';

  @override
  String get exploreNearbyEvents => 'Wydarzenia w pobliżu';

  @override
  String exploreNearbyWithFilter(String filter) {
    return '$filter w pobliżu';
  }

  @override
  String resultsCount(int count) {
    return '$count wyników';
  }

  @override
  String get sortTooltip => 'Sortowanie';

  @override
  String get sortDistance => 'Odległość';

  @override
  String get sortSoonest => 'Najbliższy termin';

  @override
  String get sortTrending => 'Popularność';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterMusic => 'Muzyka';

  @override
  String get filterArt => 'Sztuka';

  @override
  String get filterWorkshops => 'Warsztaty';

  @override
  String get filterFood => 'Food';

  @override
  String get areaMyLocation => 'Moja lokalizacja';

  @override
  String get areaMyLocationDescription => 'Domyślnie wydarzenia najbliżej Ciebie';

  @override
  String get areaWarsawCenter => 'Centrum Warszawy';

  @override
  String get areaWarsawCenterDescription => 'Adres lub pin ustawiony ręcznie';

  @override
  String get areaPowisle => 'Powiśle';

  @override
  String get areaPowisleDescription => 'Okolice bulwarów i mostu Poniatowskiego';

  @override
  String get areaMokotow => 'Mokotów';

  @override
  String get areaMokotowDescription => 'Rejon Pole Mokotowskie i okolice';

  @override
  String get eventJazzTitle => 'Jazz w Ogrodzie Botanicznym';

  @override
  String get eventSketchingTitle => 'Noc szkicowania nad Wisłą';

  @override
  String get eventRunClubTitle => 'Poranny run club i coffee stop';

  @override
  String get eventStreetFoodTitle => 'Street food i vinyl market';

  @override
  String get eventToday2030 => 'Dziś, 20:30';

  @override
  String get eventToday1900 => 'Dziś, 19:00';

  @override
  String get eventTomorrow0800 => 'Jutro, 08:00';

  @override
  String get eventTomorrow1200 => 'Jutro, 12:00';

  @override
  String get venueBotanicalGarden => 'Ogród Botaniczny';

  @override
  String get venueVistulaBoulevards => 'Bulwary Wiślane';

  @override
  String get venuePoleMokotowskie => 'Pole Mokotowskie';

  @override
  String get venueHalaKoszyki => 'Hala Koszyki';

  @override
  String distanceMeters(int count) {
    return '$count m';
  }

  @override
  String distanceKilometers(String count) {
    return '$count km';
  }

  @override
  String get mapReturnToLocation => 'Wróć do mojej lokalizacji';

  @override
  String mapStyleLoadFailed(String error) {
    return 'Nie udało się wczytać lokalnego stylu mapy.\n$error';
  }

  @override
  String get mapRetry => 'Ponów';

  @override
  String get mapAppSettings => 'Ustawienia aplikacji';

  @override
  String get mapLocationSettings => 'Ustawienia lokalizacji';

  @override
  String get mapServiceDisabled => 'Włącz usługi lokalizacji, aby zobaczyć swoją pozycję.';

  @override
  String get mapPermissionDenied => 'Pozwól na dostęp do lokalizacji, aby wycentrować mapę na Tobie.';

  @override
  String get mapPermissionDeniedForever => 'Dostęp do lokalizacji jest zablokowany w ustawieniach systemu.';

  @override
  String get mapUnableDetermineLocation => 'Nie udało się ustalić Twojej lokalizacji.';

  @override
  String get mapLocationTimeout => 'Żądanie lokalizacji przekroczyło limit czasu. Spróbuj ponownie.';

  @override
  String get mapUnableLoadLocation => 'Nie udało się wczytać Twojej lokalizacji.';
}
