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
  String get tabExplore => 'Odkrywaj';

  @override
  String get tabInbox => 'Skrzynka';

  @override
  String get tabHub => 'Hub';

  @override
  String get tabProfile => 'Profil';

  @override
  String get headerMap => 'Mapa';

  @override
  String get headerList => 'Lista';

  @override
  String get hubTitle => 'Hub';

  @override
  String get hubDescription => 'Skróty do tworzenia i ogarniania Twojej lokalnej społeczności';

  @override
  String get hubCreateEventTitle => 'Stwórz wydarzenie';

  @override
  String get hubCreateEventSubtitle => 'Zorganizuj coś fajnego';

  @override
  String get hubCreateEventNameLabel => 'Nazwa wydarzenia';

  @override
  String get hubCreateEventNameHint => 'Jak nazywa się twoje wydarzenie?';

  @override
  String get hubCreateEventCategoryLabel => 'Kategoria';

  @override
  String get hubCreateEventLocationLabel => 'Miejsce';

  @override
  String get hubCreateEventLocationHint => 'Gdzie odbędzie się wydarzenie?';

  @override
  String get hubCreateEventLocationLoadingLabel => 'Pobieramy Twoją lokalizację';

  @override
  String get hubCreateEventLocationLoadingDescription => 'To może potrwać chwilę.';

  @override
  String get hubCreateEventDateLabel => 'Data';

  @override
  String get hubCreateEventDateHint => 'Wybierz datę';

  @override
  String get hubCreateEventDatePlaceholder => 'Wybierz dzień';

  @override
  String get hubCreateEventTimeLabel => 'Godzina';

  @override
  String get hubCreateEventTimeHint => '--:--';

  @override
  String get hubCreateEventTimePlaceholder => 'Wybierz godzinę';

  @override
  String get hubCreateEventDescriptionLabel => 'Opis wydarzenia';

  @override
  String get hubCreateEventDescriptionHint => 'Opowiedz o swoim wydarzeniu...';

  @override
  String get hubCreateEventMainPhotoLabel => 'Dodaj zdjęcie główne';

  @override
  String get hubCreateEventMainPhotoSizeHint => 'Sugerowany rozmiar: 1600 x 900 px';

  @override
  String get hubCreateEventTicketingTitle => 'Bilety i wstęp';

  @override
  String get hubCreateEventTicketingSwitchLabel => 'Włącz bilety i limity miejsc';

  @override
  String get hubCreateEventTicketSeatsLabel => 'Liczba miejsc';

  @override
  String get hubCreateEventTicketPriceLabel => 'Cena biletu';

  @override
  String get hubCreateEventSubmitButton => 'Stwórz wydarzenie';

  @override
  String get hubCreateEventValidationMinChars3 => 'Podaj co najmniej 3 znaki.';

  @override
  String get hubCreateEventValidationRequired => 'To pole jest wymagane.';

  @override
  String get hubCreateEventValidationDescriptionMin10 => 'Opis powinien mieć co najmniej 10 znaków.';

  @override
  String get hubCreateEventValidationCategoryRequired => 'Wybierz co najmniej jedną kategorię.';

  @override
  String get hubCreateEventValidationPositiveNumber => 'Podaj poprawną dodatnią liczbę.';

  @override
  String get hubCreateEventValidationDateTimeRequired => 'Wybierz datę i godzinę wydarzenia.';

  @override
  String get hubCreateEventValidationLocationRequired => 'Wybierz lokalizację wydarzenia.';

  @override
  String get hubCreateEventCreatedSuccess => 'Wydarzenie zostało utworzone.';

  @override
  String get hubCreateEventCreateFailed => 'Nie udało się utworzyć wydarzenia. Spróbuj ponownie.';

  @override
  String get hubCreateEventLocationLookupFailed => 'Nie udało się ustalić lokalizacji. Spróbuj wpisać inny adres lub wskaż punkt na mapie.';

  @override
  String get hubCommunityTitle => 'Społeczność';

  @override
  String get hubCommunitySubtitle => 'Lokalne aktualizacje';

  @override
  String get hubFriendsTitle => 'Znajomi';

  @override
  String get hubFriendsSubtitle => 'Twoja sieć';

  @override
  String get profileTitle => 'Profil';

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
  String get savedTitle => 'Zapisane';

  @override
  String get savedSubtitle => 'Miejsca, wydarzenia i listy, do których chcesz wrócić';

  @override
  String get languageSectionTitle => 'Język';

  @override
  String get languageSectionSubtitle => 'Wybierz, w jakim języku aplikacja ma z Tobą rozmawiać';

  @override
  String get themeSectionTitle => 'Wygląd';

  @override
  String get themeSectionSubtitle => 'Wybierz, czy aplikacja ma podążać za systemem czy trzymać stały motyw';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Jasny';

  @override
  String get themeModeDark => 'Ciemny';

  @override
  String get exploreSearchHint => 'Szukaj wydarzeń...';

  @override
  String get exploreNearbyEvents => 'Wydarzenia w pobliżu';

  @override
  String exploreNearbyWithFilter(String filter) {
    return '$filter w pobliżu';
  }

  @override
  String get exploreLoadingTitle => 'Ładowanie wydarzeń';

  @override
  String get exploreLoadingSubtitle => 'Pobieramy najnowsze wydarzenia z backendu.';

  @override
  String get exploreErrorTitle => 'Wydarzenia są niedostępne';

  @override
  String get exploreErrorSubtitle => 'Nie udało się teraz pobrać wydarzeń.';

  @override
  String get exploreEmptyTitle => 'Brak wydarzeń';

  @override
  String get exploreEmptySubtitle => 'Spróbuj zmienić obszar albo wróć później.';

  @override
  String get exploreRetryButton => 'Spróbuj ponownie';

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
  String get distanceFilterTooltip => 'Zasięg listy';

  @override
  String get distanceFilterAny => 'Wszędzie';

  @override
  String distanceFilterWithinKm(int km) {
    return 'Do $km km';
  }

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterMusic => 'Muzyka';

  @override
  String get filterArt => 'Sztuka';

  @override
  String get filterWorkshops => 'Warsztaty';

  @override
  String get filterFood => 'Jedzenie';

  @override
  String get areaMyLocation => 'Moja lokalizacja';

  @override
  String get areaMyLocationDescription => 'Domyślnie wydarzenia najbliżej Ciebie';

  @override
  String get areaTypedAddressDescription => 'Adres wpisany ręcznie';

  @override
  String get areaPinnedOnMap => 'Punkt na mapie';

  @override
  String get areaPickerTitle => 'Wybierz obszar';

  @override
  String get areaPickerSubtitle => 'Możesz wpisać adres, wskazać punkt na mapie albo wrócić do bieżącej lokalizacji.';

  @override
  String get areaUseCurrentLocation => 'Moja lokalizacja';

  @override
  String get areaUseCurrentLocationSubtitle => 'Użyj Twojej aktualnej pozycji jako punktu odniesienia';

  @override
  String get areaEnterAddress => 'Wpisz adres';

  @override
  String get areaEnterAddressSubtitle => 'Podaj ulicę, dzielnicę albo konkretne miejsce';

  @override
  String get areaPickOnMap => 'Wskaż na mapie';

  @override
  String get areaPickOnMapTitle => 'Wskaż punkt na mapie';

  @override
  String get areaPickOnMapSubtitle => 'Przesuń mapę tak, aby wybrany punkt był pod znacznikiem na środku.';

  @override
  String get areaPickOnMapConfirm => 'Użyj tego punktu';

  @override
  String get areaAddressDialogTitle => 'Wpisz adres';

  @override
  String get areaAddressDialogHint => 'Np. Stary Rynek 12, Poznań';

  @override
  String get areaAddressNotFound => 'Nie udało się znaleźć tego adresu.';

  @override
  String get areaAddressLookupFailed => 'Nie udało się wyszukać adresu. Spróbuj ponownie.';

  @override
  String get areaDialogCancel => 'Anuluj';

  @override
  String get areaDialogConfirm => 'Gotowe';

  @override
  String areaPinnedCoordinates(String lat, String lon) {
    return '$lat, $lon';
  }

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
  String get eventDetailsScreenTitle => 'Szczegóły wydarzenia';

  @override
  String get eventDetailsImagePlaceholder => 'Tymczasowy placeholder zdjęcia';

  @override
  String get eventDetailsTitleLabel => 'Tytuł wydarzenia';

  @override
  String get eventDetailsLocationLabel => 'Lokalizacja';

  @override
  String get eventDetailsDateLabel => 'Data';

  @override
  String get eventDetailsTimeLabel => 'Godzina';

  @override
  String get eventDetailsPriceLabel => 'Cena';

  @override
  String get eventDetailsSeatsLabel => 'Liczba miejsc';

  @override
  String get eventDetailsAboutLabel => 'O wydarzeniu';

  @override
  String get eventDetailsOrganizerLabel => 'Organizator';

  @override
  String get eventDetailsChatLabel => 'Czat uczestników';

  @override
  String get eventDetailsBuyTicketButton => 'Kup bilet';

  @override
  String get eventDetailsJoinButton => 'Zapisz się';

  @override
  String get eventDetailsUnknownEventTitle => 'Wydarzenie';

  @override
  String get eventDetailsUnknownLocation => 'Lokalizacja nieznana';

  @override
  String get eventDetailsFallbackDescription => 'To tymczasowy opis wydarzenia. W kolejnych krokach podepniemy pełne dane z formularza tworzenia wydarzenia i backendu.';

  @override
  String get eventDetailsLoadingTitle => 'Ładowanie wydarzenia';

  @override
  String get eventDetailsLoadingSubtitle => 'Pobieramy szczegóły wydarzenia z backendu.';

  @override
  String get eventDetailsErrorTitle => 'Wydarzenie jest niedostępne';

  @override
  String get eventDetailsErrorSubtitle => 'Nie udało się teraz wczytać tego wydarzenia.';

  @override
  String get eventDetailsJazzDescription => 'Wieczorny koncert jazzowy pod otwartym niebem. Zabierz znajomych, koc i dobry humor.';

  @override
  String get eventDetailsSketchingDescription => 'Spotkanie dla osób lubiących szkicowanie i ilustracje miejskie. Materiały we własnym zakresie.';

  @override
  String get eventDetailsRunClubDescription => 'Lekki poranny bieg, potem wspólna kawa i networking. Tempo konwersacyjne, każdy mile widziany.';

  @override
  String get eventDetailsStreetFoodDescription => 'Street food, selekcja płyt winylowych i mini sety DJ-skie. Wydarzenie całodzienne.';

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

  @override
  String mapClusterSheetTitle(int count) {
    return 'Wybierz wydarzenie ($count)';
  }

  @override
  String mapEventOpenSoon(String title) {
    return 'Ekran wydarzenia „$title” dodamy później.';
  }
}
