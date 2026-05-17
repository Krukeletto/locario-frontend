// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get authSubtitle => 'Odkryj lokalne perełki w Twojej okolicy';

  @override
  String get authGoogleContinue => 'Kontynuuj przez Google';

  @override
  String get authDividerOr => 'LUB';

  @override
  String get authEmailLabel => 'E-MAIL';

  @override
  String get authEmailHint => 'twoj@email.pl';

  @override
  String get authPasswordLabel => 'HASŁO';

  @override
  String get authPasswordHint => '********';

  @override
  String get authFooterTerms => 'REGULAMIN';

  @override
  String get authFooterPrivacy => 'PRYWATNOŚĆ';

  @override
  String get authFooterHelp => 'POMOC';

  @override
  String get authLoginWelcome => 'Witaj ponownie';

  @override
  String get authLoginSubmit => 'Zaloguj się';

  @override
  String get authLoginNoAccount => 'Nie masz jeszcze konta?';

  @override
  String get authLoginCreateAccount => 'Utwórz darmowe konto';

  @override
  String get authLogoutSuccess => 'Wylogowano pomyślnie.';

  @override
  String get authLoginSuccess => 'Zalogowano pomyślnie.';

  @override
  String get authLoginErrorInvalidCredentials => 'Błędny e-mail lub hasło.';

  @override
  String get authRegisterWelcome => 'Witaj';

  @override
  String get authRegisterUsernameLabel => 'NAZWA UŻYTKOWNIKA';

  @override
  String get authRegisterUsernameHint => 'twoja nazwa uzytkownika';

  @override
  String get authRegisterSubmit => 'Zarejestruj się';

  @override
  String get authRegisterHasAccount => 'Masz już konto?';

  @override
  String get authRegisterSignIn => 'Zaloguj się na konto';

  @override
  String get authValidationUsernameRequired => 'Podaj nazwę użytkownika';

  @override
  String get authValidationUsernameMin3 =>
      'Nazwa użytkownika musi mieć min. 3 znaki';

  @override
  String get authValidationUsernameAllowed => 'Dozwolone: litery, cyfry, . _ -';

  @override
  String get authValidationEmailRequired => 'Podaj adres e-mail';

  @override
  String get authValidationEmailInvalid => 'Podaj poprawny adres e-mail';

  @override
  String get authValidationPasswordRequired => 'Podaj hasło';

  @override
  String get authValidationPasswordMin8 => 'Hasło musi mieć min. 8 znaków';

  @override
  String get eventJazzTitle => 'Jazz w Ogrodzie Botanicznym';

  @override
  String get eventSketchingTitle => 'Noc szkicowania nad Wisłą';

  @override
  String get eventRunClubTitle => 'Poranny run club i coffee stop';

  @override
  String get eventStreetFoodTitle => 'Street food i vinyl market';

  @override
  String get eventDetailsScreenTitle => 'Szczegóły';

  @override
  String get eventDetailsImagePlaceholder => 'Tymczasowy placeholder zdjęcia';

  @override
  String get eventDetailsTitleLabel => 'Tytuł wydarzenia';

  @override
  String get eventDetailsLocationLabel => 'Lokalizacja';

  @override
  String get eventDetailsDateLabel => 'Data';

  @override
  String get eventDetailsEndDateLabel => 'Data końca';

  @override
  String get eventDetailsStartTimeLabel => 'Start';

  @override
  String get eventDetailsEndTimeLabel => 'Koniec';

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
  String get eventOrganizerRatingLabel => 'Ocena organizatora';

  @override
  String eventOrganizerRatingValue(String average, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opinii',
      many: '$count opinii',
      few: '$count opinie',
      one: '1 opinia',
    );
    return '$average/5 · $_temp0';
  }

  @override
  String get eventOrganizerRatingEmpty => 'Brak opinii o organizatorze';

  @override
  String get eventDetailsBuyTicketButton => 'Kup bilet';

  @override
  String get eventDetailsJoinButton => 'Zapisz się';

  @override
  String get eventDetailsLeaveButton => 'Opuść wydarzenie';

  @override
  String get eventDetailsReviewButton => 'Wystaw opinię';

  @override
  String get eventJoinSuccess => 'Zapisano na wydarzenie.';

  @override
  String get eventLeaveSuccess => 'Opuściłeś/aś wydarzenie.';

  @override
  String get eventJoinError => 'Nie udało się zapisać na wydarzenie.';

  @override
  String get eventJoinRequiresLogin =>
      'Zaloguj się, aby zapisać się na wydarzenie.';

  @override
  String get eventDetailsUnknownEventTitle => 'Wydarzenie';

  @override
  String get eventDetailsUnknownLocation => 'Lokalizacja nieznana';

  @override
  String get eventDetailsFallbackDescription =>
      'To tymczasowy opis wydarzenia. W kolejnych krokach podepniemy pełne dane z formularza tworzenia wydarzenia i backendu.';

  @override
  String get eventDetailsLoadingTitle => 'Ładowanie wydarzenia';

  @override
  String get eventDetailsLoadingSubtitle =>
      'Pobieramy szczegóły wydarzenia z backendu.';

  @override
  String get eventDetailsErrorTitle => 'Wydarzenie jest niedostępne';

  @override
  String get eventDetailsErrorSubtitle =>
      'Nie udało się teraz wczytać tego wydarzenia.';

  @override
  String get eventReviewScreenTitle => 'Wystaw opinię';

  @override
  String get eventReviewLoadingTitle => 'Ładowanie opinii';

  @override
  String get eventReviewLoadingSubtitle =>
      'Przygotowujemy formularz opinii i szczegóły wydarzenia.';

  @override
  String get eventReviewErrorTitle => 'Opinia jest niedostępna';

  @override
  String get eventReviewErrorSubtitle =>
      'Nie udało się teraz wczytać ekranu opinii.';

  @override
  String get eventReviewFormTitle => 'Twoja opinia';

  @override
  String get eventReviewFormSubtitle =>
      'Wybierz ocenę i dodaj opcjonalny komentarz.';

  @override
  String get eventReviewLockedSubtitle =>
      'Możesz wystawić opinię po zakończeniu wydarzenia i tylko jeśli do niego dołączyłeś/aś.';

  @override
  String get eventReviewCommentLabel => 'Komentarz';

  @override
  String get eventReviewCommentHint => 'Co zrobiło wrażenie?';

  @override
  String get eventReviewSubmitButton => 'Wyślij opinię';

  @override
  String get eventReviewSubmittedButton => 'Opinia wysłana';

  @override
  String get eventReviewSubmittedLabel => 'Twoja opinia została zapisana.';

  @override
  String get eventReviewEligibilityHint =>
      'Opinię mogą wystawić tylko uczestnicy po zakończeniu wydarzenia.';

  @override
  String get eventReviewSuccess => 'Opinia została wysłana.';

  @override
  String get eventReviewError => 'Nie udało się wysłać opinii.';

  @override
  String get eventDetailsJazzDescription =>
      'Wieczorny koncert jazzowy pod otwartym niebem. Zabierz znajomych, koc i dobry humor.';

  @override
  String get eventDetailsSketchingDescription =>
      'Spotkanie dla osób lubiących szkicowanie i ilustracje miejskie. Materiały we własnym zakresie.';

  @override
  String get eventDetailsRunClubDescription =>
      'Lekki poranny bieg, potem wspólna kawa i networking. Tempo konwersacyjne, każdy mile widziany.';

  @override
  String get eventDetailsStreetFoodDescription =>
      'Street food, selekcja płyt winylowych i mini sety DJ-skie. Wydarzenie całodzienne.';

  @override
  String get eventDetailsTicketLabel => 'Bilety';

  @override
  String get eventDetailsSlotsLabel => 'Limit miejsc';

  @override
  String eventDetailsSlotsValue(int count) {
    return '$count wolnych miejsc';
  }

  @override
  String eventSlotsTaken(int registered, int limit) {
    return '$registered / $limit zajętych';
  }

  @override
  String eventSlotsJoined(int count) {
    return '$count dołączyło';
  }

  @override
  String get eventSlotsSoldOut => 'Brak miejsc';

  @override
  String eventSlotsWaitlist(int count) {
    return '$count na liście rezerwowej';
  }

  @override
  String eventCardSpots(int count) {
    return '$count miejsc';
  }

  @override
  String get eventDetailsShowOnMapButton => 'Pokaż na mapie';

  @override
  String get eventDetailsOpenMapError =>
      'Nie udało się teraz otworzyć aplikacji map.';

  @override
  String get eventToday2030 => 'Dziś, 20:30';

  @override
  String get eventToday1900 => 'Dziś, 19:00';

  @override
  String get eventTomorrow0800 => 'Jutro, 08:00';

  @override
  String get eventTomorrow1200 => 'Jutro, 12:00';

  @override
  String get eventSaveSuccess => 'Wydarzenie zapisano na Twojej liście.';

  @override
  String get eventRemoveSuccess => 'Wydarzenie usunięto z Twojej listy.';

  @override
  String get eventPublishSuccess => 'Wydarzenie zostało opublikowane.';

  @override
  String get eventPublishError =>
      'Nie udało się opublikować wydarzenia. Spróbuj ponownie.';

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
  String get exploreLoadingSubtitle =>
      'Pobieramy najnowsze wydarzenia, poczekaj chwilkę.';

  @override
  String get exploreErrorTitle => 'Wydarzenia są niedostępne';

  @override
  String get exploreErrorSubtitle => 'Nie udało się teraz pobrać wydarzeń.';

  @override
  String get exploreEmptyTitle => 'Brak wydarzeń';

  @override
  String get exploreEmptySubtitle =>
      'Spróbuj zmienić obszar albo wróć później.';

  @override
  String get exploreRetryButton => 'Spróbuj ponownie';

  @override
  String get exploreErrorPermissionTitle => 'Wymagany dostęp do lokalizacji';

  @override
  String get exploreErrorPermissionSubtitle =>
      'Zezwól na dostęp do lokalizacji, aby zobaczyć wydarzenia w pobliżu.';

  @override
  String get exploreErrorUnknownTitle => 'Coś poszło nie tak';

  @override
  String get exploreErrorUnknownSubtitle => 'Wystąpił nieoczekiwany błąd.';

  @override
  String get exploreSearchThisArea => 'Przeszukaj ten obszar';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wyniku',
      many: '$count wyników',
      few: '$count wyniki',
      one: '1 wynik',
      zero: '0 wyników',
    );
    return '$_temp0';
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
  String get filterAdvancedFilters => 'Filtry zaawansowane';

  @override
  String get filterAdvancedDistance => 'Zasięg wyszukiwania';

  @override
  String get filterAdvancedDateRange => 'Data wydarzenia';

  @override
  String get filterAdvancedAge => 'Wiek (lata)';

  @override
  String get filterAdvancedType => 'Typ wydarzenia';

  @override
  String get filterAdvancedSource => 'Źródło wydarzenia';

  @override
  String get filterAdvancedApply => 'Pokaż wyniki';

  @override
  String get filterAdvancedClear => 'Wyczyść';

  @override
  String get filterAdvancedDateFrom => 'Od';

  @override
  String get filterAdvancedDateTo => 'Do';

  @override
  String get filterAdvancedDateAny => 'Dowolna data';

  @override
  String get filterAdvancedDateToday => 'Dziś';

  @override
  String get filterAdvancedDateTomorrow => 'Jutro';

  @override
  String get filterAdvancedDateCustomRange => 'Zakres dat';

  @override
  String get filterAdvancedDateOther => 'Inna data';

  @override
  String get filterAdvancedDateSelection => 'Wybrana data';

  @override
  String get filterAdvancedAgeFrom => 'Min';

  @override
  String get filterAdvancedAgeTo => 'Max';

  @override
  String get filterAdvancedAgeSelection => 'Wiek uczestnika';

  @override
  String get filterAdvancedAgeCustomRange => 'Przedział wieku';

  @override
  String get filterAdvancedAgeOther => 'Inny wiek';

  @override
  String filterAdvancedAgeRangeSummary(int from, int to) {
    return '$from–$to lat';
  }

  @override
  String get areaMyLocation => 'Moja lokalizacja';

  @override
  String get areaMyLocationDescription =>
      'Domyślnie wydarzenia najbliżej Ciebie';

  @override
  String get areaTypedAddressDescription => 'Adres wpisany ręcznie';

  @override
  String get areaPinnedOnMap => 'Punkt na mapie';

  @override
  String get areaPickerTitle => 'Wybierz obszar';

  @override
  String get areaPickerSubtitle =>
      'Możesz wpisać adres, wskazać punkt na mapie albo wrócić do bieżącej lokalizacji.';

  @override
  String get areaUseCurrentLocation => 'Moja lokalizacja';

  @override
  String get areaUseCurrentLocationSubtitle =>
      'Użyj Twojej aktualnej pozycji jako punktu odniesienia';

  @override
  String get areaEnterAddress => 'Wpisz adres';

  @override
  String get areaEnterAddressSubtitle =>
      'Podaj ulicę, dzielnicę albo konkretne miejsce';

  @override
  String get areaPickOnMap => 'Wskaż na mapie';

  @override
  String get areaPickOnMapTitle => 'Wskaż punkt na mapie';

  @override
  String get areaPickOnMapSubtitle =>
      'Przesuń mapę tak, aby wybrany punkt był pod znacznikiem na środku.';

  @override
  String get areaPickOnMapConfirm => 'Użyj tego punktu';

  @override
  String get areaAddressDialogTitle => 'Wpisz adres';

  @override
  String get areaAddressDialogHint => 'Np. Stary Rynek 12, Poznań';

  @override
  String get areaAddressNotFound => 'Nie udało się znaleźć tego adresu.';

  @override
  String get areaAddressLookupFailed =>
      'Nie udało się wyszukać adresu. Spróbuj ponownie.';

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
  String get areaPowisleDescription =>
      'Okolice bulwarów i mostu Poniatowskiego';

  @override
  String get areaMokotow => 'Mokotów';

  @override
  String get areaMokotowDescription => 'Rejon Pole Mokotowskie i okolice';

  @override
  String get hubTitle => 'Hub';

  @override
  String get hubDescription =>
      'Skróty do tworzenia i ogarniania Twojej lokalnej społeczności';

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
  String get hubCreateEventLocationLoadingLabel =>
      'Pobieramy Twoją lokalizację';

  @override
  String get hubCreateEventLocationLoadingDescription =>
      'To może potrwać chwilę.';

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
  String get hubCreateEventPhotosLabel => 'Dodaj zdjęcia';

  @override
  String get hubCreateEventMainPhotoSizeHint =>
      'Sugerowany rozmiar: 1600 x 900 px';

  @override
  String hubCreateEventSelectedPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wybranego zdjęcia',
      many: '$count wybranych zdjęć',
      few: '$count wybrane zdjęcia',
      one: '1 wybrane zdjęcie',
      zero: 'Brak zdjęć',
    );
    return '$_temp0';
  }

  @override
  String get hubCreateEventPrimaryPhotoHint =>
      'Zdjęcie główne (miniatura). Przeciągnij inne zdjęcie na początek, aby je ustawić.';

  @override
  String get hubCreateEventSecondaryPhotoHint =>
      'Dodatkowe zdjęcie. Przeciągnij, aby zmienić kolejność.';

  @override
  String get hubCreateEventTicketingTitle => 'Bilety i wstęp';

  @override
  String get hubCreateEventTicketingSwitchLabel =>
      'Włącz bilety i limity miejsc';

  @override
  String get hubCreateEventTicketSeatsLabel => 'Liczba miejsc';

  @override
  String get hubCreateEventTicketPriceLabel => 'Cena biletu';

  @override
  String get hubCreateEventTicketingLabel => 'Bilety i wstęp';

  @override
  String get hubCreateEventTicketUrlHint => 'Link do zakupu biletów';

  @override
  String get hubCreateEventStatusLabel => 'Status wydarzenia';

  @override
  String get eventStatusDraft => 'Szkic';

  @override
  String get eventStatusPublished => 'Live';

  @override
  String get hubCreateEventSubmitButton => 'Stwórz wydarzenie';

  @override
  String get hubCreateEventSubmitDisabledHint =>
      'Tworzenie wydarzeń jest tymczasowo wyłączone, dopóki logowanie nie zostanie podpięte w aplikacji.';

  @override
  String get hubCreateEventValidationMinChars3 => 'Podaj co najmniej 3 znaki.';

  @override
  String get hubCreateEventValidationRequired => 'To pole jest wymagane.';

  @override
  String get hubCreateEventValidationDescriptionMin10 =>
      'Opis powinien mieć co najmniej 10 znaków.';

  @override
  String get hubCreateEventValidationCategoryRequired =>
      'Wybierz co najmniej jedną kategorię.';

  @override
  String get hubCreateEventValidationPositiveNumber =>
      'Podaj poprawną dodatnią liczbę.';

  @override
  String get hubCreateEventValidationDateTimeRequired =>
      'Wybierz datę i godzinę wydarzenia.';

  @override
  String get hubCreateEventValidationLocationRequired =>
      'Wybierz lokalizację wydarzenia.';

  @override
  String get hubCreateEventCreatedSuccess => 'Wydarzenie zostało utworzone.';

  @override
  String get hubCreateEventCreateFailed =>
      'Nie udało się utworzyć wydarzenia. Spróbuj ponownie.';

  @override
  String get hubCreateEventLocationLookupFailed =>
      'Nie udało się ustalić lokalizacji. Spróbuj wpisać inny adres lub wskaż punkt na mapie.';

  @override
  String get hubMessagesTitle => 'Wiadomości';

  @override
  String get hubMessagesSubtitle => 'Wiadomości prywatne';

  @override
  String get hubCommunityTitle => 'Społeczność';

  @override
  String get hubCommunitySubtitle => 'Lokalne aktualizacje';

  @override
  String get hubFriendsTitle => 'Znajomi';

  @override
  String get hubFriendsSubtitle => 'Twoja sieć';

  @override
  String get inboxEmpty => 'Brak powiadomień';

  @override
  String get inboxMarkAllRead => 'Oznacz wszystkie jako przeczytane';

  @override
  String get notificationSettingsTitle => 'Powiadomienia Push';

  @override
  String get notificationSettingsSubtitle =>
      'Wybierz, które powiadomienia chcesz otrzymywać';

  @override
  String get notificationTypeUpcomingEvent => 'Nadchodzące wydarzenia';

  @override
  String get notificationTypeUpcomingEventDesc =>
      'Przypomnienia przed rozpoczęciem zapisanych wydarzeń';

  @override
  String get notificationTypeExpiredEvent => 'Zakończone wydarzenia';

  @override
  String get notificationTypeExpiredEventDesc =>
      'Gdy zapisane wydarzenie już minęło';

  @override
  String get notificationTypeEventPublished => 'Nowe wydarzenia';

  @override
  String get notificationTypeEventPublishedDesc =>
      'Gdy nowe wydarzenia pojawią się w pobliżu';

  @override
  String get notificationTypeSystemMessage => 'Wiadomości systemowe';

  @override
  String get notificationTypeSystemMessageDesc =>
      'Ważne aktualizacje z aplikacji';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDescription => 'Konto, preferencje i zapisane miejsca.';

  @override
  String get profileAuthLoginTitle => 'Logowanie';

  @override
  String get profileAuthLoginSubtitle => 'Przejdź do ekranu logowania';

  @override
  String get profileAuthLogoutTitle => 'Wyloguj';

  @override
  String get profileAuthLogoutSubtitle => 'Zakończ aktualną sesję';

  @override
  String get profileOrganizerRatingsTitle => 'Oceny organizatora';

  @override
  String get profileOrganizerRatingsLoading => 'Ładowanie ocen';

  @override
  String get profileOrganizerRatingsEmpty => 'Brak opinii';

  @override
  String profileOrganizerRatingsValue(String average, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opinii',
      many: '$count opinii',
      few: '$count opinie',
      one: '1 opinia',
    );
    return '$average/5 · $_temp0';
  }

  @override
  String get profileOrganizerReviewsScreenTitle => 'Opinie organizatora';

  @override
  String get profileOrganizerReviewsLoadingTitle => 'Ładowanie opinii';

  @override
  String get profileOrganizerReviewsLoadingSubtitle =>
      'Zbieramy opinie z Twoich wydarzeń.';

  @override
  String get profileOrganizerReviewsEmptyTitle => 'Brak opinii';

  @override
  String get profileOrganizerReviewsEmptySubtitle =>
      'Tutaj pojawią się opinie z wydarzeń, które organizujesz.';

  @override
  String get profileOrganizerReviewsSummaryTitle => 'Twój wynik organizatora';

  @override
  String get profileEventHistoryTitle => 'Archiwum wydarzeń';

  @override
  String get profileEventHistorySubtitle => 'Historia twoich wydarzeń.';

  @override
  String get profileEventHistoryEmptyTitle => 'Brak dołączonych wydarzeń';

  @override
  String get profileEventHistoryEmptySubtitle =>
      'Tutaj pojawią się wydarzenia po zapisaniu się.';

  @override
  String get profileEventHistoryCurrentSectionTitle => 'Obecne';

  @override
  String get profileEventHistoryPastSectionTitle => 'Przeszłe';

  @override
  String get profileEventHistoryOpenEvent => 'Otwórz wydarzenie';

  @override
  String get profileInboxSubtitle => 'Otwórz powiadomienia';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsSubtitle => 'Język, preferencje i podstawy aplikacji';

  @override
  String get settingsScreenTitle => 'Ustawienia';

  @override
  String get settingsScreenDescription =>
      'Tu możesz ogarnąć podstawy aplikacji, zanim sekcja ustawień bardziej urośnie.';

  @override
  String get languageSectionTitle => 'Język';

  @override
  String get languageSectionSubtitle =>
      'Wybierz, w jakim języku aplikacja ma z Tobą rozmawiać';

  @override
  String get themeSectionTitle => 'Wygląd';

  @override
  String get themeSectionSubtitle =>
      'Wybierz, czy aplikacja ma podążać za systemem czy trzymać stały motyw';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Jasny';

  @override
  String get themeModeDark => 'Ciemny';

  @override
  String get savedTitle => 'Zapisane';

  @override
  String get savedSubtitle => 'Miejsca, eventy i listy.';

  @override
  String get savedSaveAction => 'Zapisz wydarzenie';

  @override
  String get savedRemoveAction => 'Usuń z zapisanych';

  @override
  String get savedSaveActionTooltip => 'Zapisz wydarzenie';

  @override
  String get savedRemoveActionTooltip => 'Usuń z zapisanych';

  @override
  String get savedSortTooltip => 'Sortowanie zapisanych';

  @override
  String get savedSortRecent => 'Ostatnio zapisane';

  @override
  String get savedSortDistance => 'Odległość';

  @override
  String get savedFiltersTooltip => 'Filtry zapisanych';

  @override
  String get savedFiltersTitle => 'Filtry zapisanych';

  @override
  String get savedFiltersClear => 'Wyczyść';

  @override
  String get savedFiltersApply => 'Zastosuj';

  @override
  String get savedFilterCategoriesTitle => 'Kategorie';

  @override
  String get savedFilterAgeTitle => 'Grupy wiekowe';

  @override
  String get savedFilterTagsTitle => 'Tagi';

  @override
  String get savedAgeGroupAny => 'Dowolny wiek';

  @override
  String get savedAgeGroup12Plus => '12+';

  @override
  String get savedAgeGroup18Plus => '18+';

  @override
  String get savedShowPastEvents => 'Pokaż archiwalne';

  @override
  String get savedEmptyTitle => 'Brak zapisanych wydarzeń';

  @override
  String get savedEmptySubtitle =>
      'Zapisuj wydarzenia z ekranu Odkrywaj, żeby mieć je tutaj.';

  @override
  String get savedEmptyFilteredTitle =>
      'Żadne wydarzenia nie pasują do filtrów';

  @override
  String get savedEmptyFilteredSubtitle =>
      'Wyczyść filtry albo spróbuj innej kombinacji.';

  @override
  String get savedEventsTab => 'Wydarzenia';

  @override
  String get savedFiltersTab => 'Filtry';

  @override
  String get savedFiltersEmptyTitle => 'Brak zapisanych filtrów';

  @override
  String get savedFiltersEmptySubtitle =>
      'Tutaj pojawią się zapisane przez Ciebie presety filtrów.';

  @override
  String get savedFiltersSaveDialogTitle => 'Zapisz filtr';

  @override
  String get savedFiltersSaveAction => 'Zapisz';

  @override
  String get savedFiltersNameHint => 'Nazwa filtru';

  @override
  String get savedFiltersDeleteTooltip => 'Usuń filtr';

  @override
  String get savedFiltersLoadTooltip => 'Użyj filtru';

  @override
  String get savedFilterNotificationsLabel => 'Powiadomienia';

  @override
  String get savedFilterNotificationsTooltip =>
      'Włącz powiadomienia dla tego filtru';

  @override
  String get savedFiltersLocationCurrent => 'Bieżąca lokalizacja';

  @override
  String get savedFiltersLocationSaved => 'Zapisana lokalizacja';

  @override
  String get savedFiltersUseCurrentLocation => 'Użyj bieżącej lokalizacji';

  @override
  String get savedFiltersUseSavedLocation => 'Użyj zapisanej lokalizacji';

  @override
  String get savedFiltersSaveConfirmation => 'Filtr zapisany';

  @override
  String get savedFiltersDeleteConfirmation => 'Filtr usunięty';

  @override
  String get savedFiltersLoadConfirmation => 'Filtr zastosowany';

  @override
  String get savedFiltersCreateButton => 'Zapisz bieżące filtry';

  @override
  String get savedFiltersCancel => 'Anuluj';

  @override
  String get savedFiltersLocationLabel => 'Lokalizacja';

  @override
  String get appTitle => 'Locario';

  @override
  String get localeEnglish => 'Angielski';

  @override
  String get localePolish => 'Polski';

  @override
  String get featureComingSoon => 'Ta sekcja jest jeszcze w przygotowaniu.';

  @override
  String get networkError => 'Błąd sieci. Sprawdź swoje połączenie.';

  @override
  String get networkErrorRetry => 'Ponów';

  @override
  String shareEventMessage(String title, String url) {
    return 'Sprawdź to wydarzenie w Locario: $title\n\n$url';
  }

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
  String get mapServiceDisabled =>
      'Włącz usługi lokalizacji, aby zobaczyć swoją pozycję.';

  @override
  String get mapPermissionDenied =>
      'Pozwól na dostęp do lokalizacji, aby wycentrować mapę na Tobie.';

  @override
  String get mapPermissionDeniedForever =>
      'Dostęp do lokalizacji jest zablokowany w ustawieniach systemu.';

  @override
  String get mapUnableDetermineLocation =>
      'Nie udało się ustalić Twojej lokalizacji.';

  @override
  String get mapLocationTimeout =>
      'Żądanie lokalizacji przekroczyło limit czasu. Spróbuj ponownie.';

  @override
  String get mapUnableLoadLocation =>
      'Nie udało się wczytać Twojej lokalizacji.';

  @override
  String mapClusterSheetTitle(int count) {
    return 'Wybierz wydarzenie ($count)';
  }

  @override
  String mapEventOpenSoon(String title) {
    return 'Ekran wydarzenia „$title” dodamy później.';
  }
}
