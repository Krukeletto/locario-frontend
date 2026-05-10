// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authSubtitle => 'Discover local gems in your area';

  @override
  String get authGoogleContinue => 'Continue with Google';

  @override
  String get authDividerOr => 'OR';

  @override
  String get authEmailLabel => 'EMAIL';

  @override
  String get authEmailHint => 'your@email.com';

  @override
  String get authPasswordLabel => 'PASSWORD';

  @override
  String get authPasswordHint => '********';

  @override
  String get authFooterTerms => 'TERMS';

  @override
  String get authFooterPrivacy => 'PRIVACY';

  @override
  String get authFooterHelp => 'HELP';

  @override
  String get authLoginWelcome => 'Welcome back';

  @override
  String get authLoginSubmit => 'Sign in';

  @override
  String get authLoginNoAccount => 'Don\'t have an account yet?';

  @override
  String get authLoginCreateAccount => 'Create a free account';

  @override
  String get authLogoutSuccess => 'Signed out successfully.';

  @override
  String get authLoginSuccess => 'Logged in successfully.';

  @override
  String get authLoginErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authRegisterWelcome => 'Welcome';

  @override
  String get authRegisterUsernameLabel => 'USERNAME';

  @override
  String get authRegisterUsernameHint => 'your_username';

  @override
  String get authRegisterSubmit => 'Sign up';

  @override
  String get authRegisterHasAccount => 'Already have an account?';

  @override
  String get authRegisterSignIn => 'Sign in to your account';

  @override
  String get authValidationUsernameRequired => 'Enter username';

  @override
  String get authValidationUsernameMin3 =>
      'Username must be at least 3 characters';

  @override
  String get authValidationUsernameAllowed =>
      'Allowed: letters, numbers, . _ -';

  @override
  String get authValidationEmailRequired => 'Enter email address';

  @override
  String get authValidationEmailInvalid => 'Enter a valid email address';

  @override
  String get authValidationPasswordRequired => 'Enter password';

  @override
  String get authValidationPasswordMin8 =>
      'Password must be at least 8 characters';

  @override
  String get eventJazzTitle => 'Jazz in the Botanical Garden';

  @override
  String get eventSketchingTitle => 'Night sketching by the Vistula';

  @override
  String get eventRunClubTitle => 'Morning run club and coffee stop';

  @override
  String get eventStreetFoodTitle => 'Street food and vinyl market';

  @override
  String get eventDetailsScreenTitle => 'Details';

  @override
  String get eventDetailsImagePlaceholder => 'Temporary image placeholder';

  @override
  String get eventDetailsTitleLabel => 'Event title';

  @override
  String get eventDetailsLocationLabel => 'Location';

  @override
  String get eventDetailsDateLabel => 'Date';

  @override
  String get eventDetailsTimeLabel => 'Time';

  @override
  String get eventDetailsPriceLabel => 'Price';

  @override
  String get eventDetailsSeatsLabel => 'Seats';

  @override
  String get eventDetailsAboutLabel => 'About the event';

  @override
  String get eventDetailsOrganizerLabel => 'Organizer';

  @override
  String get eventDetailsChatLabel => 'Participants chat';

  @override
  String get eventDetailsBuyTicketButton => 'Buy ticket';

  @override
  String get eventDetailsJoinButton => 'Join';

  @override
  String get eventDetailsLeaveButton => 'Leave event';

  @override
  String get eventJoinSuccess => 'You\'re registered for this event.';

  @override
  String get eventLeaveSuccess => 'You\'ve left this event.';

  @override
  String get eventJoinError => 'Could not register for this event.';

  @override
  String get eventJoinRequiresLogin => 'Sign in to join this event.';

  @override
  String get eventDetailsUnknownEventTitle => 'Event';

  @override
  String get eventDetailsUnknownLocation => 'Location unknown';

  @override
  String get eventDetailsFallbackDescription =>
      'This is a temporary event description. In the next steps we will connect full data from the create event form and backend.';

  @override
  String get eventDetailsLoadingTitle => 'Loading event';

  @override
  String get eventDetailsLoadingSubtitle =>
      'We are fetching the event details from the backend.';

  @override
  String get eventDetailsErrorTitle => 'Event unavailable';

  @override
  String get eventDetailsErrorSubtitle =>
      'We could not load this event right now.';

  @override
  String get eventDetailsJazzDescription =>
      'An evening jazz concert under the open sky. Bring your friends, a blanket and a good mood.';

  @override
  String get eventDetailsSketchingDescription =>
      'A meetup for people who enjoy sketching and urban illustration. Bring your own materials.';

  @override
  String get eventDetailsRunClubDescription =>
      'A light morning run followed by coffee and networking. Conversational pace, everyone is welcome.';

  @override
  String get eventDetailsStreetFoodDescription =>
      'Street food, curated vinyl records and mini DJ sets. An all-day event.';

  @override
  String get eventDetailsTicketLabel => 'Tickets';

  @override
  String get eventDetailsSlotsLabel => 'Seat limit';

  @override
  String eventDetailsSlotsValue(int count) {
    return '$count seats available';
  }

  @override
  String eventSlotsTaken(int registered, int limit) {
    return '$registered / $limit taken';
  }

  @override
  String eventSlotsJoined(int count) {
    return '$count joined';
  }

  @override
  String get eventSlotsSoldOut => 'Sold out';

  @override
  String eventSlotsWaitlist(int count) {
    return '$count on waitlist';
  }

  @override
  String eventCardSpots(int count) {
    return '$count spots';
  }

  @override
  String get eventDetailsShowOnMapButton => 'Show on map';

  @override
  String get eventDetailsOpenMapError =>
      'We could not open the map app right now.';

  @override
  String get eventToday2030 => 'Today, 20:30';

  @override
  String get eventToday1900 => 'Today, 19:00';

  @override
  String get eventTomorrow0800 => 'Tomorrow, 08:00';

  @override
  String get eventTomorrow1200 => 'Tomorrow, 12:00';

  @override
  String get eventSaveSuccess => 'Event saved to your list.';

  @override
  String get eventRemoveSuccess => 'Event removed from your list.';

  @override
  String get eventPublishSuccess => 'Event published successfully.';

  @override
  String get eventPublishError => 'Failed to publish event. Try again.';

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
  String get exploreSearchHint => 'Search events...';

  @override
  String get exploreNearbyEvents => 'Nearby events';

  @override
  String exploreNearbyWithFilter(String filter) {
    return '$filter nearby';
  }

  @override
  String get exploreLoadingTitle => 'Loading events';

  @override
  String get exploreLoadingSubtitle =>
      'We are fetching the latest events, please wait.';

  @override
  String get exploreErrorTitle => 'Events unavailable';

  @override
  String get exploreErrorSubtitle => 'We could not load events right now.';

  @override
  String get exploreEmptyTitle => 'No events found';

  @override
  String get exploreEmptySubtitle => 'Try a different area or come back later.';

  @override
  String get exploreRetryButton => 'Retry';

  @override
  String get exploreErrorPermissionTitle => 'Location permission required';

  @override
  String get exploreErrorPermissionSubtitle =>
      'Please allow location access to see events nearby.';

  @override
  String get exploreErrorUnknownTitle => 'Something went wrong';

  @override
  String get exploreErrorUnknownSubtitle =>
      'We encountered an unexpected error.';

  @override
  String get exploreSearchThisArea => 'Search this area';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: '0 results',
    );
    return '$_temp0';
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
  String get distanceFilterTooltip => 'List range';

  @override
  String get distanceFilterAny => 'Anywhere';

  @override
  String distanceFilterWithinKm(int km) {
    return 'Within $km km';
  }

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
  String get filterAdvancedFilters => 'Advanced Filters';

  @override
  String get filterAdvancedDistance => 'Search Range';

  @override
  String get filterAdvancedDateRange => 'Event Date';

  @override
  String get filterAdvancedAge => 'Age (years)';

  @override
  String get filterAdvancedType => 'Event Type';

  @override
  String get filterAdvancedSource => 'Event Source';

  @override
  String get filterAdvancedApply => 'Show Results';

  @override
  String get filterAdvancedClear => 'Clear';

  @override
  String get filterAdvancedDateFrom => 'From';

  @override
  String get filterAdvancedDateTo => 'To';

  @override
  String get filterAdvancedDateAny => 'Any date';

  @override
  String get filterAdvancedDateToday => 'Today';

  @override
  String get filterAdvancedDateTomorrow => 'Tomorrow';

  @override
  String get filterAdvancedDateCustomRange => 'Date range';

  @override
  String get filterAdvancedDateOther => 'Other date';

  @override
  String get filterAdvancedDateSelection => 'Selected date';

  @override
  String get filterAdvancedAgeFrom => 'Min';

  @override
  String get filterAdvancedAgeTo => 'Max';

  @override
  String get filterAdvancedAgeSelection => 'Participant age';

  @override
  String get filterAdvancedAgeCustomRange => 'Age range';

  @override
  String get filterAdvancedAgeOther => 'Other age';

  @override
  String filterAdvancedAgeRangeSummary(int from, int to) {
    return '$from-$to years';
  }

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
  String get hubTitle => 'Hub';

  @override
  String get hubDescription =>
      'Shortcuts for creating and managing your local circle';

  @override
  String get hubCreateEventTitle => 'Create event';

  @override
  String get hubCreateEventSubtitle => 'Start something new';

  @override
  String get hubCreateEventNameLabel => 'Event name';

  @override
  String get hubCreateEventNameHint => 'What is your event called?';

  @override
  String get hubCreateEventCategoryLabel => 'Category';

  @override
  String get hubCreateEventLocationLabel => 'Location';

  @override
  String get hubCreateEventLocationHint => 'Where will the event take place?';

  @override
  String get hubCreateEventLocationLoadingLabel => 'Fetching your location';

  @override
  String get hubCreateEventLocationLoadingDescription =>
      'This may take a moment.';

  @override
  String get hubCreateEventDateLabel => 'Date';

  @override
  String get hubCreateEventDateHint => 'Choose a date';

  @override
  String get hubCreateEventDatePlaceholder => 'Choose a date';

  @override
  String get hubCreateEventTimeLabel => 'Time';

  @override
  String get hubCreateEventTimeHint => '--:--';

  @override
  String get hubCreateEventTimePlaceholder => 'Choose a time';

  @override
  String get hubCreateEventDescriptionLabel => 'Event description';

  @override
  String get hubCreateEventDescriptionHint => 'Tell people about your event...';

  @override
  String get hubCreateEventMainPhotoLabel => 'Add main photo';

  @override
  String get hubCreateEventPhotosLabel => 'Add photos';

  @override
  String get hubCreateEventMainPhotoSizeHint => 'Suggested size: 1600 x 900 px';

  @override
  String hubCreateEventSelectedPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos selected',
      one: '1 photo selected',
      zero: 'No photos selected',
    );
    return '$_temp0';
  }

  @override
  String get hubCreateEventPrimaryPhotoHint =>
      'Main photo (thumbnail). Drag to keep another image first.';

  @override
  String get hubCreateEventSecondaryPhotoHint =>
      'Additional photo. Drag to change order.';

  @override
  String get hubCreateEventTicketingTitle => 'Tickets and entry';

  @override
  String get hubCreateEventTicketingSwitchLabel =>
      'Enable tickets and seat limits';

  @override
  String get hubCreateEventTicketSeatsLabel => 'Number of seats';

  @override
  String get hubCreateEventTicketPriceLabel => 'Ticket price';

  @override
  String get hubCreateEventTicketingLabel => 'Ticketing';

  @override
  String get hubCreateEventTicketUrlHint => 'URL for buying tickets';

  @override
  String get hubCreateEventStatusLabel => 'Event status';

  @override
  String get eventStatusDraft => 'Draft';

  @override
  String get eventStatusPublished => 'Live';

  @override
  String get hubCreateEventSubmitButton => 'Create event';

  @override
  String get hubCreateEventSubmitDisabledHint =>
      'Creating events is temporarily disabled until login is wired into the app.';

  @override
  String get hubCreateEventValidationMinChars3 =>
      'Enter at least 3 characters.';

  @override
  String get hubCreateEventValidationRequired => 'This field is required.';

  @override
  String get hubCreateEventValidationDescriptionMin10 =>
      'Description should be at least 10 characters.';

  @override
  String get hubCreateEventValidationCategoryRequired =>
      'Choose at least one category.';

  @override
  String get hubCreateEventValidationPositiveNumber =>
      'Enter a valid positive number.';

  @override
  String get hubCreateEventValidationDateTimeRequired =>
      'Choose the event date and time.';

  @override
  String get hubCreateEventValidationLocationRequired =>
      'Choose the event location.';

  @override
  String get hubCreateEventCreatedSuccess => 'Event has been created.';

  @override
  String get hubCreateEventCreateFailed =>
      'Event could not be created. Try again.';

  @override
  String get hubCreateEventLocationLookupFailed =>
      'We couldn\'t resolve that location. Try another address or point on the map.';

  @override
  String get hubMessagesTitle => 'Messages';

  @override
  String get hubMessagesSubtitle => 'Direct messages';

  @override
  String get hubCommunityTitle => 'Community';

  @override
  String get hubCommunitySubtitle => 'Local updates';

  @override
  String get hubFriendsTitle => 'Friends';

  @override
  String get hubFriendsSubtitle => 'Your network';

  @override
  String get inboxEmpty => 'No notifications yet';

  @override
  String get inboxMarkAllRead => 'Mark all as read';

  @override
  String get notificationSettingsTitle => 'Push Notifications';

  @override
  String get notificationSettingsSubtitle =>
      'Choose which notifications you want to receive';

  @override
  String get notificationTypeUpcomingEvent => 'Upcoming events';

  @override
  String get notificationTypeUpcomingEventDesc =>
      'Reminders before saved events start';

  @override
  String get notificationTypeExpiredEvent => 'Expired events';

  @override
  String get notificationTypeExpiredEventDesc =>
      'When a saved event has passed';

  @override
  String get notificationTypeEventPublished => 'New events';

  @override
  String get notificationTypeEventPublishedDesc =>
      'When new events are published nearby';

  @override
  String get notificationTypeSystemMessage => 'System messages';

  @override
  String get notificationTypeSystemMessageDesc =>
      'Important updates from the app';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDescription =>
      'Account, preferences and your saved places in one calmer section.';

  @override
  String get profileAuthLoginTitle => 'Sign in';

  @override
  String get profileAuthLoginSubtitle => 'Go to the login screen';

  @override
  String get profileAuthLogoutTitle => 'Sign out';

  @override
  String get profileAuthLogoutSubtitle => 'End the current session';

  @override
  String get profileInboxSubtitle => 'Open your notifications';

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
  String get savedTitle => 'Saved';

  @override
  String get savedSubtitle => 'Places, events and lists you want to revisit';

  @override
  String get savedSaveAction => 'Save event';

  @override
  String get savedRemoveAction => 'Remove saved';

  @override
  String get savedSaveActionTooltip => 'Save event';

  @override
  String get savedRemoveActionTooltip => 'Remove from saved';

  @override
  String get savedSortTooltip => 'Saved sort';

  @override
  String get savedSortRecent => 'Recently saved';

  @override
  String get savedSortDistance => 'Distance';

  @override
  String get savedFiltersTooltip => 'Saved filters';

  @override
  String get savedFiltersTitle => 'Saved filters';

  @override
  String get savedFiltersClear => 'Clear';

  @override
  String get savedFiltersApply => 'Apply';

  @override
  String get savedFilterCategoriesTitle => 'Categories';

  @override
  String get savedFilterAgeTitle => 'Age groups';

  @override
  String get savedFilterTagsTitle => 'Tags';

  @override
  String get savedAgeGroupAny => 'Any age';

  @override
  String get savedAgeGroup12Plus => '12+';

  @override
  String get savedAgeGroup18Plus => '18+';

  @override
  String get savedShowPastEvents => 'Show past events';

  @override
  String get savedEmptyTitle => 'No saved events yet';

  @override
  String get savedEmptySubtitle =>
      'Save events from Explore to keep them here.';

  @override
  String get savedEmptyFilteredTitle => 'No events match the filters';

  @override
  String get savedEmptyFilteredSubtitle =>
      'Clear the filters or try a different combination.';

  @override
  String get savedEventsTab => 'Events';

  @override
  String get savedFiltersTab => 'Filters';

  @override
  String get savedFiltersEmptyTitle => 'No saved filters yet';

  @override
  String get savedFiltersEmptySubtitle =>
      'Custom filter presets you create will appear here.';

  @override
  String get savedFiltersSaveDialogTitle => 'Save filter';

  @override
  String get savedFiltersSaveAction => 'Save';

  @override
  String get savedFiltersNameHint => 'Filter name';

  @override
  String get savedFiltersDeleteTooltip => 'Delete filter';

  @override
  String get savedFiltersLoadTooltip => 'Use filter';

  @override
  String get savedFilterNotificationsLabel => 'Notifications';

  @override
  String get savedFilterNotificationsTooltip =>
      'Enable notifications for this filter';

  @override
  String get savedFiltersLocationCurrent => 'Current location';

  @override
  String get savedFiltersLocationSaved => 'Saved location';

  @override
  String get savedFiltersUseCurrentLocation => 'Use current location';

  @override
  String get savedFiltersUseSavedLocation => 'Use saved location';

  @override
  String get savedFiltersSaveConfirmation => 'Filter saved';

  @override
  String get savedFiltersDeleteConfirmation => 'Filter deleted';

  @override
  String get savedFiltersLoadConfirmation => 'Filter applied';

  @override
  String get savedFiltersCreateButton => 'Save current filters';

  @override
  String get savedFiltersCancel => 'Cancel';

  @override
  String get savedFiltersLocationLabel => 'Location';

  @override
  String get appTitle => 'Locario';

  @override
  String get localeEnglish => 'English';

  @override
  String get localePolish => 'Polish';

  @override
  String get featureComingSoon => 'This section is still being built.';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get networkErrorRetry => 'Retry';

  @override
  String shareEventMessage(String title, String url) {
    return 'Check out this event on Locario: $title\n\n$url';
  }

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
