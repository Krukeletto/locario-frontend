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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover local gems in your area'**
  String get authSubtitle;

  /// No description provided for @authGoogleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogleContinue;

  /// No description provided for @authDividerOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authDividerOr;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'********'**
  String get authPasswordHint;

  /// No description provided for @authFooterTerms.
  ///
  /// In en, this message translates to:
  /// **'TERMS'**
  String get authFooterTerms;

  /// No description provided for @authFooterPrivacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get authFooterPrivacy;

  /// No description provided for @authFooterHelp.
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get authFooterHelp;

  /// No description provided for @authLoginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginWelcome;

  /// No description provided for @authLoginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginSubmit;

  /// No description provided for @authLoginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get authLoginNoAccount;

  /// No description provided for @authLoginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a free account'**
  String get authLoginCreateAccount;

  /// No description provided for @authLogoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully.'**
  String get authLogoutSuccess;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully.'**
  String get authLoginSuccess;

  /// No description provided for @authLoginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authLoginErrorInvalidCredentials;

  /// No description provided for @authRegisterWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authRegisterWelcome;

  /// No description provided for @authRegisterUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get authRegisterUsernameLabel;

  /// No description provided for @authRegisterUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'your_username'**
  String get authRegisterUsernameHint;

  /// No description provided for @authRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterSubmit;

  /// No description provided for @authRegisterHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authRegisterHasAccount;

  /// No description provided for @authRegisterSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get authRegisterSignIn;

  /// No description provided for @authValidationUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get authValidationUsernameRequired;

  /// No description provided for @authValidationUsernameMin3.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get authValidationUsernameMin3;

  /// No description provided for @authValidationUsernameAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed: letters, numbers, . _ -'**
  String get authValidationUsernameAllowed;

  /// No description provided for @authValidationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get authValidationEmailRequired;

  /// No description provided for @authValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authValidationEmailInvalid;

  /// No description provided for @authValidationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authValidationPasswordRequired;

  /// No description provided for @authValidationPasswordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authValidationPasswordMin8;

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

  /// No description provided for @eventDetailsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get eventDetailsScreenTitle;

  /// No description provided for @eventDetailsImagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Temporary image placeholder'**
  String get eventDetailsImagePlaceholder;

  /// No description provided for @eventDetailsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get eventDetailsTitleLabel;

  /// No description provided for @eventDetailsLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get eventDetailsLocationLabel;

  /// No description provided for @eventDetailsDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDetailsDateLabel;

  /// No description provided for @eventDetailsTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get eventDetailsTimeLabel;

  /// No description provided for @eventDetailsPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get eventDetailsPriceLabel;

  /// No description provided for @eventDetailsSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get eventDetailsSeatsLabel;

  /// No description provided for @eventDetailsAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About the event'**
  String get eventDetailsAboutLabel;

  /// No description provided for @eventDetailsOrganizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get eventDetailsOrganizerLabel;

  /// No description provided for @eventDetailsChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Participants chat'**
  String get eventDetailsChatLabel;

  /// No description provided for @eventDetailsBuyTicketButton.
  ///
  /// In en, this message translates to:
  /// **'Buy ticket'**
  String get eventDetailsBuyTicketButton;

  /// No description provided for @eventDetailsJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get eventDetailsJoinButton;

  /// No description provided for @eventDetailsLeaveButton.
  ///
  /// In en, this message translates to:
  /// **'Leave event'**
  String get eventDetailsLeaveButton;

  /// No description provided for @eventJoinSuccess.
  ///
  /// In en, this message translates to:
  /// **'You\'re registered for this event.'**
  String get eventJoinSuccess;

  /// No description provided for @eventLeaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'You\'ve left this event.'**
  String get eventLeaveSuccess;

  /// No description provided for @eventJoinError.
  ///
  /// In en, this message translates to:
  /// **'Could not register for this event.'**
  String get eventJoinError;

  /// No description provided for @eventJoinRequiresLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to join this event.'**
  String get eventJoinRequiresLogin;

  /// No description provided for @eventDetailsUnknownEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventDetailsUnknownEventTitle;

  /// No description provided for @eventDetailsUnknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Location unknown'**
  String get eventDetailsUnknownLocation;

  /// No description provided for @eventDetailsFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'This is a temporary event description. In the next steps we will connect full data from the create event form and backend.'**
  String get eventDetailsFallbackDescription;

  /// No description provided for @eventDetailsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading event'**
  String get eventDetailsLoadingTitle;

  /// No description provided for @eventDetailsLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are fetching the event details from the backend.'**
  String get eventDetailsLoadingSubtitle;

  /// No description provided for @eventDetailsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Event unavailable'**
  String get eventDetailsErrorTitle;

  /// No description provided for @eventDetailsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We could not load this event right now.'**
  String get eventDetailsErrorSubtitle;

  /// No description provided for @eventDetailsJazzDescription.
  ///
  /// In en, this message translates to:
  /// **'An evening jazz concert under the open sky. Bring your friends, a blanket and a good mood.'**
  String get eventDetailsJazzDescription;

  /// No description provided for @eventDetailsSketchingDescription.
  ///
  /// In en, this message translates to:
  /// **'A meetup for people who enjoy sketching and urban illustration. Bring your own materials.'**
  String get eventDetailsSketchingDescription;

  /// No description provided for @eventDetailsRunClubDescription.
  ///
  /// In en, this message translates to:
  /// **'A light morning run followed by coffee and networking. Conversational pace, everyone is welcome.'**
  String get eventDetailsRunClubDescription;

  /// No description provided for @eventDetailsStreetFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Street food, curated vinyl records and mini DJ sets. An all-day event.'**
  String get eventDetailsStreetFoodDescription;

  /// No description provided for @eventDetailsTicketLabel.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get eventDetailsTicketLabel;

  /// No description provided for @eventDetailsSlotsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seat limit'**
  String get eventDetailsSlotsLabel;

  /// No description provided for @eventDetailsSlotsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} seats available'**
  String eventDetailsSlotsValue(int count);

  /// No description provided for @eventSlotsTaken.
  ///
  /// In en, this message translates to:
  /// **'{registered} / {limit} taken'**
  String eventSlotsTaken(int registered, int limit);

  /// No description provided for @eventSlotsJoined.
  ///
  /// In en, this message translates to:
  /// **'{count} joined'**
  String eventSlotsJoined(int count);

  /// No description provided for @eventSlotsSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get eventSlotsSoldOut;

  /// No description provided for @eventSlotsWaitlist.
  ///
  /// In en, this message translates to:
  /// **'{count} on waitlist'**
  String eventSlotsWaitlist(int count);

  /// No description provided for @eventCardSpots.
  ///
  /// In en, this message translates to:
  /// **'{count} spots'**
  String eventCardSpots(int count);

  /// No description provided for @eventDetailsShowOnMapButton.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get eventDetailsShowOnMapButton;

  /// No description provided for @eventDetailsOpenMapError.
  ///
  /// In en, this message translates to:
  /// **'We could not open the map app right now.'**
  String get eventDetailsOpenMapError;

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

  /// No description provided for @eventSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event saved to your list.'**
  String get eventSaveSuccess;

  /// No description provided for @eventRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event removed from your list.'**
  String get eventRemoveSuccess;

  /// No description provided for @eventPublishSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event published successfully.'**
  String get eventPublishSuccess;

  /// No description provided for @eventPublishError.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish event. Try again.'**
  String get eventPublishError;

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

  /// No description provided for @exploreLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading events'**
  String get exploreLoadingTitle;

  /// No description provided for @exploreLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are fetching the latest events, please wait.'**
  String get exploreLoadingSubtitle;

  /// No description provided for @exploreErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Events unavailable'**
  String get exploreErrorTitle;

  /// No description provided for @exploreErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We could not load events right now.'**
  String get exploreErrorSubtitle;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different area or come back later.'**
  String get exploreEmptySubtitle;

  /// No description provided for @exploreRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get exploreRetryButton;

  /// No description provided for @exploreErrorPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get exploreErrorPermissionTitle;

  /// No description provided for @exploreErrorPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please allow location access to see events nearby.'**
  String get exploreErrorPermissionSubtitle;

  /// No description provided for @exploreErrorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get exploreErrorUnknownTitle;

  /// No description provided for @exploreErrorUnknownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We encountered an unexpected error.'**
  String get exploreErrorUnknownSubtitle;

  /// No description provided for @exploreSearchThisArea.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get exploreSearchThisArea;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{0 results} =1{1 result} other{{count} results}}'**
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

  /// No description provided for @distanceFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'List range'**
  String get distanceFilterTooltip;

  /// No description provided for @distanceFilterAny.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get distanceFilterAny;

  /// No description provided for @distanceFilterWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String distanceFilterWithinKm(int km);

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

  /// No description provided for @filterAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get filterAdvancedFilters;

  /// No description provided for @filterAdvancedDistance.
  ///
  /// In en, this message translates to:
  /// **'Search Range'**
  String get filterAdvancedDistance;

  /// No description provided for @filterAdvancedDateRange.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get filterAdvancedDateRange;

  /// No description provided for @filterAdvancedAge.
  ///
  /// In en, this message translates to:
  /// **'Age (years)'**
  String get filterAdvancedAge;

  /// No description provided for @filterAdvancedType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get filterAdvancedType;

  /// No description provided for @filterAdvancedSource.
  ///
  /// In en, this message translates to:
  /// **'Event Source'**
  String get filterAdvancedSource;

  /// No description provided for @filterAdvancedApply.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get filterAdvancedApply;

  /// No description provided for @filterAdvancedClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterAdvancedClear;

  /// No description provided for @filterAdvancedDateFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterAdvancedDateFrom;

  /// No description provided for @filterAdvancedDateTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterAdvancedDateTo;

  /// No description provided for @filterAdvancedDateAny.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get filterAdvancedDateAny;

  /// No description provided for @filterAdvancedDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterAdvancedDateToday;

  /// No description provided for @filterAdvancedDateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get filterAdvancedDateTomorrow;

  /// No description provided for @filterAdvancedDateCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get filterAdvancedDateCustomRange;

  /// No description provided for @filterAdvancedDateOther.
  ///
  /// In en, this message translates to:
  /// **'Other date'**
  String get filterAdvancedDateOther;

  /// No description provided for @filterAdvancedDateSelection.
  ///
  /// In en, this message translates to:
  /// **'Selected date'**
  String get filterAdvancedDateSelection;

  /// No description provided for @filterAdvancedAgeFrom.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get filterAdvancedAgeFrom;

  /// No description provided for @filterAdvancedAgeTo.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get filterAdvancedAgeTo;

  /// No description provided for @filterAdvancedAgeSelection.
  ///
  /// In en, this message translates to:
  /// **'Participant age'**
  String get filterAdvancedAgeSelection;

  /// No description provided for @filterAdvancedAgeCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get filterAdvancedAgeCustomRange;

  /// No description provided for @filterAdvancedAgeOther.
  ///
  /// In en, this message translates to:
  /// **'Other age'**
  String get filterAdvancedAgeOther;

  /// No description provided for @filterAdvancedAgeRangeSummary.
  ///
  /// In en, this message translates to:
  /// **'{from}-{to} years'**
  String filterAdvancedAgeRangeSummary(int from, int to);

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

  /// No description provided for @hubCreateEventNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get hubCreateEventNameLabel;

  /// No description provided for @hubCreateEventNameHint.
  ///
  /// In en, this message translates to:
  /// **'What is your event called?'**
  String get hubCreateEventNameHint;

  /// No description provided for @hubCreateEventCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get hubCreateEventCategoryLabel;

  /// No description provided for @hubCreateEventLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get hubCreateEventLocationLabel;

  /// No description provided for @hubCreateEventLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Where will the event take place?'**
  String get hubCreateEventLocationHint;

  /// No description provided for @hubCreateEventLocationLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Fetching your location'**
  String get hubCreateEventLocationLoadingLabel;

  /// No description provided for @hubCreateEventLocationLoadingDescription.
  ///
  /// In en, this message translates to:
  /// **'This may take a moment.'**
  String get hubCreateEventLocationLoadingDescription;

  /// No description provided for @hubCreateEventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get hubCreateEventDateLabel;

  /// No description provided for @hubCreateEventDateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get hubCreateEventDateHint;

  /// No description provided for @hubCreateEventDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get hubCreateEventDatePlaceholder;

  /// No description provided for @hubCreateEventTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get hubCreateEventTimeLabel;

  /// No description provided for @hubCreateEventTimeHint.
  ///
  /// In en, this message translates to:
  /// **'--:--'**
  String get hubCreateEventTimeHint;

  /// No description provided for @hubCreateEventTimePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get hubCreateEventTimePlaceholder;

  /// No description provided for @hubCreateEventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Event description'**
  String get hubCreateEventDescriptionLabel;

  /// No description provided for @hubCreateEventDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell people about your event...'**
  String get hubCreateEventDescriptionHint;

  /// No description provided for @hubCreateEventMainPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Add main photo'**
  String get hubCreateEventMainPhotoLabel;

  /// No description provided for @hubCreateEventPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get hubCreateEventPhotosLabel;

  /// No description provided for @hubCreateEventMainPhotoSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Suggested size: 1600 x 900 px'**
  String get hubCreateEventMainPhotoSizeHint;

  /// No description provided for @hubCreateEventSelectedPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No photos selected} =1{1 photo selected} other{{count} photos selected}}'**
  String hubCreateEventSelectedPhotosCount(int count);

  /// No description provided for @hubCreateEventPrimaryPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Main photo (thumbnail). Drag to keep another image first.'**
  String get hubCreateEventPrimaryPhotoHint;

  /// No description provided for @hubCreateEventSecondaryPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Additional photo. Drag to change order.'**
  String get hubCreateEventSecondaryPhotoHint;

  /// No description provided for @hubCreateEventTicketingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tickets and entry'**
  String get hubCreateEventTicketingTitle;

  /// No description provided for @hubCreateEventTicketingSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable tickets and seat limits'**
  String get hubCreateEventTicketingSwitchLabel;

  /// No description provided for @hubCreateEventTicketSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of seats'**
  String get hubCreateEventTicketSeatsLabel;

  /// No description provided for @hubCreateEventTicketPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket price'**
  String get hubCreateEventTicketPriceLabel;

  /// No description provided for @hubCreateEventTicketingLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticketing'**
  String get hubCreateEventTicketingLabel;

  /// No description provided for @hubCreateEventTicketUrlHint.
  ///
  /// In en, this message translates to:
  /// **'URL for buying tickets'**
  String get hubCreateEventTicketUrlHint;

  /// No description provided for @hubCreateEventStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Event status'**
  String get hubCreateEventStatusLabel;

  /// No description provided for @eventStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get eventStatusDraft;

  /// No description provided for @eventStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get eventStatusPublished;

  /// No description provided for @hubCreateEventSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get hubCreateEventSubmitButton;

  /// No description provided for @hubCreateEventSubmitDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Creating events is temporarily disabled until login is wired into the app.'**
  String get hubCreateEventSubmitDisabledHint;

  /// No description provided for @hubCreateEventValidationMinChars3.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters.'**
  String get hubCreateEventValidationMinChars3;

  /// No description provided for @hubCreateEventValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get hubCreateEventValidationRequired;

  /// No description provided for @hubCreateEventValidationDescriptionMin10.
  ///
  /// In en, this message translates to:
  /// **'Description should be at least 10 characters.'**
  String get hubCreateEventValidationDescriptionMin10;

  /// No description provided for @hubCreateEventValidationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one category.'**
  String get hubCreateEventValidationCategoryRequired;

  /// No description provided for @hubCreateEventValidationPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number.'**
  String get hubCreateEventValidationPositiveNumber;

  /// No description provided for @hubCreateEventValidationDateTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the event date and time.'**
  String get hubCreateEventValidationDateTimeRequired;

  /// No description provided for @hubCreateEventValidationLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the event location.'**
  String get hubCreateEventValidationLocationRequired;

  /// No description provided for @hubCreateEventCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event has been created.'**
  String get hubCreateEventCreatedSuccess;

  /// No description provided for @hubCreateEventCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Event could not be created. Try again.'**
  String get hubCreateEventCreateFailed;

  /// No description provided for @hubCreateEventLocationLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t resolve that location. Try another address or point on the map.'**
  String get hubCreateEventLocationLookupFailed;

  /// No description provided for @hubMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get hubMessagesTitle;

  /// No description provided for @hubMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct messages'**
  String get hubMessagesSubtitle;

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

  /// Text shown when the inbox has no notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get inboxEmpty;

  /// Button text to mark all notifications as read.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get inboxMarkAllRead;

  /// Title for notification preferences section in settings.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notificationSettingsTitle;

  /// Subtitle for notification preferences section in settings.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive'**
  String get notificationSettingsSubtitle;

  /// Label for upcoming event notifications.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get notificationTypeUpcomingEvent;

  /// Description for upcoming event notifications.
  ///
  /// In en, this message translates to:
  /// **'Reminders before saved events start'**
  String get notificationTypeUpcomingEventDesc;

  /// Label for expired event notifications.
  ///
  /// In en, this message translates to:
  /// **'Expired events'**
  String get notificationTypeExpiredEvent;

  /// Description for expired event notifications.
  ///
  /// In en, this message translates to:
  /// **'When a saved event has passed'**
  String get notificationTypeExpiredEventDesc;

  /// Label for new event published notifications.
  ///
  /// In en, this message translates to:
  /// **'New events'**
  String get notificationTypeEventPublished;

  /// Description for new event published notifications.
  ///
  /// In en, this message translates to:
  /// **'When new events are published nearby'**
  String get notificationTypeEventPublishedDesc;

  /// Label for system message notifications.
  ///
  /// In en, this message translates to:
  /// **'System messages'**
  String get notificationTypeSystemMessage;

  /// Description for system message notifications.
  ///
  /// In en, this message translates to:
  /// **'Important updates from the app'**
  String get notificationTypeSystemMessageDesc;

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

  /// No description provided for @profileAuthLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileAuthLoginTitle;

  /// No description provided for @profileAuthLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to the login screen'**
  String get profileAuthLoginSubtitle;

  /// No description provided for @profileAuthLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileAuthLogoutTitle;

  /// No description provided for @profileAuthLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'End the current session'**
  String get profileAuthLogoutSubtitle;

  /// No description provided for @profileInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open your notifications'**
  String get profileInboxSubtitle;

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

  /// No description provided for @settingsAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settingsAccountSectionTitle;

  /// No description provided for @settingsAccountSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get settingsAccountSectionSubtitle;

  /// No description provided for @settingsAccountChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsAccountChangePassword;

  /// No description provided for @settingsChangePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordDialogTitle;

  /// No description provided for @settingsChangePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get settingsChangePasswordCurrentLabel;

  /// No description provided for @settingsChangePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settingsChangePasswordNewLabel;

  /// No description provided for @settingsChangePasswordCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsChangePasswordCancel;

  /// No description provided for @settingsChangePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get settingsChangePasswordSubmit;

  /// No description provided for @settingsChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get settingsChangePasswordSuccess;

  /// No description provided for @settingsChangePasswordInvalidOld.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get settingsChangePasswordInvalidOld;

  /// No description provided for @settingsChangePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update password.'**
  String get settingsChangePasswordFailed;

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

  /// No description provided for @savedSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get savedSaveAction;

  /// No description provided for @savedRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove saved'**
  String get savedRemoveAction;

  /// No description provided for @savedSaveActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get savedSaveActionTooltip;

  /// No description provided for @savedRemoveActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get savedRemoveActionTooltip;

  /// No description provided for @savedSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saved sort'**
  String get savedSortTooltip;

  /// No description provided for @savedSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently saved'**
  String get savedSortRecent;

  /// No description provided for @savedSortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get savedSortDistance;

  /// No description provided for @savedFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saved filters'**
  String get savedFiltersTooltip;

  /// No description provided for @savedFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved filters'**
  String get savedFiltersTitle;

  /// No description provided for @savedFiltersClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get savedFiltersClear;

  /// No description provided for @savedFiltersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get savedFiltersApply;

  /// No description provided for @savedFilterCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get savedFilterCategoriesTitle;

  /// No description provided for @savedFilterAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Age groups'**
  String get savedFilterAgeTitle;

  /// No description provided for @savedFilterTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get savedFilterTagsTitle;

  /// No description provided for @savedAgeGroupAny.
  ///
  /// In en, this message translates to:
  /// **'Any age'**
  String get savedAgeGroupAny;

  /// No description provided for @savedAgeGroup12Plus.
  ///
  /// In en, this message translates to:
  /// **'12+'**
  String get savedAgeGroup12Plus;

  /// No description provided for @savedAgeGroup18Plus.
  ///
  /// In en, this message translates to:
  /// **'18+'**
  String get savedAgeGroup18Plus;

  /// No description provided for @savedShowPastEvents.
  ///
  /// In en, this message translates to:
  /// **'Show past events'**
  String get savedShowPastEvents;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved events yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save events from Explore to keep them here.'**
  String get savedEmptySubtitle;

  /// No description provided for @savedEmptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No events match the filters'**
  String get savedEmptyFilteredTitle;

  /// No description provided for @savedEmptyFilteredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the filters or try a different combination.'**
  String get savedEmptyFilteredSubtitle;

  /// No description provided for @savedEventsTab.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get savedEventsTab;

  /// No description provided for @savedFiltersTab.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get savedFiltersTab;

  /// No description provided for @savedFiltersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved filters yet'**
  String get savedFiltersEmptyTitle;

  /// No description provided for @savedFiltersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Custom filter presets you create will appear here.'**
  String get savedFiltersEmptySubtitle;

  /// No description provided for @savedFiltersSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save filter'**
  String get savedFiltersSaveDialogTitle;

  /// No description provided for @savedFiltersSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savedFiltersSaveAction;

  /// No description provided for @savedFiltersNameHint.
  ///
  /// In en, this message translates to:
  /// **'Filter name'**
  String get savedFiltersNameHint;

  /// No description provided for @savedFiltersDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete filter'**
  String get savedFiltersDeleteTooltip;

  /// No description provided for @savedFiltersLoadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use filter'**
  String get savedFiltersLoadTooltip;

  /// No description provided for @savedFilterNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get savedFilterNotificationsLabel;

  /// No description provided for @savedFilterNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications for this filter'**
  String get savedFilterNotificationsTooltip;

  /// No description provided for @savedFiltersLocationCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get savedFiltersLocationCurrent;

  /// No description provided for @savedFiltersLocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved location'**
  String get savedFiltersLocationSaved;

  /// No description provided for @savedFiltersUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get savedFiltersUseCurrentLocation;

  /// No description provided for @savedFiltersUseSavedLocation.
  ///
  /// In en, this message translates to:
  /// **'Use saved location'**
  String get savedFiltersUseSavedLocation;

  /// No description provided for @savedFiltersSaveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Filter saved'**
  String get savedFiltersSaveConfirmation;

  /// No description provided for @savedFiltersDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Filter deleted'**
  String get savedFiltersDeleteConfirmation;

  /// No description provided for @savedFiltersLoadConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Filter applied'**
  String get savedFiltersLoadConfirmation;

  /// No description provided for @savedFiltersCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Save current filters'**
  String get savedFiltersCreateButton;

  /// No description provided for @savedFiltersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get savedFiltersCancel;

  /// No description provided for @savedFiltersLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get savedFiltersLocationLabel;

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

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section is still being built.'**
  String get featureComingSoon;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @networkErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get networkErrorRetry;

  /// No description provided for @shareEventMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out this event on Locario: {title}\n\n{url}'**
  String shareEventMessage(String title, String url);

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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
