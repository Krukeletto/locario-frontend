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
  String get eventDetailsEndDateLabel => 'End date';

  @override
  String get eventDetailsStartTimeLabel => 'Start';

  @override
  String get eventDetailsEndTimeLabel => 'End';

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
  String get eventOrganizerRatingLabel => 'Organizer rating';

  @override
  String eventOrganizerRatingValue(String average, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$average/5 · $_temp0';
  }

  @override
  String get eventOrganizerRatingEmpty => 'No organizer reviews yet';

  @override
  String get eventDetailsBuyTicketButton => 'Buy ticket';

  @override
  String get eventDetailsJoinButton => 'Join';

  @override
  String get eventDetailsLeaveButton => 'Leave event';

  @override
  String get eventDetailsReviewButton => 'Write a review';

  @override
  String get eventEditAction => 'Edit';

  @override
  String get eventEditScreenTitle => 'Edit event';

  @override
  String get eventEditSubmitButton => 'Save changes';

  @override
  String get eventUpdateSuccess => 'Event updated successfully.';

  @override
  String get eventJoinSuccess => 'You\'re registered for this event.';

  @override
  String get eventLeaveSuccess => 'You\'ve left this event.';

  @override
  String get eventJoinError => 'Could not register for this event.';

  @override
  String get eventJoinRequiresLogin => 'Sign in to join this event.';

  @override
  String get eventCalendarPromptTitle => 'Add to calendar?';

  @override
  String get eventCalendarPromptBody =>
      'You can add this event now or later from the event details screen. The calendar will open with the details already filled in.';

  @override
  String get eventCalendarPromptAddNow => 'Add now';

  @override
  String get eventCalendarPromptLater => 'Later';

  @override
  String get eventDetailsAddToCalendarButton => 'Add to calendar';

  @override
  String get eventAddToCalendarSuccess => 'Event added to your calendar.';

  @override
  String get eventAddToCalendarError =>
      'Could not add the event to your calendar.';

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
  String get eventReviewScreenTitle => 'Write a review';

  @override
  String get eventReviewLoadingTitle => 'Loading review';

  @override
  String get eventReviewLoadingSubtitle =>
      'We are preparing the review form and event details.';

  @override
  String get eventReviewErrorTitle => 'Review unavailable';

  @override
  String get eventReviewErrorSubtitle =>
      'We could not load the review screen right now.';

  @override
  String get eventReviewFormTitle => 'Your opinion';

  @override
  String get eventReviewFormSubtitle =>
      'Choose a rating and add an optional comment.';

  @override
  String get eventReviewLockedSubtitle =>
      'You can review this event after it ends and only if you joined it.';

  @override
  String get eventReviewCommentLabel => 'Comment';

  @override
  String get eventReviewCommentHint => 'What stood out?';

  @override
  String get eventReviewSubmitButton => 'Send review';

  @override
  String get eventReviewSubmittedButton => 'Review sent';

  @override
  String get eventReviewSubmittedLabel => 'Your review has been saved.';

  @override
  String get eventReviewEligibilityHint =>
      'Only joined participants can review after the event ends.';

  @override
  String get eventReviewSuccess => 'Review sent successfully.';

  @override
  String get eventReviewError => 'We could not send your review.';

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
  String get groupsDiscoverTitle => 'Groups';

  @override
  String get groupsLoadingTitle => 'Loading groups';

  @override
  String get groupsLoadingSubtitle => 'We are fetching communities for you.';

  @override
  String get groupsErrorTitle => 'Could not load groups';

  @override
  String get groupsErrorSubtitle => 'Try again in a moment.';

  @override
  String get groupsCreateCta => 'Create group';

  @override
  String get groupsMyGroupsTab => 'My groups';

  @override
  String get groupsMyGroupsTitle => 'My groups';

  @override
  String get groupsMyGroupsSubtitle => 'Communities you already belong to.';

  @override
  String get groupsMyGroupsEmptyTitle => 'No groups yet';

  @override
  String get groupsMyGroupsEmptySubtitle =>
      'Join a public group to see it here.';

  @override
  String get groupsDiscoverTab => 'Discover';

  @override
  String get groupsDiscoverPublicTitle => 'Public groups';

  @override
  String get groupsDiscoverPublicSubtitle =>
      'Browse communities that are open to discovery.';

  @override
  String get groupsDiscoverEmptyTitle => 'No groups found';

  @override
  String get groupsDiscoverEmptySubtitle =>
      'Try a different phrase or category.';

  @override
  String get groupsSearchHint => 'Search groups';

  @override
  String get groupsCategoryAll => 'All categories';

  @override
  String get groupsCategoryUnknown => 'No category';

  @override
  String get groupsVisibilityPublic => 'Public';

  @override
  String get groupsVisibilityPrivate => 'Private';

  @override
  String groupsMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get groupsMembershipActive => 'Member';

  @override
  String get groupsMembershipPending => 'Pending';

  @override
  String get groupsMembershipBanned => 'Banned';

  @override
  String get groupsCreateTitle => 'Create group';

  @override
  String get groupsEditTitle => 'Edit group';

  @override
  String get groupsEditForbidden =>
      'You do not have permission to edit this group.';

  @override
  String get groupsFieldName => 'Group name';

  @override
  String get groupsFieldDescription => 'Description';

  @override
  String get groupsFieldCategory => 'Category';

  @override
  String get groupsFieldAvatarUrl => 'Avatar URL';

  @override
  String get groupsFieldIconUrl => 'Icon URL';

  @override
  String get groupsFieldMapPinIconUrl => 'Map pin icon URL';

  @override
  String get groupsFieldMapPinStyle => 'Map pin style';

  @override
  String get groupsCategoryNone => 'No category';

  @override
  String get groupsAdvancedTitle => 'Advanced settings';

  @override
  String get groupsAdvancedSubtitle =>
      'Optional visual settings from the backend contract.';

  @override
  String get groupsCreateSubmit => 'Create group';

  @override
  String get groupsSaveChanges => 'Save changes';

  @override
  String get groupsValidationNameRequired => 'Enter a group name.';

  @override
  String get groupsValidationNameTooLong =>
      'The name can be at most 255 characters.';

  @override
  String get groupsValidationDescriptionTooLong =>
      'The description can be at most 5000 characters.';

  @override
  String get groupsValidationMapPinStyleTooLong =>
      'The map pin style can be at most 50 characters.';

  @override
  String get groupsValidationUrlTooLong =>
      'The URL can be at most 2048 characters.';

  @override
  String get groupsValidationUrlInvalid => 'Enter a valid URL.';

  @override
  String get groupsJoinAction => 'Join group';

  @override
  String get groupsLeaveAction => 'Leave group';

  @override
  String get groupsPendingAction => 'Cancel request';

  @override
  String get groupsTabFeed => 'Feed';

  @override
  String get groupsTabMembers => 'Members';

  @override
  String get groupsTabEvents => 'Events';

  @override
  String get groupsTabManage => 'Manage';

  @override
  String get groupsTabInfo => 'Info';

  @override
  String get groupsFeedEmptyTitle => 'No feed yet';

  @override
  String get groupsFeedEmptySubtitle =>
      'Posts and events linked to this group will appear here.';

  @override
  String get groupsFeedPostLabel => 'Post';

  @override
  String get groupsFeedEventLabel => 'Event';

  @override
  String get groupsFeedPostFallbackAuthor => 'Unknown author';

  @override
  String get groupsFeedEventFallbackTitle => 'Group event';

  @override
  String get groupsPostCreateAction => 'Write post';

  @override
  String get groupsPostCreateTitle => 'New post';

  @override
  String get groupsPostEditTitle => 'Edit post';

  @override
  String get groupsPostHint => 'What do you want to share with the group?';

  @override
  String get groupsPostPublish => 'Publish';

  @override
  String get groupsEditAction => 'Edit';

  @override
  String get groupsDeleteAction => 'Delete';

  @override
  String get groupsHideAction => 'Hide';

  @override
  String get groupsReportAction => 'Report';

  @override
  String get groupsOpenEventAction => 'Open event';

  @override
  String get groupsJoinRequestsTitle => 'Join requests';

  @override
  String get groupsApproveAction => 'Approve';

  @override
  String get groupsRejectAction => 'Reject';

  @override
  String get groupsMembersEmptyTitle => 'No members';

  @override
  String get groupsMembersEmptySubtitle =>
      'Members will appear here after people join.';

  @override
  String get groupsMemberOwner => 'Owner';

  @override
  String get groupsMemberAdmin => 'Admin';

  @override
  String get groupsMemberRegular => 'Member';

  @override
  String get groupsMakeAdminAction => 'Make admin';

  @override
  String get groupsMakeMemberAction => 'Make member';

  @override
  String get groupsBanAction => 'Ban';

  @override
  String get groupsUnbanAction => 'Unban';

  @override
  String get groupsRemoveMemberAction => 'Remove member';

  @override
  String get groupsTransferOwnershipAction => 'Transfer ownership';

  @override
  String get groupsCreateEventAction => 'Create event for group';

  @override
  String get groupsLinkExistingEventAction => 'Link existing event';

  @override
  String get groupsUnlinkEventAction => 'Unlink event';

  @override
  String get groupsEventsEmptyTitle => 'No events yet';

  @override
  String get groupsEventsEmptySubtitle =>
      'Create or link an event to start the group timeline.';

  @override
  String get groupsManageRestrictedTitle => 'Restricted section';

  @override
  String get groupsManageRestrictedSubtitle =>
      'Only the owner and group admins can manage reports and members.';

  @override
  String get groupsReportsEmptyTitle => 'No reports';

  @override
  String get groupsReportsEmptySubtitle => 'New reports will appear here.';

  @override
  String get groupsResolveAction => 'Resolve';

  @override
  String get groupsReportGroupAction => 'Report group';

  @override
  String get groupsReportGroupTitle => 'Report group';

  @override
  String get groupsReportPostTitle => 'Report post';

  @override
  String get groupsReportEventTitle => 'Report event';

  @override
  String get groupsReportReasonLabel => 'Reason';

  @override
  String get groupsReportDescriptionLabel => 'Description';

  @override
  String get groupsReportSubmit => 'Send report';

  @override
  String get groupsConfirmAction => 'Confirm';

  @override
  String get groupsDeleteGroupTitle => 'Delete group';

  @override
  String get groupsDeleteGroupBody =>
      'The group will be deleted for members and removed from discovery.';

  @override
  String get groupsDeletePostTitle => 'Delete post';

  @override
  String get groupsDeletePostBody =>
      'This post will disappear from the group feed.';

  @override
  String get groupsActionFailed => 'The action could not be completed.';

  @override
  String get groupsEventGroupsLabel => 'Linked groups';

  @override
  String get groupsEventGroupsOptionalHint =>
      'Leave empty to create a public event, or select groups to attach it.';

  @override
  String get groupsEventGroupsRequiredHint =>
      'Select at least one group. As a regular member you can only create group events.';

  @override
  String get groupsEventGroupsEmpty =>
      'You are not an active member of any group yet.';

  @override
  String get groupsEventValidationGroupRequired =>
      'Select at least one group for this event.';

  @override
  String get groupsEventValidationSlotLimitRequired =>
      'Regular members must set a positive slot limit.';

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
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalTermsContent =>
      'These Terms of Service (\"Terms\") govern your use of the Locario mobile application and related services. By using Locario, you agree to these Terms. If you do not agree, do not use the app.\n\n1. Account Registration.\nYou must provide accurate information when creating an account. You are responsible for maintaining the confidentiality of your login credentials.\n\n2. Acceptable Use.\nYou agree not to misuse the app, including but not limited to impersonating others, submitting false event information, or engaging in any activity that disrupts the platform.\n\n3. Content.\nYou retain ownership of the content you submit. We reserve the right to remove content that violates these Terms.\n\n4. Limitation of Liability.\nLocario and its affiliates are not liable for indirect damages arising from your use of the app.\n\n5. Changes.\nWe may update these Terms. Continued use after changes constitutes acceptance.\n\n6. Contact.\nFor questions, contact us at locario.app@gmail.com.\n\nLast updated: May 2026.';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalPrivacyContent =>
      'Your privacy matters to us. This Privacy Policy explains how we collect, use, and protect your personal data when you use Locario.\n\n1. Data We Collect.\nWe collect information you provide (username, email, profile data) and automatically collected data (device info, location when enabled, usage analytics).\n\n2. How We Use Data.\nWe use your data to operate the app, personalize content, send notifications (with your consent), and improve our services.\n\n3. Data Sharing.\nWe do not sell your data. We may share it with service providers who help operate our platform, under strict confidentiality agreements.\n\n4. Your Rights.\nYou can access, correct, or delete your data at any time through your profile settings or by contacting us.\n\n5. Data Retention.\nWe retain your data as long as your account is active. After deletion, we keep anonymized data for analytics.\n\n6. Security.\nWe implement industry-standard measures to protect your data.\n\n7. Contact.\nlocario.app@gmail.com\n\nLast updated: May 2026.';

  @override
  String get legalHelpTitle => 'Help & Support';

  @override
  String get legalHelpSectionFaq => 'Frequently Asked Questions';

  @override
  String get legalHelpFaqContent =>
      'Q: How do I create an event?\nA: Tap the + button from the hub panel and follow the event creation form.\n\nQ: How can I change my password?\nA: Go to Profile → Settings → Password and enter your current and new password.\n\nQ: I forgot my password.\nA: Use the \"Forgot password\" option on the login screen.\n\nQ: How do I report an issue?\nA: Send an email to locario.app@gmail.com with details about your problem.';

  @override
  String get legalHelpSectionContact => 'Contact Us';

  @override
  String get legalHelpContactContent =>
      'Need further assistance? Reach out to us:\n\nEmail: locario.app@gmail.com\n\nWe aim to respond within 24-48 hours on business days.';

  @override
  String get legalConsentsTitle => 'Your Consents';

  @override
  String get legalConsentsSectionTitle => 'Privacy Consents';

  @override
  String get legalConsentsSectionSubtitle =>
      'Manage what you agree to share with us. You can change these anytime.';

  @override
  String get consentTypeMarketingEmails => 'Marketing emails';

  @override
  String get consentTypeMarketingEmailsDesc =>
      'Receive promotional offers, event suggestions, and news about Locario';

  @override
  String get consentTypeDataProcessing => 'Data processing';

  @override
  String get consentTypeDataProcessingDesc =>
      'Allow us to analyze your usage to improve the app experience';

  @override
  String get consentTypeLocationData => 'Location data';

  @override
  String get consentTypeLocationDataDesc =>
      'Share precise location to discover nearby events and personalized recommendations';

  @override
  String get settingsLegalSectionTitle => 'Legal & Policies';

  @override
  String get settingsLegalSectionSubtitle =>
      'Terms of service, privacy, and help resources';

  @override
  String get settingsLegalTerms => 'Terms of Service';

  @override
  String get settingsLegalPrivacy => 'Privacy Policy';

  @override
  String get settingsLegalHelp => 'Help & Support';

  @override
  String get settingsConsentsSectionTitle => 'Your Consents';

  @override
  String get settingsConsentsSectionSubtitle =>
      'Manage your privacy preferences';

  @override
  String get legalAcceptanceTitle => 'Updated Terms & Privacy';

  @override
  String get legalAcceptanceSubtitle =>
      'We have updated our legal documents. Please review and accept the changes to continue using Locario.';

  @override
  String get legalAcceptanceTermsTitle => 'Terms of Service';

  @override
  String get legalAcceptancePrivacyTitle => 'Privacy Policy';

  @override
  String get legalAcceptanceButton => 'Accept & Continue';

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
  String get profileDescription => 'Account, preferences and saved places.';

  @override
  String get profileAuthLoginTitle => 'Sign in';

  @override
  String get profileAuthLoginSubtitle => 'Go to the login screen';

  @override
  String get profileAuthLogoutTitle => 'Sign out';

  @override
  String get profileAuthLogoutSubtitle => 'End the current session';

  @override
  String get profileOrganizerRatingsTitle => 'Organizer ratings';

  @override
  String get profileOrganizerRatingsLoading => 'Loading your ratings';

  @override
  String get profileOrganizerRatingsEmpty => 'No reviews yet';

  @override
  String profileOrganizerRatingsValue(String average, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$average/5 · $_temp0';
  }

  @override
  String get profileOrganizerReviewsScreenTitle => 'Organizer reviews';

  @override
  String get profileOrganizerReviewsLoadingTitle => 'Loading reviews';

  @override
  String get profileOrganizerReviewsLoadingSubtitle =>
      'We are gathering reviews from your events.';

  @override
  String get profileOrganizerReviewsEmptyTitle => 'No reviews yet';

  @override
  String get profileOrganizerReviewsEmptySubtitle =>
      'Reviews from events you organize will appear here.';

  @override
  String get profileOrganizerReviewsSummaryTitle => 'Your organizer score';

  @override
  String get profileEventHistoryTitle => 'Event archive';

  @override
  String get profileEventHistorySubtitle => 'Your event history.';

  @override
  String get profileEventHistoryEmptyTitle => 'No joined events yet';

  @override
  String get profileEventHistoryEmptySubtitle =>
      'Joined events will appear here after you register.';

  @override
  String get profileEventHistoryCurrentSectionTitle => 'Current';

  @override
  String get profileEventHistoryPastSectionTitle => 'Past';

  @override
  String get profileEventHistoryOpenEvent => 'Open event';

  @override
  String get profileInboxSubtitle => 'Open your notifications';

  @override
  String get profileBioPlaceholder => 'No bio yet.';

  @override
  String get profileLinksLabel => 'Links';

  @override
  String get profileLinksPlaceholder => 'No links yet.';

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
  String get settingsAccountSectionTitle => 'Password';

  @override
  String get settingsAccountSectionSubtitle => 'Update your password';

  @override
  String get settingsAccountChangePassword => 'Change password';

  @override
  String get settingsChangePasswordDialogTitle => 'Change password';

  @override
  String get settingsChangePasswordCurrentLabel => 'Current password';

  @override
  String get settingsChangePasswordNewLabel => 'New password';

  @override
  String get settingsChangePasswordCancel => 'Cancel';

  @override
  String get settingsChangePasswordSubmit => 'Update password';

  @override
  String get settingsChangePasswordSuccess => 'Password updated.';

  @override
  String get settingsChangePasswordInvalidOld =>
      'Current password is incorrect.';

  @override
  String get settingsChangePasswordFailed => 'Could not update password.';

  @override
  String get profileUpdateSuccess => 'Profile updated.';

  @override
  String get profileUpdateFailed => 'Could not update profile.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileChangePhoto => 'Change photo';

  @override
  String get editProfileUsernameLabel => 'USERNAME';

  @override
  String get editProfileUsernamePlaceholder => 'Your username';

  @override
  String get editProfileBioLabel => 'BIO';

  @override
  String get editProfileBioPlaceholder => 'Tell us about yourself';

  @override
  String get editProfileWebsiteLabel => 'WEBSITE';

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
  String get editProfileSaveButton => 'Save changes';

  @override
  String get editProfileLinkHttpsError => 'Link must start with https://';

  @override
  String get editProfileInstagramDomainError =>
      'Instagram link must contain instagram';

  @override
  String get editProfileFacebookDomainError =>
      'Facebook link must contain facebook';

  @override
  String get profileMyEventsTitle => 'My events';

  @override
  String get profileMyEventsSubtitle => 'Events you have created and manage.';

  @override
  String get profileOrganizerSectionTitle => 'Organizer';

  @override
  String get profileOrganizerSectionSubtitle =>
      'Tools for verified event organizers.';

  @override
  String get profileOrganizerCreateEvent => 'Create event';

  @override
  String get profileOrganizerCreateEventSubtitle => 'Organize something new.';

  @override
  String get profileBecomeOrganizerTitle => 'Become an organizer';

  @override
  String get profileBecomeOrganizerSubtitle =>
      'Get verified to create and manage events.';

  @override
  String get profileBecomeOrganizerDialogTitle => 'Organizer verification';

  @override
  String get profileBecomeOrganizerDialogBody =>
      'After submitting, your request will be reviewed by our team. You will be notified when the decision is made.';

  @override
  String get profileBecomeOrganizerDialogSubmit => 'Submit request';

  @override
  String get profileBecomeOrganizerDialogCancel => 'Cancel';

  @override
  String get profileBecomeOrganizerRequestSent => 'Verification request sent.';

  @override
  String get profileBecomeOrganizerRequestFailed =>
      'Could not send verification request.';

  @override
  String get profileOrganizerVerificationPendingTitle => 'Verification pending';

  @override
  String get profileOrganizerVerificationPendingSubtitle =>
      'Your request is being reviewed by our team.';

  @override
  String get profileOrganizerVerificationRejectedTitle =>
      'Verification rejected';

  @override
  String get profileOrganizerVerificationRejectedSubtitle =>
      'Your request was not approved.';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedSubtitle => 'Events and filters.';

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
