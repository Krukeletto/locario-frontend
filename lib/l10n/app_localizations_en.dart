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
  String get hubDescription => 'Shortcuts for creating and managing your local circle';

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
  String get profileDescription => 'Account, preferences and your saved places in one calmer section.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Language, preferences and app defaults';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsScreenDescription => 'Adjust the app basics before the settings surface grows.';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedSubtitle => 'Places, events and lists you want to revisit';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSectionSubtitle => 'Choose how the app should speak to you';

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
  String get mapServiceDisabled => 'Enable location services to see your position.';

  @override
  String get mapPermissionDenied => 'Allow location access to center the map on you.';

  @override
  String get mapPermissionDeniedForever => 'Location access is blocked in system settings.';

  @override
  String get mapUnableDetermineLocation => 'Unable to determine your location.';

  @override
  String get mapLocationTimeout => 'Location request timed out. Try again.';

  @override
  String get mapUnableLoadLocation => 'Unable to load your location.';
}
