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

  /// No description provided for @eventDetailsEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get eventDetailsEndDateLabel;

  /// No description provided for @eventDetailsStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get eventDetailsStartTimeLabel;

  /// No description provided for @eventDetailsEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get eventDetailsEndTimeLabel;

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

  /// No description provided for @eventOrganizerRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Organizer rating'**
  String get eventOrganizerRatingLabel;

  /// No description provided for @eventOrganizerRatingValue.
  ///
  /// In en, this message translates to:
  /// **'{average}/5 · {count,plural, one{1 review} other{{count} reviews}}'**
  String eventOrganizerRatingValue(String average, int count);

  /// No description provided for @eventOrganizerRatingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No organizer reviews yet'**
  String get eventOrganizerRatingEmpty;

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

  /// No description provided for @eventDetailsReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get eventDetailsReviewButton;

  /// No description provided for @eventEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get eventEditAction;

  /// No description provided for @eventEditScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get eventEditScreenTitle;

  /// No description provided for @eventEditSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get eventEditSubmitButton;

  /// No description provided for @eventUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event updated successfully.'**
  String get eventUpdateSuccess;

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

  /// No description provided for @eventCalendarPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar?'**
  String get eventCalendarPromptTitle;

  /// No description provided for @eventCalendarPromptBody.
  ///
  /// In en, this message translates to:
  /// **'You can add this event now or later from the event details screen. The calendar will open with the details already filled in.'**
  String get eventCalendarPromptBody;

  /// No description provided for @eventCalendarPromptAddNow.
  ///
  /// In en, this message translates to:
  /// **'Add now'**
  String get eventCalendarPromptAddNow;

  /// No description provided for @eventCalendarPromptLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get eventCalendarPromptLater;

  /// No description provided for @eventDetailsAddToCalendarButton.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get eventDetailsAddToCalendarButton;

  /// No description provided for @eventAddToCalendarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Event added to your calendar.'**
  String get eventAddToCalendarSuccess;

  /// No description provided for @eventAddToCalendarError.
  ///
  /// In en, this message translates to:
  /// **'Could not add the event to your calendar.'**
  String get eventAddToCalendarError;

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

  /// No description provided for @eventReviewScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get eventReviewScreenTitle;

  /// No description provided for @eventReviewLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading review'**
  String get eventReviewLoadingTitle;

  /// No description provided for @eventReviewLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are preparing the review form and event details.'**
  String get eventReviewLoadingSubtitle;

  /// No description provided for @eventReviewErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Review unavailable'**
  String get eventReviewErrorTitle;

  /// No description provided for @eventReviewErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We could not load the review screen right now.'**
  String get eventReviewErrorSubtitle;

  /// No description provided for @eventReviewFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Your opinion'**
  String get eventReviewFormTitle;

  /// No description provided for @eventReviewFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a rating and add an optional comment.'**
  String get eventReviewFormSubtitle;

  /// No description provided for @eventReviewLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can review this event after it ends and only if you joined it.'**
  String get eventReviewLockedSubtitle;

  /// No description provided for @eventReviewCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get eventReviewCommentLabel;

  /// No description provided for @eventReviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What stood out?'**
  String get eventReviewCommentHint;

  /// No description provided for @eventReviewSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Send review'**
  String get eventReviewSubmitButton;

  /// No description provided for @eventReviewSubmittedButton.
  ///
  /// In en, this message translates to:
  /// **'Review sent'**
  String get eventReviewSubmittedButton;

  /// No description provided for @eventReviewSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Your review has been saved.'**
  String get eventReviewSubmittedLabel;

  /// No description provided for @eventReviewEligibilityHint.
  ///
  /// In en, this message translates to:
  /// **'Only joined participants can review after the event ends.'**
  String get eventReviewEligibilityHint;

  /// No description provided for @eventReviewSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review sent successfully.'**
  String get eventReviewSuccess;

  /// No description provided for @eventReviewError.
  ///
  /// In en, this message translates to:
  /// **'We could not send your review.'**
  String get eventReviewError;

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

  /// No description provided for @groupsDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsDiscoverTitle;

  /// No description provided for @groupsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading groups'**
  String get groupsLoadingTitle;

  /// No description provided for @groupsLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are fetching communities for you.'**
  String get groupsLoadingSubtitle;

  /// No description provided for @groupsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups'**
  String get groupsErrorTitle;

  /// No description provided for @groupsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get groupsErrorSubtitle;

  /// No description provided for @groupsCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupsCreateCta;

  /// No description provided for @groupsMyGroupsTab.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get groupsMyGroupsTab;

  /// No description provided for @groupsMyGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get groupsMyGroupsTitle;

  /// No description provided for @groupsMyGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Communities you already belong to.'**
  String get groupsMyGroupsSubtitle;

  /// No description provided for @groupsMyGroupsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsMyGroupsEmptyTitle;

  /// No description provided for @groupsMyGroupsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a public group to see it here.'**
  String get groupsMyGroupsEmptySubtitle;

  /// No description provided for @groupsDiscoverTab.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get groupsDiscoverTab;

  /// No description provided for @groupsDiscoverPublicTitle.
  ///
  /// In en, this message translates to:
  /// **'Public groups'**
  String get groupsDiscoverPublicTitle;

  /// No description provided for @groupsDiscoverPublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse communities that are open to discovery.'**
  String get groupsDiscoverPublicSubtitle;

  /// No description provided for @groupsDiscoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get groupsDiscoverEmptyTitle;

  /// No description provided for @groupsDiscoverEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different phrase or category.'**
  String get groupsDiscoverEmptySubtitle;

  /// No description provided for @groupsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups'**
  String get groupsSearchHint;

  /// No description provided for @groupsCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get groupsCategoryAll;

  /// No description provided for @groupsCategoryUnknown.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get groupsCategoryUnknown;

  /// No description provided for @groupsVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get groupsVisibilityPublic;

  /// No description provided for @groupsVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get groupsVisibilityPrivate;

  /// No description provided for @groupsMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one{1 member} other{{count} members}}'**
  String groupsMembersCount(int count);

  /// No description provided for @groupsMembershipActive.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupsMembershipActive;

  /// No description provided for @groupsMembershipPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get groupsMembershipPending;

  /// No description provided for @groupsMembershipBanned.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get groupsMembershipBanned;

  /// No description provided for @groupsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupsCreateTitle;

  /// No description provided for @groupsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get groupsEditTitle;

  /// No description provided for @groupsEditForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to edit this group.'**
  String get groupsEditForbidden;

  /// No description provided for @groupsFieldName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupsFieldName;

  /// No description provided for @groupsFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupsFieldDescription;

  /// No description provided for @groupsFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get groupsFieldCategory;

  /// No description provided for @groupsFieldAvatarUrl.
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get groupsFieldAvatarUrl;

  /// No description provided for @groupsFieldIconUrl.
  ///
  /// In en, this message translates to:
  /// **'Icon URL'**
  String get groupsFieldIconUrl;

  /// No description provided for @groupsFieldMapPinIconUrl.
  ///
  /// In en, this message translates to:
  /// **'Map pin icon URL'**
  String get groupsFieldMapPinIconUrl;

  /// No description provided for @groupsFieldMapPinStyle.
  ///
  /// In en, this message translates to:
  /// **'Map pin style'**
  String get groupsFieldMapPinStyle;

  /// No description provided for @groupsCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get groupsCategoryNone;

  /// No description provided for @groupsAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get groupsAdvancedTitle;

  /// No description provided for @groupsAdvancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional visual settings from the backend contract.'**
  String get groupsAdvancedSubtitle;

  /// No description provided for @groupsCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupsCreateSubmit;

  /// No description provided for @groupsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get groupsSaveChanges;

  /// No description provided for @groupsValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name.'**
  String get groupsValidationNameRequired;

  /// No description provided for @groupsValidationNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The name can be at most 255 characters.'**
  String get groupsValidationNameTooLong;

  /// No description provided for @groupsValidationDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'The description can be at most 5000 characters.'**
  String get groupsValidationDescriptionTooLong;

  /// No description provided for @groupsValidationMapPinStyleTooLong.
  ///
  /// In en, this message translates to:
  /// **'The map pin style can be at most 50 characters.'**
  String get groupsValidationMapPinStyleTooLong;

  /// No description provided for @groupsValidationUrlTooLong.
  ///
  /// In en, this message translates to:
  /// **'The URL can be at most 2048 characters.'**
  String get groupsValidationUrlTooLong;

  /// No description provided for @groupsValidationUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL.'**
  String get groupsValidationUrlInvalid;

  /// No description provided for @groupsJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get groupsJoinAction;

  /// No description provided for @groupsLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get groupsLeaveAction;

  /// No description provided for @groupsPendingAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get groupsPendingAction;

  /// No description provided for @groupsTabFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get groupsTabFeed;

  /// No description provided for @groupsTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupsTabMembers;

  /// No description provided for @groupsTabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get groupsTabEvents;

  /// No description provided for @groupsTabManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get groupsTabManage;

  /// No description provided for @groupsTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get groupsTabInfo;

  /// No description provided for @groupsFeedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No feed yet'**
  String get groupsFeedEmptyTitle;

  /// No description provided for @groupsFeedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Posts and events linked to this group will appear here.'**
  String get groupsFeedEmptySubtitle;

  /// No description provided for @groupsFeedPostLabel.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get groupsFeedPostLabel;

  /// No description provided for @groupsFeedEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get groupsFeedEventLabel;

  /// No description provided for @groupsFeedPostFallbackAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get groupsFeedPostFallbackAuthor;

  /// No description provided for @groupsFeedEventFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Group event'**
  String get groupsFeedEventFallbackTitle;

  /// No description provided for @groupsPostCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Write post'**
  String get groupsPostCreateAction;

  /// No description provided for @groupsPostCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get groupsPostCreateTitle;

  /// No description provided for @groupsPostEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get groupsPostEditTitle;

  /// No description provided for @groupsPostHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to share with the group?'**
  String get groupsPostHint;

  /// No description provided for @groupsPostPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get groupsPostPublish;

  /// No description provided for @groupsEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get groupsEditAction;

  /// No description provided for @groupsDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupsDeleteAction;

  /// No description provided for @groupsHideAction.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get groupsHideAction;

  /// No description provided for @groupsReportAction.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get groupsReportAction;

  /// No description provided for @groupsOpenEventAction.
  ///
  /// In en, this message translates to:
  /// **'Open event'**
  String get groupsOpenEventAction;

  /// No description provided for @groupsJoinRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Join requests'**
  String get groupsJoinRequestsTitle;

  /// No description provided for @groupsApproveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get groupsApproveAction;

  /// No description provided for @groupsRejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get groupsRejectAction;

  /// No description provided for @groupsMembersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No members'**
  String get groupsMembersEmptyTitle;

  /// No description provided for @groupsMembersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members will appear here after people join.'**
  String get groupsMembersEmptySubtitle;

  /// No description provided for @groupsMemberOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get groupsMemberOwner;

  /// No description provided for @groupsMemberAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get groupsMemberAdmin;

  /// No description provided for @groupsMemberRegular.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupsMemberRegular;

  /// No description provided for @groupsMakeAdminAction.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get groupsMakeAdminAction;

  /// No description provided for @groupsMakeMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Make member'**
  String get groupsMakeMemberAction;

  /// No description provided for @groupsBanAction.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get groupsBanAction;

  /// No description provided for @groupsUnbanAction.
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get groupsUnbanAction;

  /// No description provided for @groupsRemoveMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get groupsRemoveMemberAction;

  /// No description provided for @groupsTransferOwnershipAction.
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership'**
  String get groupsTransferOwnershipAction;

  /// No description provided for @groupsCreateEventAction.
  ///
  /// In en, this message translates to:
  /// **'Create event for group'**
  String get groupsCreateEventAction;

  /// No description provided for @groupsLinkExistingEventAction.
  ///
  /// In en, this message translates to:
  /// **'Link existing event'**
  String get groupsLinkExistingEventAction;

  /// No description provided for @groupsUnlinkEventAction.
  ///
  /// In en, this message translates to:
  /// **'Unlink event'**
  String get groupsUnlinkEventAction;

  /// No description provided for @groupsEventsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get groupsEventsEmptyTitle;

  /// No description provided for @groupsEventsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create or link an event to start the group timeline.'**
  String get groupsEventsEmptySubtitle;

  /// No description provided for @groupsManageRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restricted section'**
  String get groupsManageRestrictedTitle;

  /// No description provided for @groupsManageRestrictedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only the owner and group admins can manage reports and members.'**
  String get groupsManageRestrictedSubtitle;

  /// No description provided for @groupsReportsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get groupsReportsEmptyTitle;

  /// No description provided for @groupsReportsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'New reports will appear here.'**
  String get groupsReportsEmptySubtitle;

  /// No description provided for @groupsResolveAction.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get groupsResolveAction;

  /// No description provided for @groupsReportGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Report group'**
  String get groupsReportGroupAction;

  /// No description provided for @groupsReportGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Report group'**
  String get groupsReportGroupTitle;

  /// No description provided for @groupsReportPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get groupsReportPostTitle;

  /// No description provided for @groupsReportEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Report event'**
  String get groupsReportEventTitle;

  /// No description provided for @groupsReportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get groupsReportReasonLabel;

  /// No description provided for @groupsReportDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupsReportDescriptionLabel;

  /// No description provided for @groupsReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get groupsReportSubmit;

  /// No description provided for @groupsConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get groupsConfirmAction;

  /// No description provided for @groupsDeleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get groupsDeleteGroupTitle;

  /// No description provided for @groupsDeleteGroupBody.
  ///
  /// In en, this message translates to:
  /// **'The group will be deleted for members and removed from discovery.'**
  String get groupsDeleteGroupBody;

  /// No description provided for @groupsDeletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get groupsDeletePostTitle;

  /// No description provided for @groupsDeletePostBody.
  ///
  /// In en, this message translates to:
  /// **'This post will disappear from the group feed.'**
  String get groupsDeletePostBody;

  /// No description provided for @groupsActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed.'**
  String get groupsActionFailed;

  /// No description provided for @groupsEventGroupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked groups'**
  String get groupsEventGroupsLabel;

  /// No description provided for @groupsEventGroupsOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to create a public event, or select groups to attach it.'**
  String get groupsEventGroupsOptionalHint;

  /// No description provided for @groupsEventGroupsRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Select at least one group. As a regular member you can only create group events.'**
  String get groupsEventGroupsRequiredHint;

  /// No description provided for @groupsEventGroupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You are not an active member of any group yet.'**
  String get groupsEventGroupsEmpty;

  /// No description provided for @groupsEventValidationGroupRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one group for this event.'**
  String get groupsEventValidationGroupRequired;

  /// No description provided for @groupsEventValidationSlotLimitRequired.
  ///
  /// In en, this message translates to:
  /// **'Regular members must set a positive slot limit.'**
  String get groupsEventValidationSlotLimitRequired;

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

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalTermsContent.
  ///
  /// In en, this message translates to:
  /// **'These Terms of Service (\"Terms\") govern your use of the Locario mobile application and related services. By using Locario, you agree to these Terms. If you do not agree, do not use the app.\n\n1. Account Registration.\nYou must provide accurate information when creating an account. You are responsible for maintaining the confidentiality of your login credentials.\n\n2. Acceptable Use.\nYou agree not to misuse the app, including but not limited to impersonating others, submitting false event information, or engaging in any activity that disrupts the platform.\n\n3. Content.\nYou retain ownership of the content you submit. We reserve the right to remove content that violates these Terms.\n\n4. Limitation of Liability.\nLocario and its affiliates are not liable for indirect damages arising from your use of the app.\n\n5. Changes.\nWe may update these Terms. Continued use after changes constitutes acceptance.\n\n6. Contact.\nFor questions, contact us at locario.app@gmail.com.\n\nLast updated: May 2026.'**
  String get legalTermsContent;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters to us. This Privacy Policy explains how we collect, use, and protect your personal data when you use Locario.\n\n1. Data We Collect.\nWe collect information you provide (username, email, profile data) and automatically collected data (device info, location when enabled, usage analytics).\n\n2. How We Use Data.\nWe use your data to operate the app, personalize content, send notifications (with your consent), and improve our services.\n\n3. Data Sharing.\nWe do not sell your data. We may share it with service providers who help operate our platform, under strict confidentiality agreements.\n\n4. Your Rights.\nYou can access, correct, or delete your data at any time through your profile settings or by contacting us.\n\n5. Data Retention.\nWe retain your data as long as your account is active. After deletion, we keep anonymized data for analytics.\n\n6. Security.\nWe implement industry-standard measures to protect your data.\n\n7. Contact.\nlocario.app@gmail.com\n\nLast updated: May 2026.'**
  String get legalPrivacyContent;

  /// No description provided for @legalHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get legalHelpTitle;

  /// No description provided for @legalHelpSectionFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get legalHelpSectionFaq;

  /// No description provided for @legalHelpFaqContent.
  ///
  /// In en, this message translates to:
  /// **'Q: How do I create an event?\nA: Tap the + button from the hub panel and follow the event creation form.\n\nQ: How can I change my password?\nA: Go to Profile → Settings → Password and enter your current and new password.\n\nQ: I forgot my password.\nA: Use the \"Forgot password\" option on the login screen.\n\nQ: How do I report an issue?\nA: Send an email to locario.app@gmail.com with details about your problem.'**
  String get legalHelpFaqContent;

  /// No description provided for @legalHelpSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get legalHelpSectionContact;

  /// No description provided for @legalHelpContactContent.
  ///
  /// In en, this message translates to:
  /// **'Need further assistance? Reach out to us:\n\nEmail: locario.app@gmail.com\n\nWe aim to respond within 24-48 hours on business days.'**
  String get legalHelpContactContent;

  /// No description provided for @legalConsentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Consents'**
  String get legalConsentsTitle;

  /// No description provided for @legalConsentsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Consents'**
  String get legalConsentsSectionTitle;

  /// No description provided for @legalConsentsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage what you agree to share with us. You can change these anytime.'**
  String get legalConsentsSectionSubtitle;

  /// No description provided for @consentTypeMarketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing emails'**
  String get consentTypeMarketingEmails;

  /// No description provided for @consentTypeMarketingEmailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive promotional offers, event suggestions, and news about Locario'**
  String get consentTypeMarketingEmailsDesc;

  /// No description provided for @consentTypeDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'Data processing'**
  String get consentTypeDataProcessing;

  /// No description provided for @consentTypeDataProcessingDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow us to analyze your usage to improve the app experience'**
  String get consentTypeDataProcessingDesc;

  /// No description provided for @consentTypeLocationData.
  ///
  /// In en, this message translates to:
  /// **'Location data'**
  String get consentTypeLocationData;

  /// No description provided for @consentTypeLocationDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Share precise location to discover nearby events and personalized recommendations'**
  String get consentTypeLocationDataDesc;

  /// No description provided for @settingsLegalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Policies'**
  String get settingsLegalSectionTitle;

  /// No description provided for @settingsLegalSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service, privacy, and help resources'**
  String get settingsLegalSectionSubtitle;

  /// No description provided for @settingsLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsLegalTerms;

  /// No description provided for @settingsLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsLegalPrivacy;

  /// No description provided for @settingsLegalHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsLegalHelp;

  /// No description provided for @settingsConsentsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Consents'**
  String get settingsConsentsSectionTitle;

  /// No description provided for @settingsConsentsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy preferences'**
  String get settingsConsentsSectionSubtitle;

  /// No description provided for @legalAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Updated Terms & Privacy'**
  String get legalAcceptanceTitle;

  /// No description provided for @legalAcceptanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We have updated our legal documents. Please review and accept the changes to continue using Locario.'**
  String get legalAcceptanceSubtitle;

  /// No description provided for @legalAcceptanceTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalAcceptanceTermsTitle;

  /// No description provided for @legalAcceptancePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalAcceptancePrivacyTitle;

  /// No description provided for @legalAcceptanceButton.
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get legalAcceptanceButton;

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
  /// **'Account, preferences and saved places.'**
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

  /// No description provided for @profileOrganizerRatingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Organizer ratings'**
  String get profileOrganizerRatingsTitle;

  /// No description provided for @profileOrganizerRatingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your ratings'**
  String get profileOrganizerRatingsLoading;

  /// No description provided for @profileOrganizerRatingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get profileOrganizerRatingsEmpty;

  /// No description provided for @profileOrganizerRatingsValue.
  ///
  /// In en, this message translates to:
  /// **'{average}/5 · {count,plural, one{1 review} other{{count} reviews}}'**
  String profileOrganizerRatingsValue(String average, int count);

  /// No description provided for @profileOrganizerReviewsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Organizer reviews'**
  String get profileOrganizerReviewsScreenTitle;

  /// No description provided for @profileOrganizerReviewsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading reviews'**
  String get profileOrganizerReviewsLoadingTitle;

  /// No description provided for @profileOrganizerReviewsLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are gathering reviews from your events.'**
  String get profileOrganizerReviewsLoadingSubtitle;

  /// No description provided for @profileOrganizerReviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get profileOrganizerReviewsEmptyTitle;

  /// No description provided for @profileOrganizerReviewsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews from events you organize will appear here.'**
  String get profileOrganizerReviewsEmptySubtitle;

  /// No description provided for @profileOrganizerReviewsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your organizer score'**
  String get profileOrganizerReviewsSummaryTitle;

  /// No description provided for @profileEventHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Event archive'**
  String get profileEventHistoryTitle;

  /// No description provided for @profileEventHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your event history.'**
  String get profileEventHistorySubtitle;

  /// No description provided for @profileEventHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No joined events yet'**
  String get profileEventHistoryEmptyTitle;

  /// No description provided for @profileEventHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Joined events will appear here after you register.'**
  String get profileEventHistoryEmptySubtitle;

  /// No description provided for @profileEventHistoryCurrentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get profileEventHistoryCurrentSectionTitle;

  /// No description provided for @profileEventHistoryPastSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get profileEventHistoryPastSectionTitle;

  /// No description provided for @profileEventHistoryOpenEvent.
  ///
  /// In en, this message translates to:
  /// **'Open event'**
  String get profileEventHistoryOpenEvent;

  /// No description provided for @profileInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open your notifications'**
  String get profileInboxSubtitle;

  /// No description provided for @profileBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No bio yet.'**
  String get profileBioPlaceholder;

  /// No description provided for @profileLinksLabel.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get profileLinksLabel;

  /// No description provided for @profileLinksPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No links yet.'**
  String get profileLinksPlaceholder;

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

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile.'**
  String get profileUpdateFailed;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editProfileChangePhoto;

  /// No description provided for @editProfileUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get editProfileUsernameLabel;

  /// No description provided for @editProfileUsernamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your username'**
  String get editProfileUsernamePlaceholder;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In en, this message translates to:
  /// **'BIO'**
  String get editProfileBioLabel;

  /// No description provided for @editProfileBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get editProfileBioPlaceholder;

  /// No description provided for @editProfileWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'WEBSITE'**
  String get editProfileWebsiteLabel;

  /// No description provided for @editProfileWebsitePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://example.com'**
  String get editProfileWebsitePlaceholder;

  /// No description provided for @editProfileInstagramLabel.
  ///
  /// In en, this message translates to:
  /// **'INSTAGRAM'**
  String get editProfileInstagramLabel;

  /// No description provided for @editProfileInstagramPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://instagram.com/...'**
  String get editProfileInstagramPlaceholder;

  /// No description provided for @editProfileFacebookLabel.
  ///
  /// In en, this message translates to:
  /// **'FACEBOOK'**
  String get editProfileFacebookLabel;

  /// No description provided for @editProfileFacebookPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://facebook.com/...'**
  String get editProfileFacebookPlaceholder;

  /// No description provided for @editProfileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSaveButton;

  /// No description provided for @editProfileLinkHttpsError.
  ///
  /// In en, this message translates to:
  /// **'Link must start with https://'**
  String get editProfileLinkHttpsError;

  /// No description provided for @editProfileInstagramDomainError.
  ///
  /// In en, this message translates to:
  /// **'Instagram link must contain instagram'**
  String get editProfileInstagramDomainError;

  /// No description provided for @editProfileFacebookDomainError.
  ///
  /// In en, this message translates to:
  /// **'Facebook link must contain facebook'**
  String get editProfileFacebookDomainError;

  /// No description provided for @profileMyEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get profileMyEventsTitle;

  /// No description provided for @profileMyEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events you have created and manage.'**
  String get profileMyEventsSubtitle;

  /// No description provided for @profileOrganizerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get profileOrganizerSectionTitle;

  /// No description provided for @profileOrganizerSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tools for verified event organizers.'**
  String get profileOrganizerSectionSubtitle;

  /// No description provided for @profileOrganizerCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get profileOrganizerCreateEvent;

  /// No description provided for @profileOrganizerCreateEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize something new.'**
  String get profileOrganizerCreateEventSubtitle;

  /// No description provided for @profileBecomeOrganizerTitle.
  ///
  /// In en, this message translates to:
  /// **'Become an organizer'**
  String get profileBecomeOrganizerTitle;

  /// No description provided for @profileBecomeOrganizerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get verified to create and manage events.'**
  String get profileBecomeOrganizerSubtitle;

  /// No description provided for @profileBecomeOrganizerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Organizer verification'**
  String get profileBecomeOrganizerDialogTitle;

  /// No description provided for @profileBecomeOrganizerDialogBody.
  ///
  /// In en, this message translates to:
  /// **'After submitting, your request will be reviewed by our team. You will be notified when the decision is made.'**
  String get profileBecomeOrganizerDialogBody;

  /// No description provided for @profileBecomeOrganizerDialogSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get profileBecomeOrganizerDialogSubmit;

  /// No description provided for @profileBecomeOrganizerDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileBecomeOrganizerDialogCancel;

  /// No description provided for @profileBecomeOrganizerRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Verification request sent.'**
  String get profileBecomeOrganizerRequestSent;

  /// No description provided for @profileBecomeOrganizerRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send verification request.'**
  String get profileBecomeOrganizerRequestFailed;

  /// No description provided for @profileOrganizerVerificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get profileOrganizerVerificationPendingTitle;

  /// No description provided for @profileOrganizerVerificationPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request is being reviewed by our team.'**
  String get profileOrganizerVerificationPendingSubtitle;

  /// No description provided for @profileOrganizerVerificationRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification rejected'**
  String get profileOrganizerVerificationRejectedTitle;

  /// No description provided for @profileOrganizerVerificationRejectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request was not approved.'**
  String get profileOrganizerVerificationRejectedSubtitle;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events and filters.'**
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
