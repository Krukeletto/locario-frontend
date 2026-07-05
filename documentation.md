# Locario - dokumentacja techniczna frontendu

## 1. Wprowadzenie

Locario to aplikacja mobilna Flutter służąca do odkrywania wydarzeń w okolicy, przeglądania ich na mapie i liście, zapisywania wydarzeń, zarządzania profilem, obsługi grup społecznościowych, czatu, powiadomień oraz tworzenia wydarzeń przez uprawnionych użytkowników.

Dokument opisuje frontend projektu. Backend jest omawiany wyłącznie w zakresie sposobu komunikacji frontendu z usługami REST, Firebase, Firestore i mechanizmami uploadu.

Zakres dokumentu wynika z plików znajdujących się w repozytorium. Jeżeli opis wskazuje ograniczenie, brak mechanizmu albo miejsce wymagające doprecyzowania, oznacza to stan zaobserwowany w kodzie frontendu lub konfiguracji projektu, a nie założenie dotyczące backendu.

Projekt jest aplikacją Flutter/Dart z architekturą opartą o moduły funkcjonalne, ręcznie składaną kompozycję zależności oraz kontrolery `ChangeNotifier`. Nie używa zewnętrznego frameworka zarządzania stanem typu Bloc, Riverpod lub Provider. Zamiast tego stosuje własne scope'y oparte o `InheritedNotifier` i `InheritedWidget`.

Najważniejsze założenia:

- aplikacja startuje przez `main.dart`,
- globalne zależności są tworzone w `LocarioApp`,
- routing jest centralnie zarządzany przez `go_router`,
- stan globalny jest przekazywany przez scope'y,
- komunikacja z backendem REST jest realizowana przez klasy `Api` i `Repository`,
- czat działa przez Cloud Firestore,
- powiadomienia działają przez Firebase Messaging i lokalne notyfikacje,
- dane lokalne są przechowywane w `SharedPreferences`, `flutter_secure_storage` i `sqflite`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/main.dart`
- `lib/app/app.dart`
- `README.md`
- `pubspec.yaml`
- `firebase.json`

## 2. Architektura aplikacji

Architektura projektu jest warstwowa i jednocześnie podzielona według funkcji aplikacji. Kod nie zawiera osobnego frameworka architektonicznego ani kontenera dependency injection. Główne elementy są składane ręcznie w `LocarioApp`, a następnie udostępniane ekranom przez własne scope'y lub przekazywane bezpośrednio przez konstruktory.

Ogólny układ architektury:

1. `main.dart` wykonuje inicjalizację platformową.
2. `LocarioApp` tworzy długowieczne zależności aplikacji.
3. `MaterialApp.router` uruchamia UI z konfiguracją routingu, motywów i lokalizacji.
4. Ekrany z `lib/features/` korzystają z kontrolerów globalnych przez scope'y albo tworzą kontrolery lokalne.
5. Kontrolery wykonują logikę stanu, walidacji, synchronizacji i odświeżania danych.
6. Repozytoria oraz klasy API z `lib/shared/` komunikują się z usługami zewnętrznymi albo lokalnymi magazynami danych.
7. Modele domenowe mapują dane JSON lub dane lokalne na obiekty używane w UI.

### Warstwy aplikacji

W kodzie można wyróżnić następujące warstwy:

1. Warstwa startowa i kompozycji aplikacji.
2. Warstwa routingu.
3. Warstwa prezentacji.
4. Warstwa kontrolerów stanu.
5. Warstwa domenowo-dostępowa.
6. Warstwa usług platformowych i lokalnych magazynów danych.

Warstwa startowa i kompozycji obejmuje `main.dart` oraz `app.dart`. `main()` inicjalizuje Flutter binding, Firebase i lokalne powiadomienia. `LocarioApp` tworzy instancje repozytoriów, API, kontrolerów, cache i routera. Ta warstwa odpowiada za cykl życia globalnych obiektów: tworzy je w `initState`, uruchamia początkowe ładowanie danych i zwalnia zasoby w `dispose`.

Warstwa routingu znajduje się głównie w `app/router.dart`. Odpowiada za strukturę tras, deep linki, redirecty zależne od sesji, redirecty zależne od akceptacji dokumentów prawnych oraz ograniczenia dostępu do części ekranów. Router obserwuje `SessionController` i `LegalController` przez `refreshListenable`.

Warstwa prezentacji znajduje się przede wszystkim w `lib/features/`. Są to ekrany i widgety, np. `ExploreScreen`, `ProfileScreen`, `EventScreen`, `SavedScreen`, `GroupDetailsScreen`, `ChatThreadScreen` oraz elementy powłoki `Shell`. Ekrany budują UI, reagują na interakcje użytkownika i wywołują metody kontrolerów. Część ekranów przechowuje również lokalny stan interakcji, np. fokus wyszukiwarki, timery, lokalny widok mapy albo stan formularza.

Warstwa kontrolerów stanu jest oparta o `ChangeNotifier`. Kontrolery przechowują dane, statusy ładowania, błędy i metody akcji. Przykłady to `SessionController`, `ExploreController`, `GroupController`, `EventDetailController`, `SavedEventsController`, `SavedFiltersController`, `CreateEventController`, `ReviewController`, `JoinedEventsController`, `NotificationController`, `LegalController`, `ThemeController` i `LocaleController`. Po zmianie stanu kontrolery wywołują `notifyListeners()`.

Warstwa domenowo-dostępowa obejmuje modele, repozytoria i klasy API. Repozytoria HTTP, takie jak `HttpEventRepository`, `HttpGroupRepository` i `HttpReviewRepository`, budują żądania HTTP, dekodują odpowiedzi JSON i zwracają modele domenowe. `AuthRepository` dodatkowo koordynuje `AuthApi` i `AuthTokenStorage`. Część logiki domenowej znajduje się bezpośrednio w kontrolerach, np. filtrowanie i sortowanie wyników Explore albo synchronizacja zapisanych wydarzeń.

Warstwa usług platformowych i lokalnych magazynów danych obejmuje integracje z Firebase, Firestore, geolokalizacją, lokalnymi powiadomieniami, `SharedPreferences`, `flutter_secure_storage` i `sqflite`. Przykłady to `NotificationService`, `FirestoreChatRepository`, `GeolocatorLocationService`, `CacheService`, `AuthStorage`, `SharedPreferencesSavedEventsRepository` i `SharedPreferencesAppSettingsStore`.

### Odpowiedzialność warstw i zależności między nimi

Zależności w projekcie są skierowane głównie od warstw wyższych do niższych:

- `main.dart` zależy od Firebase, `NotificationService` i `LocarioApp`.
- `LocarioApp` zależy od kontrolerów, repozytoriów, API, cache, routingu, theme i l10n.
- Router zależy od kontrolerów sesji i dokumentów prawnych oraz od ekranów.
- Ekrany zależą od kontrolerów, scope'ów, modeli i widgetów wspólnych.
- Kontrolery zależą od repozytoriów, API, cache, storage albo innych kontrolerów.
- Repozytoria zależą od `http.Client`, `ApiConfig`, modeli i parserów JSON.
- Usługi platformowe zależą od pakietów Flutter/Firebase/platformowych.

Przykład zależności dla sesji użytkownika:

```text
LoginScreen/RegisterScreen
  -> SessionController
  -> AuthRepository
  -> AuthApi
  -> http.Client
```

Równolegle `AuthRepository` zależy od `AuthTokenStorage`, którego implementacją produkcyjną jest `AuthStorage` używający `FlutterSecureStorage`.

Przykład zależności dla Explore:

```text
ExploreScreen
  -> ExploreController
  -> EventRepository
  -> HttpEventRepository
  -> http.Client
```

`ExploreScreen` korzysta też z `ExploreMapViewModel`, który zależy od `LocationService`, a produkcyjnie od `GeolocatorLocationService`.

Przykład zależności dla grup:

```text
GroupDetailsScreen / GroupDiscoverScreen
  -> GroupScope
  -> GroupController
  -> GroupRepository + EventRepository + CacheService + SessionController
```

`GroupController` pobiera token z `SessionController`, używa repozytorium grup do komunikacji HTTP i zapisuje część wyników przez `CacheService`.

Przykład zależności dla powiadomień:

```text
NotificationService
  -> NotificationController
  -> NotificationHistoryRepository + NotificationPreferencesStore + NotificationsApi + SessionController
```

`NotificationService` obsługuje integrację z Firebase Messaging i lokalnymi powiadomieniami, natomiast `NotificationController` przechowuje stan historii, preferencji i tokena FCM.

W kilku miejscach warstwa prezentacji komunikuje się bezpośrednio z `http` albo `ApiConfig`. Dotyczy to m.in. uploadu w `EditProfileScreen` i `pin_selector.dart`. To jest faktyczny stan kodu w repozytorium, a nie osobna warstwa abstrakcji.

### Przepływ danych

Najczęstszy przepływ danych w aplikacji wygląda następująco:

```text
Widget
  -> Controller
  -> Repository/API/Service
  -> model lub błąd
  -> aktualizacja pól kontrolera
  -> notifyListeners()
  -> przebudowa UI
```

Przykład dla danych wydarzeń w Explore:

1. `ExploreScreen` ustala lokalizację przez `ExploreMapViewModel`.
2. `ExploreController.updateReferenceLocation` zapisuje punkt odniesienia.
3. `ExploreController.loadEvents` próbuje odczytać listę z `CacheService`, jeśli cache został przekazany.
4. `HttpEventRepository.fetchMapEvents` pobiera świeże dane przez REST.
5. `ExploreController` porównuje hash świeżych danych z hashem cache.
6. `ExploreEventQuery` filtruje i sortuje listę.
7. Stan przechodzi do `ExploreData`, `ExploreEmpty`, `ExploreDataLoading` albo `ExploreError`.
8. `ExploreScreen` przebudowuje mapę lub listę.

Przykład dla szczegółów wydarzenia:

1. `EventScreen` korzysta z `EventDetailScope`.
2. `EventDetailController.loadEvent` sprawdza cache `event_<id>`.
3. `EventRepository.fetchEvent` pobiera świeży model.
4. Kontroler scala świeże dane z poprzednim modelem przez `_mergeEventDetails`.
5. Dane są zapisywane w cache.
6. Równolegle uruchamiane jest `loadEventSlots`.

Przykład dla zapisanych wydarzeń:

1. UI wywołuje `SavedEventsController.toggleSaved`.
2. Kontroler sprawdza lokalną listę rekordów.
3. Jeżeli użytkownik jest zalogowany, wywoływany jest `FavoritesApi`.
4. Lokalna lista jest aktualizowana i zapisywana przez `SavedEventsRepository`.
5. Po zalogowaniu `syncWithRemote` porównuje lokalne rekordy z ulubionymi z profilu.

Przykład dla czatu:

1. `ChatListScreen` albo `ChatThreadScreen` używa `FirestoreChatRepository`.
2. Repozytorium zwraca stream z Firestore.
3. UI reaguje na kolejne snapshoty.
4. Przy wysyłaniu wiadomości repozytorium zapisuje dokument wiadomości i best-effort aktualizuje dokument rozmowy.

### Wzorce projektowe obecne w kodzie

W repozytorium występują następujące wzorce:

- Feature-first structure: moduły funkcjonalne znajdują się w `lib/features`.
- Repository pattern: komunikacja HTTP jest ukryta za interfejsami lub klasami repozytoriów, np. `EventRepository`, `GroupRepository`, `ReviewRepository`, `SavedEventsRepository`.
- API client classes: część obszarów ma klasy API bezpośrednio reprezentujące endpointy, np. `AuthApi`, `FavoritesApi`, `NotificationsApi`, `EventRegistrationApi`.
- Controller pattern: logika stanu i akcji jest skupiona w klasach `ChangeNotifier`.
- Scope pattern: kontrolery globalne są udostępniane przez `InheritedNotifier` lub `InheritedWidget`.
- Cache-aside: kontrolery najpierw czytają cache, a potem odświeżają dane z repozytorium.
- Optimistic update: część akcji w `GroupController` aktualizuje UI przed zakończeniem operacji zdalnej.
- Local-first storage: zapisane wydarzenia i filtry działają lokalnie, a synchronizacja zdalna jest dodatkowym krokiem.
- Constructor injection: wiele klas przyjmuje zależności przez konstruktor, np. repozytoria z `http.Client`, kontrolery z repozytoriami i storage, ekrany z opcjonalnymi kontrolerami testowymi.
- Centralized route guards: logika dostępu do tras jest w `createAppRouter`.

W kodzie nie ma osobnych warstw typu use case/interactor. Ich rolę częściowo pełnią kontrolery, które łączą logikę UI, logikę domenową i wywołania repozytoriów.

### Dependency injection

Dependency injection jest ręczne i jawne.

Główne miejsce kompozycji produkcyjnej to `LocarioApp.initState`. Tam tworzone są konkretne implementacje:

- `HttpEventRepository`,
- `AuthApi`,
- `AuthStorage`,
- `AuthRepository`,
- `SessionController`,
- `FavoritesApi`,
- `EventRegistrationApi`,
- `HttpGroupRepository`,
- `HttpReviewRepository`,
- `CacheService`,
- `GroupController`,
- `EventDetailController`,
- `ReviewController`,
- `SavedEventsController`,
- `SavedFiltersController`,
- `NotificationsApi`,
- `NotificationController`.

Po utworzeniu obiekty są przekazywane:

- do konstruktorów innych kontrolerów,
- do `createAppRouter`,
- do scope'ów w drzewie widgetów,
- do `NotificationService.init`.

Scope'y są sposobem dystrybucji zależności w UI. Przykładowo `AuthScope.of(context)` udostępnia `SessionController`, `GroupScope.maybeOf(context)` udostępnia `GroupController`, a `CacheScope.maybeOf(context)` udostępnia `CacheService`.

Testy korzystają z tego, że zależności są wstrzykiwane przez konstruktory. Przykłady z repozytorium:

- `AuthRepository` przyjmuje `AuthApi`, `AuthTokenStorage` i opcjonalne `now`.
- `HttpEventRepository` przyjmuje opcjonalne `http.Client` i `baseUrl`.
- `ExploreController` przyjmuje `EventRepository`.
- `ExploreScreen` przyjmuje opcjonalny `ExploreController`, `ExploreMapViewModel`, `ExploreAreaController`, `MapStyleRepository`, `ShellHeaderController`.
- `CreateEventController` przyjmuje `EventRepository` i `SessionController`.
- `GroupController` przyjmuje `GroupRepository`, `EventRepository`, `CacheService`, `SessionController`.

Projekt nie używa automatycznego service locatora ani kontenera DI. Nie ma generowania zależności ani rejestracji providerów w osobnej konfiguracji.

### Zarządzanie błędami

Zarządzanie błędami jest rozproszone i zależne od modułu.

Warstwa API i repozytoriów zwykle rzuca wyjątki domenowe z opcjonalnym kodem statusu:

- `AuthApiException`,
- `AuthRepositoryException`,
- `EventRepositoryException`,
- `EventRegistrationApiException`,
- `GroupRepositoryException`,
- `ReviewRepositoryException`,
- `NotificationsApiException`,
- `FavoritesApiException`,
- `ChatSendException`.

Kontrolery obsługują błędy na kilka sposobów:

- zapisują komunikat błędu w polu stanu,
- przechodzą do stanu błędu,
- zachowują dane z cache,
- ignorują błąd jako niefatalny,
- wykonują fallback,
- czyszczą sesję przy błędach autoryzacji.

Przykłady z kodu:

- `SessionController` przy błędzie 401 lub 404 podczas pobierania profilu czyści tokeny i ustawia stan `unauthenticated`. Przy części innych błędów zachowuje stan `authenticated`.
- `ExploreController` mapuje błąd repozytorium na `ExploreErrorType.network`, `permission` albo `unknown`.
- `EventDetailController` pokazuje błąd tylko wtedy, gdy nie ma żadnego wydarzenia w stanie; jeśli istnieje cache, zachowuje poprzednie dane.
- `GroupController` w wielu operacjach ignoruje błędy i zostawia istniejący stan lub cache. Przy usuwaniu/ukrywaniu posta przywraca lokalny element, jeśli operacja zdalna się nie powiedzie.
- `SavedEventsController` zapisuje błędy w `_error`, próbuje rollbacku przy nieudanych operacjach i podczas synchronizacji loguje błędy przez `debugPrint`.
- `NotificationService` otacza część integracji platformowych blokami `try/catch` i traktuje błędy jako niefatalne.
- `FirestoreChatRepository` zamienia wybrane `FirebaseException` i `FirebaseAuthException` na komunikaty `ChatSendException`.

W UI błędy są prezentowane m.in. przez `StatePanel.error`, pola błędów formularzy lub lokalne komunikaty ekranów. Nie ma jednego globalnego mechanizmu obsługi błędów dla całej aplikacji.

Istotne ograniczenie widoczne w kodzie: część catchy jest pusta albo ograniczona do `debugPrint`. Oznacza to, że nie wszystkie błędy trafiają do użytkownika lub centralnego logowania.

### Inicjalizacja i cykl życia

Główny przepływ inicjalizacji:

1. `main()` wywołuje `WidgetsFlutterBinding.ensureInitialized()`.
2. Inicjalizowany jest Firebase przez `Firebase.initializeApp`.
3. Inicjalizowane są lokalne powiadomienia.
4. Uruchamiany jest `LocarioApp`.
5. `LocarioApp` tworzy repozytoria, API, kontrolery i router.
6. `CacheService.init()` jest wywoływany bez oczekiwania na wynik.
7. Kontrolery rozpoczynają ładowanie danych początkowych.
8. Kontrolery są opakowywane w zagnieżdżone scope'y.
9. `MaterialApp.router` otrzymuje konfigurację routingu, theme, locale i delegaty lokalizacji.

W `dispose` klasy `_LocarioAppState` usuwany jest listener sesji, dispose'owane są kontrolery, a cache zamyka bazę danych. `NotificationService` jest usługą statyczną i nie ma analogicznego dispose w `LocarioApp`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/app/navigation_history.dart`
- `lib/app/theme/theme_controller.dart`
- `lib/app/locale/locale_controller.dart`
- `lib/shared/cache/cache_service.dart`
- `lib/shared/auth/session_controller.dart`
- `lib/shared/auth/auth_repository.dart`
- `lib/shared/auth/auth_api.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/events/event_detail_controller.dart`
- `lib/shared/groups/group_controller.dart`
- `lib/shared/groups/group_repository.dart`
- `lib/features/explore/explore_screen.dart`
- `lib/features/explore/explore_controller.dart`
- `lib/features/chat/chat_repository.dart`
- `lib/shared/notifications/notification_controller.dart`
- `lib/shared/notifications/notification_service.dart`

## 3. Struktura projektu

Projekt ma strukturę typową dla aplikacji Flutter, ale kod aplikacyjny jest zorganizowany według podziału na warstwę aplikacyjną, moduły funkcjonalne i kod współdzielony. Poniższe drzewo pomija katalogi generowane automatycznie, takie jak `.dart_tool/`, `build/`, pliki efemeryczne platform oraz raporty buildów.

Najważniejsze katalogi:

```text
.
├── .github/
│   └── workflows/
├── .vscode/
├── android/
│   ├── app/
│   │   └── src/
│   │       ├── debug/
│   │       ├── main/
│   │       └── profile/
│   └── gradle/
├── assets/
│   ├── google_signin/
│   ├── instagram_profile/
│   ├── map_styles/
│   └── splash/
├── ios/
│   ├── Flutter/
│   ├── Runner/
│   └── RunnerTests/
├── lib/
│   ├── app/
│   │   ├── locale/
│   │   ├── settings/
│   │   └── theme/
│   ├── features/
│   │   ├── auth/
│   │   ├── chat/
│   │   ├── events/
│   │   ├── explore/
│   │   ├── groups/
│   │   ├── hub/
│   │   ├── inbox/
│   │   ├── legals/
│   │   ├── profile/
│   │   ├── reviews/
│   │   ├── saved/
│   │   └── shell/
│   ├── l10n/
│   │   └── features/
│   └── shared/
│       ├── auth/
│       ├── cache/
│       ├── config/
│       ├── events/
│       ├── groups/
│       ├── location/
│       ├── map/
│       ├── notifications/
│       ├── reviews/
│       ├── services/
│       └── widgets/
├── macos/
├── test/
│   ├── app/
│   ├── features/
│   ├── shared/
│   └── test_helpers/
├── tool/
└── windows/ (pusty katalog)
```

### `lib/`

Przeznaczenie: główny katalog kodu Dart aplikacji.

Zawartość: punkt wejścia `main.dart`, konfiguracja Firebase `firebase_options.dart`, warstwa aplikacyjna, moduły funkcjonalne, lokalizacje i kod współdzielony.

Zależności: zależy od pakietów Flutter i zależności z `pubspec.yaml`; podkatalogi `features/` i `shared/` są importowane przez `app/`.

Kiedy dodawać pliki: każdy nowy kod runtime aplikacji powinien trafiać do `lib/`, z wyborem podkatalogu zależnym od odpowiedzialności. Nowy ekran domenowy należy dodać do `features/`, kod współdzielony do `shared/`, a konfigurację aplikacyjną do `app/`.

### `lib/app/`

Przeznaczenie: kompozycja aplikacji, routing, globalne ustawienia, motyw i język.

Zawartość:

- `app.dart` - kompozycja aplikacji,
- `router.dart` - routing i redirecty,
- `navigation_history.dart` - śledzenie ostatniej bezpiecznej lokalizacji,
- `theme/` - konfiguracja jasnego i ciemnego motywu,
- `locale/` - kontrola języka,
- `settings/` - trwały zapis ustawień aplikacji.

Zależności: zależy od kontrolerów, scope'ów i repozytoriów z `shared/`, ekranów z `features/`, lokalizacji z `l10n/` oraz konfiguracji Firebase. `app/` jest najwyższą warstwą kompozycji i może importować moduły funkcjonalne, ale moduły funkcjonalne nie powinny przejmować odpowiedzialności za globalny bootstrap.

Kiedy dodawać pliki: gdy zmiana dotyczy całej aplikacji, np. nowa trasa globalna, nowy globalny scope, konfiguracja motywu, języka, ustawień lub historia nawigacji. Nie należy dodawać tutaj ekranów specyficznych dla jednej funkcji.

### `lib/app/theme/`

Przeznaczenie: definicja wyglądu aplikacji.

Zawartość: `app_theme.dart`, `app_theme_colors.dart`, `theme_controller.dart`, `theme_scope.dart`.

Zależności: zależy od Flutter Material oraz lokalnego storage ustawień przez `AppSettingsStore`.

Kiedy dodawać pliki: gdy pojawia się globalny element design systemu, rozszerzenie `ThemeExtension`, nowy kontroler/scope motywu albo konfiguracja wspólna dla całego UI.

### `lib/app/locale/`

Przeznaczenie: zarządzanie aktualnym językiem aplikacji.

Zawartość: `LocaleController` i `LocaleScope`.

Zależności: zależy od `AppSettingsStore` i Flutter `Locale`.

Kiedy dodawać pliki: gdy zmiana dotyczy globalnego wyboru języka lub sposobu propagacji locale w aplikacji.

### `lib/app/settings/`

Przeznaczenie: trwały zapis ustawień aplikacji.

Zawartość: abstrakcja `AppSettingsStore` i implementacja oparta o `SharedPreferences`.

Zależności: zależy od `shared_preferences` i Flutter typów `Locale` oraz `ThemeMode`.

Kiedy dodawać pliki: gdy dochodzi nowe globalne ustawienie aplikacji niezwiązane z pojedynczą funkcją domenową.

### `lib/features/`

Przeznaczenie: moduły funkcjonalne aplikacji.

Zawartość:

- `auth/` - logowanie i rejestracja,
- `chat/` - lista rozmów i wątki czatu,
- `events/` - szczegóły wydarzeń, galeria, rejestracje,
- `explore/` - mapa, lista, filtry i wyszukiwanie wydarzeń,
- `groups/` - grupy, feed, członkowie i moderacja,
- `hub/` - panel akcji i tworzenie wydarzeń,
- `inbox/` - ekran skrzynki,
- `legals/` - regulaminy, zgody i akceptacja wersji,
- `profile/` - profil, ustawienia, historia i edycja,
- `reviews/` - recenzje,
- `saved/` - zapisane wydarzenia i filtry,
- `shell/` - główna powłoka aplikacji z nawigacją.

Zależności: moduły w `features/` korzystają z `shared/`, `app` scope'ów, lokalizacji i modeli. Część modułów zależy od innych modułów tylko tam, gdzie kod już to robi, np. `events` i `saved` używają modeli Explore, a `hub/create_event` używa modeli wydarzeń i grup. Trasy do ekranów funkcjonalnych są rejestrowane w `app/router.dart`.

Kiedy dodawać pliki: gdy plik dotyczy konkretnej funkcji użytkownika lub konkretnego ekranu. Nowy obszar produktowy powinien dostać osobny podkatalog w `features/`. Plik należy trzymać w module, który jest jego właścicielem; do `shared/` przenosić dopiero wtedy, gdy kod jest używany przez wiele modułów.

### `lib/features/auth/`

Przeznaczenie: UI logowania i rejestracji.

Zawartość: `login_screen.dart`, `register_screen.dart`, widget ikony Google.

Zależności: korzysta z `SessionController` przez `AuthScope`, `ApiConfig.googleWebClientId`, Firebase Auth, Google Sign-In oraz lokalizacji.

Kiedy dodawać pliki: gdy zmiana dotyczy ekranów lub widgetów auth. Logika tokenów i komunikacji auth należy do `shared/auth/`, nie do `features/auth/`.

### `lib/features/explore/`

Przeznaczenie: odkrywanie wydarzeń na mapie i liście.

Zawartość: `ExploreScreen`, `ExploreController`, modele Explore, stan Explore, query filtrowania, view model mapy, kontroler obszaru oraz widgety mapy, listy, headera i filtrów.

Zależności: korzysta z `shared/events`, `shared/location`, `shared/map`, `shared/cache`, `shared/groups`, `saved` scope'ów, `shell/header` oraz lokalizacji.

Kiedy dodawać pliki: gdy funkcja dotyczy wyszukiwania, filtrowania, sortowania, mapy lub listy wydarzeń. Wspólne modele wydarzeń używane globalnie należy ostrożnie umieszczać w `shared/events` albo utrzymać w `features/explore/models.dart`, jeśli taki jest aktualny wzorzec kodu.

### `lib/features/events/`

Przeznaczenie: szczegóły wydarzenia, galeria, informacje i stan dołączenia do wydarzeń.

Zawartość: `event_screen.dart`, `JoinedEventsController`, scope joined events, widgety galerii i informacji.

Zależności: korzysta z `shared/events`, `shared/reviews`, `shared/services`, `saved` i modeli Explore.

Kiedy dodawać pliki: gdy zmiana dotyczy prezentacji szczegółów wydarzenia, galerii, akcji na wydarzeniu albo UI rejestracji. Repozytoria wydarzeń należy dodawać w `shared/events/`.

### `lib/features/saved/`

Przeznaczenie: zapisane wydarzenia i zapisane filtry.

Zawartość: ekran zapisanych wydarzeń, kontrolery, repozytoria `SharedPreferences`, modele filtrów i query zapisanych wydarzeń.

Zależności: korzysta z modeli Explore, `FavoritesApi`, `SessionController`, `EventRepository`, `SharedPreferences` i lokalizacji.

Kiedy dodawać pliki: gdy funkcja dotyczy lokalnego zapisu wydarzeń, synchronizacji ulubionych lub zapisanych filtrów. Kod ogólnego API ulubionych pozostaje w `shared/auth/favorites_api.dart`.

### `lib/features/groups/`

Przeznaczenie: ekrany społeczności i grup.

Zawartość: odkrywanie grup, szczegóły grupy, formularz grupy, komentarze postów, widget wyboru pinu.

Zależności: korzysta głównie z `shared/groups`, `shared/auth`, `shared/events`, `shared/config`, `shared/services`, Map/HTTP oraz lokalizacji.

Kiedy dodawać pliki: gdy zmiana dotyczy UI grup, postów, komentarzy, formularzy albo widoków społeczności. Modele i repozytorium grup powinny pozostać w `shared/groups/`.

### `lib/features/hub/`

Przeznaczenie: panel akcji oraz tworzenie/edycja wydarzeń.

Zawartość: placeholder Hub, ekran tworzenia wydarzenia, stan formularza, kontrolery formularza i lokalizacji, widgety sekcji formularza.

Zależności: korzysta z `shared/events`, `shared/auth`, `shared/groups`, `shared/services`, modeli Explore i lokalizacji.

Kiedy dodawać pliki: gdy zmiana dotyczy akcji dostępnych z Hub albo formularza tworzenia/edycji wydarzenia. Same definicje elementów Hub używane przez shell znajdują się w `features/shell/hub/`.

### `lib/features/chat/`

Przeznaczenie: UI i repozytorium czatu Firestore.

Zawartość: ekran listy rozmów, ekran wątku oraz `FirestoreChatRepository`.

Zależności: korzysta z Firebase Core, Firebase Auth, Cloud Firestore oraz `AuthScope`.

Kiedy dodawać pliki: gdy zmiana dotyczy czatu, rozmów, wiadomości lub mapowania dokumentów Firestore. Jeśli powstanie komunikacja REST dla czatu, powinna być wydzielona analogicznie do innych klas API.

### `lib/features/profile/`

Przeznaczenie: profil użytkownika, ustawienia, historia, edycja profilu i widoki organizatora.

Zawartość: ekrany profilu, ustawień, edycji, historii, wydarzeń organizatora i recenzji organizatora.

Zależności: korzysta z `SessionController`, `ThemeController`, `LocaleController`, `EventDetailController`, `ReviewController`, `ApiConfig`, `http`, usług współdzielonych i lokalizacji.

Kiedy dodawać pliki: gdy zmiana dotyczy UI profilu lub ustawień użytkownika. Logika sesji i API profilu należy do `shared/auth/`.

### `lib/features/legals/`

Przeznaczenie: regulaminy, prywatność, zgody i wymuszenie akceptacji wersji.

Zawartość: ekrany prawne, `LegalController`, wersje dokumentów, store akceptacji i zgód.

Zależności: korzysta z `SessionController` i `SharedPreferences`.

Kiedy dodawać pliki: gdy zmiana dotyczy dokumentów prawnych, wersjonowania akceptacji, zgód lub ekranów pomocy prawnej.

### `lib/features/reviews/`

Przeznaczenie: ekran wystawiania recenzji wydarzenia.

Zawartość: `event_review_screen.dart`.

Zależności: korzysta z `shared/reviews`, routingu i sesji użytkownika.

Kiedy dodawać pliki: gdy zmiana dotyczy UI recenzowania. Modele, formatery, repozytorium i kontroler recenzji znajdują się w `shared/reviews/`.

### `lib/features/shell/`

Przeznaczenie: główna powłoka aplikacji.

Zawartość: `Shell`, dolna nawigacja, taby, header, kontroler headera, scope headera, panel Hub i definicje akcji Hub.

Zależności: korzysta z `go_router`, lokalizacji, modeli Explore dla przełącznika mapa/lista oraz ekranów docelowych przez router.

Kiedy dodawać pliki: gdy zmiana dotyczy globalnej nawigacji, nagłówka, panelu Hub albo sposobu osadzania branchy routingu.

### `lib/features/inbox/`

Przeznaczenie: ekran skrzynki.

Zawartość: `inbox_screen.dart`.

Zależności: zależności są lokalne dla ekranu i routingu.

Kiedy dodawać pliki: gdy funkcja skrzynki zostanie rozbudowana o dodatkowe widoki lub lokalne komponenty.

### `lib/shared/`

Przeznaczenie: kod współdzielony między modułami funkcjonalnymi.

Zawartość:

- `auth/` - modele auth, API, repozytorium, storage, scope,
- `cache/` - cache sqflite,
- `config/` - konfiguracja API,
- `events/` - repozytoria wydarzeń, kontrolery kategorii i szczegółów,
- `groups/` - modele i repozytoria grup,
- `location/` - integracja geolokalizacji,
- `map/` - ładowanie i transformacja stylu mapy,
- `notifications/` - FCM, lokalna historia, preferencje,
- `reviews/` - modele, repozytorium i kontroler recenzji,
- `services/` - usługi pomocnicze,
- `widgets/` - współdzielone komponenty UI.

Zależności: `shared/` może zależeć od pakietów zewnętrznych, modeli domenowych i usług platformowych. Kod z `features/` może importować `shared/`. Należy unikać przenoszenia do `shared/` kodu specyficznego dla jednego ekranu.

Kiedy dodawać pliki: gdy kod jest używany przez więcej niż jeden moduł albo reprezentuje infrastrukturę wspólną: API, repozytorium, storage, cache, model domenowy, usługę platformową, scope lub wspólny widget.

### `lib/shared/auth/`

Przeznaczenie: współdzielona obsługa autoryzacji i sesji.

Zawartość: modele auth, `AuthApi`, `AuthRepository`, `AuthStorage`, `AuthScope`, `SessionController`, `FavoritesApi`.

Zależności: korzysta z `http`, `flutter_secure_storage`, `ApiConfig` i modeli profilu.

Kiedy dodawać pliki: gdy zmiana dotyczy tokenów, sesji, profilu użytkownika, ulubionych albo komunikacji auth używanej poza ekranami logowania.

### `lib/shared/events/`

Przeznaczenie: współdzielona logika wydarzeń.

Zawartość: `EventRepository`, `EventRegistrationApi`, kontrolery szczegółów i kategorii, scope'y oraz modele odpowiedzi slotów.

Zależności: korzysta z `http`, `ApiConfig`, `CacheService`, `SessionController`, `L10nService` i modeli Explore.

Kiedy dodawać pliki: gdy zmiana dotyczy API wydarzeń, rejestracji, kategorii lub współdzielonego stanu szczegółów wydarzenia.

### `lib/shared/groups/`

Przeznaczenie: współdzielona logika grup.

Zawartość: modele grup, repozytorium HTTP, kontroler grup, scope, cache grup użytkownika i style pinów.

Zależności: korzysta z `http`, `ApiConfig`, `CacheService`, `SessionController`, `EventRepository` i modeli Explore.

Kiedy dodawać pliki: gdy zmiana dotyczy modelu grup, komunikacji grup, kontrolera grup lub współdzielonych danych grupowych.

### `lib/shared/notifications/`

Przeznaczenie: powiadomienia push, lokalne powiadomienia, historia i preferencje.

Zawartość: `NotificationService`, `NotificationController`, API powiadomień, payload, typy, historia, preferencje i scope.

Zależności: korzysta z Firebase Messaging, Flutter Local Notifications, `go_router`, `SharedPreferences`, `SessionController` i `NotificationsApi`.

Kiedy dodawać pliki: gdy zmiana dotyczy typów powiadomień, obsługi FCM, historii, preferencji, payloadów lub rejestracji urządzenia.

### `lib/shared/reviews/`

Przeznaczenie: współdzielona obsługa recenzji.

Zawartość: modele, formatery, repozytorium HTTP, kontroler i scope.

Zależności: korzysta z `http`, `ApiConfig`, `CacheService`, `SessionController` i modeli Explore.

Kiedy dodawać pliki: gdy zmiana dotyczy danych, API lub stanu recenzji używanych przez więcej niż jeden ekran.

### `lib/shared/cache/`

Przeznaczenie: lokalny cache domenowy.

Zawartość: `CacheService` i `CacheScope`.

Zależności: korzysta z `sqflite` i `path`.

Kiedy dodawać pliki: gdy zmiana dotyczy ogólnego mechanizmu cache albo sposobu udostępniania cache w drzewie widgetów.

### `lib/shared/services/`

Przeznaczenie: małe usługi pomocnicze niezwiązane z jedną domeną.

Zawartość: usługi lokalizacji tekstów, feedbacku, kalendarza, map launch i share.

Zależności: zależne od konkretnych pakietów platformowych, np. `url_launcher`, `share_plus` lub lokalizacji.

Kiedy dodawać pliki: gdy usługa jest użyteczna w wielu modułach i nie pasuje do konkretnej domeny typu auth/events/groups.

### `lib/shared/widgets/`

Przeznaczenie: współdzielone komponenty UI.

Zawartość: `StatePanel`, `EventListCard`.

Zależności: korzysta z Flutter Material, lokalizacji i modeli wydarzeń.

Kiedy dodawać pliki: gdy widget jest używany w wielu modułach albo powinien tworzyć wspólny język UI aplikacji. Widget specyficzny dla jednego ekranu powinien pozostać przy tym ekranie lub w lokalnym katalogu `widgets/` danego feature'a.

### `lib/shared/config/`, `lib/shared/location/`, `lib/shared/map/`

Przeznaczenie: konfiguracja API, geolokalizacja i obsługa stylu mapy.

Zawartość: `ApiConfig`, `LocationService`, `GeolocatorLocationService`, `MapStyleRepository`.

Zależności: `config/` używa `String.fromEnvironment`, `location/` używa `geolocator` i `latlong2`, `map/` używa Flutter asset bundle oraz parsera JSON.

Kiedy dodawać pliki: gdy zmiana dotyczy globalnej konfiguracji środowiskowej, abstrakcji lokalizacji albo stylów mapy używanych poza pojedynczym widgetem.

### `lib/l10n/`

Przeznaczenie: lokalizacja językowa aplikacji.

Zawartość: pliki ARB, podzielone pliki tłumaczeń w `features/`, scalone `app_en.arb` i `app_pl.arb` oraz wygenerowane klasy `AppLocalizations`.

Zależności: używane przez Flutter gen-l10n i importowane w UI oraz `L10nService`.

Kiedy dodawać pliki: nowe klucze tekstów należy dodawać do odpowiedniego pliku ARB w `lib/l10n/features/<feature>/`. Po zmianach należy uruchomić generator lokalizacji. Plików wygenerowanych nie należy edytować ręcznie.

### `assets/`

Przeznaczenie: statyczne zasoby aplikacji.

Zawartość:

- `map_styles/` - JSON stylu mapy,
- `google_signin/` - zasoby przycisku/logotypu Google,
- `instagram_profile/` - ikona Instagrama,
- `splash/` - obrazy splash screen.

Zależności: zasoby są deklarowane w `pubspec.yaml` albo używane przez konfiguracje `flutter_native_splash` i `flutter_launcher_icons`.

Kiedy dodawać pliki: gdy aplikacja potrzebuje zasobu statycznego używanego w runtime albo konfiguracji platformowej. Po dodaniu zasobu runtime należy sprawdzić, czy jest wpisany w `pubspec.yaml`.

### `test/`

Przeznaczenie: testy jednostkowe i widgetowe.

Zawartość: testy podzielone podobnie do `lib/`, helpery testowe, fake repozytoria i fake serwisy.

Zależności: korzysta z `flutter_test`, `shared_preferences` mocków, `sqflite_common_ffi`, fake'ów i klas produkcyjnych z `lib/`.

Kiedy dodawać pliki: przy dodawaniu lub zmianie logiki kontrolera, repozytorium, modelu, routingu albo istotnego UI. Test powinien trafić do ścieżki odpowiadającej testowanemu modułowi, np. `test/features/explore/` dla `lib/features/explore/`.

### `test/test_helpers/`

Przeznaczenie: współdzielona infrastruktura testowa.

Zawartość: `test_app.dart`, fake location service, fake event repository, fake app settings store.

Zależności: korzysta z lokalizacji, Flutter test API i klas produkcyjnych.

Kiedy dodawać pliki: gdy helper lub fake jest używany przez więcej niż jeden test. Fake specyficzny dla jednego testu powinien zostać w tym pliku testowym.

### `tool/`

Przeznaczenie: skrypty pomocnicze uruchamiane lokalnie.

Zawartość: `generate_l10n.dart`.

Zależności: korzysta z Dart IO, JSON i polecenia `flutter gen-l10n`.

Kiedy dodawać pliki: gdy projekt potrzebuje powtarzalnego skryptu developerskiego, który nie jest częścią runtime aplikacji.

### `.github/workflows/`

Przeznaczenie: automatyzacja CI i buildów release.

Zawartość: workflow CI oraz workflow builda Android release.

Zależności: zależy od GitHub Actions, Java, Flutter i Gradle cache.

Kiedy dodawać pliki: gdy powstaje nowy proces automatyzacji, np. osobny build, publikacja, walidacja lub workflow manualny.

### `android/`

Przeznaczenie: konfiguracja platformy Android.

Zawartość: Gradle Kotlin DSL, manifesty, zasoby Android, ikony, splash screen, konfiguracja Google Services.

Zależności: zależy od Flutter Gradle Plugin, Android Gradle Plugin, Kotlin, Google Services i zasobów wygenerowanych przez narzędzia Flutter.

Kiedy dodawać pliki: gdy zmiana dotyczy uprawnień Androida, konfiguracji builda, deep linków, ikon, splash screen, Firebase Android albo kodu natywnego. Nie należy ręcznie modyfikować plików generowanych, jeśli są odtwarzane przez Flutter tooling.

### `ios/`

Przeznaczenie: konfiguracja platformy iOS.

Zawartość: projekt Xcode, `Info.plist`, assety Runnera, storyboardy, konfiguracje Flutter i testy Runnera.

Zależności: zależy od Flutter iOS tooling, Xcode i konfiguracji Firebase wygenerowanej w `firebase_options.dart`.

Kiedy dodawać pliki: gdy zmiana dotyczy uprawnień iOS, konfiguracji Runnera, assetów iOS, deep linków, Firebase iOS albo kodu natywnego.

### `macos/` i `windows/`

Przeznaczenie: stan platform desktopowych w repozytorium.

Zawartość: `macos/` zawiera pliki platformowe Flutter oraz pliki efemeryczne w `macos/Flutter/ephemeral/`, których nie należy traktować jako ręcznie utrzymywanej struktury. `windows/` istnieje jako katalog, ale nie zawiera plików źródłowych ani konfiguracji platformowej widocznej w repozytorium.

Zależności: `macos/` zależy od Flutter desktop tooling i konfiguracji platform. Dla `windows/` nie ma w repozytorium plików, z których można wywnioskować realną konfigurację.

Kiedy dodawać pliki: tylko gdy aplikacja ma być realnie rozwijana lub konfigurowana dla danej platformy. Plików efemerycznych nie należy edytować ręcznie. Dla Windows należy najpierw wygenerować albo dodać właściwą konfigurację platformową Flutter, a dopiero potem dokumentować jej szczegóły.

### `.vscode/`

Przeznaczenie: ustawienia edytora dla projektu.

Zawartość: `settings.json` z konfiguracją Java/Gradle dla VS Code.

Zależności: dotyczy wyłącznie środowiska VS Code.

Kiedy dodawać pliki: gdy ustawienie edytora jest potrzebne zespołowo i nie zawiera danych prywatnych użytkownika.

Katalogi świadomie pomijane w tej dokumentacji:

- `.dart_tool/` - generowany przez Dart/Flutter,
- `build/` - wyniki buildów,
- `android/build/` - wyniki buildów Android,
- `macos/Flutter/ephemeral/` - pliki efemeryczne Flutter,
- cache i pliki tymczasowe narzędzi.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/app.dart`
- `lib/features/explore/explore_screen.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/groups/group_repository.dart`
- `test/test_helpers/test_app.dart`
- `pubspec.yaml`
- `tool/generate_l10n.dart`
- `.github/workflows/ci.yml`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`

## 4. Konfiguracja projektu i zależności

Konfiguracja projektu jest rozproszona między standardowe pliki Fluttera, konfigurację platformową Android/iOS, pliki Firebase, workflow GitHub Actions oraz własne pliki konfiguracyjne aplikacji. Źródłem zależności Dart/Flutter jest `pubspec.yaml`.

### Wymagania środowiskowe

Z repozytorium wynikają następujące wymagania:

- Flutter SDK 3.41.5 - wskazany w `README.md` oraz w workflow GitHub Actions,
- Dart SDK zgodny z ograniczeniem `^3.11.3` w `pubspec.yaml`,
- Java dostępna dla buildów Android; workflow GitHub Actions używa Java 21,
- Android SDK i Gradle dla buildów Android,
- Xcode i narzędzia iOS dla buildów iOS,
- dostęp do konfiguracji Firebase zawartej w `firebase.json`, `lib/firebase_options.dart` i `android/app/google-services.json`.

`android/app/build.gradle.kts` ustawia kompatybilność źródeł Java na Java 17, natomiast CI instaluje Java 21. Oznacza to, że środowisko builda może używać JDK 21, ale konfiguracja kompilacji Androida jest ustawiona na target/source compatibility 17.

### Flutter SDK

W `README.md` i `.github/workflows/*.yml` wskazany jest Flutter `3.41.5`. Workflow CI i release używają `subosito/flutter-action@v2` z:

```yaml
flutter-version: "3.41.5"
```

Projekt jest aplikacją Flutter, co widać również w `.metadata` przez `project_type: app`.

### Dart SDK

W `pubspec.yaml` ustawiono:

```yaml
environment:
  sdk: ^3.11.3
```

Kod używa składni współczesnego Darta, m.in. `switch` expressions, sealed classes i collection features.

### Instalacja zależności

Podstawowa instalacja zależności:

```bash
flutter pub get
```

Ta komenda jest używana również w workflow CI i release. Zależności są blokowane przez `pubspec.lock`.

Najważniejsze zależności runtime:

- `go_router` - routing,
- `http` - komunikacja REST,
- `firebase_core` - inicjalizacja Firebase,
- `firebase_auth` - logowanie Google i sesja Firebase dla czatu,
- `firebase_messaging` - push notifications,
- `cloud_firestore` - czat,
- `flutter_local_notifications` - lokalne powiadomienia,
- `maplibre` - mapa,
- `geolocator` i `geocoding` - lokalizacja i geokodowanie,
- `latlong2` - współrzędne i dystanse,
- `shared_preferences` - lokalne ustawienia i proste dane,
- `flutter_secure_storage` - tokeny auth,
- `sqflite` - lokalny cache,
- `cached_network_image` - obrazki sieciowe,
- `url_launcher`, `share_plus`, `flutter_svg`, `file_picker`.

Najważniejsze zależności developerskie:

- `flutter_test` - testy,
- `sqflite_common_ffi` - testowy backend sqflite,
- `flutter_lints` - reguły lint,
- `flutter_launcher_icons` - generowanie ikon,
- `flutter_native_splash` - splash screen.

### build_runner

W projekcie nie ma skonfigurowanego `build_runner`.

W `pubspec.yaml` nie występuje zależność `build_runner`, `json_serializable`, `freezed` ani inne typowe generatory kodu. Modele JSON są serializowane ręcznie przez `toJson`, `fromJson`, `jsonEncode` i `jsonDecode`.

Kod generowany przez Flutter l10n powstaje przez `flutter gen-l10n`, a nie przez `build_runner`.

### Uruchamianie aplikacji

Podstawowe uruchomienie:

```bash
flutter run
```

Uruchomienie z nadpisaniem konfiguracji API:

```bash
flutter run --dart-define=LOCARIO_API_BASE_URL=http://localhost:8080
```

Uruchomienie z nadpisaniem Google Web Client ID:

```bash
flutter run --dart-define=LOCARIO_GOOGLE_WEB_CLIENT_ID=<client-id>
```

Projekt ma konfiguracje platform Android, iOS, macOS i Windows, ale najpełniej skonfigurowany jest Android. README wymienia standardowe komendy developerskie:

```bash
flutter pub get
flutter analyze
flutter test --no-pub
```

### Debugowanie

Debugowanie odbywa się standardowymi narzędziami Flutter:

- `flutter run` dla uruchomienia debug,
- hot reload/hot restart przez Flutter tooling,
- `flutter analyze` dla analizy statycznej,
- `flutter test --no-pub` dla testów,
- DevTools zgodnie z konfiguracją `devtools_options.yaml`.

Android debug/profile manifest zawiera uprawnienie `INTERNET`, opisane jako wymagane przez Flutter tooling do komunikacji z uruchomioną aplikacją, breakpointów i hot reload.

W kodzie aplikacji część błędów diagnostycznych jest wypisywana przez `debugPrint`, np. w auth, saved events, chat i usługach pomocniczych.

### Konfiguracja Android

Konfiguracja Android znajduje się w katalogu `android/`.

Najważniejsze pliki:

- `android/settings.gradle.kts`,
- `android/build.gradle.kts`,
- `android/app/build.gradle.kts`,
- `android/app/src/main/AndroidManifest.xml`,
- `android/app/src/debug/AndroidManifest.xml`,
- `android/app/src/profile/AndroidManifest.xml`,
- `android/app/google-services.json`.

`android/settings.gradle.kts` konfiguruje:

- Flutter plugin loader,
- Android Gradle Plugin `8.11.1`,
- Google Services plugin `4.3.15`,
- Kotlin Android plugin `2.2.20`,
- repozytoria `google`, `mavenCentral`, `gradlePluginPortal`.

`android/app/build.gradle.kts` konfiguruje:

- plugin `com.android.application`,
- plugin `com.google.gms.google-services`,
- plugin `kotlin-android`,
- Flutter Gradle Plugin,
- namespace `com.example.locario`,
- `compileSdk`, `minSdk`, `targetSdk` z konfiguracji Fluttera,
- Java source/target compatibility 17,
- Kotlin JVM target 17,
- core library desugaring,
- release signing tymczasowo ustawiony na debug signing config.

W pliku jest TODO dotyczące docelowego `applicationId` oraz release signing. Aktualne `applicationId` to `com.example.locario`.

`AndroidManifest.xml` zawiera:

- główną aktywność `MainActivity`,
- label `locario`,
- ikonę launcher,
- konfigurację launch mode,
- deep link HTTPS dla `locario-events.web.app/events`,
- domyślny kanał Firebase Messaging `high_importance_channel`,
- uprawnienia lokalizacji `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
- uprawnienie `POST_NOTIFICATIONS`,
- queries dla `ACTION_PROCESS_TEXT`.

### Konfiguracja iOS

Konfiguracja iOS istnieje w katalogu `ios/`.

Najważniejsze pliki:

- `ios/Runner/Info.plist`,
- `ios/Runner/AppDelegate.swift`,
- `ios/Runner/SceneDelegate.swift`,
- `ios/Runner.xcodeproj/`,
- `ios/Runner.xcworkspace/`,
- `ios/Flutter/Debug.xcconfig`,
- `ios/Flutter/Release.xcconfig`,
- `ios/Runner/Assets.xcassets/`.

`Info.plist` zawiera m.in.:

- `CFBundleDisplayName` ustawione na `Locario`,
- konfigurację sceny Flutter,
- `UILaunchStoryboardName`,
- orientacje ekranu,
- opisy uprawnień lokalizacji,
- opisy dostępu do kalendarza,
- deep link custom scheme `locario`,
- `UIBackgroundModes` z `remote-notification`.

Firebase options dla iOS znajdują się w `lib/firebase_options.dart`, wygenerowanym przez FlutterFire. W `firebase.json` widoczna jest konfiguracja iOS oraz macOS przez ten plik Dart.

### Flavors

W repozytorium nie ma skonfigurowanych flavors.

Nie widać:

- osobnych flavorów w Gradle,
- osobnych schematów Xcode dla dev/stage/prod poza standardowym Runner,
- osobnych plików konfiguracyjnych per flavor,
- osobnych entrypointów Dart typu `main_dev.dart`.

Różnicowanie środowiska odbywa się obecnie przez `--dart-define`, przede wszystkim dla `LOCARIO_API_BASE_URL` i `LOCARIO_GOOGLE_WEB_CLIENT_ID`.

### Zmienne środowiskowe i dart-define

Kod używa `String.fromEnvironment` w `ApiConfig`.

Dostępne klucze:

- `LOCARIO_API_BASE_URL`,
- `LOCARIO_GOOGLE_WEB_CLIENT_ID`.

Przykłady:

```bash
flutter run --dart-define=LOCARIO_API_BASE_URL=http://localhost:8080
flutter build apk --release --dart-define=LOCARIO_API_BASE_URL=https://example.com
```

Jeżeli wartości nie zostaną przekazane, aplikacja używa wartości domyślnych zapisanych w `ApiConfig`.

### Lokalizacja i generowanie l10n

Konfiguracja lokalizacji znajduje się w `l10n.yaml`.

Generowanie lokalizacji:

```bash
dart run tool/generate_l10n.dart
```

Na Windows dostępny jest helper:

```bat
gen-l10n.bat
```

Skrypt scala pliki ARB z `lib/l10n/features/` do `lib/l10n/app_en.arb` i `lib/l10n/app_pl.arb`, a następnie uruchamia `flutter gen-l10n`.

### Pliki konfiguracyjne

Najważniejsze pliki konfiguracyjne projektu:

| Plik | Rola |
| --- | --- |
| `pubspec.yaml` | zależności, assety, wersja aplikacji, splash, launcher icons |
| `pubspec.lock` | zablokowane wersje zależności |
| `analysis_options.yaml` | konfiguracja lintera i analizy statycznej |
| `l10n.yaml` | konfiguracja Flutter gen-l10n |
| `firebase.json` | konfiguracja FlutterFire |
| `lib/firebase_options.dart` | opcje Firebase per platforma |
| `android/app/google-services.json` | konfiguracja Firebase dla Androida |
| `android/settings.gradle.kts` | konfiguracja pluginów Gradle |
| `android/build.gradle.kts` | konfiguracja głównego projektu Android |
| `android/app/build.gradle.kts` | konfiguracja aplikacji Android |
| `android/app/src/main/AndroidManifest.xml` | manifest Android |
| `ios/Runner/Info.plist` | konfiguracja iOS Runner |
| `.github/workflows/ci.yml` | analiza, formatowanie i testy w CI |
| `.github/workflows/build-release-android.yml` | build release Android |
| `devtools_options.yaml` | ustawienia DevTools |
| `.metadata` | metadane projektu Flutter |
| `.vscode/settings.json` | ustawienia VS Code |

### Analiza statyczna i CI

Konfiguracja statycznej analizy znajduje się w `analysis_options.yaml`. Projekt rozszerza `flutter_lints` i włącza dodatkowe reguły, m.in.:

- `prefer_const_constructors`,
- `prefer_const_declarations`,
- `prefer_const_literals_to_create_immutables`,
- `unawaited_futures`,
- `require_trailing_commas`,
- `prefer_single_quotes`,
- `avoid_print`,
- `cancel_subscriptions`,
- `close_sinks`.

Workflow CI wykonuje:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --no-pub
```

Workflow release Android wykonuje:

```bash
flutter pub get
flutter build apk --release --no-pub
flutter build appbundle --release --no-pub
```

Budowa AAB jest opcjonalna i zależy od inputu `build_aab` w workflow manualnym.

Najważniejsze pliki wykorzystane podczas analizy:

- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `README.md`
- `l10n.yaml`
- `tool/generate_l10n.dart`
- `gen-l10n.bat`
- `firebase.json`
- `lib/firebase_options.dart`
- `lib/shared/config/api_config.dart`
- `.github/workflows/ci.yml`
- `.github/workflows/build-release-android.yml`
- `android/settings.gradle.kts`
- `android/build.gradle.kts`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/profile/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## 5. Bootstrap aplikacji

Punkt wejścia aplikacji znajduje się w `lib/main.dart`.

Sekwencja startowa:

1. Flutter binding jest inicjalizowany.
2. Firebase jest inicjalizowany na podstawie `DefaultFirebaseOptions.currentPlatform`.
3. Inicjalizowane są lokalne powiadomienia przez `NotificationService.initLocalNotifications`.
4. Uruchamiany jest `LocarioApp`.

`LocarioApp` jest `StatefulWidget`, ponieważ przechowuje długowieczne kontrolery i repozytoria. W `initState` tworzone są m.in.:

- `SharedPreferencesAppSettingsStore`,
- `HttpEventRepository`,
- `AuthApi`,
- `AuthStorage`,
- `AuthRepository`,
- `SessionController`,
- `FavoritesApi`,
- `EventRegistrationApi`,
- `HttpGroupRepository`,
- `HttpReviewRepository`,
- `CacheService`,
- `GroupController`,
- `EventDetailController`,
- `ReviewController`,
- `JoinedEventsController`,
- `LegalController`,
- `GoRouter`,
- `SavedEventsController`,
- `SavedFiltersController`,
- `NotificationsApi`,
- `NotificationController`.

Po utworzeniu zależności uruchamiane są operacje ładowania:

- język,
- motyw,
- kategorie,
- zapisane wydarzenia,
- zapisane filtry,
- wydarzenia, do których użytkownik dołączył,
- sesja użytkownika,
- akceptacja regulaminu,
- historia i preferencje powiadomień.

`SessionController` jest obserwowany przez `LocarioApp`. Po zmianie sesji aplikacja ładuje grupy użytkownika i ponawia rejestrację urządzenia dla push notifications. Po wylogowaniu invalidowany jest cache `my_groups`.

W `dispose` wszystkie kontrolery i cache są zwalniane.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/main.dart`
- `lib/app/app.dart`
- `lib/firebase_options.dart`
- `lib/shared/notifications/notification_service.dart`
- `lib/shared/auth/session_controller.dart`

## 6. Zarządzanie stanem

Projekt używa mechanizmów stanu dostarczanych przez Flutter SDK: przede wszystkim `ChangeNotifier`, `Listenable`, `InheritedNotifier`, `InheritedWidget`, `StatefulWidget`, `setState`, `AnimatedBuilder` i `ListenableBuilder`. W kodzie nie ma zewnętrznej biblioteki do zarządzania stanem, takiej jak Bloc, Riverpod, Provider, Redux albo MobX.

W praktyce projekt ma własny, lekki model zarządzania stanem:

- kontrolery domenowe dziedziczą po `ChangeNotifier`,
- scope'y udostępniają kontrolery w drzewie widgetów,
- ekrany pobierają kontrolery ze scope'ów lub dostają je przez konstruktor,
- zmiany danych są publikowane przez `notifyListeners()`,
- UI reaguje przez scope, `AnimatedBuilder`, `ListenableBuilder` albo lokalne `setState`.

### Użyta biblioteka i mechanizm

Nie została użyta osobna biblioteka state management. Użyty jest Flutter foundation/widgets:

- `ChangeNotifier` - baza dla kontrolerów stanu,
- `InheritedNotifier<T>` - scope dla kontrolerów będących `Listenable`,
- `InheritedWidget` - scope dla obiektów, które nie muszą same emitować zmian, np. `CacheScope`,
- `Listenable.merge` - połączenie kilku kontrolerów do przebudowy `MaterialApp.router`,
- `AnimatedBuilder` i `ListenableBuilder` - reakcja UI na zmiany `Listenable`,
- `StatefulWidget` i `setState` - lokalny stan ekranu.

W repozytorium nie ma komentarza architektonicznego wyjaśniającego decyzję o wyborze takiego podejścia. Z kodu wynika natomiast, że taki model pasuje do obecnej struktury, ponieważ kontrolery są jawnie tworzone, łatwo wstrzykiwane w testach i nie wymagają dodatkowej konfiguracji globalnej.

### Dlaczego taki model pasuje do kodu projektu

Na podstawie kodu można wskazać praktyczne powody stosowania `ChangeNotifier` i własnych scope'ów:

- aplikacja ma ograniczoną liczbę globalnych kontrolerów tworzonych w jednym miejscu, w `LocarioApp`,
- kontrolery są długo żyjące i mają jawny cykl życia `initState`/`dispose`,
- ekrany mogą przyjmować zależności przez konstruktor, co upraszcza testy,
- `go_router` może obserwować `SessionController` i `LegalController` przez `refreshListenable`,
- UI Fluttera naturalnie współpracuje z `Listenable`,
- nie trzeba utrzymywać osobnej konfiguracji providerów ani generowania kodu.

Nie oznacza to, że projekt ma centralny store. Stan jest podzielony domenowo: auth, grupy, wydarzenia, zapisane wydarzenia, powiadomienia, recenzje, motyw i język mają osobne kontrolery.

### Przepływ danych

Typowy przepływ danych wygląda tak:

```text
Akcja użytkownika lub lifecycle ekranu
  -> metoda kontrolera
  -> repozytorium / API / storage / cache
  -> dane albo błąd
  -> aktualizacja pól kontrolera
  -> notifyListeners()
  -> UI odczytuje nowe wartości i przebudowuje fragment ekranu
```

Przykład dla sesji:

1. `LoginScreen` wywołuje `SessionController.login`.
2. `SessionController` wywołuje `AuthRepository.login`.
3. `AuthRepository` zapisuje tokeny przez `AuthStorage`.
4. `SessionController` aktualizuje `_tokens`, `_profile`, `_status` i `_isBusy`.
5. Kontroler wywołuje `notifyListeners()`.
6. `AuthScope`, router i ekrany zależne od sesji otrzymują nowy stan.

Przykład dla Explore:

1. `ExploreScreen` aktualizuje zapytanie, filtr, lokalizację albo widok.
2. `ExploreController` pobiera dane przez `EventRepository` albo czyta cache.
3. Kontroler zapisuje listę wydarzeń i wylicza `ExploreState`.
4. Po `notifyListeners()` ekran przebudowuje mapę albo listę.

Przykład dla grup:

1. `GroupDetailsScreen` wywołuje `GroupController.loadGroupDetail`.
2. Kontroler próbuje wczytać cache przez `CacheService`.
3. Kontroler pobiera świeże dane przez `GroupRepository`.
4. Aktualizuje pola detail, members, feed, events, reports.
5. UI obserwujący `GroupScope` dostaje nowy stan.

Główne wzorce:

- kontroler dziedziczy po `ChangeNotifier`,
- ekran lub scope nasłuchuje kontrolera,
- zmiana stanu kończy się `notifyListeners()`,
- scope udostępnia kontroler w drzewie widgetów,
- część ekranów przyjmuje kontrolery przez konstruktor, co ułatwia testowanie.

### Lokalizacja klas odpowiedzialnych za stan

Klasy odpowiedzialne za stan są rozmieszczone według odpowiedzialności:

- stan globalny aplikacji: `lib/app/`,
- stan sesji i współdzielonych domen: `lib/shared/`,
- stan konkretnej funkcji lub ekranu: `lib/features/`,
- stan lokalny widgetu: bezpośrednio w klasie `State<...>`.

Przykładowe scope'y i ich lokalizacja:

- `AuthScope`,
- `ThemeScope`,
- `LocaleScope`,
- `CategoryScope`,
- `GroupScope`,
- `EventDetailScope`,
- `ReviewScope`,
- `SavedEventsScope`,
- `SavedFiltersScope`,
- `JoinedEventsScope`,
- `NotificationScope`,
- `LegalScope`,
- `ShellHeaderScope`,
- `CacheScope`.

Przykładowe kontrolery globalne i współdzielone:

- `SessionController` - status sesji, tokeny, profil, login, logout, refresh,
- `ThemeController` - tryb jasny/ciemny/systemowy,
- `LocaleController` - aktualny język aplikacji,
- `CategoryController` - kategorie wydarzeń,
- `SavedEventsController` - zapisane wydarzenia i synchronizacja,
- `GroupController` - grupy, feed, członkowie, moderacja,
- `EventDetailController` - szczegóły wydarzenia i sloty,
- `ReviewController` - recenzje,
- `NotificationController` - historia, preferencje i token FCM,
- `LegalController` - wymaganie akceptacji dokumentów prawnych.

Przykładowe kontrolery lokalne lub funkcjonalne:

- `ExploreController` - stan listy i filtrów Explore,
- `ExploreMapViewModel` - stan lokalizacji i mapy,
- `ExploreAreaController` - wybór obszaru,
- `CreateEventController` - stan formularza wydarzenia,
- `CreateEventLocationController` - lokalizacja w formularzu wydarzenia,
- `ShellHeaderController` - stan widoku mapa/lista i filtrów nagłówka.

Stan lokalny ekranów występuje głównie w modułach o bardziej złożonej interakcji. Przykładowo `ExploreScreen` utrzymuje:

- lokalny `TextEditingController`,
- `FocusNode`,
- timer auto-refresh,
- timer minimalnego czasu ładowania,
- ostatnio przeszukany obszar,
- centrum mapy,
- pending search radius,
- lokalny lub wstrzyknięty `ExploreController`,
- lokalny lub wstrzyknięty `ExploreMapViewModel`.

### Typy stanu stosowane w projekcie

W kodzie występuje kilka sposobów modelowania stanu:

- proste pola prywatne i gettery, np. `_isLoading`, `_error`, `_records`,
- enum statusu, np. `SessionStatus`,
- sealed class dla stanu ekranu, np. `ExploreState`,
- niemutowalne obiekty formularza z `copyWith`, np. `CreateEventState`,
- kolekcje zwracane jako niemodyfikowalne widoki, np. `List.unmodifiable` i `Set.unmodifiable`,
- lokalny stan widgetu przez pola klasy `State`.

`ExploreState` jest najbardziej formalnym przykładem stanu ekranu. Rozróżnia:

- `ExploreLoading`,
- `ExploreData`,
- `ExploreDataLoading`,
- `ExploreEmpty`,
- `ExploreError`.

W innych kontrolerach stan jest zwykle reprezentowany przez zestaw pól, np. lista danych, flaga ładowania i opcjonalny błąd.

### Jak dodać nowy stan

Sposób dodania nowego stanu zależy od zakresu funkcji.

Jeżeli stan jest lokalny dla jednego widgetu:

1. Dodać pole w klasie `State`.
2. Aktualizować je przez `setState`.
3. Zwolnić zasoby w `dispose`, jeżeli stan używa kontrolerów, timerów lub subskrypcji.

Jeżeli stan należy do istniejącego kontrolera:

1. Dodać prywatne pole, np. `_isLoadingDetails`.
2. Dodać publiczny getter.
3. Aktualizować pole w metodach kontrolera.
4. Po zmianie wywołać `notifyListeners()`.
5. Jeżeli stan wymaga czyszczenia, uwzględnić go w metodach `clear`, `load`, `dispose` lub obsłudze wylogowania.
6. Dodać test kontrolera, jeśli zmiana dotyczy logiki albo przepływu.

Jeżeli stan jest nowym obszarem funkcjonalnym:

1. Utworzyć kontroler dziedziczący po `ChangeNotifier`.
2. Wstrzyknąć zależności przez konstruktor.
3. Dodać scope oparty o `InheritedNotifier`, jeśli stan ma być dostępny w wielu miejscach drzewa.
4. Utworzyć instancję kontrolera w `LocarioApp`, jeśli ma być globalna.
5. Opakować odpowiedni fragment drzewa widgetów w scope.
6. Zwolnić kontroler w `dispose`.
7. Jeśli router ma reagować na ten stan, dodać kontroler do `refreshListenable` lub istniejącego `Listenable.merge`.

Jeżeli stan ma formę wariantów ekranu:

1. Rozważyć sealed class podobną do `ExploreState`.
2. Dodać warianty loading/data/empty/error tylko wtedy, gdy UI realnie rozróżnia te stany.
3. W ekranie obsłużyć wszystkie warianty przez `switch`.

### Dobre praktyki stosowane w projekcie

W kodzie widać kilka powtarzalnych dobrych praktyk:

- prywatne pola stanu i publiczne gettery,
- używanie `notifyListeners()` tylko po zmianie stanu,
- zabezpieczenia przed równoległymi operacjami przez flagi typu `_isBusy`, `_isLoading`, `_isSyncing`,
- zwracanie niemodyfikowalnych kolekcji przez `List.unmodifiable` albo `Set.unmodifiable`,
- wstrzykiwanie zależności przez konstruktor zamiast tworzenia ich bezpośrednio w kontrolerze,
- możliwość podmiany kontrolerów i repozytoriów w testach,
- czyszczenie listenerów, timerów i kontrolerów w `dispose`,
- zachowywanie danych z cache przy błędzie odświeżania,
- rozdzielanie stanu globalnego i lokalnego UI,
- trzymanie tokenów i profilu w jednym źródle prawdy, czyli `SessionController`,
- używanie scope'ów zamiast przekazywania globalnych kontrolerów przez wiele poziomów widgetów.

Są też praktyki, które warto zachować przy dalszym rozwoju:

- nie tworzyć stanu globalnego dla danych używanych tylko przez jeden ekran,
- nie przenosić lokalnego stanu formularza do `LocarioApp`,
- nie udostępniać mutowalnych list bezpośrednio z kontrolerów,
- nie wykonywać komunikacji HTTP bezpośrednio w UI, jeśli logika ma być używana ponownie,
- uzupełniać testy przy dodawaniu nowego kontrolera albo nowej ścieżki stanu,
- pamiętać o `removeListener`, `cancel` i `dispose` dla listenerów, timerów i subskrypcji.

W projekcie nie ma jednej centralnej warstwy store. Stan jest rozproszony według domeny, co upraszcza zależności, ale wymaga utrzymywania jasnych granic między kontrolerami i dokumentowania przepływów między modułami.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/auth/session_controller.dart`
- `lib/app/theme/theme_controller.dart`
- `lib/app/locale/locale_controller.dart`
- `lib/features/explore/explore_controller.dart`
- `lib/features/explore/explore_state.dart`
- `lib/features/explore/explore_screen.dart`
- `lib/features/explore/map_view_model.dart`
- `lib/features/hub/create_event/create_event_controller.dart`
- `lib/features/hub/create_event/create_event_state.dart`
- `lib/shared/groups/group_controller.dart`
- `lib/shared/notifications/notification_controller.dart`
- `lib/features/shell/header/header_controller.dart`

## 7. Routing i nawigacja

Routing jest zdefiniowany centralnie w `lib/app/router.dart` i używa biblioteki `go_router`. Konfiguracja routera jest tworzona przez funkcję `createAppRouter`, która przyjmuje dwa kontrolery:

- `SessionController` - stan logowania i profil użytkownika,
- `LegalController` - stan wymaganej akceptacji dokumentów prawnych.

Router używa globalnego `_rootNavigatorKey`. Domyślna lokalizacja startowa to `/explore`.

### Konfiguracja routingu

`GoRouter` jest skonfigurowany z:

- `navigatorKey: _rootNavigatorKey`,
- `initialLocation: '/explore'`,
- `refreshListenable: Listenable.merge([sessionController, legalController])`,
- funkcją `redirect`,
- listą tras.

`refreshListenable` powoduje ponowną ocenę redirectów, gdy zmieni się sesja użytkownika albo stan akceptacji dokumentów prawnych. To jest główny mechanizm powiązania routingu ze stanem aplikacji.

Główna nawigacja korzysta z `StatefulShellRoute.indexedStack`. W shellu są dwa branche:

```text
StatefulShellRoute.indexedStack
├── branch 0: /explore
└── branch 1: /profile
```

Shell buduje widget `Shell`, który zawiera dolną nawigację, nagłówek i warstwę Hub. Dla ekranów root-section router ustala:

- `currentSection`,
- czy ekran jest rootem sekcji,
- czy pokazać header,
- czy pokazać przełącznik mapa/lista dla Explore.

Pozostałe trasy są rejestrowane poza branchem shell, z `parentNavigatorKey: _rootNavigatorKey`. Dzięki temu otwierają się jako root-level screens, a nie jako zawartość jednego branch'a shell route.

Wszystkie strony są tworzone przez `NoTransitionPage` opakowany w `RouteHistoryReporter`. Ten wrapper zapisuje aktualną lokalizację i informację, czy może być traktowana jako "bezpieczna" lokalizacja powrotu po logowaniu.

### Główne ekrany i trasy

| Trasa | Ekran | Uwagi |
| --- | --- | --- |
| `/explore` | `ExploreScreen` | główny ekran odkrywania wydarzeń, branch shell |
| `/profile` | `ProfileScreen` | profil, branch shell |
| `/profile/settings` | `SettingsScreen` | ustawienia profilu i aplikacji |
| `/profile/edit` | `EditProfileScreen` | edycja profilu, trasa chroniona |
| `/profile/reviews` | `OrganizerReviewsScreen` | recenzje organizatora, wymaga dostępu organizatora |
| `/profile/my-events` | `OrganizerEventsScreen` | wydarzenia organizatora |
| `/profile/history` | `EventHistoryScreen` | historia wydarzeń, trasa chroniona |
| `/hub/messages` | `ChatListScreen` | lista rozmów, trasa chroniona |
| `/hub/saved` | `SavedScreen` | zapisane wydarzenia, dostęp publiczny |
| `/hub/community` | `GroupDiscoverScreen` | odkrywanie grup, trasa chroniona |
| `/hub/create-event` | `CreateEventScreen` | tworzenie wydarzenia, trasa chroniona |
| `/groups/create` | `GroupFormScreen` | tworzenie grupy, wymaga organizatora albo admina |
| `/groups/:groupId` | `GroupDetailsScreen` | szczegóły grupy |
| `/groups/:groupId/edit` | `GroupFormScreen` | edycja grupy, trasa chroniona |
| `/chat/:chatId` | `ChatThreadScreen` | wątek czatu, trasa chroniona |
| `/inbox` | `InboxScreen` | skrzynka, trasa chroniona |
| `/events/:eventId` | `EventScreen` | szczegóły wydarzenia |
| `/events/:eventId/edit` | `CreateEventScreen` | edycja wydarzenia, trasa chroniona |
| `/events/:eventId/review` | `EventReviewScreen` | recenzja wydarzenia, trasa chroniona |
| `/auth/login` | `LoginScreen` | logowanie |
| `/auth/register` | `RegisterScreen` | rejestracja |
| `/legal/terms` | `PolicyScreen(type: terms)` | regulamin |
| `/legal/privacy` | `PolicyScreen(type: privacy)` | polityka prywatności |
| `/legal/help` | `HelpScreen` | pomoc |
| `/legal/consents` | `ConsentsScreen` | zgody |
| `/legal/accept` | `LegalAcceptanceScreen` | wymuszona akceptacja dokumentów |

Akcje Hub są zdefiniowane w liście `hubActionItems`:

- `messages` -> `/hub/messages`,
- `saved` -> `/hub/saved`,
- `community` -> `/hub/community`.

### Przechodzenie między ekranami

W kodzie występują dwa podstawowe sposoby przechodzenia między ekranami:

- `context.push(...)` - dodaje nową trasę na stos,
- `router.go(...)` lub `navigationShell.goBranch(...)` - zmienia bieżącą lokalizację albo branch.

Przykłady z kodu:

- `ShellBottomNav` wybiera branch przez `navigationShell.goBranch`.
- Kliknięcie elementu Hub wywołuje `context.push(item.routePath)`.
- `ExploreScreen` otwiera szczegóły wydarzenia przez `context.push('/events/${event.id}')`.
- Ekrany i kontrolery mogą kierować użytkownika do tras czatu, grup albo wydarzeń przez ścieżki z parametrami.
- `NotificationService` po tapnięciu powiadomienia wywołuje callback nawigacji, który używa payloadu z trasą.

`StatefulShellRoute.indexedStack` zachowuje stan branchy shell route. Dzięki temu przełączanie między `/explore` i `/profile` nie musi odtwarzać całej zawartości branchy od zera.

### Przekazywanie parametrów

Router przekazuje parametry trzema sposobami:

1. Parametry ścieżki przez `state.pathParameters`.
2. Query parameters przez `state.uri.queryParameters`.
3. Znormalizowana lokalizacja z deep linka.

Parametry ścieżki:

- `/events/:eventId` przekazuje `eventId` do `EventScreen`,
- `/events/:eventId/edit` przekazuje `eventId` jako `editingEventId` do `CreateEventScreen`,
- `/events/:eventId/review` przekazuje `eventId` do `EventReviewScreen`,
- `/groups/:groupId` przekazuje `groupId` do `GroupDetailsScreen`,
- `/groups/:groupId/edit` przekazuje `groupId` do `GroupFormScreen`,
- `/chat/:chatId` przekazuje `chatId` do `ChatThreadScreen`.

Query parameters:

- `/auth/login?from=...&target=...` przekazuje `returnLocation` i `targetLocation` do `LoginScreen`,
- `/auth/register?from=...&target=...` przekazuje `returnLocation` i `targetLocation` do `RegisterScreen`,
- `/hub/create-event?groupId=...` przekazuje `initialGroupId` do `CreateEventScreen`,
- `/chat/:chatId?recipientId=...&recipientName=...&groupName=...&isGroup=true&participantIds=a,b` przekazuje dane rozmowy do `ChatThreadScreen`,
- `/legal/accept?from=...` pozwala wrócić do poprzedniej lokalizacji po akceptacji dokumentów,
- `?header=false` może ukryć header shell na root-section screen.

`participantIds` dla czatu jest przekazywane jako lista rozdzielona przecinkami i przetwarzane przez `split(',')` z odfiltrowaniem pustych wartości.

### Deep linki i normalizacja lokalizacji

Funkcja `normalizeIncomingLocation` obsługuje kilka formatów linków przychodzących:

- `locario://events/<id>` -> `/events/<id>`,
- `https://locario-events.web.app/events/<id>` -> `/events/<id>`,
- `/messages` -> `/hub/messages`,
- `/<uuid>` -> `/events/<uuid>`, jeżeli segment wygląda jak UUID i nie jest jedną z głównych tras.

Dla UUID używany jest `_uuidLikePattern`. Router wykonuje normalizację w funkcji `redirect`, zanim przejdzie do pozostałych reguł ochrony tras.

Na Androidzie manifest deklaruje deep link dla hosta `locario-events.web.app` i ścieżki `/events`.

### Autoryzacja i ochrona tras

Ochrona tras jest zdefiniowana w funkcji `_requiresAuth`. Za chronione uznawane są m.in.:

- `/hub/messages`,
- `/chat/...`,
- `/hub/create-event`,
- `/hub/community`,
- `/groups/create`,
- `/groups/:groupId/edit`,
- `/inbox`,
- `/profile/edit`,
- `/profile/reviews`,
- `/profile/history`,
- `/events/:eventId/review`,
- `/events/:eventId/edit`.

Jeżeli użytkownik nie jest zalogowany i przechodzi na trasę chronioną, router przekierowuje go do `/auth/login`. Login dostaje:

- `from` - ostatnią bezpieczną lokalizację zapamiętaną przez `NavigationHistoryController`,
- `target` - docelową trasę, na którą użytkownik próbował wejść.

Bezpieczna lokalizacja to trasa, która:

- nie wymaga auth,
- nie jest `/auth/login`,
- nie jest `/auth/register`.

Jeżeli użytkownik jest już zalogowany i próbuje wejść na `/auth/login` lub `/auth/register`, router przenosi go do:

1. `target` z query parameters,
2. `from` z query parameters,
3. `/profile`, jeśli nie ma żadnego z powyższych.

### Ochrona na podstawie roli i profilu

Router zawiera dodatkowe reguły zależne od profilu:

- `/profile/reviews` wymaga `sessionController.profile?.hasOrganizerReviewAccess == true`,
- `/groups/create` wymaga `sessionController.profile?.organizer == true` albo `sessionController.profile?.admin == true`.

Jeżeli użytkownik nie spełnia warunku dostępu do recenzji organizatora, zostaje przeniesiony na `/profile`.

Jeżeli użytkownik nie jest organizatorem ani adminem i próbuje wejść na `/groups/create`, zostaje przeniesiony na `/hub/community`.

### Ochrona przez akceptację dokumentów prawnych

Router używa `LegalController` do wymuszenia akceptacji aktualnych wersji dokumentów prawnych.

Jeżeli:

- użytkownik jest zalogowany,
- `legalController.isAcceptanceRequired == true`,
- aktualna lokalizacja nie jest `/legal/accept`,

router przekierowuje na:

```text
/legal/accept?from=<aktualna_lokalizacja>
```

Jeżeli użytkownik jest zalogowany, akceptacja nie jest już wymagana i znajduje się na `/legal/accept`, router przenosi go do `from` albo `/profile`.

### Historia nawigacji

`NavigationHistoryController` przechowuje:

- `_currentLocation`,
- `_lastSafeLocation`.

`RouteHistoryReporter` zapisuje lokalizację po zakończeniu klatki przez `WidgetsBinding.instance.addPostFrameCallback`. Dzięki temu router może przekazać do loginu sensowne `from`, gdy użytkownik trafia na trasę chronioną.

### Testy routingu

W `test/app/router_test.dart` sprawdzane są m.in.:

- normalizacja deep linków,
- dostęp niezalogowanego użytkownika do `/hub/saved`,
- przekierowanie niezalogowanego użytkownika z `/hub/create-event` do loginu,
- otwieranie tras czatu dla zalogowanego użytkownika,
- przekierowanie `/messages` do `/hub/messages`, a następnie do loginu przy braku sesji,
- blokada `/profile/reviews` dla użytkownika bez dostępu organizatora.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/router.dart`
- `lib/app/navigation_history.dart`
- `lib/features/shell/shell.dart`
- `lib/features/shell/nav/bottom_nav.dart`
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart`
- `lib/features/chat/chat_screen.dart`
- `lib/features/events/event_screen.dart`
- `lib/features/groups/group_details_screen.dart`
- `lib/features/hub/create_event/create_event_screen.dart`
- `lib/features/legals/legal_controller.dart`
- `test/app/router_test.dart`

## 8. Powłoka aplikacji i nawigacja UI

Główna powłoka aplikacji znajduje się w module `features/shell`.

`Shell` składa się z:

- górnego nagłówka `ShellHeader`,
- obszaru aktualnego branch'a `StatefulNavigationShell`,
- dolnej nawigacji `ShellBottomNav`,
- warstwy Hub otwieranej z dolnej nawigacji.

Dolna nawigacja ma trzy główne elementy:

- Explore,
- Hub,
- Profile.

Hub nie jest osobnym branchem shell route. Jest warstwą modalną/panelem akcji. Kliknięcie akcji w Hub prowadzi do tras root-level, np.:

- wiadomości,
- zapisane wydarzenia,
- społeczność.

`ShellHeaderController` przechowuje stan nagłówka:

- aktualny widok Explore: mapa lub lista,
- wybrane indeksy filtrów kategorii,
- specjalny indeks `0` oznaczający filtr "wszystko".

Explore korzysta z `ShellHeaderScope`, aby synchronizować stan nagłówka z filtrowaniem i przełączaniem widoku.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/shell/shell.dart`
- `lib/features/shell/header/header.dart`
- `lib/features/shell/header/header_controller.dart`
- `lib/features/shell/header/header_scope.dart`
- `lib/features/shell/hub/hub_panel.dart`
- `lib/features/shell/nav/bottom_nav.dart`

## 9. Komunikacja z backendem

Frontend komunikuje się z backendem REST przez klasy API i repozytoria znajdujące się głównie w `lib/shared/`. Kod nie ma jednej wspólnej klasy klienta sieciowego ani centralnego modułu typu `ApiClient`. Każda klasa API lub repozytorium tworzy własny `http.Client`, chyba że klient zostanie przekazany przez konstruktor.

Warstwa komunikacji z backendem jest rozproszona według domen:

- `shared/auth/` - autoryzacja, profil i ulubione,
- `shared/events/` - wydarzenia, kategorie, media wydarzeń i rejestracje,
- `shared/groups/` - grupy, feed, członkowie, komentarze, raporty i media grup,
- `shared/reviews/` - recenzje,
- `shared/notifications/` - rejestracja urządzenia i historia powiadomień,
- pojedyncze miejsca w UI, np. `EditProfileScreen` i `pin_selector.dart`, wykonują upload mediów bezpośrednio przez `http`.

### Klient HTTP

Projekt używa pakietu `http` i typu `http.Client`.

Typowy konstruktor klasy sieciowej wygląda tak:

```dart
ClassName({http.Client? client, String? baseUrl})
  : _client = client ?? http.Client(),
    _baseUrl = baseUrl ?? ApiConfig.baseUrl;
```

Taki wzorzec występuje m.in. w:

- `AuthApi`,
- `FavoritesApi`,
- `HttpEventRepository`,
- `EventRegistrationApi`,
- `HttpGroupRepository`,
- `HttpReviewRepository`,
- `NotificationsApi`.

Dzięki opcjonalnemu `http.Client` testy mogą podstawiać własne implementacje albo klienta testowego. Dzięki opcjonalnemu `baseUrl` testy repozytoriów mogą używać adresów typu `http://example.com` albo `http://localhost`.

W kodzie nie ma centralnego klienta z globalnymi nagłówkami, kolejką żądań, retry policy ani wspólną obsługą odpowiedzi. Każda klasa samodzielnie:

1. buduje `Uri`,
2. przygotowuje nagłówki,
3. wykonuje metodę HTTP,
4. sprawdza status,
5. dekoduje odpowiedź,
6. rzuca własny wyjątek przy błędzie.

### Konfiguracja API

Konfiguracja API znajduje się w `ApiConfig`.

Dostępne wartości:

- `LOCARIO_API_BASE_URL` - bazowy URL backendu REST,
- `LOCARIO_GOOGLE_WEB_CLIENT_ID` - identyfikator klienta Google używany przez logowanie Google.

Obie wartości są pobierane przez `String.fromEnvironment`, czyli mogą być przekazane przez `--dart-define`. Jeżeli nie zostaną przekazane, kod używa wartości domyślnych zapisanych w `ApiConfig`.

Repozytoria budują adresy przez prywatne metody typu:

```dart
Uri _uri(String path) => Uri.parse('$_baseUrl$path');
```

W części kodu adres jest budowany bezpośrednio przez `Uri.parse('${ApiConfig.baseUrl}/...')`, np. w uploadzie profilu lub selektorze pinu grupy.

### Struktura warstwy sieciowej

Warstwa sieciowa nie jest jednym katalogiem `network/`. Jest podzielona domenowo.

Najważniejsze klasy:

| Klasa | Rola |
| --- | --- |
| `AuthApi` | niskopoziomowe wywołania auth i profilu |
| `AuthRepository` | koordynacja `AuthApi` i storage tokenów |
| `FavoritesApi` | operacje ulubionych wydarzeń |
| `HttpEventRepository` | komunikacja REST dla wydarzeń, kategorii i mediów wydarzeń |
| `EventRegistrationApi` | rejestracja i anulowanie udziału w wydarzeniu oraz sloty |
| `HttpGroupRepository` | komunikacja REST dla grup, feedu, członków, komentarzy, raportów i mediów |
| `HttpReviewRepository` | komunikacja REST dla recenzji |
| `NotificationsApi` | rejestracja urządzenia i operacje historii powiadomień |

Nazewnictwo jest mieszane:

- klasy z sufiksem `Api` zwykle reprezentują bardziej bezpośredni klient HTTP,
- klasy z sufiksem `Repository` zwykle mapują dane na modele domenowe i są używane przez kontrolery.

Kontrolery nie powinny znać szczegółów JSON ani statusów HTTP poza wyjątkami rzucanymi przez repozytoria. W praktyce większość kontrolerów wywołuje metody repozytorium/API i reaguje na sukces albo wyjątek.

### Autoryzacja

Autoryzacja opiera się na tokenach przechowywanych lokalnie w `AuthStorage`, który implementuje `AuthTokenStorage` i używa `flutter_secure_storage`.

Zapisywane wartości:

- access token,
- refresh token,
- token type,
- data wygaśnięcia access tokena.

`SessionController` jest głównym źródłem tokenów dla aplikacji. Kontrolery domenowe pobierają tokeny z `SessionController`, np.:

- `SavedEventsController` używa tokenów przy synchronizacji ulubionych,
- `GroupController` używa tokenów przy operacjach grup,
- `EventDetailController` używa tokenów przy części danych zależnych od użytkownika,
- `ReviewController` używa tokenów przy recenzjach użytkownika,
- `NotificationController` używa tokena przy rejestracji urządzenia.

Nagłówek autoryzacji jest dodawany ręcznie w klasach API/repozytoriów. Najczęściej ma postać:

```text
Authorization: <tokenType> <accessToken>
```

Domyślnym `tokenType` jest `Bearer`. W `NotificationsApi` helper `_authHeaders` tworzy nagłówek w formacie `Authorization: Bearer <token>`.

Niektóre metody dopuszczają opcjonalny token, np. pobieranie wydarzeń lub grup może być wykonywane jako użytkownik anonimowy albo zalogowany. Wtedy nagłówek `Authorization` jest dodawany tylko, gdy `accessToken` nie jest nullem.

### Interceptory

W kodzie nie ma interceptorów HTTP.

Nie występuje:

- globalny interceptor dodający token,
- globalny interceptor odświeżający token,
- globalny interceptor logujący żądania,
- globalny interceptor mapujący błędy,
- wspólny mechanizm retry.

Każda klasa sieciowa ręcznie przygotowuje nagłówki i ręcznie obsługuje statusy odpowiedzi. Refresh token również nie jest zaimplementowany jako interceptor. Odświeżanie tokena odbywa się jawnie w `SessionController` i `AuthRepository`.

### Refresh token

Refresh token jest obsługiwany przez:

- `AuthRepository.refresh`,
- `AuthApi.refresh`,
- `SessionController._tryRefreshTokens`.

Przepływ przy starcie aplikacji:

1. `SessionController.load` odczytuje tokeny z `AuthRepository.readTokens`.
2. Jeżeli nie ma tokenów, ustawia stan `unauthenticated`.
3. Jeżeli access token jest przeterminowany, wywołuje `_tryRefreshTokens`.
4. `_tryRefreshTokens` deleguje do `AuthRepository.refresh`.
5. `AuthRepository.refresh` odczytuje refresh token ze storage i wywołuje `AuthApi.refresh`.
6. Nowe tokeny są zapisywane w storage.
7. `SessionController` aktualizuje `_tokens` i kontynuuje ładowanie profilu.

Refresh po błędzie 401 występuje jawnie w wybranych metodach `SessionController`:

- pobieranie profilu przez `_fetchProfileWithRefresh`,
- aktualizacja profilu przez `_updateProfileWithRefresh`,
- zmiana hasła przez `_changePasswordWithRefresh`.

Jeżeli refresh się nie powiedzie, `SessionController` czyści storage, usuwa tokeny z pamięci i ustawia stan `unauthenticated`.

Istotne ograniczenie widoczne w kodzie: repozytoria domenowe, takie jak `HttpEventRepository`, `HttpGroupRepository` czy `HttpReviewRepository`, same nie odświeżają tokena po 401. Refresh jest skupiony w logice sesji, a nie w globalnej warstwie HTTP.

### Obsługa błędów

Każda domenowa klasa sieciowa definiuje własny typ wyjątku. Przykłady:

- `AuthApiException`,
- `AuthRepositoryException`,
- `FavoritesApiException`,
- `EventRepositoryException`,
- `EventRegistrationApiException`,
- `GroupRepositoryException`,
- `ReviewRepositoryException`,
- `NotificationsApiException`.

Typowy wzorzec:

1. Frontend wykonuje żądanie.
2. Sprawdza `response.statusCode`.
3. Jeżeli kod nie jest oczekiwany, rzuca wyjątek z komunikatem i opcjonalnym `statusCode`.
4. Kontroler wywołujący repozytorium decyduje, czy pokazać błąd, zachować cache, wykonać fallback, czy zignorować błąd jako niefatalny.

Przykłady obsługi:

- `AuthApi` przy błędach wybranych operacji loguje szczegóły przez `debugPrint` i rzuca `AuthApiException`.
- `SessionController` przy 401 lub 404 podczas pobierania profilu czyści sesję.
- `ExploreController` mapuje `EventRepositoryException` na `ExploreErrorType`.
- `EventDetailController` zapisuje błąd tylko wtedy, gdy nie ma danych wydarzenia w stanie.
- `GroupController` często zachowuje cache albo ignoruje błąd, aby nie czyścić ekranu z istniejących danych.
- `ApiNotificationHistoryRepository` ma lokalny fallback historii powiadomień, gdy operacje API nie mogą zostać wykonane.

Nie ma jednego wspólnego typu błędu dla całej aplikacji. Nie ma też centralnego error handlera dla wszystkich odpowiedzi HTTP.

### Serializacja modeli

Serializacja jest ręczna i oparta o:

- `jsonEncode`,
- `jsonDecode`,
- metody `toJson`,
- fabryki lub konstruktory `fromJson`.

Modele requestów budują mapy JSON ręcznie, np.:

- `RegisterRequest.toJson`,
- `LoginRequest.toJson`,
- `RefreshTokenRequest.toJson`,
- `EventRequest.toJson`,
- requesty grup i recenzji.

Modele odpowiedzi są tworzone z map JSON przez metody typu:

```dart
Model.fromJson(Map<String, dynamic>.from(decoded))
```

Repozytoria często walidują kształt odpowiedzi przed mapowaniem:

- jeżeli odpowiedź powinna być obiektem, sprawdzają `decoded is Map`,
- jeżeli odpowiedź może być listą albo stroną z `content`, obsługują oba warianty,
- przy nieoczekiwanym formacie rzucają wyjątek domenowy albo zwracają pustą listę, zależnie od klasy.

W kodzie nie ma generatora modeli JSON typu `json_serializable`, `freezed` ani build runnera. Wszystkie mapowania są zapisane ręcznie.

### Upload mediów

Upload mediów używa wzorca presigned URL.

Przepływ w kodzie:

1. Frontend wysyła żądanie o presigned upload URL.
2. Odpowiedź zawiera co najmniej `uploadUrl` i `objectKey`; w części kodu także `publicUrl` i `expiresAt`.
3. Frontend wykonuje `PUT` na `uploadUrl` z odpowiednim `Content-Type`.
4. Dla mediów wydarzeń frontend potwierdza upload w repozytorium wydarzeń i może ustawić thumbnail.
5. Dla części mediów grup lub profilu kod wykorzystuje `objectKey` w kolejnych operacjach domenowych.

Typ MIME jest ustalany lokalnie na podstawie rozszerzenia pliku. Obsługiwane są m.in. `png`, `webp`, `gif`, `jpg`, `jpeg`; domyślnie używane jest `image/jpeg`.

### Zakres endpointów wynikający z kodu

Dokumentacja nie rozszerza kontraktu backendu ponad to, co da się wywnioskować z kodu. Z klas API i repozytoriów wynika, że frontend komunikuje się z obszarami:

- auth i profil,
- wydarzenia, mapa wydarzeń, kategorie i media,
- rejestracja na wydarzenia i sloty,
- grupy, członkowie, feed, komentarze, raporty i media,
- recenzje,
- ulubione wydarzenia,
- powiadomienia i historia powiadomień,
- presigned upload URL.

Szczegółowa lista endpointów powinna być generowana lub spisywana bezpośrednio z klas API/repozytoriów, aby nie dokumentować tras, których kod frontendu nie używa.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/config/api_config.dart`
- `lib/shared/auth/auth_api.dart`
- `lib/shared/auth/auth_repository.dart`
- `lib/shared/auth/auth_storage.dart`
- `lib/shared/auth/favorites_api.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/events/event_registration_api.dart`
- `lib/shared/groups/group_repository.dart`
- `lib/shared/reviews/review_repository.dart`
- `lib/shared/notifications/notifications_api.dart`
- `lib/shared/notifications/api_notification_history_repository.dart`
- `lib/features/profile/edit_profile_screen.dart`
- `lib/features/groups/widgets/pin_selector.dart`

## 10. Cache i dane lokalne

Projekt używa kilku mechanizmów lokalnego przechowywania danych:

- `flutter_secure_storage` - tokeny auth,
- `SharedPreferences` - ustawienia, zapisane wydarzenia, zapisane filtry, zgody, preferencje powiadomień,
- `sqflite` - cache domenowy dla danych pobieranych z API.

`CacheService` tworzy bazę `locario_cache.db` z tabelą:

- `key`,
- `data`,
- `hash`,
- `fetched_at`.

Cache działa jako cache-aside:

1. Kontroler próbuje odczytać dane z cache.
2. Jeśli dane istnieją, UI może je pokazać od razu.
3. Równolegle lub później kontroler pobiera świeże dane z API.
4. Świeże dane są hashowane przez `jsonEncode(...).hashCode`.
5. Jeżeli hash różni się od zapisanego, stan i cache są aktualizowane.

W projekcie nie widać TTL dla cache. Inwalidacja odbywa się ręcznie przez:

- `invalidate(key)`,
- `invalidateByPrefix(prefix)`,
- `clear()`.

Przykładowe klucze cache:

- `event_<eventId>`,
- `map_events_<lat>_<lng>_<radius>`,
- `discover_groups_<...>`,
- `my_groups`,
- `group_detail_<groupId>`,
- `group_members_<groupId>`,
- `group_feed_<groupId>_page<page>`,
- `group_events_<groupId>`,
- `organizer_rating_<organizerId>`.

Zapisane wydarzenia są przechowywane lokalnie jako JSON w `SharedPreferences` pod kluczem `saved.events.v1`. Dodatkowo, po zalogowaniu, są synchronizowane z backendową listą ulubionych. Kontroler rozróżnia stany synchronizacji:

- `localOnly`,
- `pendingSync`,
- `synced`,
- `syncFailed`.

Zapisane filtry są przechowywane pod kluczem `saved.filters.v1` i mogą mieć włączone powiadomienia.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/cache/cache_service.dart`
- `lib/shared/auth/auth_storage.dart`
- `lib/app/settings/app_settings_store.dart`
- `lib/features/saved/saved_events_repository.dart`
- `lib/features/saved/saved_events_controller.dart`
- `lib/features/saved/saved_filters_repository.dart`
- `lib/features/saved/saved_filters_controller.dart`

## 11. Logika aplikacji

Logika aplikacji jest podzielona między moduły funkcjonalne w `lib/features/`, kontrolery i repozytoria współdzielone w `lib/shared/` oraz warstwę kompozycji w `lib/app/`. Kod nie zawiera osobnej warstwy use case. W praktyce rolę logiki biznesowej pełnią kontrolery `ChangeNotifier`, repozytoria domenowe, klasy API oraz część modeli.

Podstawowy schemat działania modułów:

```text
Ekran / widget
  -> kontroler modułu albo kontroler współdzielony
  -> repozytorium / API / usługa platformowa / storage
  -> model domenowy albo wyjątek
  -> aktualizacja stanu kontrolera
  -> notifyListeners()
  -> przebudowa UI
```

### Moduły funkcjonalne

| Moduł | Lokalizacja | Główna odpowiedzialność |
| --- | --- | --- |
| App | `lib/app/` | bootstrap, routing, globalna kompozycja zależności, theme, locale |
| Shell | `lib/features/shell/` | globalna powłoka, dolna nawigacja, nagłówek Explore, panel Hub |
| Auth | `lib/features/auth/`, `lib/shared/auth/` | logowanie, rejestracja, sesja, tokeny, profil użytkownika |
| Explore | `lib/features/explore/` | mapa i lista wydarzeń, lokalizacja, filtrowanie, sortowanie |
| Events | `lib/features/events/`, `lib/shared/events/` | szczegóły wydarzeń, rejestracja, sloty, kategorie |
| Hub/Create Event | `lib/features/hub/` | panel akcji, tworzenie i edycja wydarzeń |
| Saved | `lib/features/saved/` | zapisane wydarzenia, zapisane filtry, synchronizacja ulubionych |
| Groups | `lib/features/groups/`, `lib/shared/groups/` | grupy, feed, członkowie, moderacja, komentarze, media |
| Chat | `lib/features/chat/` | lista rozmów i wiadomości przez Firestore |
| Notifications | `lib/shared/notifications/` | FCM, lokalne powiadomienia, historia, preferencje |
| Profile | `lib/features/profile/` | profil, ustawienia, edycja danych, historia, widoki organizatora |
| Legals | `lib/features/legals/` | regulaminy, zgody, wymuszenie akceptacji wersji |
| Reviews | `lib/features/reviews/`, `lib/shared/reviews/` | recenzje wydarzeń i organizatorów |
| Shared Services | `lib/shared/services/` | usługi pomocnicze używane przez wiele ekranów |

### Odpowiedzialność modułów

Moduł App tworzy obiekty długowieczne i łączy je w działającą aplikację. `LocarioApp` tworzy konkretne implementacje API, repozytoriów i kontrolerów, uruchamia początkowe ładowanie danych oraz opakowuje aplikację w scope'y. `createAppRouter` definiuje trasy i reguły dostępu.

Moduł Shell odpowiada za układ aplikacji po zalogowaniu i niezależnie od logowania: dolną nawigację, przełączanie branchy `StatefulShellRoute`, panel Hub oraz stan nagłówka Explore. `ShellHeaderController` nie pobiera danych z API; przechowuje wyłącznie stan UI, który jest konsumowany przez `ExploreScreen`.

Moduł Auth odpowiada za formularze logowania i rejestracji oraz współdzielony stan sesji. Ekrany auth wywołują metody `SessionController`, a kontroler deleguje komunikację do `AuthRepository` i `AuthApi`. Tokeny są przechowywane przez `AuthStorage`. `SessionController` jest wykorzystywany przez routing, grupy, wydarzenia, zapisane wydarzenia, profil, powiadomienia i dokumenty prawne.

Moduł Explore odpowiada za widok mapy/listy wydarzeń. `ExploreScreen` koordynuje stan UI, mapę, wyszukiwarkę, filtr zaawansowany i przełącznik widoku. `ExploreController` pobiera dane przez `EventRepository`, filtruje je przez `ExploreEventQuery` i wystawia `ExploreState`. `ExploreMapViewModel` odpowiada za lokalizację oraz centrum mapy.

Moduł Events odpowiada za szczegóły wydarzenia i akcje użytkownika na wydarzeniu. `EventDetailController` ładuje szczegóły, używa cache i pobiera sloty. `JoinedEventsController` utrzymuje zbiór wydarzeń, do których użytkownik jest zapisany, na podstawie profilu sesji i wywołań `EventRegistrationApi`.

Moduł Hub/Create Event odpowiada za akcje dostępne z panelu Hub oraz formularz tworzenia i edycji wydarzeń. `CreateEventController` przechowuje stan formularza, waliduje pola, buduje `EventRequest`, wywołuje `EventRepository.createEvent` albo `updateEvent` i obsługuje upload wybranych obrazów.

Moduł Saved odpowiada za lokalne zapisanie wydarzeń i filtrów oraz synchronizację zapisanych wydarzeń z ulubionymi użytkownika po zalogowaniu. `SavedEventsController` komunikuje się z `FavoritesApi`, `SessionController`, `EventRepository` i `SavedEventsRepository`. `SavedFiltersController` umożliwia przeniesienie zapisanego filtra do Explore przez pole `pendingLoadFilter`.

Moduł Groups odpowiada za ekrany grup, ale główna logika znajduje się w `GroupController` i `HttpGroupRepository`. Kontroler przechowuje osobne stany discover, my groups, detail, members, feed, events, join requests i reports. Korzysta z `SessionController` do tokena, `CacheService` do cache i repozytorium grup do komunikacji HTTP.

Moduł Chat odpowiada za rozmowy i wiadomości. `FirestoreChatRepository` obserwuje Firestore i zapisuje wiadomości. Ekrany czatu korzystają ze streamów zwracanych przez repozytorium oraz z `AuthScope`, aby znać aktualnego użytkownika aplikacji.

Moduł Notifications odpowiada za token FCM, lokalne powiadomienia, historię, preferencje i nawigację po tapnięciu. `NotificationService` integruje się z Firebase Messaging i pluginem lokalnych powiadomień. `NotificationController` przechowuje historię i preferencje oraz rejestruje urządzenie przez `NotificationsApi`, jeżeli dostępna jest sesja.

Moduł Profile odpowiada za prezentację danych profilu, ustawienia i edycję. Korzysta z `SessionController` jako źródła profilu, z `ThemeController` i `LocaleController` dla ustawień oraz z kontrolerów wydarzeń/recenzji dla widoków organizatora i historii.

Moduł Legals odpowiada za dokumenty prawne i wymuszenie akceptacji. `LegalController` obserwuje `SessionController`, ładuje zaakceptowane wersje z lokalnego store i udostępnia routerowi informację `isAcceptanceRequired`.

Moduł Reviews odpowiada za recenzje. `ReviewController` pobiera średnią ocenę organizatora, recenzje wydarzenia, recenzję bieżącego użytkownika i podsumowanie recenzji organizatora. `EventReviewScreen` wykorzystuje ten stan do wystawienia recenzji.

### Komunikacja między modułami

Moduły komunikują się głównie przez kontrolery udostępnione w scope'ach, router oraz współdzielone repozytoria i modele. Nie ma centralnego event busa ani globalnego store.

Najważniejsze kanały komunikacji:

- Scope'y: `AuthScope`, `GroupScope`, `EventDetailScope`, `ReviewScope`, `SavedEventsScope`, `SavedFiltersScope`, `JoinedEventsScope`, `NotificationScope`, `LegalScope`, `ThemeScope`, `LocaleScope`.
- Router: przekazuje identyfikatory i parametry przez ścieżki oraz query parameters, np. `eventId`, `groupId`, `chatId`, `target`, `from`.
- Kontrolery współdzielone: `SessionController`, `GroupController`, `EventDetailController`, `ReviewController`, `NotificationController`.
- Repozytoria współdzielone: `EventRepository`, `GroupRepository`, `ReviewRepository`, `FavoritesApi`, `EventRegistrationApi`.
- Modele współdzielone: `ExploreEvent`, `Category`, modele grup, modele auth, modele recenzji i payload powiadomień.
- Lokalne store'y: `SharedPreferences` i `CacheService` umożliwiają utrzymanie danych między ekranami i uruchomieniami aplikacji.

Przykłady komunikacji między modułami widoczne w kodzie:

- Router używa `SessionController` i `LegalController`, aby decydować o redirectach.
- `ExploreScreen` pobiera kategorie z `CategoryScope`, zapisane wydarzenia z `SavedEventsScope`, zapisane filtry z `SavedFiltersScope`, grupy użytkownika z `GroupScope` oraz stan nagłówka z `ShellHeaderScope`.
- `SavedFiltersController.loadFilterToExplore` ustawia pending filter, a `ExploreScreen` odczytuje go i stosuje w `ExploreController`.
- `SavedEventsController` po zalogowaniu synchronizuje lokalne rekordy z ulubionymi z profilu przez `SessionController.refreshProfile`.
- `JoinedEventsController` aktualizuje stan po `joinEvent` i `cancelRegistration`, a następnie odświeża profil przez `SessionController`.
- `GroupDetailsScreen` może budować identyfikatory czatu przez `FirestoreChatRepository.directChatId` albo `groupChatId`, a przejście do czatu odbywa się przez routing.
- `NotificationService` po tapnięciu powiadomienia tworzy payload i używa callbacku z `NotificationController`, który wykonuje nawigację przez router.
- `CreateEventController` korzysta z `SessionController` do tokenów oraz z `EventRepository` do zapisu wydarzenia; po zapisie nie emituje globalnego eventu odświeżenia, tylko ustawia stan formularza.

### Przepływ między ekranami i logiką biznesową

Ekrany w projekcie zwykle nie wykonują bezpośrednio złożonej logiki biznesowej. Ich typowa odpowiedzialność to:

- pobrać kontroler ze scope'a albo utworzyć lokalny kontroler,
- zsynchronizować lokalne kontrolery UI z kontrolerem domenowym,
- wywołać metodę kontrolera po akcji użytkownika,
- zareagować na zmianę stanu przez `setState`, `AnimatedBuilder`, `ListenableBuilder` albo scope,
- pokazać loading, pusty stan, błąd lub dane.

Kontrolery wykonują logikę właściwą dla funkcji:

- walidują dane formularza,
- pobierają dane z repozytoriów,
- synchronizują dane lokalne i zdalne,
- aktualizują cache,
- mapują błędy na stan UI,
- udostępniają listy, flagi ładowania i komunikaty błędów.

Repozytoria i API odpowiadają za techniczne pobranie lub zapis danych:

- budowanie `Uri`,
- dodawanie nagłówków,
- serializację JSON,
- dekodowanie odpowiedzi,
- mapowanie odpowiedzi na modele,
- rzucanie wyjątków domenowych przy błędach HTTP lub nieoczekiwanym payloadzie.

Przykładowe przepływy ekran-logika:

| Akcja użytkownika | Ekran | Kontroler | Warstwa danych | Efekt w UI |
| --- | --- | --- | --- | --- |
| Logowanie | `LoginScreen` | `SessionController` | `AuthRepository` -> `AuthApi` -> `AuthStorage` | router zmienia dostępne trasy, UI widzi profil |
| Zmiana widoku mapa/lista | `ShellHeader` / `ExploreScreen` | `ShellHeaderController` | brak API | Explore przebudowuje mapę albo listę |
| Wyszukiwanie wydarzeń | `ExploreScreen` | `ExploreController` | `EventRepository`, opcjonalnie `CacheService` | `ExploreState` przechodzi na data/empty/error |
| Zapisanie wydarzenia | lista/szczegóły wydarzenia | `SavedEventsController` | `SavedEventsRepository`, opcjonalnie `FavoritesApi` | ikona zapisu i lista zapisanych zmieniają stan |
| Dołączenie do wydarzenia | `EventScreen` | `JoinedEventsController` | `EventRegistrationApi`, potem `SessionController.refreshProfile` | stan rejestracji wydarzenia jest odświeżony |
| Utworzenie wydarzenia | `CreateEventScreen` | `CreateEventController` | `EventRepository`, presigned upload | formularz przechodzi na success/error |
| Załadowanie grupy | `GroupDetailsScreen` | `GroupController` | `GroupRepository`, `CacheService` | ekran pokazuje szczegóły, feed, członków, eventy |
| Wysłanie wiadomości | `ChatThreadScreen` | brak osobnego kontrolera, repozytorium w ekranie | `FirestoreChatRepository` | stream Firestore dostarcza nową wiadomość |
| Tapnięcie powiadomienia | system notification | `NotificationController` / `NotificationService` | payload FCM/local notification | router przechodzi na wskazaną trasę |
| Akceptacja regulaminu | `LegalAcceptanceScreen` | `LegalController` | `LegalAcceptanceStore` | router przestaje wymuszać `/legal/accept` |

### Granice logiki modułów

W aktualnym kodzie granice między modułami są praktyczne, ale nie całkowicie formalne. Najczęstsza reguła to: ekran i lokalne widgety pozostają w `features/`, a kod używany przez kilka obszarów trafia do `shared/`.

Przykłady granic:

- Auth UI jest w `features/auth`, ale sesja i tokeny są w `shared/auth`.
- Events UI jest w `features/events`, ale repozytorium wydarzeń i kontroler szczegółów są w `shared/events`.
- Groups UI jest w `features/groups`, ale modele, repozytorium i główny kontroler są w `shared/groups`.
- Reviews UI jest w `features/reviews`, ale kontroler, modele i repozytorium są w `shared/reviews`.
- Saved ma zarówno UI, jak i lokalne repozytoria w `features/saved`, ponieważ zapisane wydarzenia i filtry są funkcją aplikacji, a nie ogólną infrastrukturą.
- Chat trzyma repozytorium Firestore w `features/chat`, ponieważ w repozytorium nie widać użycia poza modułem czatu.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/features/shell/shell.dart`
- `lib/features/shell/header/header_controller.dart`
- `lib/features/explore/explore_screen.dart`
- `lib/features/explore/explore_controller.dart`
- `lib/features/saved/saved_events_controller.dart`
- `lib/features/saved/saved_filters_controller.dart`
- `lib/features/hub/create_event/create_event_controller.dart`
- `lib/features/chat/chat_repository.dart`
- `lib/shared/auth/session_controller.dart`
- `lib/shared/events/event_detail_controller.dart`
- `lib/shared/groups/group_controller.dart`
- `lib/shared/notifications/notification_service.dart`
- `lib/shared/notifications/notification_controller.dart`
- `lib/shared/reviews/review_controller.dart`

## 12. Moduł Auth

Moduł Auth obsługuje:

- logowanie e-mail/hasło,
- rejestrację,
- logowanie Google,
- zapis tokenów,
- odświeżanie tokenów,
- pobieranie profilu,
- wylogowanie,
- zmianę hasła,
- aktualizację profilu,
- wniosek o weryfikację organizatora.

Warstwy modułu:

- ekrany: `LoginScreen`, `RegisterScreen`,
- `AuthApi` - surowe wywołania HTTP,
- `AuthRepository` - zapis tokenów i pośrednia logika auth,
- `AuthStorage` - secure storage,
- `SessionController` - stan sesji używany przez aplikację,
- `AuthScope` - udostępnienie sesji w drzewie widgetów.

Google Sign-In działa przez uzyskanie credentiala Firebase i przekazanie ID tokena do backendowego endpointu OAuth. Frontend używa `ApiConfig.googleWebClientId`.

`SessionController` jest centralnym źródłem prawdy dla:

- statusu sesji,
- tokenów,
- profilu,
- flagi `isBusy`.

Router obserwuje `SessionController`, więc zmiany sesji automatycznie wywołują ponowną ocenę redirectów.

### Szczegóły przepływu logowania i rejestracji

`LoginScreen` i `RegisterScreen` przechowują lokalny stan formularza w klasach `State`. Każdy ekran ma własne `TextEditingController`, pola błędów, flagę `_hasSubmitted` i flagę `_isSubmitting`. Walidacja jest wykonywana przed wywołaniem `SessionController`. Błędy z `AuthApiException` i innych wyjątków są mapowane na lokalne komunikaty błędów lub komunikaty ogólne.

Logowanie e-mail/hasło przebiega następująco:

1. ekran waliduje pola,
2. ekran wywołuje `AuthScope.of(context).login(...)`,
3. `SessionController.login` ustawia `_isBusy`,
4. `AuthRepository.login` wysyła `LoginRequest` przez `AuthApi.login`,
5. `AuthRepository` zapisuje tokeny w `AuthTokenStorage`,
6. `SessionController` odczytuje tokeny, ładuje profil i ustawia `SessionStatus.authenticated`,
7. ekran wykonuje powrót do `targetLocation`, `returnLocation` albo profilu.

Rejestracja działa analogicznie, ale używa `RegisterRequest` i `AuthRepository.register`. Oba ekrany wspierają `target` i `from` z query parameters, dzięki czemu router może przywrócić użytkownika do trasy chronionej po udanym logowaniu lub rejestracji.

Google Sign-In jest inicjowany w ekranach auth. Ekran pobiera token przez Firebase/Google Sign-In, a następnie przekazuje ID token do `SessionController.loginWithGoogle`. Frontend nie utrzymuje osobnej sesji Google jako źródła prawdy dla aplikacji; po udanym logowaniu źródłem prawdy nadal jest `SessionController` i tokeny zapisane w `AuthStorage`.

### Profil i odświeżanie tokenów

`SessionController.load` jest wywoływany przy starcie aplikacji. Kontroler odczytuje tokeny ze storage, sprawdza `AuthTokens.isExpired` i w razie potrzeby próbuje odświeżyć token przez `AuthRepository.refresh`. Po udanym odświeżeniu pobierany jest profil użytkownika.

Odświeżanie po błędzie 401 nie jest globalnym interceptorem. Kod implementuje jawne retry w metodach:

- `_fetchProfileWithRefresh`,
- `_updateProfileWithRefresh`,
- `_changePasswordWithRefresh`.

Jeżeli refresh token nie pozwala odnowić sesji, kontroler czyści storage i ustawia status `unauthenticated`. Ten stan jest natychmiast widoczny dla routera i ekranów przez `AuthScope`.

`UserProfile` zawiera dane używane przez wiele modułów: role, flagi organizatora/admina, historię wydarzeń, ulubione wydarzenia, dane profilu i linki. Routing korzysta m.in. z `profile?.hasOrganizerReviewAccess`, a grupy i tworzenie wydarzeń korzystają z informacji o uprawnieniach organizatora.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart`
- `lib/shared/auth/auth_api.dart`
- `lib/shared/auth/auth_repository.dart`
- `lib/shared/auth/auth_storage.dart`
- `lib/shared/auth/session_controller.dart`
- `lib/shared/auth/auth_scope.dart`

## 13. Moduł Explore

Moduł Explore odpowiada za odkrywanie wydarzeń na mapie i liście.

Główne elementy:

- `ExploreScreen` - ekran główny,
- `ExploreController` - pobieranie, filtrowanie i sortowanie wydarzeń,
- `ExploreState` - sealed state dla loading/data/error/empty,
- `ExploreEventQuery` - logika filtrowania i sortowania,
- `ExploreMapViewModel` - lokalizacja i centrum mapy,
- `ExploreAreaController` - wybór obszaru,
- widgety mapy, listy, headera i arkusza filtrów.

Przepływ danych:

1. `ExploreMapViewModel` ustala lokalizację użytkownika albo fallback.
2. `ExploreController` dostaje referencyjną lokalizację.
3. `loadEvents` pobiera wydarzenia mapy przez `EventRepository.fetchMapEvents`.
4. Jeżeli dostępny jest `CacheScope`, najpierw używany jest cache.
5. Dane są filtrowane lokalnie przez `ExploreEventQuery`.
6. UI pokazuje mapę albo listę zależnie od stanu `ShellHeaderController`.

Obsługiwane parametry filtrowania:

- wyszukiwarka tekstowa,
- kategorie,
- sortowanie,
- kolejność sortowania,
- zaawansowane filtry,
- dystans,
- grupy,
- obszar mapy.

Mapa używa MapLibre i stylu z assetu `assets/map_styles/openstreetmap_custom.json`. `MapStyleRepository` potrafi wygenerować wariant ciemny przez transformację kolorów JSON.

Lokalizacja używa `GeolocatorLocationService`. Obsługiwane są stany:

- ready,
- permission denied,
- service disabled,
- error,
- loading.

### Szczegóły mapy, filtrów i cache

`ExploreScreen` koordynuje kilka źródeł stanu naraz. Lokalny stan ekranu obejmuje wyszukiwarkę, fokus, opóźnienia ładowania, ostatnio przeszukany obszar, aktualne centrum mapy i informację, czy użytkownik przesunął mapę poza obszar ostatniego wyszukiwania. Stan domenowy listy wydarzeń jest w `ExploreController`, a stan lokalizacji w `ExploreMapViewModel`.

`ExploreController.loadEvents` może działać z cache, jeżeli do ekranu trafił `CacheService`. Klucz cache dla wydarzeń mapy jest budowany z lokalizacji i promienia wyszukiwania. Kontroler potrafi pokazać poprzednie wyniki podczas kolejnego ładowania przez `ExploreDataLoading`, dzięki czemu UI nie musi znikać przy ponownym wyszukiwaniu.

`ExploreEventQuery` jest wydzielony z kontrolera i odpowiada za operacje czyste na listach wydarzeń. Filtry uwzględniają m.in. tekst wyszukiwania, kategorie, statusy, daty, wiek, grupy, dystans i sortowanie. `ExploreAdvancedFilters` ma `copyWith`, `toJson`, `fromJson`, `activeFiltersCount` i jest używany również przez zapisane filtry.

Mapa jest zbudowana z `ExploreMapView`, `MapWidget`, `MapStyleRepository`, `MapStyleCoordinator`, `MapCameraSync` i `MapEventClusterer`. `MapWidget` reaguje na zmianę stylu, synchronizuje warstwy markerów, obsługuje tapnięcia markerów i klastrów oraz renderuje promień wyszukiwania. `MapStyleRepository` ładuje JSON stylu z assetu i przygotowuje wariant dla ciemnego motywu.

Wybór obszaru wyszukiwania jest rozdzielony od samego kontrolera wyników. `ExploreAreaController` przechowuje tryb wyboru obszaru: bieżąca lokalizacja, adres wpisany przez użytkownika albo punkt z mapy. Arkusz filtrów może uruchomić wybór adresu lub tryb wyboru na mapie, a `ExploreScreen` stosuje wynik w `ExploreController`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/explore/explore_screen.dart`
- `lib/features/explore/explore_controller.dart`
- `lib/features/explore/explore_state.dart`
- `lib/features/explore/explore_event_query.dart`
- `lib/features/explore/map_view_model.dart`
- `lib/features/explore/widgets/map_view.dart`
- `lib/shared/location/location_service.dart`
- `lib/shared/map/style_repository.dart`

## 14. Moduł Events

Moduł Events odpowiada za szczegóły wydarzeń, galerię, informacje, rejestrację i recenzowanie.

Źródłem danych wydarzeń jest `EventRepository`. Szczegóły pojedynczego wydarzenia są zarządzane przez `EventDetailController`.

`EventDetailController`:

- ładuje wydarzenie z cache,
- pobiera świeże dane z API,
- porównuje hash cache i świeżych danych,
- scala część pól ze starymi danymi, gdy świeża odpowiedź jest uboższa,
- ładuje sloty wydarzenia przez `EventRegistrationApi`,
- obsługuje listę wydarzeń organizatora.

Rejestracja na wydarzenie jest obsługiwana przez `JoinedEventsController`:

- stan dołączonych wydarzeń pochodzi z profilu użytkownika,
- `joinEvent` wywołuje endpoint join i odświeża profil,
- `cancelRegistration` wywołuje endpoint cancel i odświeża profil,
- sloty mogą być cachowane w pamięci kontrolera.

Edycja wydarzenia korzysta z tego samego flow co tworzenie wydarzenia w module Hub.

### Szczegóły ekranu wydarzenia

`EventScreen` nie pobiera danych bezpośrednio z HTTP. Korzysta z `EventDetailScope`, `SavedEventsScope`, `JoinedEventsScope` i `ReviewScope`. Ekran uruchamia ładowanie szczegółów przez `EventDetailController.loadEvent`, a następnie przekazuje dane do komponentów galerii i sekcji informacyjnej.

Najważniejsze akcje użytkownika na ekranie wydarzenia:

- zapisanie lub usunięcie wydarzenia przez `SavedEventsController.toggleSaved`,
- dołączenie przez `JoinedEventsController.joinEvent`,
- anulowanie rejestracji przez `JoinedEventsController.cancelRegistration`,
- udostępnienie przez `ShareService.shareEvent`,
- otwarcie lokalizacji przez `MapLaunchService.openLocation`,
- dodanie do kalendarza przez `CalendarService.addEvent`,
- przejście do recenzji przez trasę `/events/:eventId/review`,
- przejście do edycji przez `/events/:eventId/edit`, gdy bieżący użytkownik jest autorem.

`EventDetailsInfo` odpowiada za warstwę prezentacji akcji i sekcji informacyjnych. Ukrywa lub pokazuje elementy zależnie od stanu wydarzenia, np. dla wydarzeń zakończonych nie pokazuje akcji zapisu i dołączania. Galeria jest rozbita na mniejsze komponenty: `EventGallery`, `EventDetailsGallery`, `FullscreenGallery` i `EventImagePlaceholder`.

`EventDetailController` zachowuje poprzedni model wydarzenia, jeżeli odświeżenie zakończy się błędem i dane są już dostępne. Dzięki temu błąd odświeżenia nie musi kasować całego ekranu szczegółów.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/events/event_screen.dart`
- `lib/shared/events/event_detail_controller.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/events/event_registration_api.dart`
- `lib/features/events/joined_events_controller.dart`
- `lib/features/events/widgets/gallery/event_gallery.dart`
- `lib/features/events/widgets/info/event_details_info.dart`

## 15. Moduł Hub i tworzenie wydarzeń

Hub pełni rolę centralnego panelu akcji. Dostępne akcje są opisane przez `HubActionItem` i skonfigurowane w routerze.

Tworzenie wydarzeń znajduje się w `features/hub/create_event`.

`CreateEventController` obsługuje:

- tytuł,
- opis,
- lokalizację,
- datę,
- godzinę,
- kategorie,
- grupy,
- status wydarzenia,
- link do biletów,
- limit miejsc,
- wybrane obrazy,
- tryb tworzenia lub edycji.

Walidacja formularza odbywa się w kontrolerze. Kontroler korzysta z `L10nService`, aby generować komunikaty błędów.

Submit:

1. Kontroler waliduje pola.
2. Buduje `EventRequest`.
3. Dla nowego wydarzenia wywołuje `createEvent`.
4. Dla edycji wywołuje `updateEvent`.
5. Jeżeli wybrano obrazy, przesyła je przez presigned upload.
6. Pierwszy przesłany obraz może zostać ustawiony jako thumbnail.

Wybór lokalizacji jest obsługiwany przez osobny kontroler i ekran mapy.

### Szczegóły formularza wydarzenia

Stan formularza jest niemutowalnym obiektem `CreateEventState`. Zmiany pól są wykonywane przez metody `CreateEventController`, które tworzą kolejne kopie stanu przez `copyWith`. Kontroler rozdziela wartości formularza, błędy walidacji i status submitu (`idle`, `submitting`, `success`, `error`).

`CreateEventScreen` łączy kontroler formularza z UI. Ekran:

- inicjalizuje kontroler,
- ładuje edytowane wydarzenie, jeżeli dostał `editingEventId`,
- stosuje grupę początkową z `initialGroupId`,
- pobiera kategorie z `CategoryScope`,
- pobiera grupy z `GroupScope`,
- obsługuje wybór plików przez `file_picker`,
- otwiera wybór lokalizacji przez bottom sheet albo `EventMapPickerScreen`.

`CreateEventLocationController` rozwiązuje trzy tryby lokalizacji: bieżąca lokalizacja, adres i punkt z mapy. Dla adresu używa geokodowania, a dla bieżącej lokalizacji korzysta z `LocationService`. Wynik jest przekazywany do `CreateEventController.updateLocation`.

Tryb edycji jest aktywowany przez `setEditingEventId` i `initializeFromEvent`. W trybie edycji submit wywołuje `EventRepository.updateEvent`, a w trybie tworzenia `EventRepository.createEvent`. Po sukcesie kontroler emituje `EventRefreshSignal`, aby inne części aplikacji mogły odświeżyć listy wydarzeń.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/hub/hub_placeholder_screen.dart`
- `lib/features/shell/hub/hub_panel.dart`
- `lib/features/shell/hub/hub_action_item.dart`
- `lib/features/hub/create_event/create_event_screen.dart`
- `lib/features/hub/create_event/create_event_controller.dart`
- `lib/features/hub/create_event/create_event_state.dart`
- `lib/features/hub/create_event/create_event_location_controller.dart`
- `lib/features/hub/create_event/event_map_picker_screen.dart`

## 16. Moduł Saved

Moduł Saved obsługuje zapisane wydarzenia oraz zapisane filtry.

Zapisane wydarzenia:

- są przechowywane lokalnie w `SharedPreferences`,
- mogą być synchronizowane z backendową listą ulubionych,
- są czyszczone z wydarzeń zakończonych,
- zachowują stan synchronizacji.

`SavedEventsController` obsługuje:

- ładowanie lokalnych zapisów,
- dodawanie i usuwanie wydarzenia,
- synchronizację po zalogowaniu,
- pobieranie pełnych danych wydarzenia dla pozycji zdalnych,
- rollback w przypadku błędu lokalnego lub zdalnego,
- odświeżenie profilu po synchronizacji.

Zapisane filtry:

- są przechowywane lokalnie,
- mogą mieć nazwę,
- mogą wskazywać bieżącą lokalizację albo konkretną lokalizację,
- mogą mieć włączone powiadomienia,
- mogą zostać załadowane do Explore jako pending filter.

### Synchronizacja i zapytania lokalne

`SavedEventsController` działa lokalnie również dla użytkownika niezalogowanego. Rekordy są przechowywane przez `SavedEventsRepository` jako `SavedEventRecord`, który zawiera model wydarzenia, czas zapisu i `SavedEventSyncState`. Po zalogowaniu kontroler porównuje lokalny stan z ulubionymi wydarzeniami z profilu i próbuje zsynchronizować różnice przez `FavoritesApi`.

W przypadku zapisu lub usunięcia wydarzenia kontroler stosuje lokalną aktualizację i w razie niepowodzenia próbuje rollbacku. Dla rekordów zdalnych, które nie mają pełnych danych wydarzenia, kontroler pobiera szczegóły przez `EventRepository.fetchEvent`.

`SavedEventQuery` filtruje i sortuje zapisane rekordy na potrzeby `SavedScreen`. Filtry obejmują tekst wyszukiwania, kategorie, datę, dystans i sortowanie. Lokalizacja do sortowania po dystansie pochodzi z `LocationService`, jeżeli jest dostępna.

`SavedFiltersController` przechowuje filtry Explore jako `SavedFilter`. Metoda `loadFilterToExplore` nie nawiguje sama do Explore; ustawia `pendingLoadFilter`, który jest konsumowany przez `ExploreScreen`. Dzięki temu kontroler filtrów nie musi znać szczegółów routingu ani kontrolera Explore.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/saved/saved_screen.dart`
- `lib/features/saved/saved_events_controller.dart`
- `lib/features/saved/saved_events_repository.dart`
- `lib/features/saved/saved_filters_controller.dart`
- `lib/features/saved/saved_filters_repository.dart`
- `lib/features/saved/saved_filter_model.dart`
- `lib/features/saved/saved_event_query.dart`

## 17. Moduł Groups

Moduł Groups jest jednym z największych modułów domenowych. Obsługuje:

- odkrywanie grup,
- listę grup użytkownika,
- szczegóły grupy,
- członków,
- prośby o dołączenie,
- feed,
- posty,
- komentarze,
- polubienia,
- wydarzenia powiązane z grupą,
- raporty,
- moderację,
- media grupy i postów.

`GroupController` jest głównym kontrolerem stanu. Przechowuje osobne sekcje stanu dla:

- discover,
- my groups,
- detail,
- members,
- feed,
- events,
- join requests,
- reports,
- paginacji feedu.

Kontroler stosuje cache-aside podobnie jak moduł Events. Dla szczegółów grupy potrafi:

- załadować dane z cache,
- odświeżyć szczegóły,
- równolegle ładować members/feed/events,
- ładować join requests i reports tylko dla moderatorów,
- fallbackować do znanych grup, gdy szczegółowe pobranie się nie powiedzie.

Część akcji jest optymistyczna. Przykładowo usunięcie lub ukrycie posta najpierw usuwa element z lokalnego feedu, a w razie błędu przywraca go.

Repozytorium `HttpGroupRepository` ma szeroki zakres endpointów i obsługuje również presigned upload dla mediów grup i postów.

### Szczegóły stanu i ekranów grup

`GroupController` rozdziela stan listy discover od stanu "my groups" i od stanu szczegółów. Dzięki temu ekran odkrywania grup może odświeżać listę publiczną bez kasowania danych szczegółów aktualnie oglądanej grupy. Gettery zwracają niemodyfikowalne listy, a kontroler wewnętrznie pilnuje flag ładowania i odświeżania.

`GroupDiscoverScreen` używa `GroupController.loadDiscoverGroups` oraz `loadMyGroups`. Ekran ma lokalne kontrolery wyszukiwania i filtrów widoczności. Dla odkrywania z lokalizacją korzysta z `LocationService`, a wyniki zależą od bieżącego tekstu wyszukiwania, kategorii i widoczności.

`GroupDetailsScreen` jest ekranem wielozakładkowym. Korzysta z danych `detailGroup`, `detailMembers`, `detailFeed`, `detailEvents`, `detailJoinRequests` i `detailReports`. Akcje członkowskie, moderacyjne, raportowania i linkowania wydarzeń są delegowane do `GroupController`. Ekran buduje również trasy czatu bezpośredniego i grupowego przez `FirestoreChatRepository.directChatId` oraz `groupChatId`.

`GroupFormScreen` obsługuje tworzenie i edycję grupy. Przy edycji ładuje istniejącą grupę z `GroupScope`, a przy zapisie buduje `GroupCreateRequest` albo `GroupUpdateRequest`. Widget `PinSelector` pozwala wybrać styl pinu lub uploadować własny pin, używając `HttpGroupRepository` i presigned upload.

Komentarze postów są obsługiwane przez `GroupPostCommentsScreen`, który wywołuje `GroupController.fetchComments`, `createComment`, `updateComment` i `deleteComment`. Komentarze nie mają osobnego globalnego kontrolera; są częścią kontrolera grup.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/groups/group_controller.dart`
- `lib/shared/groups/group_repository.dart`
- `lib/shared/groups/group_models.dart`
- `lib/shared/groups/group_scope.dart`
- `lib/features/groups/group_discover_screen.dart`
- `lib/features/groups/group_details_screen.dart`
- `lib/features/groups/group_form_screen.dart`
- `lib/features/groups/group_post_comments_screen.dart`
- `lib/features/groups/widgets/pin_selector.dart`

## 18. Moduł Chat

Czat jest oparty o Cloud Firestore.

Główna klasa integracyjna to `FirestoreChatRepository`. Obsługuje:

- generowanie ID rozmowy bezpośredniej,
- generowanie ID rozmowy grupowej,
- obserwowanie listy rozmów,
- obserwowanie wiadomości w wątku,
- pobieranie metadanych rozmowy,
- wysyłanie wiadomości direct,
- wysyłanie wiadomości grupowej.

Lista rozmów jest budowana przez `collectionGroup('messages')`, filtrowana po `participantAppUserIds`, a następnie grupowana lokalnie po `chatId`. Najnowsza wiadomość wyznacza kolejność rozmów.

Wysyłanie wiadomości:

1. Frontend ustala `firebaseSenderId`.
2. Jeżeli Firebase Auth nie ma bieżącego użytkownika, próbuje zalogować anonimowo.
3. Dodaje dokument wiadomości w `chats/<chatId>/messages`.
4. Próbuje zaktualizować metadane dokumentu `chats/<chatId>`.
5. Błąd aktualizacji metadanych nie cofa wysłania wiadomości, ponieważ backend może słuchać dokumentów wiadomości.

Ekrany czatu korzystają z repozytorium przez strumienie Firestore.

### Szczegóły modeli i ekranów czatu

`ChatConversation` mapuje dokument rozmowy i dane ostatniej wiadomości na model używany przez listę rozmów. Metoda `titleFor` wybiera tytuł względem bieżącego użytkownika, a `participantIdFor` pozwala znaleźć drugiego uczestnika rozmowy direct.

`ChatMessage` reprezentuje pojedynczą wiadomość. Model zawiera identyfikator, tekst, nadawcę, nazwę nadawcy, datę utworzenia oraz dane uczestników aplikacyjnych. Ekran wątku używa tych pól do rozróżnienia wiadomości własnych i cudzych.

`ChatListScreen` zachowuje ostatnią niepustą listę rozmów, gdy stream zwróci pusty snapshot. `ChatThreadScreen` analogicznie zachowuje ostatnie wiadomości, obsługuje lokalną flagę `_isSending` i deleguje wysyłkę do repozytorium. Wysyłka może dotyczyć rozmowy direct albo grupowej, zależnie od parametrów trasy.

Routing do czatu obsługuje `chatId`, `recipientId`, `recipientName`, `groupName`, `isGroup` i `participantIds`. Dla grup ekran szczegółów grupy buduje identyfikator przez `FirestoreChatRepository.groupChatId(group.id)`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/chat/chat_repository.dart`
- `lib/features/chat/chat_screen.dart`
- `lib/app/router.dart`
- `lib/features/groups/group_details_screen.dart`

## 19. Moduł Notifications

Moduł Notifications łączy Firebase Messaging, lokalne powiadomienia, historię powiadomień i preferencje użytkownika.

`NotificationService` jest statyczną usługą odpowiedzialną za:

- inicjalizację lokalnych powiadomień,
- inicjalizację Firebase Messaging,
- pobranie tokena FCM,
- nasłuchiwanie odświeżenia tokena,
- obsługę wiadomości foreground,
- obsługę tapnięcia powiadomienia,
- pokazanie lokalnego powiadomienia,
- subskrypcje topiców,
- żądanie uprawnień,
- czyszczenie lokalnych powiadomień.

`NotificationController` przechowuje:

- historię,
- liczbę nieprzeczytanych,
- informacje o paginacji historii,
- token FCM,
- preferencje typów powiadomień,
- callback nawigacji po kliknięciu.

Historia powiadomień jest obsługiwana przez `NotificationHistoryRepository`. Istnieje implementacja lokalna oraz API-backed z lokalnym fallbackiem.

Obsługiwane typy powiadomień wynikają z `NotificationType`, m.in.:

- upcoming event,
- expired event,
- event published,
- system message,
- chat message.

Nawigacja po tapnięciu opiera się na payloadzie. Jeżeli payload zawiera route, frontend przechodzi do odpowiedniego ekranu.

### Szczegóły historii, payloadu i preferencji

`NotificationController` korzysta z `NotificationHistoryRepository`. W kodzie występują dwie implementacje repozytorium historii: lokalna `SharedPrefsNotificationHistoryRepository` oraz `ApiNotificationHistoryRepository`. Implementacja API przyjmuje provider tokenu i używa `NotificationsApi`; jeżeli token nie jest dostępny albo operacja API nie może zostać wykonana, korzysta z lokalnego fallbacku.

`NotificationPayload` buduje trasę na podstawie danych powiadomienia. Jeżeli payload zawiera `screen`, używa tej wartości jako trasy. Jeżeli zawiera `chatId`, buduje `/chat/<chatId>`. Jeżeli zawiera `eventId`, buduje `/events/<eventId>`. Metoda `navigate` wykonuje `router.go(route)`.

`NotificationController.onNotificationReceived` zapisuje powiadomienie w historii, wylicza route, aktualizuje licznik nieprzeczytanych i może uruchomić lokalną notyfikację przez `NotificationService`. Ekran `InboxScreen` używa `NotificationScope`, aby ładować historię, oznaczać pozycje jako przeczytane i przechodzić do zapisanej trasy.

Preferencje są przechowywane per `NotificationType` w `NotificationPreferencesStore`. `SharedPrefsNotificationPreferencesStore` używa kluczy z prefiksem `notifications.enabled.` i ustala wartości domyślne w kodzie. `NotificationController.setEnabled` zapisuje preferencję i aktualizuje stan UI.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/notifications/notification_service.dart`
- `lib/shared/notifications/notification_controller.dart`
- `lib/shared/notifications/notification_payload.dart`
- `lib/shared/notifications/notification_type.dart`
- `lib/shared/notifications/notifications_api.dart`
- `lib/shared/notifications/api_notification_history_repository.dart`
- `lib/shared/notifications/shared_prefs_notification_history_repository.dart`
- `lib/shared/notifications/shared_prefs_notification_preferences_store.dart`
- `lib/features/inbox/inbox_screen.dart`

## 20. Moduł Profile

Moduł Profile odpowiada za ekran profilu, ustawienia, edycję danych, historię wydarzeń, wydarzenia organizatora i recenzje organizatora.

Profil użytkownika pochodzi z `SessionController.profile`. Aktualizacja profilu odbywa się przez `SessionController.updateProfile`, który deleguje do `AuthRepository.updateProfile`.

Edycja profilu zawiera także logikę uploadu mediów profilu przez presigned URL. Jest to jedno z miejsc, gdzie ekran bezpośrednio używa `http` oraz `ApiConfig.baseUrl`, zamiast w pełni wydzielonego repozytorium.

Ustawienia profilu korzystają z:

- `ThemeController`,
- `LocaleController`,
- `SessionController`,
- ekranów legal/help/consents.

Dostęp do części ekranów profilu jest chroniony przez router.

### Szczegóły ekranów profilu

`ProfileScreen` obsługuje dwa warianty: użytkownik niezalogowany widzi kartę logowania, a użytkownik zalogowany widzi dane profilu, linki, akcje profilu i sekcję organizatora. Ekran używa `ReviewScope` do synchronizacji ratingu organizatora, jeżeli profil ma dane organizatora.

`SettingsScreen` korzysta z `ThemeScope`, `LocaleScope`, `AuthScope` i `NotificationScope`. Ekran pozwala zmienić język, tryb motywu, preferencje powiadomień, przejść do dokumentów prawnych oraz wykonać akcje konta. Dialog zmiany hasła wywołuje `SessionController.changePassword`.

`EditProfileScreen` ładuje dane z `SessionController.profile`, waliduje linki profilu i wysyła `UpdateProfileRequest` przez `SessionController.updateProfile`. Upload avataru jest wykonywany bezpośrednio w ekranie przez `http` i `ApiConfig.baseUrl`, co jest świadomym wyjątkiem od dominującego wzorca repozytoriów.

`EventHistoryScreen` bazuje na historii z profilu i w razie potrzeby pobiera szczegóły wydarzenia przez `EventRepository`. `OrganizerEventsScreen` pobiera wydarzenia organizatora przez repozytorium wydarzeń. `OrganizerReviewsScreen` korzysta z `ReviewController.loadOrganizerReviews`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/profile/profile_screen.dart`
- `lib/features/profile/settings_screen.dart`
- `lib/features/profile/edit_profile_screen.dart`
- `lib/features/profile/event_history_screen.dart`
- `lib/features/profile/organizer_events_screen.dart`
- `lib/features/profile/organizer_reviews_screen.dart`
- `lib/shared/auth/session_controller.dart`

## 21. Moduł Legals

Moduł Legals obsługuje regulamin, politykę prywatności, zgody oraz wymuszenie akceptacji aktualnych wersji dokumentów.

`LegalController`:

- obserwuje `SessionController`,
- po zalogowaniu ładuje zaakceptowane wersje dokumentów,
- porównuje je z wartościami z `LegalVersions`,
- wystawia `isAcceptanceRequired`,
- zapisuje akceptację przez `LegalAcceptanceStore`.

Router używa `LegalController` jako części `refreshListenable`. Jeżeli użytkownik jest zalogowany i wymaga akceptacji, każda trasa poza `/legal/accept` przekierowuje na ekran akceptacji.

Akceptacje są przechowywane lokalnie per użytkownik. Zgody dodatkowe są obsługiwane przez osobny store `ConsentsStore`.

### Szczegóły ochrony prawnej i zgód

`LegalController` nasłuchuje `SessionController`. Po zmianie sesji kontroler ponownie sprawdza, czy bieżący użytkownik zaakceptował wersje z `LegalVersions.termsVersion` i `LegalVersions.privacyVersion`. Gdy użytkownik nie jest zalogowany, akceptacja nie jest wymuszana.

`SharedPrefsLegalAcceptanceStore` zapisuje wersje dokumentów lokalnie z rozróżnieniem użytkownika. Oznacza to, że stan akceptacji wynika z lokalnego storage frontendu, a nie z globalnego stanu backendu opisanego w tej dokumentacji.

`LegalAcceptanceScreen` wywołuje `LegalController.acceptAll`. Po zaakceptowaniu router przestaje kierować użytkownika na `/legal/accept` i może wrócić do trasy z parametru `from`.

`ConsentsScreen` używa `ConsentsStore` niezależnie od `LegalController`. Zgody dodatkowe są przechowywane jako osobne wartości typu `ConsentType`, mają własne klucze `prefsKey` i nie blokują routingu.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/features/legals/legal_controller.dart`
- `lib/features/legals/legal_scope.dart`
- `lib/features/legals/legal_versions.dart`
- `lib/features/legals/legal_acceptance_store.dart`
- `lib/features/legals/shared_prefs_legal_acceptance_store.dart`
- `lib/features/legals/consents_store.dart`
- `lib/features/legals/shared_prefs_consents_store.dart`
- `lib/features/legals/legal_acceptance_screen.dart`

## 22. Recenzje

Recenzje są obsługiwane przez współdzielony moduł `shared/reviews` oraz ekran `features/reviews`.

`ReviewController` obsługuje:

- średnią ocenę organizatora,
- recenzje wydarzenia,
- recenzję bieżącego użytkownika dla wydarzenia,
- podsumowanie recenzji organizatora,
- wysłanie recenzji.

Część danych, np. średnia ocena organizatora, używa lokalnego cache przez `CacheService`.

Wysłanie recenzji wymaga sesji użytkownika. Po submit kontroler aktualizuje `userReview`, powiadamia UI i asynchronicznie odświeża listę recenzji wydarzenia.

### Szczegóły recenzji wydarzeń i organizatora

`ReviewRepository` definiuje kontrakt pobierania średniej oceny organizatora, recenzji wydarzenia, recenzji bieżącego użytkownika, wysłania recenzji i pobrania przeglądu recenzji organizatora. `HttpReviewRepository` implementuje ten kontrakt przez HTTP.

`ReviewController.loadOrganizerRating` używa cache dla średniej oceny organizatora. `loadEventReviews` i `loadMyReviewForEvent` pobierają dane dla konkretnego wydarzenia. `submitReview` wymaga tokena z `SessionController`, wysyła `ReviewRequest`, aktualizuje `userReview` i odświeża zależne dane.

`EventReviewScreen` jest ekranem formularza recenzji. Korzysta z `EventDetailScope`, aby znać wydarzenie, z `ReviewScope`, aby pobrać lub wysłać recenzję, oraz z `AuthScope`, aby działać tylko dla zalogowanego użytkownika. `OrganizerReviewsScreen` w profilu korzysta z przeglądu recenzji organizatora udostępnianego przez `ReviewController`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/reviews/review_controller.dart`
- `lib/shared/reviews/review_repository.dart`
- `lib/shared/reviews/review_models.dart`
- `lib/shared/reviews/review_scope.dart`
- `lib/features/reviews/event_review_screen.dart`

## 23. Wspólne komponenty UI i motyw

Interfejs użytkownika jest zbudowany na Flutter Material 3. Projekt nie ma osobnego pakietu design systemu, ale zawiera globalny motyw, kilka współdzielonych widgetów, lokalne zestawy komponentów w modułach funkcjonalnych oraz powtarzalne wzorce formularzy i ekranów.

### ThemeData

Motyw aplikacji jest zdefiniowany ręcznie w `lib/app/theme/app_theme.dart`.

Projekt używa dwóch funkcji budujących `ThemeData`:

- `buildLightAppTheme`,
- `buildDarkAppTheme`.

Obie funkcje tworzą własny `ColorScheme` i przekazują go do wspólnej funkcji `_buildTheme`. Motyw używa `useMaterial3: true`.

Konfigurowane elementy `ThemeData`:

- `brightness`,
- `colorScheme`,
- `scaffoldBackgroundColor`,
- `canvasColor`,
- `dividerColor`,
- `shadowColor`,
- `AppBarTheme`,
- `TextTheme`,
- `SegmentedButtonThemeData`,
- `CardThemeData`,
- `PopupMenuThemeData`,
- `ThemeExtension` w postaci `LocarioThemeColors`.

Jasny motyw używa zielonego koloru głównego, jasnych powierzchni i różowego koloru trzeciorzędowego. Ciemny motyw używa ciemnych powierzchni oraz jaśniejszych odcieni zieleni i różu. Kolory powierzchni są zdefiniowane jawnie jako wartości `Color`, m.in. `surface`, `surfaceContainerLow`, `surfaceContainerHigh`, `outline`, `onSurface`.

`LocarioThemeColors` jest rozszerzeniem motywu. Aktualnie zawiera pole `onScrim`.

Tryb motywu jest przechowywany przez `ThemeController`. Kontroler ładuje i zapisuje `ThemeMode` przez `AppSettingsStore`, a `ThemeScope` udostępnia go w drzewie widgetów. `MaterialApp.router` otrzymuje `theme`, `darkTheme` i `themeMode`.

### Style UI

Style są stosowane głównie przez:

- globalny `ThemeData`,
- lokalne wywołania `Theme.of(context)`,
- `ColorScheme`,
- `TextTheme`,
- lokalne `BoxDecoration`,
- lokalne `InputDecoration`,
- ikony Material.

W kodzie powtarza się użycie:

- `scheme.surfaceContainerLow`,
- `scheme.surfaceContainerHighest`,
- `scheme.outline.withValues(alpha: ...)`,
- `scheme.primary`,
- `scheme.secondary`,
- `scheme.error`,
- `scheme.onSurface.withValues(alpha: ...)`.

Zaokrąglenia i odstępy są definiowane lokalnie w widgetach. Występują m.in. promienie `16`, `18`, `24` i `28`, zależnie od komponentu. Karty i panele często używają powierzchni z `ColorScheme` oraz delikatnej ramki z `outline`.

### Wspólne widgety

Najważniejsze współdzielone widgety w `lib/shared/widgets/`:

- `StatePanel`,
- `EventListCard`.

`StatePanel` obsługuje powtarzalne stany ekranu:

- loading,
- error,
- empty.

Widget ma fabryki:

- `StatePanel.loading`,
- `StatePanel.error`,
- `StatePanel.empty`.

Panel składa się z ikony w kontenerze, tytułu, podtytułu i opcjonalnej akcji lub custom content. Jest używany tam, gdzie ekran musi pokazać stan pusty, błąd albo ładowanie w spójny sposób.

`EventListCard` jest kartą wydarzenia używaną w listach. Obsługuje:

- thumbnail z `CachedNetworkImage`,
- fallback ikonowy,
- tytuł wydarzenia,
- kategorię,
- dystans względem lokalizacji referencyjnej,
- czas i miejsce,
- limit miejsc,
- przycisk akcji,
- stan aktywnej akcji, np. zapisane wydarzenie.

`EventListCard` zależy od modelu `ExploreEvent`, lokalizacji `AppLocalizations` i `latlong2`.

### Komponenty wielokrotnego użytku w modułach

Poza `shared/widgets` projekt ma wiele komponentów wielokrotnego użytku trzymanych lokalnie przy modułach. To jest dominujący wzorzec: komponent trafia do `shared/` tylko wtedy, gdy jest realnie używany szerzej.

Przykłady komponentów lokalnych:

- `features/shell/nav/bottom_nav.dart` - dolna nawigacja,
- `features/shell/header/header.dart` - nagłówek shell,
- `features/shell/hub/hub_panel.dart` - panel Hub,
- `features/explore/widgets/header.dart` - header Explore,
- `features/explore/widgets/list_view.dart` - lista wydarzeń Explore,
- `features/explore/widgets/map_view.dart` i `map_widget.dart` - widok mapy,
- `features/explore/widgets/advanced_filter_sheet.dart` - arkusz filtrów,
- `features/events/widgets/gallery/*` - galeria wydarzenia,
- `features/events/widgets/info/*` - sekcja informacji wydarzenia,
- `features/hub/create_event/widgets/*` - komponenty formularza tworzenia wydarzenia,
- `features/groups/widgets/pin_selector.dart` - wybór pinu grupy,
- `features/auth/widgets/google_logo_icon.dart` - ikona Google.

Komponenty lokalne mogą zależeć bezpośrednio od kontrolerów i modeli swojego modułu. Komponenty w `shared/widgets` powinny pozostawać bardziej ogólne.

### Formularze

Formularze w projekcie są tworzone ręcznie przez widgety Fluttera i kontrolery stanu. W kodzie nie widać użycia globalnego frameworka formularzy.

Najważniejsze przykłady:

- `LoginScreen`,
- `RegisterScreen`,
- `EditProfileScreen`,
- `CreateEventScreen`,
- `GroupFormScreen`,
- `ExploreAdvancedFilterSheet`,
- dialog zapisu filtra w Explore.

Formularze auth używają lokalnych `TextEditingController`, pól błędów i flag submitu w stanie ekranu. Przykładowo `LoginScreen` ma:

- `_emailController`,
- `_passwordController`,
- `_emailError`,
- `_passwordError`,
- `_hasSubmitted`,
- `_isSubmitting`.

Formularz tworzenia wydarzenia jest bardziej rozbudowany i używa osobnego `CreateEventController` oraz niemutowalnego `CreateEventState`. Stan formularza obejmuje:

- tytuł i błąd tytułu,
- opis i błąd opisu,
- lokalizację i błąd lokalizacji,
- datę i błąd daty,
- godzinę i błąd godziny,
- kategorie i błąd kategorii,
- grupy i błąd grup,
- status wydarzenia,
- URL biletów,
- limit miejsc,
- wybrane obrazy,
- status formularza.

Dla formularza tworzenia wydarzenia istnieją lokalne komponenty w `features/hub/create_event/widgets/form_primitives.dart`:

- `CreateEventSection`,
- `CreateEventFieldLabel`,
- `createEventFieldDecoration`,
- `CreateEventPickerTile`,
- `CreateEventLocationPickerTile`.

Te komponenty standaryzują wygląd sekcji formularza, etykiet, pól tekstowych, kafli wyboru daty/godziny oraz kafla lokalizacji.

### Walidacja

Walidacja jest wykonywana lokalnie w ekranach lub kontrolerach, zależnie od formularza.

W `LoginScreen` walidacja jest w stanie ekranu:

- e-mail jest wymagany,
- e-mail musi pasować do lokalnego wyrażenia regularnego,
- hasło jest wymagane.

W `CreateEventController` walidacja jest częścią logiki kontrolera:

- tytuł jest wymagany i musi mieć co najmniej 3 znaki,
- opis jest wymagany i musi mieć co najmniej 10 znaków,
- lokalizacja jest wymagana,
- data i godzina są wymagane,
- przynajmniej jedna kategoria jest wymagana,
- grupa może być wymagana, gdy użytkownik nie może tworzyć publicznych wydarzeń,
- limit miejsc musi być dodatni, a w części scenariuszy grupowych jest wymagany.

Błędy walidacji są przechowywane w stanie formularza jako pola typu `String?`, np. `titleError`, `descriptionError`, `locationError`. `CreateEventState.canSubmit` wylicza, czy formularz może zostać wysłany.

Komunikaty walidacyjne są pobierane z lokalizacji przez `AppLocalizations` lub `L10nService`.

W arkuszu filtrów Explore stan filtrów jest utrzymywany lokalnie w `StatefulWidget`. Dla dialogu zapisu filtra używany jest `TextEditingController`, a przycisk zapisu zależy od zawartości pola nazwy.

### Organizacja ekranów

Ekrany są organizowane feature-first. Każdy większy obszar aplikacji ma własny katalog w `lib/features/`.

Typowy układ modułu:

- ekran główny modułu,
- kontroler lub view model, jeśli stan jest specyficzny dla modułu,
- modele lokalne, jeśli nie są współdzielone globalnie,
- katalog `widgets/` dla komponentów używanych tylko w tym module.

Przykłady:

- `features/explore/` ma ekran, kontrolery, modele, query i lokalne widgety,
- `features/hub/create_event/` ma ekran, kontrolery, state i widgety formularza,
- `features/events/widgets/` jest podzielony na `gallery/` i `info/`,
- `features/shell/` rozdziela header, hub i nav,
- `features/groups/` trzyma duże ekrany grup i lokalne widgety.

Ekrany korzystają ze scope'ów globalnych przez `maybeOf` albo `of`, np. `AuthScope`, `GroupScope`, `SavedEventsScope`, `ShellHeaderScope`. Część ekranów przyjmuje kontrolery przez konstruktor, co jest używane w testach.

### Organizacja assetów

Assety znajdują się w katalogu `assets/`.

Najważniejsze podkatalogi:

- `assets/map_styles/` - styl mapy MapLibre,
- `assets/google_signin/` - zasoby logowania Google,
- `assets/instagram_profile/` - ikona Instagrama,
- `assets/splash/` - obrazy splash screen,
- `assets/locario-icon-dark.png` - ikona używana przez konfigurację launcher icons.

Assety runtime są deklarowane w `pubspec.yaml`:

- `assets/map_styles/openstreetmap_custom.json`,
- `assets/google_signin/google_g.svg`,
- `assets/instagram_profile/instagram.svg`.

Splash screen i ikony aplikacji są skonfigurowane również w `pubspec.yaml` przez:

- `flutter_launcher_icons`,
- `flutter_native_splash`.

Wygenerowane zasoby platformowe znajdują się m.in. w `android/app/src/main/res/` i `ios/Runner/Assets.xcassets/`. Nie są to miejsca, w których powinno się zaczynać dodawanie nowych assetów runtime. Nowy asset używany przez Flutter UI powinien najpierw trafić do `assets/` i zostać zadeklarowany w `pubspec.yaml`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_theme_colors.dart`
- `lib/app/theme/theme_controller.dart`
- `lib/app/theme/theme_scope.dart`
- `lib/shared/widgets/state_panel.dart`
- `lib/shared/widgets/event_list_card.dart`
- `lib/features/shell/shell.dart`
- `lib/features/shell/nav/bottom_nav.dart`
- `lib/features/shell/header/header.dart`
- `lib/features/explore/widgets/advanced_filter_sheet.dart`
- `lib/features/explore/widgets/map_view.dart`
- `lib/features/events/widgets/gallery/event_gallery.dart`
- `lib/features/events/widgets/info/event_details_info.dart`
- `lib/features/hub/create_event/widgets/form_primitives.dart`
- `lib/features/hub/create_event/create_event_controller.dart`
- `lib/features/hub/create_event/create_event_state.dart`
- `lib/features/auth/login_screen.dart`
- `pubspec.yaml`

## 24. Lokalizacja językowa

Projekt używa Flutter gen-l10n.

Konfiguracja znajduje się w `l10n.yaml`:

- katalog ARB: `lib/l10n`,
- template: `app_en.arb`,
- output: `lib/l10n/app_localizations.dart`,
- klasa: `AppLocalizations`,
- `nullable-getter: false`.

Tłumaczenia źródłowe są podzielone na feature'y:

```text
lib/l10n/features/<feature>/<feature>_en.arb
lib/l10n/features/<feature>/<feature>_pl.arb
```

Skrypt `tool/generate_l10n.dart`:

1. Wyszukuje pliki `_<locale>.arb`.
2. Scala je do `app_en.arb` i `app_pl.arb`.
3. Uruchamia `flutter gen-l10n`.

`L10nService` jest używany w miejscach, gdzie komunikat lokalizacji jest potrzebny poza bezpośrednim kontekstem widgetu, np. w kontrolerach lub repozytoriach.

Najważniejsze pliki wykorzystane podczas analizy:

- `l10n.yaml`
- `tool/generate_l10n.dart`
- `gen-l10n.bat`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_pl.arb`
- `lib/l10n/features/`
- `lib/shared/services/l10n_service.dart`

## 25. Build, uruchamianie i CI

Podstawowe komendy lokalne:

```bash
flutter pub get
flutter analyze
flutter test --no-pub
```

Regeneracja lokalizacji:

```bash
dart run tool/generate_l10n.dart
```

Przykładowe uruchomienie z innym backendem:

```bash
flutter run --dart-define=LOCARIO_API_BASE_URL=http://localhost:8080
```

Przykładowe uruchomienie z Google Web Client ID:

```bash
flutter run --dart-define=LOCARIO_GOOGLE_WEB_CLIENT_ID=<client-id>
```

CI w `.github/workflows/ci.yml` działa dla pull requestów do gałęzi `dev`, z ignorowaniem zmian wyłącznie w Markdown i `.gitignore`. Workflow wykonuje:

- checkout,
- setup Java 21,
- setup Flutter 3.41.5,
- `flutter pub get`,
- `dart format --output=none --set-exit-if-changed lib test`,
- `flutter analyze`,
- `flutter test --no-pub`.

Release Android w `.github/workflows/build-release-android.yml` działa na push do gałęzi `release` i ręczne `workflow_dispatch`. Buduje:

- APK release,
- opcjonalnie AAB.

Android:

- Gradle Kotlin DSL,
- Android Gradle Plugin 8.11.1,
- Kotlin 2.2.20,
- Google Services plugin,
- Java compatibility 17,
- core library desugaring.

Do dopracowania przed produkcyjną publikacją:

- `applicationId` nadal ma wartość template'ową `com.example.locario`,
- release signing używa debug signing config,
- należy potwierdzić docelowe konfiguracje Firebase dla wszystkich platform,
- należy ustalić politykę środowisk i dart-define dla release.

Najważniejsze pliki wykorzystane podczas analizy:

- `README.md`
- `pubspec.yaml`
- `.github/workflows/ci.yml`
- `.github/workflows/build-release-android.yml`
- `android/app/build.gradle.kts`
- `android/settings.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`

## 26. Testy

Projekt zawiera zestaw testów jednostkowych i widgetowych oparty o `flutter_test`. Dodatkową zależnością testową jest `sqflite_common_ffi`, używane w testach wymagających działania lokalnej bazy SQLite poza urządzeniem lub emulatorem. W `pubspec.yaml` nie ma zależności typu `mockito` albo `mocktail`; izolacja testów jest realizowana przez ręcznie pisane fake'i i pamięciowe implementacje repozytoriów, storage oraz usług.

### Istniejące testy

`test/widget_test.dart` pełni rolę smoke testu aplikacji. Test inicjalizuje `sqflite_common_ffi`, ustawia `databaseFactory = databaseFactoryFfi`, konfiguruje `SharedPreferences.setMockInitialValues({})`, uruchamia `LocarioApp` i sprawdza podstawowe elementy dolnej nawigacji.

Testy w `test/app/` obejmują konfigurację aplikacyjną niezależną od konkretnego ekranu. `router_test.dart` sprawdza normalizację linków wejściowych, dostęp do tras publicznych, przekierowania na logowanie, obsługę ścieżki `/messages`, wejście w trasy czatu oraz ochronę tras organizatora. `settings_controllers_test.dart` testuje `LocaleController` i `ThemeController` przy użyciu `FakeAppSettingsStore`.

Testy w `test/shared/` sprawdzają wspólną logikę domenową i serwisową. W module auth testowane są modele oraz `AuthRepository`, w tym logowanie, rejestracja, odświeżanie tokenów, pobieranie profilu i czyszczenie tokenów przy wylogowaniu. W module events testowany jest `HttpEventRepository` oraz `EventDetailController`. W module groups testowane są modele, `HttpGroupRepository` i `GroupController`. Osobne testy obejmują usługi `ShareService` oraz `MapLaunchService`.

Testy w `test/features/` są pogrupowane według modułów ekranowych:

- `features/auth/` sprawdza formularze logowania i rejestracji, walidację oraz powrót do docelowej trasy po poprawnym uwierzytelnieniu.
- `features/explore/` obejmuje modele filtrów, `ExploreController`, `ExploreMapViewModel`, `MapWidget`, nagłówek wyszukiwania, ekran eksploracji i arkusz filtrów zaawansowanych.
- `features/events/` sprawdza ekran wydarzenia, stany ładowania i błędu, akcje autora, dołączanie do wydarzenia, widoczność akcji kalendarza, biletów i przycisków dla wydarzeń zakończonych.
- `features/hub/create_event/` testuje `CreateEventController`, `CreateEventLocationController` i ekran tworzenia wydarzenia, w tym wybór lokalizacji, tryb edycji, tworzenie wydarzenia oraz upload mediów po utworzeniu wydarzenia.
- `features/groups/` sprawdza ekran odkrywania grup, szczegóły grupy, domyślne zakładki dla członków i osób spoza grupy, publikowanie oraz usuwanie wpisów.
- `features/profile/` obejmuje ekran profilu, ustawienia, edycję profilu i historię wydarzeń.
- `features/saved/` obejmuje zapytania zapisanych wydarzeń, `SavedEventsController` i ekran zapisanych wydarzeń.
- `features/chat/` testuje listę rozmów, utrzymywanie ostatniej listy po pustej emisji streamu, renderowanie wiadomości oraz wysyłanie wiadomości bezpośrednich i grupowych.
- `features/shell/` obejmuje nagłówek powłoki, kontroler nagłówka i panel huba.

### Struktura katalogów testowych

Najważniejsza struktura katalogu `test/`:

```text
test/
  app/
    router_test.dart
    settings_controllers_test.dart
  features/
    auth/
    chat/
    events/
    explore/
    groups/
    hub/create_event/
    profile/
    saved/
    shell/
  shared/
    auth/
    events/
    groups/
    services/
  test_helpers/
    fake_app_settings_store.dart
    fake_event_repository.dart
    fake_location_service.dart
    test_app.dart
  widget_test.dart
```

Katalog `test/app/` jest przeznaczony dla testów elementów globalnych: routingu, ustawień aplikacji i kontrolerów wykorzystywanych ponad pojedynczym modułem. Nowe testy należy tu dodawać wtedy, gdy sprawdzana logika dotyczy konfiguracji aplikacji jako całości, a nie konkretnego feature'a.

Katalog `test/features/` odwzorowuje strukturę `lib/features/`. Testy ekranów, kontrolerów ekranowych, widżetów lokalnych i przepływów użytkownika należy dodawać do podkatalogu odpowiadającego modułowi funkcjonalnemu. Dla przykładu logika tworzenia wydarzenia trafia do `test/features/hub/create_event/`, a testy mapy i filtrów do `test/features/explore/`.

Katalog `test/shared/` odwzorowuje `lib/shared/`. Należy tu dodawać testy modeli, repozytoriów, serwisów i kontrolerów współdzielonych przez wiele ekranów. Przykładami są testy `AuthRepository`, `HttpEventRepository`, `GroupController` i serwisów uruchamiania mapy lub udostępniania.

Katalog `test/test_helpers/` zawiera wspólne narzędzia testowe. `test_app.dart` buduje uproszczony `MaterialApp` z delegatami lokalizacji i inicjalizacją `L10nService`, a fake'i usług pozwalają testować ekrany bez realnej geolokalizacji, sieci lub trwałego storage. Nowe helpery powinny trafiać do tego katalogu, gdy są używane przez więcej niż jeden plik testowy. Fake'i jednorazowe są zwykle definiowane lokalnie w pliku testu.

### Sposób uruchamiania

Pełny zestaw testów uruchamia się poleceniem:

```bash
flutter test --no-pub
```

Takie samo polecenie jest zapisane w `README.md` i w workflow CI `.github/workflows/ci.yml`. W CI zależności są instalowane wcześniej przez `flutter pub get`, dlatego testy są uruchamiane z flagą `--no-pub`.

Pojedynczy plik testowy można uruchomić standardowym poleceniem Fluttera, na przykład:

```bash
flutter test test/app/router_test.dart --no-pub
```

Przed pierwszym lokalnym uruchomieniem należy wykonać:

```bash
flutter pub get
```

Testów nie uruchomiono podczas przeglądu i aktualizacji dokumentacji, ponieważ zmiany dotyczą wyłącznie treści pliku Markdown.

### Mockowanie i izolacja zależności

Projekt nie używa generatorów mocków. Testy korzystają z ręcznie implementowanych klas fake, które implementują te same interfejsy lub rozszerzają te same klasy co produkcyjne zależności.

Wspólne fake'i znajdują się w `test/test_helpers/`:

- `FakeLocationService` zastępuje geolokalizację, geokodowanie i sprawdzanie dostępności usługi lokalizacji.
- `FakeEventRepository` zastępuje repozytorium wydarzeń i pozwala kontrolować listy wydarzeń, szczegóły wydarzenia oraz operacje tworzenia lub aktualizacji.
- `FakeAppSettingsStore` zastępuje storage ustawień języka i motywu.

W wielu plikach testowych znajdują się też fake'i lokalne, tworzone wyłącznie dla danego scenariusza. Przykładami są fake'i `AuthApi`, `LegalAcceptanceStore`, `FirestoreChatRepository`, `JoinedEventsController`, `CalendarService`, `GroupRepository`, `AuthTokenStorage`, pamięciowe repozytoria zapisanych wydarzeń oraz pamięciowe implementacje cache. Taki układ ogranicza zależność testów od zewnętrznych usług i pozwala sprawdzać zachowanie kontrolerów oraz widżetów deterministycznie.

Warstwa routingu w testach jest izolowana przez ręcznie składane kontrolery i repozytoria. Testy ekranów budują minimalne drzewo widgetów, często przez helper `buildLocalizedTestApp`, aby zapewnić dostęp do lokalizacji, `ScaffoldMessenger` i `L10nService` bez uruchamiania całej aplikacji.

### Dobre praktyki widoczne w projekcie

Testy są organizowane zgodnie z podziałem kodu produkcyjnego. Dzięki temu dodając nową funkcję w `lib/features/...` można łatwo wskazać odpowiadające jej miejsce w `test/features/...`.

Scenariusze z zależnościami zewnętrznymi są testowane przez wstrzykiwanie zależności. Kontrolery, repozytoria i ekrany w testach otrzymują fake'i zamiast realnego HTTP, Firestore, lokalizacji, kalendarza lub storage. Jest to spójne z architekturą aplikacji, w której zależności są przekazywane przez konstruktory albo scopes.

Testy widgetowe skupiają się na obserwowalnym zachowaniu: widoczności elementów, walidacji formularzy, nawigacji, komunikatach błędów i skutkach kliknięć. Testy kontrolerów sprawdzają stan oraz wywołania repozytoriów bez budowania pełnego UI.

Testy routingu pokrywają nie tylko ścieżki poprawne, ale też redirecty i ochronę tras. Ma to znaczenie, ponieważ routing korzysta z `SessionController`, `LegalController`, parametrów ścieżki i linków przychodzących.

W testach wymagających lokalnej bazy konfiguracja SQLite jest wykonywana przez `sqflite_common_ffi`. Pozwala to uruchamiać testy na maszynie developerskiej i w CI bez emulatora.

Warto kontynuować praktykę dodawania testu blisko zmienianego modułu oraz używania fake'ów lokalnych tylko wtedy, gdy nie są współdzielone. Jeżeli dany fake zaczyna być potrzebny w kilku plikach, powinien zostać przeniesiony do `test/test_helpers/`.

Potencjalne luki testowe do dalszego sprawdzenia:

- pełny przepływ FCM i lokalnych powiadomień,
- pełny przepływ Firestore z regułami bezpieczeństwa,
- upload mediów przez presigned URL,
- scenariusze konfliktów synchronizacji zapisanych wydarzeń,
- scenariusze unieważniania cache,
- build Android release z docelowym signingiem,
- integracyjne testy end-to-end obejmujące kilka modułów naraz.

Najważniejsze pliki wykorzystane podczas analizy:

- `pubspec.yaml`
- `README.md`
- `.github/workflows/ci.yml`
- `test/widget_test.dart`
- `test/test_helpers/test_app.dart`
- `test/test_helpers/fake_location_service.dart`
- `test/test_helpers/fake_event_repository.dart`
- `test/test_helpers/fake_app_settings_store.dart`
- `test/app/router_test.dart`
- `test/app/settings_controllers_test.dart`
- `test/shared/auth/auth_repository_test.dart`
- `test/shared/events/event_repository_test.dart`
- `test/shared/groups/group_controller_test.dart`
- `test/features/explore/explore_screen_test.dart`
- `test/features/hub/create_event/create_event_controller_test.dart`
- `test/features/chat/chat_screen_test.dart`

## 27. Katalog najważniejszych klas, serwisów, repozytoriów, modeli i komponentów

Ten rozdział opisuje publiczne i architektonicznie istotne klasy występujące w projekcie. Pominięto prywatne klasy pomocnicze rozpoczynające się od `_`, klasy generowane przez Fluttera oraz drobne widgety używane wyłącznie lokalnie w jednym pliku, jeżeli nie pełnią samodzielnej roli architektonicznej.

W projekcie nie występują klasy BLoC ani pakiety `provider`, `flutter_bloc`, `riverpod` albo `bloc`. Rolę providerów pełnią własne klasy `Scope` oparte o `InheritedWidget` i `InheritedNotifier`.

### App, konfiguracja i bootstrap

- `LocarioApp`
  - Odpowiedzialność: główny widget aplikacji; tworzy repozytoria, kontrolery, scopes i `MaterialApp.router`.
  - Lokalizacja: `lib/app/app.dart`.
  - Zależności: `AuthRepository`, `AuthApi`, `AuthStorage`, `CacheService`, `SessionController`, kontrolery ustawień, kontrolery domenowe, `createAppRouter`.
  - Najważniejsze metody: `initState`, `dispose`, `_onSessionChanged`, `build`.
  - Miejsce użycia: uruchamiany w `lib/main.dart` po inicjalizacji Firebase i lokalnych powiadomień.

- `ApiConfig`
  - Odpowiedzialność: przechowuje konfigurację bazowego URL API i Google Web Client ID.
  - Lokalizacja: `lib/shared/config/api_config.dart`.
  - Zależności: `String.fromEnvironment`.
  - Najważniejsze metody/pola: `baseUrl`, `googleWebClientId`.
  - Miejsce użycia: klasy API i repozytoria HTTP, m.in. `AuthApi`, `HttpEventRepository`, `HttpGroupRepository`, `NotificationsApi`, `HttpReviewRepository`.

- `NavigationHistoryController`
  - Odpowiedzialność: zapamiętuje aktualną lokalizację routera i ostatnią bezpieczną lokalizację powrotu.
  - Lokalizacja: `lib/app/navigation_history.dart`.
  - Zależności: brak zewnętrznych zależności.
  - Najważniejsze metody: `recordLocation`; gettery `currentLocation`, `lastSafeLocation`.
  - Miejsce użycia: routing i logika powrotu po przejściu przez logowanie.

- `RouteHistoryReporter`
  - Odpowiedzialność: widget raportujący zmianę trasy do `NavigationHistoryController`.
  - Lokalizacja: `lib/app/navigation_history.dart`.
  - Zależności: `NavigationHistoryController`, Flutter lifecycle.
  - Najważniejsze metody: `initState`, `didUpdateWidget`, `_scheduleReport`.
  - Miejsce użycia: drzewo aplikacji budowane przez router.

- `AppSettingsStore`
  - Odpowiedzialność: abstrakcyjny kontrakt trwałego zapisu ustawień aplikacji.
  - Lokalizacja: `lib/app/settings/app_settings_store.dart`.
  - Zależności: `Locale`, `ThemeMode`.
  - Najważniejsze metody: `loadLocale`, `saveLocale`, `loadThemeMode`, `saveThemeMode`.
  - Miejsce użycia: `LocaleController`, `ThemeController`, testowe fake'i ustawień.

- `SharedPreferencesAppSettingsStore`
  - Odpowiedzialność: implementuje `AppSettingsStore` przy użyciu `SharedPreferences`.
  - Lokalizacja: `lib/app/settings/app_settings_store.dart`.
  - Zależności: `shared_preferences`.
  - Najważniejsze metody: `loadLocale`, `saveLocale`, `loadThemeMode`, `saveThemeMode`.
  - Miejsce użycia: tworzony w `LocarioApp` i przekazywany do kontrolerów języka oraz motywu.

- `ThemeController`
  - Odpowiedzialność: zarządza wybranym trybem motywu i zapisuje go w `AppSettingsStore`.
  - Lokalizacja: `lib/app/theme/theme_controller.dart`.
  - Zależności: `AppSettingsStore`, `ChangeNotifier`.
  - Najważniejsze metody: `load`, `setThemeMode`; getter `themeMode`.
  - Miejsce użycia: `ThemeScope`, `LocarioApp`, `SettingsScreen`.

- `LocaleController`
  - Odpowiedzialność: zarządza aktualnym językiem aplikacji i zapisuje go w `AppSettingsStore`.
  - Lokalizacja: `lib/app/locale/locale_controller.dart`.
  - Zależności: `AppSettingsStore`, `ChangeNotifier`.
  - Najważniejsze metody: `load`, `setLocale`; getter `locale`.
  - Miejsce użycia: `LocaleScope`, `LocarioApp`, `SettingsScreen`.

- `LocarioThemeColors`
  - Odpowiedzialność: rozszerzenie `ThemeExtension` z kolorami specyficznymi dla aplikacji.
  - Lokalizacja: `lib/app/theme/app_theme_colors.dart`.
  - Zależności: `ThemeExtension`, `Color`.
  - Najważniejsze metody: `copyWith`, `lerp`.
  - Miejsce użycia: definicje motywu w `app_theme.dart` i widgety pobierające kolory z `Theme.of(context).extension`.

### Scopes i providery kontekstowe

- `AuthScope`
  - Odpowiedzialność: udostępnia `SessionController` w drzewie widgetów.
  - Lokalizacja: `lib/shared/auth/auth_scope.dart`.
  - Zależności: `InheritedNotifier<SessionController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: ekrany wymagające profilu, tokenów albo stanu sesji, np. `ProfileScreen`, `EventScreen`, `GroupDetailsScreen`, `LoginScreen`.

- `ThemeScope`
  - Odpowiedzialność: udostępnia `ThemeController`.
  - Lokalizacja: `lib/app/theme/theme_scope.dart`.
  - Zależności: `InheritedNotifier<ThemeController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: ustawienia motywu i korzeń aplikacji.

- `LocaleScope`
  - Odpowiedzialność: udostępnia `LocaleController`.
  - Lokalizacja: `lib/app/locale/locale_scope.dart`.
  - Zależności: `InheritedNotifier<LocaleController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: `SettingsScreen` i `LocarioApp`.

- `CacheScope`
  - Odpowiedzialność: udostępnia instancję `CacheService`.
  - Lokalizacja: `lib/shared/cache/cache_scope.dart`.
  - Zależności: `InheritedWidget`, `CacheService`.
  - Najważniejsze metody: `of`, `maybeOf`, `updateShouldNotify`.
  - Miejsce użycia: kontrolery i ekrany korzystające z cache, szczególnie grupy oraz dane wydarzeń.

- `CategoryScope`
  - Odpowiedzialność: udostępnia `CategoryController`.
  - Lokalizacja: `lib/shared/events/category_scope.dart`.
  - Zależności: `InheritedWidget`, `CategoryController`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: Explore, formularz tworzenia wydarzenia, formularz grupy.

- `EventDetailScope`
  - Odpowiedzialność: udostępnia `EventDetailController`.
  - Lokalizacja: `lib/shared/events/event_detail_scope.dart`.
  - Zależności: `InheritedNotifier<EventDetailController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: `EventScreen`, widoki szczegółów wydarzenia i historii wydarzeń.

- `JoinedEventsScope`
  - Odpowiedzialność: udostępnia `JoinedEventsController`.
  - Lokalizacja: `lib/features/events/joined_events_scope.dart`.
  - Zależności: `InheritedNotifier<JoinedEventsController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: `EventScreen`, `EventDetailsInfo`.

- `SavedEventsScope`
  - Odpowiedzialność: udostępnia `SavedEventsController`.
  - Lokalizacja: `lib/features/saved/saved_events_scope.dart`.
  - Zależności: `InheritedNotifier<SavedEventsController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: Explore, `EventScreen`, `SavedScreen`.

- `SavedFiltersScope`
  - Odpowiedzialność: udostępnia `SavedFiltersController`.
  - Lokalizacja: `lib/features/saved/saved_filters_scope.dart`.
  - Zależności: `InheritedNotifier<SavedFiltersController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: `SavedScreen`, `ExploreAdvancedFilterSheet`, `ExploreScreen`.

- `GroupScope`
  - Odpowiedzialność: udostępnia `GroupController`.
  - Lokalizacja: `lib/shared/groups/group_scope.dart`.
  - Zależności: `InheritedNotifier<GroupController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: ekrany grup, formularz grupy, tworzenie wydarzeń powiązanych z grupami.

- `NotificationScope`
  - Odpowiedzialność: udostępnia `NotificationController`.
  - Lokalizacja: `lib/shared/notifications/notification_scope.dart`.
  - Zależności: `InheritedNotifier<NotificationController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: `InboxScreen`, `SettingsScreen`, `ShellHeader`.

- `ReviewScope`
  - Odpowiedzialność: udostępnia `ReviewController`.
  - Lokalizacja: `lib/shared/reviews/review_scope.dart`.
  - Zależności: `InheritedNotifier<ReviewController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: `EventReviewScreen`, `ProfileScreen`, `OrganizerReviewsScreen`.

- `LegalScope`
  - Odpowiedzialność: udostępnia `LegalController`.
  - Lokalizacja: `lib/features/legals/legal_scope.dart`.
  - Zależności: `InheritedNotifier<LegalController>`.
  - Najważniejsze metody: `of`, `maybeOf`.
  - Miejsce użycia: routing, `LegalAcceptanceScreen`, ekrany auth.

### Auth i sesja

- `SessionController`
  - Odpowiedzialność: centralny kontroler sesji użytkownika, profilu, tokenów i operacji auth.
  - Lokalizacja: `lib/shared/auth/session_controller.dart`.
  - Zależności: `AuthRepository`, `ChangeNotifier`.
  - Najważniejsze metody: `load`, `login`, `loginWithGoogle`, `register`, `changePassword`, `updateProfile`, `requestOrganizerVerification`, `refreshProfile`, `logout`; wewnętrznie `_tryRefreshTokens`.
  - Miejsce użycia: `AuthScope`, `createAppRouter`, ekrany auth, profile, grupy, wydarzenia, powiadomienia i recenzje.

- `AuthApi`
  - Odpowiedzialność: niskopoziomowy klient HTTP dla operacji uwierzytelniania i profilu.
  - Lokalizacja: `lib/shared/auth/auth_api.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`, modele auth.
  - Najważniejsze metody: `register`, `login`, `refresh`, `loginWithGoogle`, `logout`, `fetchProfile`, `updateProfile`, `changePassword`, `submitOrganizerVerification`.
  - Miejsce użycia: `AuthRepository`, testy auth i ekrany profilu przez `SessionController`.

- `AuthRepository`
  - Odpowiedzialność: warstwa pośrednia między `SessionController`, `AuthApi` i trwałym storage tokenów.
  - Lokalizacja: `lib/shared/auth/auth_repository.dart`.
  - Zależności: `AuthApi`, `AuthTokenStorage`.
  - Najważniejsze metody: `register`, `login`, `loginWithGoogle`, `refresh`, `fetchProfile`, `updateProfile`, `changePassword`, `logout`, `submitOrganizerVerification`, `readTokens`, `clear`.
  - Miejsce użycia: `SessionController`.

- `AuthTokenStorage`
  - Odpowiedzialność: abstrakcyjny kontrakt zapisu i odczytu tokenów.
  - Lokalizacja: `lib/shared/auth/auth_repository.dart`.
  - Zależności: `AuthTokens`.
  - Najważniejsze metody: `saveTokens`, `readTokens`, `clear`.
  - Miejsce użycia: `AuthRepository`, `AuthStorage`, fake'i testowe.

- `AuthStorage`
  - Odpowiedzialność: implementacja `AuthTokenStorage` oparta o `flutter_secure_storage`.
  - Lokalizacja: `lib/shared/auth/auth_storage.dart`.
  - Zależności: `FlutterSecureStorage`, `AuthTokens`.
  - Najważniejsze metody: `saveTokens`, `readTokens`, `clear`.
  - Miejsce użycia: `LocarioApp` przy tworzeniu `AuthRepository`.

- `FavoritesApi`
  - Odpowiedzialność: wykonuje żądania dodania i usunięcia ulubionego wydarzenia po stronie frontendu.
  - Lokalizacja: `lib/shared/auth/favorites_api.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`, token dostępu.
  - Najważniejsze metody: `addFavorite`, `removeFavorite`.
  - Miejsce użycia: `SavedEventsController` przy synchronizacji zapisanych wydarzeń dla zalogowanego użytkownika.

- `AuthTokens`
  - Odpowiedzialność: model tokenu access/refresh, typu tokenu i daty wygaśnięcia.
  - Lokalizacja: `lib/shared/auth/auth_models.dart`.
  - Zależności: `DateTime`.
  - Najważniejsze metody/gettery: `isExpired`, `authorizationHeader`.
  - Miejsce użycia: `AuthStorage`, `AuthRepository`, `SessionController`, repozytoria wymagające autoryzacji.

- `AuthResponse`
  - Odpowiedzialność: model odpowiedzi auth zawierający tokeny i opcjonalny profil.
  - Lokalizacja: `lib/shared/auth/auth_models.dart`.
  - Zależności: `AuthTokens`, `UserProfile`.
  - Najważniejsze metody: `fromJson`.
  - Miejsce użycia: `AuthApi`, `AuthRepository`.

- `RegisterRequest`, `LoginRequest`, `RefreshTokenRequest`, `ChangePasswordRequest`, `UpdateProfileRequest`, `GoogleOAuthRequest`
  - Odpowiedzialność: modele żądań wysyłanych przez frontend do warstwy auth.
  - Lokalizacja: `lib/shared/auth/auth_models.dart`.
  - Zależności: podstawowe typy Dart.
  - Najważniejsze metody: `toJson`.
  - Miejsce użycia: `AuthApi`, `AuthRepository`, ekrany logowania, rejestracji, edycji profilu i zmiany hasła.

- `UserProfile`
  - Odpowiedzialność: model profilu użytkownika, roli, danych organizatora, linków społecznościowych i historii profilu.
  - Lokalizacja: `lib/shared/auth/auth_models.dart`.
  - Zależności: `FavoriteEventSummary`, `ProfileEventSummary`.
  - Najważniejsze metody/gettery: `fromJson`, `normalizedRole`, `hasOrganizerReviewAccess`.
  - Miejsce użycia: `SessionController`, routing, profile, grupy, recenzje, czat.

- `FavoriteEventSummary` i `ProfileEventSummary`
  - Odpowiedzialność: uproszczone modele wydarzeń zapisanych i wydarzeń użytkownika w profilu.
  - Lokalizacja: `lib/shared/auth/auth_models.dart`.
  - Zależności: `DateTime`.
  - Najważniejsze metody: `fromJson`.
  - Miejsce użycia: `UserProfile`, `ProfileScreen`, `EventHistoryScreen`.

### Wydarzenia i Explore

- `EventRepository`
  - Odpowiedzialność: abstrakcyjny kontrakt repozytorium wydarzeń.
  - Lokalizacja: `lib/shared/events/event_repository.dart`.
  - Zależności: modele `ExploreEvent`, `EventRequest`, `Category`, `EventMedia`.
  - Najważniejsze metody: `fetchMapEvents`, `fetchEvents`, `fetchEvent`, `fetchOrganizerEvents`, `createEvent`, `updateEvent`, `uploadEventMedia`, `deleteEventMedia`, `setEventThumbnail`, `fetchCategories`.
  - Miejsce użycia: `ExploreController`, `EventDetailController`, `CategoryController`, `CreateEventController`, `GroupController`, testowe fake'i.

- `HttpEventRepository`
  - Odpowiedzialność: implementacja `EventRepository` korzystająca z HTTP i serializacji JSON.
  - Lokalizacja: `lib/shared/events/event_repository.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`, modele Explore, tokeny przekazywane do wybranych metod.
  - Najważniejsze metody: implementacje metod kontraktu `EventRepository`, dodatkowo presigned upload mediów.
  - Miejsce użycia: `LocarioApp` i ekrany, które tworzą własne repozytorium domyślne.

- `EventRequest`
  - Odpowiedzialność: model danych wysyłanych przy tworzeniu lub aktualizacji wydarzenia.
  - Lokalizacja: `lib/shared/events/event_repository.dart`.
  - Zależności: `LatLng`, `EventStatus`, listy kategorii i grup.
  - Najważniejsze metody: `toJson`.
  - Miejsce użycia: `CreateEventController`, `HttpEventRepository.createEvent`, `HttpEventRepository.updateEvent`.

- `PresignedUploadResponse`
  - Odpowiedzialność: model odpowiedzi wymaganej do uploadu pliku przez presigned URL.
  - Lokalizacja: `lib/shared/events/event_repository.dart`.
  - Zależności: podstawowe typy Dart.
  - Najważniejsze metody: konstruktor i pola `uploadUrl`, `mediaId`, `publicUrl`.
  - Miejsce użycia: `HttpEventRepository.uploadEventMedia`.

- `EventRegistrationApi`
  - Odpowiedzialność: klient HTTP dla operacji dołączania do wydarzeń, anulowania rejestracji i pobierania slotów.
  - Lokalizacja: `lib/shared/events/event_registration_api.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`, `EventSlotsResponse`.
  - Najważniejsze metody: `joinEvent`, `cancelRegistration`, `fetchSlots`.
  - Miejsce użycia: `JoinedEventsController`, `EventDetailController`.

- `EventSlotsResponse`
  - Odpowiedzialność: model informacji o limitach miejsc i zajętych slotach wydarzenia.
  - Lokalizacja: `lib/shared/events/event_slots_response.dart`.
  - Zależności: podstawowe typy Dart.
  - Najważniejsze metody: `fromJson`.
  - Miejsce użycia: `EventRegistrationApi`, `EventDetailController`, UI szczegółów wydarzenia.

- `EventDetailController`
  - Odpowiedzialność: zarządza stanem szczegółów wydarzenia, slotów i innych wydarzeń organizatora.
  - Lokalizacja: `lib/shared/events/event_detail_controller.dart`.
  - Zależności: `EventRepository`, `EventRegistrationApi`, `CacheService`, `SessionController`, `ChangeNotifier`.
  - Najważniejsze metody: `loadEvent`, `loadEventSlots`, `loadOrganizerEvents`, `clearEvent`.
  - Miejsce użycia: `EventDetailScope`, `EventScreen`, `EventHistoryScreen`.

- `CategoryController`
  - Odpowiedzialność: ładuje i przechowuje listę kategorii wydarzeń.
  - Lokalizacja: `lib/shared/events/category_controller.dart`.
  - Zależności: `EventRepository`, `ChangeNotifier`.
  - Najważniejsze metody: `loadCategories`; gettery `categories`, `isLoading`, `error`.
  - Miejsce użycia: `CategoryScope`, Explore, formularze wydarzeń i grup.

- `EventRefreshSignal`
  - Odpowiedzialność: prosty sygnał `ChangeNotifier` informujący o potrzebie odświeżenia list wydarzeń.
  - Lokalizacja: `lib/shared/events/event_refresh_signal.dart`.
  - Zależności: `ChangeNotifier`.
  - Najważniejsze metody: `notifyChanged`.
  - Miejsce użycia: po utworzeniu/edycji wydarzenia i w `ExploreScreen`.

- `JoinedEventsController`
  - Odpowiedzialność: przechowuje zestaw wydarzeń, do których użytkownik dołączył, oraz wykonuje join/cancel.
  - Lokalizacja: `lib/features/events/joined_events_controller.dart`.
  - Zależności: `EventRegistrationApi`, `SessionController`, `ChangeNotifier`.
  - Najważniejsze metody: `load`, `fetchSlots`, `joinEvent`, `cancelRegistration`; getter `joinedEventIds`.
  - Miejsce użycia: `JoinedEventsScope`, `EventScreen`, `EventDetailsInfo`.

- `ExploreController`
  - Odpowiedzialność: stan listy wydarzeń w Explore, filtrowanie, sortowanie, wyszukiwanie i odświeżanie danych.
  - Lokalizacja: `lib/features/explore/explore_controller.dart`.
  - Zależności: `EventRepository`, `ExploreEventQuery`, `ExploreState`, `Category`, `ExploreAdvancedFilters`, `LatLng`, `ChangeNotifier`.
  - Najważniejsze metody: `loadEvents`, `updateSearchQuery`, `updateSort`, `toggleSortOrder`, `updateAdvancedFilters`, `applyFilters`, `updateCategories`, `updateReferenceLocation`, `updateDistanceOverride`.
  - Miejsce użycia: `ExploreScreen`.

- `ExploreEventQuery`
  - Odpowiedzialność: wykonuje czyste filtrowanie i wyszukiwanie na kolekcjach `ExploreEvent`.
  - Lokalizacja: `lib/features/explore/explore_event_query.dart`.
  - Zależności: `ExploreEvent`, `Category`, `ExploreAdvancedFilters`, `SavedEventRecord`.
  - Najważniejsze metody: `visibleEvents`, `searchResults`.
  - Miejsce użycia: `ExploreController`, `SavedEventQuery`.

- `ExploreAreaController`
  - Odpowiedzialność: zarządza wyborem obszaru wyszukiwania: bieżąca lokalizacja, wpisany adres albo punkt z mapy.
  - Lokalizacja: `lib/features/explore/explore_area_controller.dart`.
  - Zależności: `geocoding`, `LatLng`, `ChangeNotifier`.
  - Najważniejsze metody: `selectCurrentLocation`, `startMapPicking`, `cancelMapPicking`, `updateViewportCenter`, `searchInArea`, `selectAddress`.
  - Miejsce użycia: `ExploreScreen`, `ExploreAdvancedFilterSheet`, widgety wyboru obszaru.

- `ExploreMapViewModel`
  - Odpowiedzialność: stan mapy związany z lokalizacją użytkownika, uprawnieniami i komunikatami mapy.
  - Lokalizacja: `lib/features/explore/map_view_model.dart`.
  - Zależności: `LocationService`, `LatLng`, `ChangeNotifier`.
  - Najważniejsze metody: `setPreferredMapCenter`, `loadInitialLocation`, `refreshLocation`, `openAppSettings`, `openLocationSettings`.
  - Miejsce użycia: `ExploreScreen`, `MapWidget`.

- `ExploreState`, `ExploreLoading`, `ExploreData`, `ExploreDataLoading`, `ExploreEmpty`, `ExploreError`
  - Odpowiedzialność: reprezentują możliwe stany listy wydarzeń w Explore.
  - Lokalizacja: `lib/features/explore/explore_state.dart`.
  - Zależności: `ExploreEvent`, `ExploreErrorType`.
  - Najważniejsze metody: konstruktory stanów; dane stanu w polach klas.
  - Miejsce użycia: `ExploreController`, `ExploreScreen`.

- `Category`, `EventMedia`, `EventGroupSummary`, `ExploreEvent`
  - Odpowiedzialność: główne modele domenowe wydarzeń, kategorii, mediów i powiązanych grup.
  - Lokalizacja: `lib/features/explore/models.dart`.
  - Zależności: `LatLng`, `Color`, `IconData`, enumy `EventStatus`, `MediaType`.
  - Najważniejsze metody/gettery: `fromJson`, `toJson`, `accentColor`, `icon`, `effectiveThumbnailUrl`, `hasEnded`.
  - Miejsce użycia: Explore, szczegóły wydarzenia, zapisane wydarzenia, grupy, recenzje, kalendarz.

- `ExploreFilter`, `ExploreAreaSelection`, `ExploreAdvancedFilters`
  - Odpowiedzialność: modele kryteriów filtrowania i obszaru wyszukiwania.
  - Lokalizacja: `lib/features/explore/models.dart`.
  - Zależności: `DateTime`, `LatLng`.
  - Najważniejsze metody/gettery: `copyWith`, `toJson`, `fromJson`, `hasActiveFilters`, `activeFiltersCount`.
  - Miejsce użycia: `ExploreController`, `ExploreAdvancedFilterSheet`, zapisane filtry.

### Saved

- `SavedEventsController`
  - Odpowiedzialność: zarządza lokalną listą zapisanych wydarzeń i synchronizacją z ulubionymi użytkownika.
  - Lokalizacja: `lib/features/saved/saved_events_controller.dart`.
  - Zależności: `SavedEventsRepository`, `FavoritesApi`, `EventRepository`, opcjonalny `SessionController`, `ChangeNotifier`.
  - Najważniejsze metody: `load`, `syncWithRemote`, `toggleSaved`, `saveEvent`, `removeEvent`, `replaceAll`, `clear`.
  - Miejsce użycia: `SavedEventsScope`, `SavedScreen`, Explore i `EventScreen`.

- `SavedEventsRepository`
  - Odpowiedzialność: abstrakcyjny kontrakt lokalnego zapisu wydarzeń.
  - Lokalizacja: `lib/features/saved/saved_events_repository.dart`.
  - Zależności: `SavedEventRecord`.
  - Najważniejsze metody: `loadSavedEvents`, `upsertSavedEvent`, `removeSavedEvent`, `replaceSavedEvents`, `clear`.
  - Miejsce użycia: `SavedEventsController`, implementacja shared preferences i testy.

- `SharedPreferencesSavedEventsRepository`
  - Odpowiedzialność: implementuje zapis zapisanych wydarzeń w `SharedPreferences`.
  - Lokalizacja: `lib/features/saved/saved_events_repository.dart`.
  - Zależności: `shared_preferences`, `SavedEventRecord`.
  - Najważniejsze metody: implementacje kontraktu `SavedEventsRepository`.
  - Miejsce użycia: `LocarioApp`.

- `SavedEventRecord`
  - Odpowiedzialność: model lokalnie zapisanego wydarzenia wraz ze stanem synchronizacji.
  - Lokalizacja: `lib/features/saved/saved_events_repository.dart`.
  - Zależności: `ExploreEvent`, `SavedEventSyncState`.
  - Najważniejsze metody: `copyWith`, `toJson`, `fromJson`.
  - Miejsce użycia: `SavedEventsController`, `SavedEventQuery`, `SavedScreen`.

- `SavedFiltersController`
  - Odpowiedzialność: zarządza zapisanymi filtrami Explore i przekazaniem filtra do ekranu Explore.
  - Lokalizacja: `lib/features/saved/saved_filters_controller.dart`.
  - Zależności: `SavedFiltersRepository`, `SavedFilter`, `ExploreAdvancedFilters`, `ChangeNotifier`.
  - Najważniejsze metody: `loadFilters`, `saveFilter`, `deleteFilter`, `toggleNotifications`, `toggleLocationMode`, `loadFilterToExplore`, `consumePendingLoad`.
  - Miejsce użycia: `SavedFiltersScope`, `SavedScreen`, `ExploreAdvancedFilterSheet`, `ExploreScreen`.

- `SavedFiltersRepository`
  - Odpowiedzialność: abstrakcyjny kontrakt zapisu zapisanych filtrów.
  - Lokalizacja: `lib/features/saved/saved_filters_repository.dart`.
  - Zależności: `SavedFilter`.
  - Najważniejsze metody: `loadAll`, `save`, `delete`, `update`, `clear`.
  - Miejsce użycia: `SavedFiltersController`.

- `SharedPreferencesSavedFiltersRepository`
  - Odpowiedzialność: implementuje zapis filtrów w `SharedPreferences`.
  - Lokalizacja: `lib/features/saved/saved_filters_repository.dart`.
  - Zależności: `shared_preferences`, `SavedFilter`.
  - Najważniejsze metody: implementacje kontraktu `SavedFiltersRepository`.
  - Miejsce użycia: `LocarioApp`.

- `SavedFilter`
  - Odpowiedzialność: model nazwanego filtra Explore, ustawień powiadomień i trybu lokalizacji.
  - Lokalizacja: `lib/features/saved/saved_filter_model.dart`.
  - Zależności: `ExploreAdvancedFilters`.
  - Najważniejsze metody: `copyWith`, `toJson`, `fromJson`.
  - Miejsce użycia: `SavedFiltersController`, `SavedScreen`, `ExploreAdvancedFilterSheet`.

- `SavedFilters` i `SavedEventQuery`
  - Odpowiedzialność: model filtrów zapisanych wydarzeń oraz logika filtrowania/sortowania rekordów.
  - Lokalizacja: `lib/features/saved/saved_event_query.dart`.
  - Zależności: `SavedEventRecord`, `SavedSortOption`, `LatLng`.
  - Najważniejsze metody/gettery: `visibleRecords`, `hasActiveFilters`, `activeFiltersCount`.
  - Miejsce użycia: `SavedScreen`.

### Groups

- `GroupController`
  - Odpowiedzialność: centralny kontroler modułu grup: odkrywanie, moje grupy, szczegóły, feed, członkowie, wydarzenia, raporty, komentarze i media.
  - Lokalizacja: `lib/shared/groups/group_controller.dart`.
  - Zależności: `GroupRepository`, `EventRepository`, `CacheService`, `SessionController`, `ChangeNotifier`.
  - Najważniejsze metody: `loadDiscoverGroups`, `loadMyGroups`, `loadGroupDetail`, `loadGroupMembers`, `loadGroupFeed`, `loadMoreGroupFeed`, `loadGroupEvents`, `joinGroup`, `leaveGroup`, `createPost`, `updatePost`, `deletePost`, `hidePost`, `changeRole`, `banMember`, `removeMember`, `transferOwnership`, `deleteGroup`, `reportGroup`, `reportPost`, `reportEvent`, `resolveReport`, `rejectReport`, `linkEvent`, `unlinkEvent`, `uploadMedia`, `fetchComments`, `createComment`, `updateComment`, `deleteComment`, `likePost`, `unlikePost`.
  - Miejsce użycia: `GroupScope`, `GroupDiscoverScreen`, `GroupDetailsScreen`, `GroupFormScreen`, `GroupPostCommentsScreen`.

- `GroupRepository`
  - Odpowiedzialność: abstrakcyjny kontrakt sieciowych operacji grup.
  - Lokalizacja: `lib/shared/groups/group_repository.dart`.
  - Zależności: modele grup i `ExploreEvent`.
  - Najważniejsze metody: operacje CRUD grup, członkostwa, feedu, komentarzy, raportów, linkowania wydarzeń i uploadu mediów.
  - Miejsce użycia: `GroupController`, `GroupFormScreen`, `PinSelector`, testy.

- `HttpGroupRepository`
  - Odpowiedzialność: implementacja `GroupRepository` oparta o HTTP, JSON i upload presigned URL.
  - Lokalizacja: `lib/shared/groups/group_repository.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`, modele grup, tokeny przekazywane do metod.
  - Najważniejsze metody: implementacje kontraktu `GroupRepository`.
  - Miejsce użycia: `LocarioApp`, `GroupFormScreen`, `PinSelector`.

- `GroupCreateRequest` i `GroupUpdateRequest`
  - Odpowiedzialność: modele danych wysyłanych przy tworzeniu i edycji grupy.
  - Lokalizacja: `lib/shared/groups/group_models.dart`.
  - Zależności: `GroupVisibility`.
  - Najważniejsze metody: `toJson`.
  - Miejsce użycia: `GroupFormScreen`, `HttpGroupRepository`.

- `Group`
  - Odpowiedzialność: główny model grupy, widoczności, kategorii, członkostwa i metadanych wizualnych.
  - Lokalizacja: `lib/shared/groups/group_models.dart`.
  - Zależności: `GroupVisibility`, `GroupMembershipStatus`, `GroupRole`.
  - Najważniejsze metody/gettery: `fromJson`, `toJson`, `isPublic`, `isPrivate`, `isMember`, `isPending`, `isBanned`, `isAdmin`.
  - Miejsce użycia: `GroupController`, ekrany grup, `CreateEventController`.

- `GroupMember`
  - Odpowiedzialność: model członka grupy, roli i statusu członkostwa.
  - Lokalizacja: `lib/shared/groups/group_models.dart`.
  - Zależności: `GroupRole`, `GroupMembershipStatus`.
  - Najważniejsze metody: `fromJson`, `toJson`.
  - Miejsce użycia: `GroupDetailsScreen`, `GroupController`, czat bezpośredni.

- `GroupFeedItem` i `GroupPost`
  - Odpowiedzialność: modele elementu feedu i wpisu w grupie.
  - Lokalizacja: `lib/shared/groups/group_models.dart`.
  - Zależności: `GroupFeedItemType`, `ExploreEvent`, `EventMedia`.
  - Najważniejsze metody: `fromJson`, `toJson`, `copyWith`.
  - Miejsce użycia: `GroupController`, `GroupDetailsScreen`.

- `GroupPostRequest`, `GroupPostComment`, `GroupPostCommentRequest`
  - Odpowiedzialność: modele tworzenia/edycji wpisów i komentarzy grupowych.
  - Lokalizacja: `lib/shared/groups/group_models.dart`.
  - Zależności: podstawowe typy Dart.
  - Najważniejsze metody: `toJson`, `fromJson` dla komentarza.
  - Miejsce użycia: `GroupController`, `GroupDetailsScreen`, `GroupPostCommentsScreen`.

- `GroupReportRequest` i `GroupReport`
  - Odpowiedzialność: modele zgłoszeń grup, wpisów i wydarzeń.
  - Lokalizacja: `lib/shared/groups/group_models.dart`.
  - Zależności: podstawowe typy Dart.
  - Najważniejsze metody: `toJson`, `fromJson`.
  - Miejsce użycia: `GroupController`, `GroupDetailsScreen`.

- `MyGroupsCache`
  - Odpowiedzialność: statyczny cache listy grup użytkownika.
  - Lokalizacja: `lib/shared/groups/my_groups_cache.dart`.
  - Zależności: `HttpGroupRepository`, `Group`.
  - Najważniejsze metody: `prefetch`, `set`, `invalidate`; gettery `myGroups`, `hasValue`, `isNotEmpty`.
  - Miejsce użycia: bootstrap i ekrany zależne od szybkiej informacji o grupach użytkownika.

- `PredefinedPin`
  - Odpowiedzialność: model predefiniowanego stylu pinezki grupy.
  - Lokalizacja: `lib/shared/groups/pin_styles.dart`.
  - Zależności: `Color`.
  - Najważniejsze metody/pola: `all`, `fromStyleKey`.
  - Miejsce użycia: `PinSelector`, formularze grup.

### Chat

- `ChatConversation`
  - Odpowiedzialność: model rozmowy Firestore z listą uczestników, ostatnią wiadomością i metadanymi.
  - Lokalizacja: `lib/features/chat/chat_repository.dart`.
  - Zależności: `DateTime`.
  - Najważniejsze metody: `fromFirestore`, `titleFor`, `participantIdFor`.
  - Miejsce użycia: `ChatListScreen`, `FirestoreChatRepository`.

- `ChatMessage`
  - Odpowiedzialność: model wiadomości czatu.
  - Lokalizacja: `lib/features/chat/chat_repository.dart`.
  - Zależności: `DateTime`.
  - Najważniejsze metody: `fromFirestore`.
  - Miejsce użycia: `ChatThreadScreen`, `FirestoreChatRepository`.

- `FirestoreChatRepository`
  - Odpowiedzialność: komunikacja frontendu z Firestore dla listy rozmów, wiadomości i wysyłania czatu.
  - Lokalizacja: `lib/features/chat/chat_repository.dart`.
  - Zależności: `cloud_firestore`, `firebase_auth`.
  - Najważniejsze metody: `directChatId`, `groupChatId`, `watchConversations`, `watchMessages`, `fetchConversation`, `sendDirectMessage`, `sendGroupMessage`.
  - Miejsce użycia: `ChatListScreen`, `ChatThreadScreen`, ekrany grup otwierające czat.

- `ChatListScreen`
  - Odpowiedzialność: ekran listy rozmów użytkownika.
  - Lokalizacja: `lib/features/chat/chat_screen.dart`.
  - Zależności: `FirestoreChatRepository`, `AuthScope`, `GoRouter`.
  - Najważniejsze metody: `initState`, `dispose`, `build`.
  - Miejsce użycia: trasa `/messages`.

- `ChatThreadScreen`
  - Odpowiedzialność: ekran wątku rozmowy i formularz wysyłania wiadomości.
  - Lokalizacja: `lib/features/chat/chat_screen.dart`.
  - Zależności: `FirestoreChatRepository`, `AuthScope`, `ChatMessage`.
  - Najważniejsze metody: `_sendMessage`, `build`, lifecycle widgetu.
  - Miejsce użycia: trasy `/messages/:chatId` i powiązane przejścia z grup/profili.

### Powiadomienia

- `NotificationController`
  - Odpowiedzialność: stan historii powiadomień, preferencji, licznika nieprzeczytanych i rejestracji urządzenia.
  - Lokalizacja: `lib/shared/notifications/notification_controller.dart`.
  - Zależności: `NotificationHistoryRepository`, `NotificationPreferencesStore`, `NotificationsApi`, `SessionController`, `NotificationEntry`, `NotificationType`.
  - Najważniejsze metody: `loadHistory`, `loadMoreHistory`, `onNotificationReceived`, `markAsRead`, `markAllAsRead`, `loadPreferences`, `setEnabled`, `setFcmToken`, `retryDeviceRegistrationIfNeeded`.
  - Miejsce użycia: `NotificationScope`, `NotificationService`, `InboxScreen`, `SettingsScreen`, `ShellHeader`.

- `NotificationService`
  - Odpowiedzialność: integracja z Firebase Messaging i lokalnymi powiadomieniami.
  - Lokalizacja: `lib/shared/notifications/notification_service.dart`.
  - Zależności: `firebase_messaging`, `flutter_local_notifications`, `NotificationController`, `GoRouter`.
  - Najważniejsze metody: `initLocalNotifications`, `init`, `subscribeToTopic`, `unsubscribeFromTopic`, `cancelAllLocalNotifications`, `showTestNotification`.
  - Miejsce użycia: `main.dart`, `LocarioApp`, testowe i developerskie akcje powiadomień.

- `NotificationsApi`
  - Odpowiedzialność: klient HTTP dla historii powiadomień i rejestracji tokenu urządzenia.
  - Lokalizacja: `lib/shared/notifications/notifications_api.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`.
  - Najważniejsze metody: `registerDevice`, `fetchHistory`, `markAsRead`, `markAllAsRead`, `deleteNotification`.
  - Miejsce użycia: `NotificationController`, `ApiNotificationHistoryRepository`.

- `NotificationHistoryRepository`
  - Odpowiedzialność: kontrakt repozytorium historii powiadomień.
  - Lokalizacja: `lib/shared/notifications/notification_history_repository.dart`.
  - Zależności: `NotificationEntry`, `NotificationHistoryPage`.
  - Najważniejsze metody: `loadPage`, `insertEntry`, `markAsRead`, `markAllAsRead`, `deleteEntry`, `clear`, `getUnreadCount`.
  - Miejsce użycia: `NotificationController`.

- `ApiNotificationHistoryRepository`
  - Odpowiedzialność: implementacja historii powiadomień oparta o API.
  - Lokalizacja: `lib/shared/notifications/api_notification_history_repository.dart`.
  - Zależności: `NotificationsApi`, provider tokenu.
  - Najważniejsze metody: implementacje kontraktu `NotificationHistoryRepository`.
  - Miejsce użycia: konfiguracja `NotificationController`.

- `SharedPrefsNotificationHistoryRepository`
  - Odpowiedzialność: lokalna implementacja historii powiadomień w `SharedPreferences`.
  - Lokalizacja: `lib/shared/notifications/shared_prefs_notification_history_repository.dart`.
  - Zależności: `shared_preferences`, `NotificationEntry`.
  - Najważniejsze metody: implementacje kontraktu `NotificationHistoryRepository`.
  - Miejsce użycia: lokalny fallback lub konfiguracja historii powiadomień.

- `NotificationPreferencesStore` i `SharedPrefsNotificationPreferencesStore`
  - Odpowiedzialność: kontrakt i implementacja przechowywania preferencji typów powiadomień.
  - Lokalizacja: `lib/shared/notifications/notification_preferences_store.dart`, `lib/shared/notifications/shared_prefs_notification_preferences_store.dart`.
  - Zależności: `NotificationType`, `SharedPreferences`.
  - Najważniejsze metody: `isEnabled`, `setEnabled`, `loadAll`.
  - Miejsce użycia: `NotificationController`, `SettingsScreen`.

- `NotificationEntry`, `NotificationPayload`, `NotificationHistoryPage`, `NotificationType`
  - Odpowiedzialność: modele historii, payloadu nawigacyjnego, strony wyników i typu powiadomienia.
  - Lokalizacja: `lib/shared/notifications/notification_entry.dart`, `notification_payload.dart`, `notification_history_repository.dart`, `notification_type.dart`.
  - Zależności: `GoRouter` dla nawigacji payloadu, `IconData` dla typu.
  - Najważniejsze metody/gettery: `fromJson`, `toJson`, `copyWith`, `navigate`, `fromPayloadString`, `topicName`.
  - Miejsce użycia: `NotificationController`, `NotificationService`, `InboxScreen`, `SettingsScreen`.

### Recenzje

- `ReviewController`
  - Odpowiedzialność: stan ocen organizatora, recenzji wydarzenia, recenzji użytkownika i przeglądu recenzji organizatora.
  - Lokalizacja: `lib/shared/reviews/review_controller.dart`.
  - Zależności: `ReviewRepository`, `SessionController`, `ChangeNotifier`.
  - Najważniejsze metody: `loadOrganizerRating`, `loadEventReviews`, `loadMyReviewForEvent`, `loadOrganizerReviews`, `submitReview`, `clear`.
  - Miejsce użycia: `ReviewScope`, `EventReviewScreen`, `ProfileScreen`, `OrganizerReviewsScreen`.

- `ReviewRepository`
  - Odpowiedzialność: abstrakcyjny kontrakt komunikacji frontendu z funkcjami recenzji.
  - Lokalizacja: `lib/shared/reviews/review_repository.dart`.
  - Zależności: modele recenzji i `ExploreEvent`.
  - Najważniejsze metody: `fetchOrganizerAverageRating`, `fetchEventReviews`, `fetchMyReviewForEvent`, `submitEventReview`, `fetchMyOrganizerReviews`.
  - Miejsce użycia: `ReviewController`.

- `HttpReviewRepository`
  - Odpowiedzialność: implementacja `ReviewRepository` oparta o HTTP i serializację JSON.
  - Lokalizacja: `lib/shared/reviews/review_repository.dart`.
  - Zależności: `http.Client`, `ApiConfig.baseUrl`, token dostępu.
  - Najważniejsze metody: implementacje kontraktu `ReviewRepository`.
  - Miejsce użycia: `LocarioApp`.

- `ReviewRequest`, `AverageRating`, `ReviewResponse`, `OrganizerReviewEntry`, `OrganizerReviewsOverview`
  - Odpowiedzialność: modele żądań i odpowiedzi recenzji.
  - Lokalizacja: `lib/shared/reviews/review_models.dart`.
  - Zależności: `ExploreEvent` w przeglądzie recenzji organizatora.
  - Najważniejsze metody/gettery: `toJson`, `fromJson`, `hasReviews`.
  - Miejsce użycia: `ReviewRepository`, `ReviewController`, ekrany recenzji i profilu.

### Cache, lokalizacja, mapy i serwisy wspólne

- `CacheService`
  - Odpowiedzialność: lokalny cache key-value oparty o SQLite.
  - Lokalizacja: `lib/shared/cache/cache_service.dart`.
  - Zależności: `sqflite`, `path`, `dart:convert`.
  - Najważniejsze metody: `init`, `getRaw`, `get`, `getList`, `setRaw`, `set`, `setList`, `getHash`, `invalidate`, `invalidateByPrefix`, `clear`, `dispose`.
  - Miejsce użycia: `LocarioApp`, `EventDetailController`, `GroupController`.

- `LocationService`
  - Odpowiedzialność: abstrakcja nad dostępem do lokalizacji urządzenia i ustawień lokalizacji.
  - Lokalizacja: `lib/shared/location/location_service.dart`.
  - Zależności: `geolocator`, `LatLng`.
  - Najważniejsze metody: `isLocationServiceEnabled`, `checkPermission`, `requestPermission`, `getCurrentLocation`, `getLastKnownLocation`, `openAppSettings`, `openLocationSettings`.
  - Miejsce użycia: `ExploreMapViewModel`, `CreateEventLocationController`, testowe fake'i.

- `GeolocatorLocationService`
  - Odpowiedzialność: produkcyjna implementacja `LocationService` oparta o `geolocator`.
  - Lokalizacja: `lib/shared/location/location_service.dart`.
  - Zależności: `Geolocator`, `kIsWeb`.
  - Najważniejsze metody: implementacje kontraktu `LocationService`.
  - Miejsce użycia: `LocarioApp`, `ExploreScreen`, `CreateEventScreen`.

- `MapStyleRepository`
  - Odpowiedzialność: ładuje JSON stylu MapLibre z assetów i dopasowuje go do jasności motywu.
  - Lokalizacja: `lib/shared/map/style_repository.dart`.
  - Zależności: `rootBundle`, `Brightness`.
  - Najważniejsze metody: `loadStyleJson`.
  - Miejsce użycia: `MapWidget`, `ExploreMapView`.

- `ShareService`
  - Odpowiedzialność: buduje publiczny URL wydarzenia i uruchamia systemowe udostępnianie.
  - Lokalizacja: `lib/shared/services/share_service.dart`.
  - Zależności: `share_plus`.
  - Najważniejsze metody: `getEventUrl`, `shareEvent`.
  - Miejsce użycia: `EventScreen`.

- `MapLaunchService`
  - Odpowiedzialność: buduje URI map i otwiera lokalizację w zewnętrznej aplikacji.
  - Lokalizacja: `lib/shared/services/map_launch_service.dart`.
  - Zależności: `url_launcher`.
  - Najważniejsze metody: `buildLocationUri`, `openLocation`.
  - Miejsce użycia: szczegóły wydarzenia i testy usług.

- `L10nService`
  - Odpowiedzialność: przechowuje aktualne `AppLocalizations` dla miejsc bez bezpośredniego `BuildContext`.
  - Lokalizacja: `lib/shared/services/l10n_service.dart`.
  - Zależności: `AppLocalizations`.
  - Najważniejsze metody: `init`, `update`; getter `l10n`.
  - Miejsce użycia: `LocarioApp`, testowy `buildLocalizedTestApp`, serwisy i komunikaty.

- `FeedbackService`
  - Odpowiedzialność: pokazuje globalne komunikaty `SnackBar` z deduplikacją krótkich powtórzeń.
  - Lokalizacja: `lib/shared/services/feedback_service.dart`.
  - Zależności: `rootScaffoldMessengerKey`, `L10nService`, `FeedbackMessage`.
  - Najważniejsze metody: `showSuccess`, `showError`, `showInfo`, `resetForTests`.
  - Miejsce użycia: ekrany auth, profile, grupy, wydarzenia, saved i Explore.

- `CalendarService` i `CalendarEventDraft`
  - Odpowiedzialność: przygotowanie danych wydarzenia i przekazanie ich do natywnego kanału dodawania do kalendarza.
  - Lokalizacja: `lib/shared/services/calendar_service.dart`.
  - Zależności: `MethodChannel`, `ExploreEvent`.
  - Najważniejsze metody: `addEvent`; w modelu `CalendarEventDraft` tworzenie danych kalendarza.
  - Miejsce użycia: `EventScreen`, `EventDetailsInfo`.

### Legal

- `LegalController`
  - Odpowiedzialność: sprawdza, czy użytkownik musi zaakceptować aktualne regulaminy, i zapisuje akceptację.
  - Lokalizacja: `lib/features/legals/legal_controller.dart`.
  - Zależności: `SessionController`, `LegalAcceptanceStore`, `LegalVersions`, `ChangeNotifier`.
  - Najważniejsze metody: `load`, `acceptAll`, `dispose`; gettery `isAcceptanceRequired`, `isLoading`.
  - Miejsce użycia: `LegalScope`, redirecty routera, `LegalAcceptanceScreen`.

- `LegalAcceptanceStore` i `SharedPrefsLegalAcceptanceStore`
  - Odpowiedzialność: kontrakt i implementacja zapisu wersji zaakceptowanych dokumentów prawnych per użytkownik.
  - Lokalizacja: `lib/features/legals/legal_acceptance_store.dart`, `shared_prefs_legal_acceptance_store.dart`.
  - Zależności: `SharedPreferences`.
  - Najważniejsze metody: `getAcceptedTermsVersion`, `getAcceptedPrivacyVersion`, `acceptTerms`, `acceptPrivacy`.
  - Miejsce użycia: `LegalController`.

- `ConsentsStore` i `SharedPrefsConsentsStore`
  - Odpowiedzialność: kontrakt i implementacja zapisu zgód opcjonalnych.
  - Lokalizacja: `lib/features/legals/consents_store.dart`, `shared_prefs_consents_store.dart`.
  - Zależności: `ConsentType`, `SharedPreferences`.
  - Najważniejsze metody: `isGranted`, `setGranted`, `loadAll`.
  - Miejsce użycia: `ConsentsScreen`.

- `ConsentType` i `LegalVersions`
  - Odpowiedzialność: modele typów zgód oraz aktualnych wersji regulaminu i polityki prywatności.
  - Lokalizacja: `lib/features/legals/consent_type.dart`, `legal_versions.dart`.
  - Zależności: `IconData` dla typów zgód.
  - Najważniejsze metody/pola: `prefsKey`, `icon`, `termsVersion`, `privacyVersion`.
  - Miejsce użycia: `ConsentsScreen`, `LegalController`.

### Główne ekrany i komponenty UI

- `Shell`
  - Odpowiedzialność: główna powłoka aplikacji z bottom navigation, headerem i panelem huba.
  - Lokalizacja: `lib/features/shell/shell.dart`.
  - Zależności: `StatefulNavigationShell`, `ShellHeaderController`, `HubPanel`, `ShellBottomNav`.
  - Najważniejsze metody: `_handleTabSelected`, `_handleHubToggle`, `_handleHubItemSelected`, `_closeHub`, lifecycle.
  - Miejsce użycia: `StatefulShellRoute` w routerze.

- `ShellHeaderController`, `ShellHeaderScope`, `ShellHeader`
  - Odpowiedzialność: stan i widok górnego nagłówka, przełącznik map/list i akcje inbox/profil.
  - Lokalizacja: `lib/features/shell/header/header_controller.dart`, `header_scope.dart`, `header.dart`.
  - Zależności: `ExploreContentView`, `ChangeNotifier`, `NotificationScope`.
  - Najważniejsze metody: `setSelectedView`, `toggleFilter`, `of`, `maybeOf`, `build`.
  - Miejsce użycia: `Shell`, `ExploreScreen`.

- `ShellBottomNav`, `ShellTab`, `HubActionItem`, `HubPanel`
  - Odpowiedzialność: dolna nawigacja, mapowanie tras na zakładki i panel akcji huba.
  - Lokalizacja: `lib/features/shell/nav/bottom_nav.dart`, `tab.dart`, `lib/features/shell/hub/hub_action_item.dart`, `hub_panel.dart`.
  - Zależności: `GoRouter`, `IconData`, lokalizacje.
  - Najważniejsze metody/gettery: `ShellTab.fromLocation`, `HubActionItem.iconData`, `HubActionItem.accent`, `build`.
  - Miejsce użycia: `Shell`.

- `LoginScreen` i `RegisterScreen`
  - Odpowiedzialność: formularze logowania, rejestracji i Google Sign-In.
  - Lokalizacja: `lib/features/auth/login_screen.dart`, `register_screen.dart`.
  - Zależności: `AuthScope`, `LegalScope`, `GoogleSignIn`, `GoRouter`, modele requestów auth.
  - Najważniejsze metody: `_handleSubmit`, `_handleGoogleSignIn`, `_handleAuthSuccess`, `_showAuthError`, walidatory pól.
  - Miejsce użycia: trasy `/login` i `/register`.

- `ExploreScreen`
  - Odpowiedzialność: główny ekran eksploracji wydarzeń, koordynujący header, mapę, listę, filtry i zapisane filtry.
  - Lokalizacja: `lib/features/explore/explore_screen.dart`.
  - Zależności: `ExploreController`, `ExploreMapViewModel`, `ExploreAreaController`, `EventRepository`, `LocationService`, `SavedEventsController`, `SavedFiltersController`, `ShellHeaderController`.
  - Najważniejsze metody: `_loadEvents`, `_syncControllerParams`, `_handleFilterPressed`, `_handleEventTap`, `_handleMapCameraCenterChanged`, `_consumePendingFilter`.
  - Miejsce użycia: trasa `/explore`.

- `ExploreHeader`, `ExploreListView`, `ExploreMapView`, `MapWidget`
  - Odpowiedzialność: publiczne komponenty UI Explore dla wyszukiwania, listy wydarzeń i mapy MapLibre.
  - Lokalizacja: `lib/features/explore/widgets/header.dart`, `list_view.dart`, `map_view.dart`, `map_widget.dart`.
  - Zależności: `ExploreController`, `ExploreMapViewModel`, `MapStyleRepository`, `SavedEventsController`, `MapLibre`.
  - Najważniejsze metody: `build`; w `MapWidget` obsługa stylu, markerów, tapnięć, klastrów i promienia wyszukiwania.
  - Miejsce użycia: `ExploreScreen`.

- `ExploreAdvancedFilterSheet`, `ExploreAdvancedFilterResult`, `ExploreAddressInputDialog`, `ExploreAreaSelectionSheet`, `ExploreMapAreaPickerOverlay`, `SearchThisAreaButton`
  - Odpowiedzialność: komponenty filtrowania zaawansowanego i wyboru obszaru wyszukiwania.
  - Lokalizacja: `lib/features/explore/widgets/advanced_filter_sheet.dart`, `area_picker.dart`, `search_this_area_button.dart`.
  - Zależności: `ExploreAdvancedFilters`, `ExploreAreaController`, `SavedFiltersController`.
  - Najważniejsze metody: `build`, `_apply`, `_saveFilter`, `_handleAreaPressed`, `_handleAddressSelection`, `_clear`.
  - Miejsce użycia: `ExploreScreen`.

- `MapCameraSync`, `MapStyleCoordinator`, `MapEventClusterer`
  - Odpowiedzialność: pomocnicze, ale istotne klasy mapy: synchronizacja kamery, warstwy stylu i klastrowanie wydarzeń.
  - Lokalizacja: `lib/features/explore/widgets/map_camera_sync.dart`, `map_style_coordinator.dart`, `map_event_clusterer.dart`.
  - Zależności: `MapController`, `StyleController`, `LatLng`, `ExploreEvent`.
  - Najważniejsze metody: `reset`, `markSynced`, `isLocationVisible`, `initializeEventLayers`, `syncEventMarkers`, `cluster`.
  - Miejsce użycia: `MapWidget`.

- `EventScreen`
  - Odpowiedzialność: ekran szczegółów wydarzenia i orkiestracja akcji zapisu, join/leave, udostępniania, mapy, kalendarza i recenzji.
  - Lokalizacja: `lib/features/events/event_screen.dart`.
  - Zależności: `EventDetailController`, `SavedEventsController`, `JoinedEventsController`, `ReviewController`, `CalendarService`, `ShareService`, `MapLaunchService`.
  - Najważniejsze metody: `_loadEvent`, `_shareEvent`, `_toggleSaved`, `_joinEvent`, `_leaveEvent`, `_showEventOnMap`, `_openReviewScreen`, `_addEventToCalendar`.
  - Miejsce użycia: trasa `/events/:eventId`.

- `EventDetailsInfo`, `EventInfoCard`, `EventGallery`, `EventDetailsGallery`, `FullscreenGallery`, `EventImagePlaceholder`
  - Odpowiedzialność: komponenty prezentacji szczegółów wydarzenia, galerii, kart informacji i placeholderów obrazów.
  - Lokalizacja: `lib/features/events/widgets/info/*`, `lib/features/events/widgets/gallery/*`.
  - Zależności: `ExploreEvent`, `EventMedia`, `SavedEventsController`, `JoinedEventsController`.
  - Najważniejsze metody: `build`, obsługa galerii i akcji przekazywanych callbackami.
  - Miejsce użycia: `EventScreen`, testy widgetów wydarzeń.

- `CreateEventController`
  - Odpowiedzialność: stan formularza tworzenia i edycji wydarzenia oraz submit do repozytorium.
  - Lokalizacja: `lib/features/hub/create_event/create_event_controller.dart`.
  - Zależności: `EventRepository`, `SessionController`, `EventRefreshSignal`, `CreateEventState`, modele Explore i grup.
  - Najważniejsze metody: `setEditingEventId`, `initializeFromEvent`, `updateTitle`, `updateDescription`, `updateLocation`, `clearLocation`, `updateDate`, `updateTime`, `toggleCategory`, `toggleGroup`, `setSelectedGroups`, `updateStatus`, `updateTicketUrl`, `updateSlotLimit`, `addSelectedImages`, `removeSelectedImageAt`, `reorderSelectedImages`, `submit`.
  - Miejsce użycia: `CreateEventScreen`.

- `CreateEventState`, `CreateEventSelectedImage`, `CreateEventLocationController`, `CreateEventLocationSelection`, `CreateEventLocationLookupResult`
  - Odpowiedzialność: modele i kontroler stanu formularza wydarzenia oraz wyboru lokalizacji.
  - Lokalizacja: `lib/features/hub/create_event/create_event_state.dart`, `create_event_location_controller.dart`.
  - Zależności: `LocationService`, `LatLng`, `Category`, `Group`, `EventStatus`.
  - Najważniejsze metody/gettery: `canSubmit`, `copyWith`, `useCurrentLocation`, `selectAddress`, `setPinnedLocation`, `selectPinnedLocation`.
  - Miejsce użycia: `CreateEventScreen`, `EventMapPickerScreen`.

- `CreateEventScreen`, `EventMapPickerScreen`, `CreateEventBasicInfoSection`, `CreateEventImagePickerTile`, `CreateEventSection`, `CreateEventFieldLabel`, `CreateEventPickerTile`, `CreateEventLocationPickerTile` oraz sekcje formularza w `widgets/form/`
  - Odpowiedzialność: ekran tworzenia/edycji wydarzenia i publiczne komponenty formularza.
  - Lokalizacja: `lib/features/hub/create_event/*`.
  - Zależności: `CreateEventController`, `CreateEventLocationController`, `CategoryScope`, `GroupScope`, `AuthScope`, `file_picker`.
  - Najważniejsze metody: lifecycle ekranu, `_loadEditingEvent`, `_handleImagePressed`, `_pickDate`, `_pickTime`, `_handleLocationPressed`, `build` sekcji formularza.
  - Miejsce użycia: trasy tworzenia i edycji wydarzeń.

- `SavedScreen`
  - Odpowiedzialność: ekran zapisanych wydarzeń i zapisanych filtrów.
  - Lokalizacja: `lib/features/saved/saved_screen.dart`.
  - Zależności: `SavedEventsController`, `SavedFiltersController`, `SavedEventQuery`, `LocationService`.
  - Najważniejsze metody: lifecycle, obsługa sortowania, filtrów, usuwania i ładowania filtra do Explore.
  - Miejsce użycia: trasa `/hub/saved`.

- `GroupDiscoverScreen`, `GroupDetailsScreen`, `GroupFormScreen`, `GroupPostCommentsScreen`, `PinSelector`
  - Odpowiedzialność: główne komponenty UI modułu grup: odkrywanie, szczegóły, tworzenie/edycja, komentarze i wybór pinezki.
  - Lokalizacja: `lib/features/groups/*`, `lib/features/groups/widgets/pin_selector.dart`.
  - Zależności: `GroupController`, `GroupRepository`, `CategoryScope`, `AuthScope`, `FirestoreChatRepository`, `file_picker`.
  - Najważniejsze metody: ładowanie grup, obsługa wyszukiwania, join/leave, tworzenie wpisów, moderacja, komentarze, submit formularza.
  - Miejsce użycia: trasy grup.

- `ProfileScreen`, `SettingsScreen`, `EditProfileScreen`, `EventHistoryScreen`, `OrganizerEventsScreen`, `OrganizerReviewsScreen`
  - Odpowiedzialność: ekrany profilu, ustawień, edycji profilu, historii i widoków organizatora.
  - Lokalizacja: `lib/features/profile/*`.
  - Zależności: `AuthScope`, `ThemeScope`, `LocaleScope`, `NotificationScope`, `ReviewScope`, `EventRepository`.
  - Najważniejsze metody: odświeżanie profilu i ratingów, submit edycji profilu, zmiana hasła, zmiana ustawień, pobieranie wydarzeń historii.
  - Miejsce użycia: trasy profilu i podstrony organizatora.

- `InboxScreen`
  - Odpowiedzialność: ekran historii powiadomień.
  - Lokalizacja: `lib/features/inbox/inbox_screen.dart`.
  - Zależności: `NotificationScope`, `NotificationEntry`, `GoRouter`.
  - Najważniejsze metody: ładowanie historii, oznaczanie jako przeczytane, usuwanie, nawigacja z payloadu.
  - Miejsce użycia: trasa `/inbox` i akcja inbox w headerze.

- `EventReviewScreen`
  - Odpowiedzialność: ekran dodawania lub aktualizacji recenzji wydarzenia.
  - Lokalizacja: `lib/features/reviews/event_review_screen.dart`.
  - Zależności: `ReviewScope`, `EventDetailScope`, `AuthScope`.
  - Najważniejsze metody: ładowanie danych recenzji, submit recenzji, render formularza oceny.
  - Miejsce użycia: przejście z `EventScreen`.

- `LegalAcceptanceScreen`, `ConsentsScreen`, `PolicyScreen`, `HelpScreen`
  - Odpowiedzialność: ekrany akceptacji regulaminu, zgód, polityk i pomocy.
  - Lokalizacja: `lib/features/legals/*`.
  - Zależności: `LegalScope`, `ConsentsStore`, `ConsentType`, `PolicyType`.
  - Najważniejsze metody: `_handleAccept`, `_loadConsents`, `_toggle`, `build`.
  - Miejsce użycia: trasy legal/help i redirecty routera.

- `StatePanel` i `EventListCard`
  - Odpowiedzialność: współdzielone komponenty UI dla stanów pustych/błędów/ładowania oraz kart wydarzeń na listach.
  - Lokalizacja: `lib/shared/widgets/state_panel.dart`, `lib/shared/widgets/event_list_card.dart`.
  - Zależności: `ThemeData`, `ExploreEvent`, opcjonalne callbacki akcji.
  - Najważniejsze metody: `build`.
  - Miejsce użycia: Explore, Saved, Events, Profile i inne listy wydarzeń.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/shared/auth/session_controller.dart`
- `lib/shared/auth/auth_repository.dart`
- `lib/shared/auth/auth_api.dart`
- `lib/shared/auth/auth_models.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/events/event_detail_controller.dart`
- `lib/features/explore/explore_controller.dart`
- `lib/features/explore/models.dart`
- `lib/features/explore/map_view_model.dart`
- `lib/features/saved/saved_events_controller.dart`
- `lib/features/saved/saved_filters_controller.dart`
- `lib/shared/groups/group_controller.dart`
- `lib/shared/groups/group_repository.dart`
- `lib/shared/groups/group_models.dart`
- `lib/features/chat/chat_repository.dart`
- `lib/shared/notifications/notification_controller.dart`
- `lib/shared/notifications/notification_service.dart`
- `lib/shared/reviews/review_controller.dart`
- `lib/shared/reviews/review_repository.dart`
- `lib/features/hub/create_event/create_event_controller.dart`
- `lib/features/hub/create_event/create_event_location_controller.dart`
- `lib/shared/cache/cache_service.dart`
- `lib/shared/location/location_service.dart`
- `lib/features/legals/legal_controller.dart`

## 28. Wzorce projektowe

Najważniejsze wzorce występujące w projekcie:

- Feature-first structure - kod podzielony według funkcji aplikacji.
- Controller as state holder - kontrolery `ChangeNotifier` przechowują stan i akcje.
- Scope as dependency access - kontrolery są dostępne przez własne scope'y.
- Repository/API split - repozytoria i klasy API izolują komunikację z REST.
- Cache-aside - dane mogą być pokazane z cache i odświeżone z API.
- Optimistic UI - niektóre akcje grup działają optymistycznie.
- Local-first persistence - zapisane wydarzenia i filtry są najpierw lokalne.
- Constructor injection for tests - ekrany/kontrolery przyjmują zależności przez konstruktor.
- Centralized routing guards - reguły dostępu są w routerze.
- Generated localization - l10n generowane z ARB.

Miejsca, gdzie wzorzec nie jest w pełni konsekwentny:

- część uploadu mediów profilu i pinów grup używa `http` bezpośrednio w warstwie UI/widgetu,
- `LocarioApp` ma dużą odpowiedzialność za tworzenie wszystkich zależności,
- część kontrolerów łapie błędy i je ignoruje, co wymaga doprecyzowania strategii błędów,
- cache nie ma opisanego TTL ani centralnej polityki inwalidacji,
- nazewnictwo `Api` i `Repository` nie zawsze oznacza ten sam poziom abstrakcji; w praktyce oba typy klas potrafią wykonywać żądania HTTP i mapować JSON.

Najważniejsze konsekwencje tych wzorców dla dalszego rozwoju:

- nowy moduł ekranowy powinien zaczynać się w `lib/features/<module>/`, a dopiero współdzielone modele lub repozytoria powinny trafiać do `lib/shared/`,
- nowy stan globalny powinien mieć kontroler `ChangeNotifier`, scope i jawne utworzenie w `LocarioApp`,
- nowa komunikacja REST powinna przyjmować opcjonalny `http.Client` i `baseUrl`, aby zachować testowalność,
- nowy model JSON powinien mieć ręczne `fromJson`/`toJson`, bo projekt nie używa generatorów,
- akcje wymagające tokena powinny pobierać token z `SessionController`, a nie ze storage bezpośrednio w UI,
- operacje lokalne powinny mieć jasno opisany storage: `SharedPreferences`, `flutter_secure_storage` albo `CacheService`.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/shared/cache/cache_service.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/groups/group_controller.dart`
- `lib/features/profile/edit_profile_screen.dart`
- `lib/features/groups/widgets/pin_selector.dart`

## 29. Przepływy danych

### Logowanie

1. Użytkownik wysyła formularz logowania.
2. `LoginScreen` wywołuje `SessionController.login`.
3. `SessionController` deleguje do `AuthRepository`.
4. `AuthRepository` wywołuje `AuthApi.login`.
5. Tokeny są zapisywane w `AuthStorage`.
6. `SessionController` pobiera tokeny i profil.
7. Router odświeża redirecty.
8. Scope'y i UI otrzymują nowy stan sesji.

### Odkrywanie wydarzeń

1. `ExploreMapViewModel` ustala lokalizację.
2. `ExploreController` aktualizuje referencyjną lokalizację.
3. Kontroler próbuje użyć cache map events.
4. Kontroler pobiera świeże dane przez `HttpEventRepository.fetchMapEvents`.
5. Dane są filtrowane i sortowane lokalnie.
6. UI pokazuje mapę lub listę.

### Zapisanie wydarzenia

1. Użytkownik klika akcję zapisu.
2. `SavedEventsController.toggleSaved` sprawdza, czy wydarzenie jest zapisane.
3. Dla zalogowanego użytkownika próbuje dodać/usunąć favorite przez `FavoritesApi`.
4. Lokalny rekord jest zapisywany lub usuwany w `SharedPreferences`.
5. Przy logowaniu uruchamiana jest synchronizacja z profilem.

### Tworzenie wydarzenia

1. Formularz aktualizuje `CreateEventController`.
2. Submit waliduje pola.
3. Kontroler tworzy `EventRequest`.
4. Repozytorium tworzy lub aktualizuje wydarzenie.
5. Obrazy są uploadowane przez presigned URL.
6. Pierwszy obraz może zostać ustawiony jako thumbnail.
7. Stan formularza przechodzi na success albo error.

### Czat

1. Ekran czatu obserwuje rozmowy lub wiadomości przez `FirestoreChatRepository`.
2. Firestore stream aktualizuje UI.
3. Przy wysłaniu wiadomości repozytorium ustala Firebase sender ID.
4. Dokument wiadomości jest dodawany do Firestore.
5. Metadane rozmowy są aktualizowane best-effort.

### Powiadomienia

1. `NotificationService` pobiera token FCM.
2. `NotificationController` zapisuje token w stanie.
3. Jeżeli użytkownik jest zalogowany, token jest rejestrowany przez `NotificationsApi`.
4. Wiadomości foreground trafiają do historii i lokalnej notyfikacji.
5. Tapnięcie powiadomienia buduje payload i wywołuje nawigację.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/auth/session_controller.dart`
- `lib/features/explore/explore_screen.dart`
- `lib/features/explore/explore_controller.dart`
- `lib/features/saved/saved_events_controller.dart`
- `lib/features/hub/create_event/create_event_controller.dart`
- `lib/features/chat/chat_repository.dart`
- `lib/shared/notifications/notification_service.dart`

## 30. Miejsca wymagające dodatkowego opisu

Poniższe obszary są opisane w dokumencie na poziomie wynikającym z kodu frontendu, ale wymagają dodatkowych materiałów, jeżeli dokumentacja ma pełnić rolę specyfikacji operacyjnej albo onboardingowej:

- rozszerzona tabela tras z warunkami redirectów, parametrami query i przykładami deep linków,
- tabela endpointów używanych przez frontend z metodami HTTP, wymaganym tokenem i klasą wywołującą,
- formaty JSON dla modeli domenowych, wyprowadzone z metod `fromJson` i `toJson`,
- decyzja produktowo-techniczna dotycząca TTL cache, ponieważ w kodzie widać cache-aside i ręczną inwalidację, ale nie widać centralnego TTL,
- strategia obsługi błędów w kontrolerach, szczególnie tam, gdzie błędy są ignorowane, logowane przez `debugPrint` albo traktowane jako niefatalne,
- dokładne scenariusze synchronizacji lokalnych i zdalnych zapisanych wydarzeń, w tym konflikty `pendingSync` i `syncFailed`,
- presigned upload dla wydarzeń, grup, postów i profilu z przykładami payloadów po stronie frontendu,
- powiązanie konta aplikacyjnego z Firebase Auth w czacie, ponieważ kod frontendu używa Firebase Auth i potrafi logować anonimowo do wysłania wiadomości,
- wymagane reguły Firestore dla ścieżek `chats/<chatId>/messages`,
- wymagane indeksy Firestore dla `collectionGroup('messages')`,
- konfiguracja topiców FCM odpowiadających wartościom `NotificationType.topicName`,
- proces release Android z produkcyjnym `applicationId` i release signingiem,
- konfiguracje środowisk dev/stage/prod oparte o `--dart-define`,
- polityka wersjonowania lokalnych kluczy `SharedPreferences`, np. `saved.events.v1` i `saved.filters.v1`,
- migracje cache `sqflite`, jeżeli struktura tabeli `cache` zostanie rozszerzona,
- zasady dodawania nowych modułów i kontrolerów z uwzględnieniem scope'ów,
- zasady dodawania tłumaczeń przez pliki feature ARB i `tool/generate_l10n.dart`,
- kryteria test coverage dla nowych funkcji, zwłaszcza kontrolerów, routingu, formularzy i repozytoriów.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/router.dart`
- `lib/shared/cache/cache_service.dart`
- `lib/features/saved/saved_events_controller.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/groups/group_repository.dart`
- `lib/features/chat/chat_repository.dart`
- `lib/shared/notifications/notification_service.dart`
- `.github/workflows/build-release-android.yml`

## 31. Załącznik: mapa najważniejszych tras

| Trasa | Ekran | Dostęp |
| --- | --- | --- |
| `/explore` | `ExploreScreen` | publiczny |
| `/profile` | `ProfileScreen` | publiczny z wariantem zalogowany/niezalogowany |
| `/profile/settings` | `SettingsScreen` | publiczny |
| `/profile/edit` | `EditProfileScreen` | zalogowany |
| `/profile/reviews` | `OrganizerReviewsScreen` | zalogowany z dostępem organizatora |
| `/profile/my-events` | `OrganizerEventsScreen` | zalogowany |
| `/profile/history` | `EventHistoryScreen` | zalogowany |
| `/hub/messages` | `ChatListScreen` | zalogowany |
| `/hub/saved` | `SavedScreen` | publiczny |
| `/hub/community` | `GroupDiscoverScreen` | zalogowany |
| `/hub/create-event` | `CreateEventScreen` | zalogowany |
| `/groups/create` | `GroupFormScreen` | organizator lub admin |
| `/groups/:groupId` | `GroupDetailsScreen` | publiczny/zależny od grupy |
| `/groups/:groupId/edit` | `GroupFormScreen` | zalogowany |
| `/chat/:chatId` | `ChatThreadScreen` | zalogowany |
| `/inbox` | `InboxScreen` | zalogowany |
| `/events/:eventId` | `EventScreen` | publiczny |
| `/events/:eventId/edit` | `CreateEventScreen` | zalogowany |
| `/events/:eventId/review` | `EventReviewScreen` | zalogowany |
| `/auth/login` | `LoginScreen` | publiczny |
| `/auth/register` | `RegisterScreen` | publiczny |
| `/legal/terms` | `PolicyScreen` | publiczny |
| `/legal/privacy` | `PolicyScreen` | publiczny |
| `/legal/help` | `HelpScreen` | publiczny |
| `/legal/consents` | `ConsentsScreen` | publiczny |
| `/legal/accept` | `LegalAcceptanceScreen` | zalogowany, gdy wymagane |

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/app/router.dart`
- `lib/features/auth/login_screen.dart`
- `lib/features/events/event_screen.dart`
- `lib/features/explore/explore_screen.dart`
- `lib/features/groups/group_details_screen.dart`
- `lib/features/profile/profile_screen.dart`

## 32. Załącznik: mapa komunikacji frontendu

Najważniejsze klasy komunikacyjne:

| Klasa | Odpowiedzialność |
| --- | --- |
| `AuthApi` | auth, profil, password, organizer verification |
| `FavoritesApi` | ulubione wydarzenia |
| `HttpEventRepository` | wydarzenia, mapa, kategorie, media wydarzeń |
| `EventRegistrationApi` | join/cancel/slots |
| `HttpGroupRepository` | grupy, feed, członkowie, komentarze, raporty, media |
| `HttpReviewRepository` | recenzje wydarzeń i organizatorów |
| `NotificationsApi` | urządzenie FCM i historia powiadomień |
| `FirestoreChatRepository` | rozmowy i wiadomości Firestore |

Typowe nagłówki:

- `Content-Type: application/json` dla żądań JSON,
- `Authorization: <tokenType> <accessToken>` dla endpointów chronionych,
- `Authorization: Bearer <accessToken>` w `NotificationsApi`,
- `Content-Type: <mime>` dla uploadu na presigned URL.

Najważniejsze pliki wykorzystane podczas analizy:

- `lib/shared/auth/auth_api.dart`
- `lib/shared/auth/favorites_api.dart`
- `lib/shared/events/event_repository.dart`
- `lib/shared/events/event_registration_api.dart`
- `lib/shared/groups/group_repository.dart`
- `lib/shared/reviews/review_repository.dart`
- `lib/shared/notifications/notifications_api.dart`
- `lib/features/chat/chat_repository.dart`
