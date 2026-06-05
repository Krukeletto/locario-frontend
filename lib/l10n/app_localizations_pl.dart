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
  String get eventCalendarPromptTitle => 'Dodać do kalendarza?';

  @override
  String get eventCalendarPromptBody =>
      'Możesz dodać to wydarzenie teraz albo później z widoku szczegółów wydarzenia. Kalendarz otworzy się już z wypełnionymi szczegółami.';

  @override
  String get eventCalendarPromptAddNow => 'Dodaj teraz';

  @override
  String get eventCalendarPromptLater => 'Później';

  @override
  String get eventDetailsAddToCalendarButton => 'Dodaj do kalendarza';

  @override
  String get eventAddToCalendarSuccess => 'Wydarzenie dodano do kalendarza.';

  @override
  String get eventAddToCalendarError =>
      'Nie udało się dodać wydarzenia do kalendarza.';

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
  String get groupsDiscoverTitle => 'Grupy';

  @override
  String get groupsLoadingTitle => 'Ładowanie grup';

  @override
  String get groupsLoadingSubtitle =>
      'Pobieramy społeczności dostępne w aplikacji.';

  @override
  String get groupsErrorTitle => 'Nie udało się wczytać grup';

  @override
  String get groupsErrorSubtitle => 'Spróbuj ponownie za chwilę.';

  @override
  String get groupsCreateCta => 'Utwórz grupę';

  @override
  String get groupsMyGroupsTab => 'Moje grupy';

  @override
  String get groupsMyGroupsTitle => 'Moje grupy';

  @override
  String get groupsMyGroupsSubtitle => 'Społeczności, do których już należysz.';

  @override
  String get groupsMyGroupsEmptyTitle => 'Nie należysz jeszcze do żadnej grupy';

  @override
  String get groupsMyGroupsEmptySubtitle =>
      'Dołącz do publicznej grupy, aby zobaczyć ją tutaj.';

  @override
  String get groupsDiscoverTab => 'Odkryj';

  @override
  String get groupsDiscoverPublicTitle => 'Publiczne grupy';

  @override
  String get groupsDiscoverPublicSubtitle =>
      'Przeglądaj społeczności dostępne w discover.';

  @override
  String get groupsDiscoverEmptyTitle => 'Nie znaleziono grup';

  @override
  String get groupsDiscoverEmptySubtitle =>
      'Spróbuj innej frazy albo kategorii.';

  @override
  String get groupsSearchHint => 'Szukaj grup';

  @override
  String get groupsCategoryAll => 'Wszystkie kategorie';

  @override
  String get groupsCategoryUnknown => 'Bez kategorii';

  @override
  String get groupsVisibilityPublic => 'Publiczna';

  @override
  String get groupsVisibilityPrivate => 'Prywatna';

  @override
  String groupsMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count członków',
      many: '$count członków',
      few: '$count członków',
      one: '1 członek',
    );
    return '$_temp0';
  }

  @override
  String get groupsMembershipActive => 'Członek';

  @override
  String get groupsMembershipPending => 'Oczekuje';

  @override
  String get groupsMembershipBanned => 'Zbanowany';

  @override
  String get groupsCreateTitle => 'Utwórz grupę';

  @override
  String get groupsEditTitle => 'Edytuj grupę';

  @override
  String get groupsEditForbidden => 'Nie masz uprawnień do edycji tej grupy.';

  @override
  String get groupsFieldName => 'Nazwa grupy';

  @override
  String get groupsFieldDescription => 'Opis';

  @override
  String get groupsFieldCategory => 'Kategoria';

  @override
  String get groupsFieldAvatarUrl => 'URL avatara';

  @override
  String get groupsFieldIconUrl => 'URL ikony';

  @override
  String get groupsFieldMapPinIconUrl => 'URL ikony pinezki';

  @override
  String get groupsFieldMapPinStyle => 'Styl pinezki';

  @override
  String get groupsCategoryNone => 'Brak kategorii';

  @override
  String get groupsAdvancedTitle => 'Ustawienia zaawansowane';

  @override
  String get groupsAdvancedSubtitle =>
      'Opcjonalne pola wizualne zgodne z backendowym kontraktem.';

  @override
  String get groupsCreateSubmit => 'Utwórz grupę';

  @override
  String get groupsSaveChanges => 'Zapisz zmiany';

  @override
  String get groupsValidationNameRequired => 'Podaj nazwę grupy.';

  @override
  String get groupsValidationNameTooLong =>
      'Nazwa może mieć maksymalnie 255 znaków.';

  @override
  String get groupsValidationDescriptionTooLong =>
      'Opis może mieć maksymalnie 5000 znaków.';

  @override
  String get groupsValidationMapPinStyleTooLong =>
      'Styl pinezki może mieć maksymalnie 50 znaków.';

  @override
  String get groupsValidationUrlTooLong =>
      'URL może mieć maksymalnie 2048 znaków.';

  @override
  String get groupsValidationUrlInvalid => 'Podaj poprawny URL.';

  @override
  String get groupsJoinAction => 'Dołącz do grupy';

  @override
  String get groupsLeaveAction => 'Opuść grupę';

  @override
  String get groupsPendingAction => 'Wycofaj prośbę';

  @override
  String get groupsTabFeed => 'Feed';

  @override
  String get groupsTabMembers => 'Członkowie';

  @override
  String get groupsTabEvents => 'Eventy';

  @override
  String get groupsTabManage => 'Zarządzanie';

  @override
  String get groupsFeedEmptyTitle => 'Feed jest jeszcze pusty';

  @override
  String get groupsFeedEmptySubtitle =>
      'Tutaj pojawią się posty i eventy przypięte do tej grupy.';

  @override
  String get groupsFeedPostLabel => 'Post';

  @override
  String get groupsFeedEventLabel => 'Event';

  @override
  String get groupsFeedPostFallbackAuthor => 'Nieznany autor';

  @override
  String get groupsFeedEventFallbackTitle => 'Event grupowy';

  @override
  String get groupsPostCreateAction => 'Dodaj post';

  @override
  String get groupsPostCreateTitle => 'Nowy post';

  @override
  String get groupsPostEditTitle => 'Edytuj post';

  @override
  String get groupsPostHint => 'Co chcesz przekazać grupie?';

  @override
  String get groupsPostPublish => 'Opublikuj';

  @override
  String get groupsEditAction => 'Edytuj';

  @override
  String get groupsDeleteAction => 'Usuń';

  @override
  String get groupsHideAction => 'Ukryj';

  @override
  String get groupsReportAction => 'Zgłoś';

  @override
  String get groupsOpenEventAction => 'Otwórz event';

  @override
  String get groupsJoinRequestsTitle => 'Prośby o dołączenie';

  @override
  String get groupsApproveAction => 'Akceptuj';

  @override
  String get groupsRejectAction => 'Odrzuć';

  @override
  String get groupsMembersEmptyTitle => 'Brak członków';

  @override
  String get groupsMembersEmptySubtitle =>
      'Członkowie pojawią się tutaj po dołączeniu do grupy.';

  @override
  String get groupsMemberOwner => 'Właściciel';

  @override
  String get groupsMemberAdmin => 'Admin';

  @override
  String get groupsMemberRegular => 'Członek';

  @override
  String get groupsMakeAdminAction => 'Nadaj admina';

  @override
  String get groupsMakeMemberAction => 'Nadaj członka';

  @override
  String get groupsBanAction => 'Zbanuj';

  @override
  String get groupsUnbanAction => 'Odbanuj';

  @override
  String get groupsRemoveMemberAction => 'Usuń członka';

  @override
  String get groupsTransferOwnershipAction => 'Przekaż własność';

  @override
  String get groupsCreateEventAction => 'Utwórz event dla grupy';

  @override
  String get groupsLinkExistingEventAction => 'Podepnij istniejący event';

  @override
  String get groupsUnlinkEventAction => 'Odepnij event';

  @override
  String get groupsEventsEmptyTitle => 'Brak eventów';

  @override
  String get groupsEventsEmptySubtitle =>
      'Utwórz albo podepnij event, aby zasilić oś czasu grupy.';

  @override
  String get groupsManageRestrictedTitle => 'Sekcja ograniczona';

  @override
  String get groupsManageRestrictedSubtitle =>
      'Tylko właściciel i admini grupy mogą zarządzać raportami i członkami.';

  @override
  String get groupsReportsEmptyTitle => 'Brak zgłoszeń';

  @override
  String get groupsReportsEmptySubtitle => 'Nowe zgłoszenia pojawią się tutaj.';

  @override
  String get groupsResolveAction => 'Rozwiąż';

  @override
  String get groupsReportGroupAction => 'Zgłoś grupę';

  @override
  String get groupsReportGroupTitle => 'Zgłoś grupę';

  @override
  String get groupsReportPostTitle => 'Zgłoś post';

  @override
  String get groupsReportEventTitle => 'Zgłoś event';

  @override
  String get groupsReportReasonLabel => 'Powód';

  @override
  String get groupsReportDescriptionLabel => 'Opis';

  @override
  String get groupsReportSubmit => 'Wyślij zgłoszenie';

  @override
  String get groupsConfirmAction => 'Potwierdź';

  @override
  String get groupsDeleteGroupTitle => 'Usuń grupę';

  @override
  String get groupsDeleteGroupBody =>
      'Grupa zostanie usunięta dla członków i zniknie z discover.';

  @override
  String get groupsDeletePostTitle => 'Usuń post';

  @override
  String get groupsDeletePostBody => 'Ten post zniknie z feedu grupy.';

  @override
  String get groupsActionFailed => 'Nie udało się wykonać tej akcji.';

  @override
  String get groupsEventGroupsLabel => 'Powiązane grupy';

  @override
  String get groupsEventGroupsOptionalHint =>
      'Pozostaw puste, aby utworzyć event publiczny, albo wybierz grupy do przypięcia.';

  @override
  String get groupsEventGroupsRequiredHint =>
      'Wybierz co najmniej jedną grupę. Jako zwykły członek możesz tworzyć tylko eventy grupowe.';

  @override
  String get groupsEventGroupsEmpty =>
      'Nie należysz jeszcze aktywnie do żadnej grupy.';

  @override
  String get groupsEventValidationGroupRequired =>
      'Wybierz co najmniej jedną grupę dla tego eventu.';

  @override
  String get groupsEventValidationSlotLimitRequired =>
      'Zwykły członek musi ustawić dodatni limit miejsc.';

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
  String get legalTermsTitle => 'Regulamin';

  @override
  String get legalTermsContent =>
      'Niniejszy Regulamin („Regulamin”) określa zasady korzystania z aplikacji mobilnej Locario i powiązanych usług. Korzystając z Locario, akceptujesz niniejszy Regulamin. Jeśli się nie zgadzasz, nie korzystaj z aplikacji.\n\n1. Rejestracja konta.\nPrzy tworzeniu konta musisz podać prawdziwe dane. Jesteś odpowiedzialny za zachowanie poufności swoich danych logowania.\n\n2. Dozwolony użytek.\nZgadzasz się nie nadużywać aplikacji, w tym podszywać się pod inne osoby, podawać fałszywe informacje o wydarzeniach ani angażować się w działania zakłócające działanie platformy.\n\n3. Treści.\nZachowujesz własność treści, które przesyłasz. Zastrzegamy sobie prawo do usuwania treści naruszających Regulamin.\n\n4. Ograniczenie odpowiedzialności.\nLocario i jej podmioty stowarzyszone nie ponoszą odpowiedzialności za szkody pośrednie wynikające z korzystania z aplikacji.\n\n5. Zmiany.\nMożemy aktualizować Regulamin. Dalsze korzystanie z aplikacji po zmianach oznacza ich akceptację.\n\n6. Kontakt.\nPytania prosimy kierować na adres locario.app@gmail.com.\n\nOstatnia aktualizacja: maj 2026.';

  @override
  String get legalPrivacyTitle => 'Polityka prywatności';

  @override
  String get legalPrivacyContent =>
      'Twoja prywatność jest dla nas ważna. Niniejsza Polityka prywatności wyjaśnia, w jaki sposób zbieramy, wykorzystujemy i chronimy Twoje dane osobowe podczas korzystania z Locario.\n\n1. Jakie dane zbieramy.\nZbieramy dane, które nam podajesz (nazwa użytkownika, e-mail, dane profilowe) oraz dane zbierane automatycznie (informacje o urządzeniu, lokalizacja po włączeniu, analityka użycia).\n\n2. Jak wykorzystujemy dane.\nWykorzystujemy Twoje dane do działania aplikacji, personalizacji treści, wysyłania powiadomień (za Twoją zgodą) i ulepszania naszych usług.\n\n3. Udostępnianie danych.\nNie sprzedajemy Twoich danych. Możemy je udostępniać dostawcom usług pomagającym w obsłudze platformy, na podstawie ścisłych umów o poufności.\n\n4. Twoje prawa.\nMożesz w każdej chwili uzyskać dostęp do swoich danych, poprawić je lub usunąć przez ustawienia profilu lub kontaktując się z nami.\n\n5. Przechowywanie danych.\nPrzechowujemy Twoje dane tak długo, jak Twoje konto jest aktywne. Po usunięciu konta przechowujemy zanonimizowane dane do celów analitycznych.\n\n6. Bezpieczeństwo.\nStosujemy środki bezpieczeństwa zgodne ze standardami branżowymi.\n\n7. Kontakt.\nlocario.app@gmail.com\n\nOstatnia aktualizacja: maj 2026.';

  @override
  String get legalHelpTitle => 'Pomoc i wsparcie';

  @override
  String get legalHelpSectionFaq => 'Najczęściej zadawane pytania';

  @override
  String get legalHelpFaqContent =>
      'P: Jak utworzyć wydarzenie?\nO: Naciśnij przycisk + z panelu huba i wypełnij formularz tworzenia wydarzenia.\n\nP: Jak zmienić hasło?\nO: Przejdź do Profil → Ustawienia → Hasło i wprowadź obecne oraz nowe hasło.\n\nP: Zapomniałem hasła.\nO: Skorzystaj z opcji „Zapomniałem hasła” na ekranie logowania.\n\nP: Jak zgłosić problem?\nO: Wyślij e-mail na adres locario.app@gmail.com z opisem problemu.';

  @override
  String get legalHelpSectionContact => 'Skontaktuj się z nami';

  @override
  String get legalHelpContactContent =>
      'Potrzebujesz dodatkowej pomocy? Napisz do nas:\n\nE-mail: locario.app@gmail.com\n\nOdpowiadamy w ciągu 24-48 godzin w dni robocze.';

  @override
  String get legalConsentsTitle => 'Twoje zgody';

  @override
  String get legalConsentsSectionTitle => 'Zgody prywatności';

  @override
  String get legalConsentsSectionSubtitle =>
      'Zarządzaj tym, na co wyrażasz zgodę. Możesz to zmienić w każdej chwili.';

  @override
  String get consentTypeMarketingEmails => 'E-maile marketingowe';

  @override
  String get consentTypeMarketingEmailsDesc =>
      'Otrzymuj oferty promocyjne, sugestie wydarzeń i nowości o Locario';

  @override
  String get consentTypeDataProcessing => 'Przetwarzanie danych';

  @override
  String get consentTypeDataProcessingDesc =>
      'Zezwól nam na analizę Twojego użycia w celu ulepszenia aplikacji';

  @override
  String get consentTypeLocationData => 'Dane lokalizacyjne';

  @override
  String get consentTypeLocationDataDesc =>
      'Udostępnij dokładną lokalizację, aby odkrywać wydarzenia w pobliżu i spersonalizowane rekomendacje';

  @override
  String get settingsLegalSectionTitle => 'Prawo i polityki';

  @override
  String get settingsLegalSectionSubtitle =>
      'Regulamin, polityka prywatności i pomoc';

  @override
  String get settingsLegalTerms => 'Regulamin';

  @override
  String get settingsLegalPrivacy => 'Polityka prywatności';

  @override
  String get settingsLegalHelp => 'Pomoc i wsparcie';

  @override
  String get settingsConsentsSectionTitle => 'Twoje zgody';

  @override
  String get settingsConsentsSectionSubtitle =>
      'Zarządzaj swoimi preferencjami prywatności';

  @override
  String get legalAcceptanceTitle => 'Aktualizacja regulaminu i polityki';

  @override
  String get legalAcceptanceSubtitle =>
      'Zaktualizowaliśmy nasze dokumenty prawne. Przejrzyj zmiany i zaakceptuj je, aby kontynuować korzystanie z Locario.';

  @override
  String get legalAcceptanceTermsTitle => 'Regulamin';

  @override
  String get legalAcceptancePrivacyTitle => 'Polityka prywatności';

  @override
  String get legalAcceptanceButton => 'Akceptuj i kontynuuj';

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
  String get profileBioPlaceholder => 'Brak opisu.';

  @override
  String get profileLinksLabel => 'Linki';

  @override
  String get profileLinksPlaceholder => 'Brak linków.';

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
  String get settingsAccountSectionTitle => 'Hasło';

  @override
  String get settingsAccountSectionSubtitle => 'Zmień hasło do konta';

  @override
  String get settingsAccountChangePassword => 'Zmień hasło';

  @override
  String get settingsChangePasswordDialogTitle => 'Zmień hasło';

  @override
  String get settingsChangePasswordCurrentLabel => 'Obecne hasło';

  @override
  String get settingsChangePasswordNewLabel => 'Nowe hasło';

  @override
  String get settingsChangePasswordCancel => 'Anuluj';

  @override
  String get settingsChangePasswordSubmit => 'Zmień hasło';

  @override
  String get settingsChangePasswordSuccess => 'Hasło zostało zmienione.';

  @override
  String get settingsChangePasswordInvalidOld =>
      'Obecne hasło jest nieprawidłowe.';

  @override
  String get settingsChangePasswordFailed => 'Nie udało się zmienić hasła.';

  @override
  String get profileUpdateSuccess => 'Profil zaktualizowany pomyślnie.';

  @override
  String get profileUpdateFailed => 'Nie udało się zaktualizować profilu.';

  @override
  String get editProfileTitle => 'Edytuj profil';

  @override
  String get editProfileChangePhoto => 'Zmień zdjęcie';

  @override
  String get editProfileUsernameLabel => 'NAZWA UŻYTKOWNIKA';

  @override
  String get editProfileUsernamePlaceholder => 'Twoja nazwa użytkownika';

  @override
  String get editProfileBioLabel => 'BIO';

  @override
  String get editProfileBioPlaceholder => 'Opowiedz o sobie';

  @override
  String get editProfileWebsiteLabel => 'STRONA WWW';

  @override
  String get editProfileWebsitePlaceholder => 'https://example.com';

  @override
  String get editProfileInstagramLabel => 'INSTAGRAM';

  @override
  String get editProfileInstagramPlaceholder => 'https://instagram.com/...';

  @override
  String get editProfileFacebookLabel => 'FACEBOOK';

  @override
  String get editProfileFacebookPlaceholder => 'https://facebook.com/...';

  @override
  String get editProfileSaveButton => 'Zapisz profil';

  @override
  String get editProfileLinkHttpsError => 'Musi zaczynać się od https://';

  @override
  String get editProfileInstagramDomainError =>
      'Musi być linkiem do Instagrama';

  @override
  String get editProfileFacebookDomainError => 'Musi być linkiem do Facebooka';

  @override
  String get profileMyEventsTitle => 'Moje wydarzenia';

  @override
  String get profileMyEventsSubtitle =>
      'Wydarzenia, które utworzyłeś i którymi zarządzasz.';

  @override
  String get profileOrganizerSectionTitle => 'Organizator';

  @override
  String get profileOrganizerSectionSubtitle =>
      'Narzędzia dla zweryfikowanych organizatorów.';

  @override
  String get profileOrganizerCreateEvent => 'Utwórz wydarzenie';

  @override
  String get profileOrganizerCreateEventSubtitle => 'Zorganizuj coś nowego.';

  @override
  String get profileBecomeOrganizerTitle => 'Zostań organizatorem';

  @override
  String get profileBecomeOrganizerSubtitle =>
      'Przejdź weryfikację, aby tworzyć i zarządzać wydarzeniami.';

  @override
  String get profileBecomeOrganizerDialogTitle => 'Weryfikacja organizatora';

  @override
  String get profileBecomeOrganizerDialogBody =>
      'Po wysłaniu prośba zostanie rozpatrzona przez nasz zespół. Otrzymasz powiadomienie o decyzji.';

  @override
  String get profileBecomeOrganizerDialogSubmit => 'Wyślij prośbę';

  @override
  String get profileBecomeOrganizerDialogCancel => 'Anuluj';

  @override
  String get profileBecomeOrganizerRequestSent =>
      'Prośba o weryfikację została wysłana.';

  @override
  String get profileBecomeOrganizerRequestFailed =>
      'Nie udało się wysłać prośby o weryfikację.';

  @override
  String get profileOrganizerVerificationPendingTitle => 'Weryfikacja oczekuje';

  @override
  String get profileOrganizerVerificationPendingSubtitle =>
      'Twoja prośba jest rozpatrywana przez nasz zespół.';

  @override
  String get profileOrganizerVerificationRejectedTitle =>
      'Weryfikacja odrzucona';

  @override
  String get profileOrganizerVerificationRejectedSubtitle =>
      'Twoja prośba nie została zatwierdzona.';

  @override
  String get savedTitle => 'Zapisane';

  @override
  String get savedSubtitle => 'Wydarzenia i filtry.';

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
