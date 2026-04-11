// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Locario';

  @override
  String get localeEnglish => 'English';

  @override
  String get localePolish => 'Polish';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabHub => 'Hub';

  @override
  String get tabProfile => 'Profile';

  @override
  String get headerMap => 'Map';

  @override
  String get headerList => 'List';

  @override
  String get hubTitle => 'Hub';

  @override
  String get hubDescription =>
      'Shortcuts for creating and managing your local circle';

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
  String get profileDescription =>
      'Account, preferences and your saved places in one calmer section.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Language, preferences and app defaults';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsScreenDescription =>
      'Adjust the app basics before the settings surface grows.';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedSubtitle => 'Places, events and lists you want to revisit';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSectionSubtitle =>
      'Choose how the app should speak to you';

  @override
  String get themeSectionTitle => 'Appearance';

  @override
  String get themeSectionSubtitle =>
      'Choose whether the app should follow the system or stay fixed';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get exploreSearchHint => 'Search events...';

  @override
  String get exploreNearbyEvents => 'Nearby events';

  @override
  String exploreNearbyWithFilter(String filter) {
    return '$filter nearby';
  }

  @override
  String resultsCount(int count) {
    return '$count results';
  }

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortDistance => 'Distance';

  @override
  String get sortSoonest => 'Soonest';

  @override
  String get sortTrending => 'Trending';

  @override
  String get filterAll => 'All';

  @override
  String get filterMusic => 'Music';

  @override
  String get filterArt => 'Art';

  @override
  String get filterWorkshops => 'Workshops';

  @override
  String get filterFood => 'Food';

  @override
  String get areaMyLocation => 'My location';

  @override
  String get areaMyLocationDescription => 'Events closest to you by default';

  @override
  String get areaTypedAddressDescription => 'Address entered manually';

  @override
  String get areaPinnedOnMap => 'Pinned on map';

  @override
  String get areaPickerTitle => 'Choose area';

  @override
  String get areaPickerSubtitle =>
      'You can type an address, point to a spot on the map or go back to your current location.';

  @override
  String get areaUseCurrentLocation => 'My location';

  @override
  String get areaUseCurrentLocationSubtitle =>
      'Use your current position as the reference point';

  @override
  String get areaEnterAddress => 'Enter address';

  @override
  String get areaEnterAddressSubtitle =>
      'Type a street, district or exact place';

  @override
  String get areaPickOnMap => 'Pick on map';

  @override
  String get areaPickOnMapTitle => 'Pick a point on the map';

  @override
  String get areaPickOnMapSubtitle =>
      'Move the map so the chosen point sits under the center marker.';

  @override
  String get areaPickOnMapConfirm => 'Use this point';

  @override
  String get areaAddressDialogTitle => 'Enter address';

  @override
  String get areaAddressDialogHint => 'For example 12 Old Town Sq, Poznan';

  @override
  String get areaAddressNotFound => 'We couldn\'t find that address.';

  @override
  String get areaAddressLookupFailed => 'Address lookup failed. Try again.';

  @override
  String get areaDialogCancel => 'Cancel';

  @override
  String get areaDialogConfirm => 'Done';

  @override
  String areaPinnedCoordinates(String lat, String lon) {
    return '$lat, $lon';
  }

  @override
  String get areaWarsawCenter => 'Warsaw center';

  @override
  String get areaWarsawCenterDescription => 'Address or pin set manually';

  @override
  String get areaPowisle => 'Powisle';

  @override
  String get areaPowisleDescription => 'Boulevards and Poniatowski bridge area';

  @override
  String get areaMokotow => 'Mokotow';

  @override
  String get areaMokotowDescription => 'Pole Mokotowskie area and nearby';

  @override
  String get eventJazzTitle => 'Jazz in the Botanical Garden';

  @override
  String get eventSketchingTitle => 'Night sketching by the Vistula';

  @override
  String get eventRunClubTitle => 'Morning run club and coffee stop';

  @override
  String get eventStreetFoodTitle => 'Street food and vinyl market';

  @override
  String get eventToday2030 => 'Today, 20:30';

  @override
  String get eventToday1900 => 'Today, 19:00';

  @override
  String get eventTomorrow0800 => 'Tomorrow, 08:00';

  @override
  String get eventTomorrow1200 => 'Tomorrow, 12:00';

  @override
  String get venueBotanicalGarden => 'Botanical Garden';

  @override
  String get venueVistulaBoulevards => 'Vistula Boulevards';

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
  String get mapReturnToLocation => 'Return to my location';

  @override
  String mapStyleLoadFailed(String error) {
    return 'Unable to load the local map style.\n$error';
  }

  @override
  String get mapRetry => 'Retry';

  @override
  String get mapAppSettings => 'App settings';

  @override
  String get mapLocationSettings => 'Location settings';

  @override
  String get mapServiceDisabled =>
      'Enable location services to see your position.';

  @override
  String get mapPermissionDenied =>
      'Allow location access to center the map on you.';

  @override
  String get mapPermissionDeniedForever =>
      'Location access is blocked in system settings.';

  @override
  String get mapUnableDetermineLocation => 'Unable to determine your location.';

  @override
  String get mapLocationTimeout => 'Location request timed out. Try again.';

  @override
  String get mapUnableLoadLocation => 'Unable to load your location.';

  @override
  String mapClusterSheetTitle(int count) {
    return 'Choose an event ($count)';
  }

  @override
  String mapEventOpenSoon(String title) {
    return 'The event screen for “$title” will be added later.';
  }
}
