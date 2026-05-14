# Locario

Locario to mobilna aplikacja Flutter do odkrywania wydarzeń w okolicy, z funkcją mapy, zapisywania wydarzeń i powiadomień.

Projekt jest realizowany w ramach **Projektu Kompetencyjnego na Politechnice Łódzkiej**. Repozytorium zawiera aktywnie rozwijaną wersję aplikacji, dlatego część funkcji może być jeszcze dopracowywana.

## O projekcie

- Odkrywanie wydarzeń na mapie i w widoku listy.
- Filtrowanie i wyszukiwanie wydarzeń.
- Zapisane wydarzenia i zapisane filtry.
- Logowanie użytkownika i integracja z Firebase.
- Tworzenie wydarzeń z wyborem lokalizacji i zdjęć.
- Powiadomienia push oraz lokalne.

## Stack technologiczny

- Flutter 3.41.5
- Dart 3.11+
- Firebase Auth
- Firebase Messaging
- go_router
- MapLibre
- geolocator
- geocoding
- SharedPreferences

## Struktura projektu

- `lib/app/` - konfiguracja aplikacji, routing, theme
- `lib/features/` - moduły funkcjonalne aplikacji
- `lib/shared/` - elementy wspólne, serwisy i kontrolery
- `lib/l10n/` - lokalizacje i tłumaczenia
- `test/` - testy widgetowe i jednostkowe

## Uruchomienie lokalne

```bash
flutter pub get
flutter analyze
flutter test --no-pub
```

Jeśli zmieniasz pliki lokalizacji:

```bash
dart run tool/generate_l10n.dart
```