import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Locario'**
  String get appTitle;

  /// No description provided for @localeEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEnglish;

  /// No description provided for @localePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get localePolish;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get tabInbox;

  /// No description provided for @tabHub.
  ///
  /// In en, this message translates to:
  /// **'Hub'**
  String get tabHub;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @headerMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get headerMap;

  /// No description provided for @headerList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get headerList;

  /// No description provided for @hubTitle.
  ///
  /// In en, this message translates to:
  /// **'Hub'**
  String get hubTitle;

  /// No description provided for @hubDescription.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts for creating and managing your local circle'**
  String get hubDescription;

  /// No description provided for @hubCreateEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get hubCreateEventTitle;

  /// No description provided for @hubCreateEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start something new'**
  String get hubCreateEventSubtitle;

  /// No description provided for @hubCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get hubCommunityTitle;

  /// No description provided for @hubCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local updates'**
  String get hubCommunitySubtitle;

  /// No description provided for @hubFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get hubFriendsTitle;

  /// No description provided for @hubFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your network'**
  String get hubFriendsSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Account, preferences and your saved places in one calmer section.'**
  String get profileDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, preferences and app defaults'**
  String get settingsSubtitle;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust the app basics before the settings surface grows.'**
  String get settingsScreenDescription;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Places, events and lists you want to revisit'**
  String get savedSubtitle;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @languageSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app should speak to you'**
  String get languageSectionSubtitle;

  /// No description provided for @themeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeSectionTitle;

  /// No description provided for @themeSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose whether the app should follow the system or stay fixed'**
  String get themeSectionSubtitle;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events...'**
  String get exploreSearchHint;

  /// No description provided for @exploreNearbyEvents.
  ///
  /// In en, this message translates to:
  /// **'Nearby events'**
  String get exploreNearbyEvents;

  /// No description provided for @exploreNearbyWithFilter.
  ///
  /// In en, this message translates to:
  /// **'{filter} nearby'**
  String exploreNearbyWithFilter(String filter);

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get sortDistance;

  /// No description provided for @sortSoonest.
  ///
  /// In en, this message translates to:
  /// **'Soonest'**
  String get sortSoonest;

  /// No description provided for @sortTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get sortTrending;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get filterMusic;

  /// No description provided for @filterArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get filterArt;

  /// No description provided for @filterWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Workshops'**
  String get filterWorkshops;

  /// No description provided for @filterFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get filterFood;

  /// No description provided for @areaMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get areaMyLocation;

  /// No description provided for @areaMyLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Events closest to you by default'**
  String get areaMyLocationDescription;

  /// No description provided for @areaTypedAddressDescription.
  ///
  /// In en, this message translates to:
  /// **'Address entered manually'**
  String get areaTypedAddressDescription;

  /// No description provided for @areaPinnedOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pinned on map'**
  String get areaPinnedOnMap;

  /// No description provided for @areaPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose area'**
  String get areaPickerTitle;

  /// No description provided for @areaPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can type an address, point to a spot on the map or go back to your current location.'**
  String get areaPickerSubtitle;

  /// No description provided for @areaUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get areaUseCurrentLocation;

  /// No description provided for @areaUseCurrentLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your current position as the reference point'**
  String get areaUseCurrentLocationSubtitle;

  /// No description provided for @areaEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get areaEnterAddress;

  /// No description provided for @areaEnterAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a street, district or exact place'**
  String get areaEnterAddressSubtitle;

  /// No description provided for @areaPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get areaPickOnMap;

  /// No description provided for @areaPickOnMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a point on the map'**
  String get areaPickOnMapTitle;

  /// No description provided for @areaPickOnMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move the map so the chosen point sits under the center marker.'**
  String get areaPickOnMapSubtitle;

  /// No description provided for @areaPickOnMapConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use this point'**
  String get areaPickOnMapConfirm;

  /// No description provided for @areaAddressDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get areaAddressDialogTitle;

  /// No description provided for @areaAddressDialogHint.
  ///
  /// In en, this message translates to:
  /// **'For example 12 Old Town Sq, Poznan'**
  String get areaAddressDialogHint;

  /// No description provided for @areaAddressNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that address.'**
  String get areaAddressNotFound;

  /// No description provided for @areaAddressLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Address lookup failed. Try again.'**
  String get areaAddressLookupFailed;

  /// No description provided for @areaDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get areaDialogCancel;

  /// No description provided for @areaDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get areaDialogConfirm;

  /// No description provided for @areaPinnedCoordinates.
  ///
  /// In en, this message translates to:
  /// **'{lat}, {lon}'**
  String areaPinnedCoordinates(String lat, String lon);

  /// No description provided for @areaWarsawCenter.
  ///
  /// In en, this message translates to:
  /// **'Warsaw center'**
  String get areaWarsawCenter;

  /// No description provided for @areaWarsawCenterDescription.
  ///
  /// In en, this message translates to:
  /// **'Address or pin set manually'**
  String get areaWarsawCenterDescription;

  /// No description provided for @areaPowisle.
  ///
  /// In en, this message translates to:
  /// **'Powisle'**
  String get areaPowisle;

  /// No description provided for @areaPowisleDescription.
  ///
  /// In en, this message translates to:
  /// **'Boulevards and Poniatowski bridge area'**
  String get areaPowisleDescription;

  /// No description provided for @areaMokotow.
  ///
  /// In en, this message translates to:
  /// **'Mokotow'**
  String get areaMokotow;

  /// No description provided for @areaMokotowDescription.
  ///
  /// In en, this message translates to:
  /// **'Pole Mokotowskie area and nearby'**
  String get areaMokotowDescription;

  /// No description provided for @eventJazzTitle.
  ///
  /// In en, this message translates to:
  /// **'Jazz in the Botanical Garden'**
  String get eventJazzTitle;

  /// No description provided for @eventSketchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Night sketching by the Vistula'**
  String get eventSketchingTitle;

  /// No description provided for @eventRunClubTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning run club and coffee stop'**
  String get eventRunClubTitle;

  /// No description provided for @eventStreetFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Street food and vinyl market'**
  String get eventStreetFoodTitle;

  /// No description provided for @eventToday2030.
  ///
  /// In en, this message translates to:
  /// **'Today, 20:30'**
  String get eventToday2030;

  /// No description provided for @eventToday1900.
  ///
  /// In en, this message translates to:
  /// **'Today, 19:00'**
  String get eventToday1900;

  /// No description provided for @eventTomorrow0800.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, 08:00'**
  String get eventTomorrow0800;

  /// No description provided for @eventTomorrow1200.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, 12:00'**
  String get eventTomorrow1200;

  /// No description provided for @venueBotanicalGarden.
  ///
  /// In en, this message translates to:
  /// **'Botanical Garden'**
  String get venueBotanicalGarden;

  /// No description provided for @venueVistulaBoulevards.
  ///
  /// In en, this message translates to:
  /// **'Vistula Boulevards'**
  String get venueVistulaBoulevards;

  /// No description provided for @venuePoleMokotowskie.
  ///
  /// In en, this message translates to:
  /// **'Pole Mokotowskie'**
  String get venuePoleMokotowskie;

  /// No description provided for @venueHalaKoszyki.
  ///
  /// In en, this message translates to:
  /// **'Hala Koszyki'**
  String get venueHalaKoszyki;

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{count} m'**
  String distanceMeters(int count);

  /// No description provided for @distanceKilometers.
  ///
  /// In en, this message translates to:
  /// **'{count} km'**
  String distanceKilometers(String count);

  /// No description provided for @mapReturnToLocation.
  ///
  /// In en, this message translates to:
  /// **'Return to my location'**
  String get mapReturnToLocation;

  /// No description provided for @mapStyleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the local map style.\n{error}'**
  String mapStyleLoadFailed(String error);

  /// No description provided for @mapRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get mapRetry;

  /// No description provided for @mapAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get mapAppSettings;

  /// No description provided for @mapLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Location settings'**
  String get mapLocationSettings;

  /// No description provided for @mapServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to see your position.'**
  String get mapServiceDisabled;

  /// No description provided for @mapPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to center the map on you.'**
  String get mapPermissionDenied;

  /// No description provided for @mapPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked in system settings.'**
  String get mapPermissionDeniedForever;

  /// No description provided for @mapUnableDetermineLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine your location.'**
  String get mapUnableDetermineLocation;

  /// No description provided for @mapLocationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Location request timed out. Try again.'**
  String get mapLocationTimeout;

  /// No description provided for @mapUnableLoadLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your location.'**
  String get mapUnableLoadLocation;

  /// No description provided for @mapClusterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an event ({count})'**
  String mapClusterSheetTitle(int count);

  /// No description provided for @mapEventOpenSoon.
  ///
  /// In en, this message translates to:
  /// **'The event screen for “{title}” will be added later.'**
  String mapEventOpenSoon(String title);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
