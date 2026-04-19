import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/events/event_repository.dart';
import '../../../shared/events/event_refresh_signal.dart';
import '../../../shared/location/location_service.dart';
import '../../../shared/services/feedback_service.dart';
import '../../explore/widgets/area_picker.dart';
import 'create_event_controller.dart';
import 'create_event_location_controller.dart';
import 'create_event_state.dart';
import 'event_map_picker_screen.dart';
import 'widgets/basic_info_section.dart';
import 'widgets/form/categories_section.dart';
import 'widgets/form/date_time_section.dart';
import 'widgets/form/location_section.dart';
import 'widgets/form/status_section.dart';
import 'widgets/form/ticketing_section.dart';
import 'widgets/form_primitives.dart';
import 'widgets/image_picker_tile.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    EventRepository? eventRepository,
    LocationService? locationService,
    CreateEventGeocoder? geocoder,
    EventRefreshSignal? eventRefreshSignal,
  }) : _eventRepository = eventRepository,
       _locationService = locationService,
       _geocoder = geocoder,
       _eventRefreshSignal = eventRefreshSignal;

  final EventRepository? _eventRepository;
  final LocationService? _locationService;
  final CreateEventGeocoder? _geocoder;
  final EventRefreshSignal? _eventRefreshSignal;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late final CreateEventController _controller;
  late final CreateEventLocationController _locationController;
  late final EventRefreshSignal _eventRefreshSignal;
  late final LocationService _locationService;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationService = widget._locationService ?? GeolocatorLocationService();
    _eventRefreshSignal =
        widget._eventRefreshSignal ?? globalEventRefreshSignal;
    _controller = CreateEventController(
      eventRepository: widget._eventRepository ?? HttpEventRepository(),
    );
    _locationController = CreateEventLocationController(
      locationService: _locationService,
      geocoder: widget._geocoder,
    );

    _controller.addListener(_handleStateChanged);
    _locationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChanged);
    _controller.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    final state = _controller.state;
    if (state.status == CreateEventFormStatus.success) {
      FeedbackService.showSuccess(FeedbackMessage.eventCreated);
      _eventRefreshSignal.notifyChanged();
      Navigator.of(context).maybePop();
    } else if (state.status == CreateEventFormStatus.error) {
      FeedbackService.showError(FeedbackMessage.unknownError);
    }
    setState(() {});
  }

  void _clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _pickDate() async {
    _clearFocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _controller.state.selectedDate ?? now,
    );

    if (mounted && picked != null) {
      _controller.updateDate(picked);
    }
  }

  Future<void> _pickTime() async {
    _clearFocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _controller.state.selectedTime ?? DateTime.now(),
      ),
    );

    if (mounted && picked != null) {
      final now = DateTime.now();
      final time = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      _controller.updateTime(time);
    }
  }

  Future<void> _handleLocationPressed() async {
    _clearFocus();
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<ExploreAreaSelectionAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => ExploreAreaSelectionSheet(
        title: l10n.areaPickerTitle,
        subtitle: l10n.areaPickerSubtitle,
        onActionSelected: (action) => Navigator.of(context).pop(action),
      ),
    );

    if (!mounted || action == null) return;

    CreateEventLocationLookupResult? result;
    switch (action) {
      case ExploreAreaSelectionAction.currentLocation:
        result = await _locationController.useCurrentLocation();
        break;
      case ExploreAreaSelectionAction.enterAddress:
        final address = await showDialog<String>(
          context: context,
          builder: (context) => const ExploreAddressInputDialog(),
        );
        if (address != null && address.isNotEmpty) {
          result = await _locationController.selectAddress(address);
        }
        break;
      case ExploreAreaSelectionAction.pickOnMap:
        final center = await Navigator.of(context).push<LatLng>(
          MaterialPageRoute(
            builder: (_) =>
                EventMapPickerScreen(locationService: _locationService),
          ),
        );
        if (center != null) {
          _locationController.selectPinnedLocation(center);
        }
        break;
    }

    if (mounted && _locationController.selection != null) {
      final selection = _locationController.selection!;
      _controller.updateLocation(selection.label, selection.coordinates);
    } else if (mounted &&
        result != null &&
        result.status != CreateEventLocationLookupStatus.success) {
      FeedbackService.showError(FeedbackMessage.networkError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final state = _controller.state;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(context, l10n, scheme, theme),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _clearFocus,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            CreateEventSection(
              child: Column(
                children: [
                  CreateEventImagePickerTile(
                    label: l10n.hubCreateEventMainPhotoLabel,
                    subtitle: l10n.hubCreateEventMainPhotoSizeHint,
                    imageUrl: state.thumbnailUrl,
                    onTap: () async {
                      final url = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller =
                              TextEditingController(text: state.thumbnailUrl);
                          return AlertDialog(
                            title: Text(l10n.hubCreateEventMainPhotoLabel),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'https://example.com/image.jpg',
                                labelText: l10n.hubCreateEventMainPhotoLabel,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(MaterialLocalizations.of(
                                  context,
                                ).cancelButtonLabel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, controller.text),
                                child: Text(MaterialLocalizations.of(
                                  context,
                                ).okButtonLabel),
                              ),
                            ],
                          );
                        },
                      );
                      if (url != null) {
                        _controller.updateThumbnailUrl(url);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CreateEventBasicInfoSection(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    titleError: state.titleError,
                    descriptionError: state.descriptionError,
                    onTitleChanged: _controller.updateTitle,
                    onDescriptionChanged: _controller.updateDescription,
                  ),
                  const SizedBox(height: 16),
                  CreateEventCategoriesSection(
                    state: state,
                    onCategoryToggled: _controller.toggleCategory,
                  ),
                  const SizedBox(height: 16),
                  CreateEventDateTimeSection(
                    state: state,
                    onPickDate: _pickDate,
                    onPickTime: _pickTime,
                  ),
                  const SizedBox(height: 16),
                  CreateEventLocationSection(
                    state: state,
                    locationController: _locationController,
                    onLocationPressed: _handleLocationPressed,
                  ),
                  const SizedBox(height: 16),
                  CreateEventTicketingSection(
                    state: state,
                    seatsController: _seatsController,
                    onTicketUrlChanged: _controller.updateTicketUrl,
                    onSlotLimitChanged: _controller.updateSlotLimit,
                  ),
                  const SizedBox(height: 16),
                  CreateEventStatusSection(
                    state: state,
                    onStatusChanged: _controller.updateStatus,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.status == CreateEventFormStatus.submitting
                  ? null
                  : () => _controller.submit(),
              child: state.status == CreateEventFormStatus.submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.hubCreateEventSubmitButton),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return AppBar(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.hubCreateEventTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}
