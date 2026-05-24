import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/events/category_scope.dart';
import '../../../shared/events/event_repository.dart';
import '../../../shared/events/event_refresh_signal.dart';
import '../../../shared/location/location_service.dart';
import '../../../shared/services/feedback_service.dart';
import '../../../shared/services/l10n_service.dart';
import '../../../shared/widgets/state_panel.dart';
import '../../explore/models.dart';
import '../../explore/widgets/area_picker.dart';
import '../create_event/create_event_location_controller.dart';
import '../create_event/create_event_state.dart';
import '../create_event/event_map_picker_screen.dart';
import '../create_event/widgets/basic_info_section.dart';
import '../create_event/widgets/form/categories_section.dart';
import '../create_event/widgets/form/date_time_section.dart';
import '../create_event/widgets/form/location_section.dart';
import '../create_event/widgets/form/status_section.dart';
import '../create_event/widgets/form/ticketing_section.dart';
import '../create_event/widgets/form_primitives.dart';
import '../create_event/widgets/image_picker_tile.dart';

class EditEventPickedFile {
  const EditEventPickedFile({required this.bytes, required this.fileName});

  final List<int> bytes;
  final String fileName;
}

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({
    super.key,
    required this.eventId,
    EventRepository? eventRepository,
    LocationService? locationService,
    CreateEventGeocoder? geocoder,
    EventRefreshSignal? eventRefreshSignal,
    Future<List<EditEventPickedFile>> Function()? pickImageFiles,
  }) : _eventRepository = eventRepository,
       _locationService = locationService,
       _geocoder = geocoder,
       _eventRefreshSignal = eventRefreshSignal,
       _pickImageFiles = pickImageFiles;

  final String eventId;
  final EventRepository? _eventRepository;
  final LocationService? _locationService;
  final CreateEventGeocoder? _geocoder;
  final EventRefreshSignal? _eventRefreshSignal;
  final Future<List<EditEventPickedFile>> Function()? _pickImageFiles;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final EditEventController _controller;
  late final CreateEventLocationController _locationController;
  late final EventRefreshSignal _eventRefreshSignal;
  late final LocationService _locationService;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ticketUrlController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  Future<ExploreEvent?>? _eventFuture;

  @override
  void initState() {
    super.initState();
    _locationService = widget._locationService ?? GeolocatorLocationService();
    _eventRefreshSignal =
        widget._eventRefreshSignal ?? globalEventRefreshSignal;
    _controller = EditEventController(
      eventRepository: widget._eventRepository ?? HttpEventRepository(),
      eventId: widget.eventId,
    );
    _locationController = CreateEventLocationController(
      locationService: _locationService,
      geocoder: widget._geocoder,
    );

    _controller.addListener(_handleStateChanged);
    _locationController.addListener(() => setState(() {}));
    _eventFuture = _loadEvent();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChanged);
    _controller.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _ticketUrlController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    final state = _controller.state;
    if (state.status == CreateEventFormStatus.success) {
      FeedbackService.showSuccess(FeedbackMessage.eventPublishSuccess);
      _eventRefreshSignal.notifyChanged();
      Navigator.of(context).maybePop();
    } else if (state.status == CreateEventFormStatus.error) {
      FeedbackService.showError(FeedbackMessage.eventPublishError);
    }
    setState(() {});
  }

  Future<ExploreEvent?> _loadEvent() async {
    final event = await _controller.loadEvent();
    if (!mounted || event == null) {
      return event;
    }

    _titleController.text = _controller.state.title;
    _descriptionController.text = _controller.state.description;
    _ticketUrlController.text = _controller.state.ticketUrl ?? '';
    _seatsController.text = _controller.state.slotLimit?.toString() ?? '';
    final label = _controller.state.locationLabel.isEmpty
        ? event.venue
        : _controller.state.locationLabel;
    _locationController.setSelectionFromCoordinates(
      label: label,
      coordinates: event.location,
    );
    return event;
  }

  void _clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _handleImagePressed() async {
    _clearFocus();
    final pickedFiles =
        await (widget._pickImageFiles?.call() ?? _pickImageFiles());
    if (!mounted || pickedFiles.isEmpty) {
      return;
    }

    _controller.addSelectedImages(
      pickedFiles
          .map(
            (file) => CreateEventSelectedImage(
              bytes: file.bytes,
              fileName: file.fileName,
            ),
          )
          .toList(),
    );
  }

  Future<List<EditEventPickedFile>> _pickImageFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    final files = result?.files ?? const [];
    return files
        .where((file) => file.bytes != null && file.bytes!.isNotEmpty)
        .map(
          (file) =>
              EditEventPickedFile(bytes: file.bytes!, fileName: file.name),
        )
        .toList();
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
    final l10n = AppLocalizations.of(context);
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
      _controller.clearLocation();
      FeedbackService.showError(FeedbackMessage.networkError);
    }
  }

  void _retryLoadEvent() {
    setState(() {
      _eventFuture = _loadEvent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(context, scheme, theme),
      body: FutureBuilder<ExploreEvent?>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return StatePanel.loading(
              title: 'Edit event',
              subtitle: 'Loading event details.',
            );
          }

          final event = snapshot.data;
          if (event == null) {
            return StatePanel.empty(
              title: 'Edit event',
              subtitle: 'Unable to load event details.',
              customContent: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilledButton(
                  onPressed: _retryLoadEvent,
                  child: Text(l10n.exploreRetryButton),
                ),
              ),
            );
          }

          return _buildForm(context, l10n);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = _controller.state;
    final categoriesController = CategoryScope.maybeOf(context);
    final available = categoriesController?.categories ?? const <Category>[];
    if ((categoriesController?.isLoading ?? false) == false &&
        available.isNotEmpty) {
      _controller.syncAvailableCategories(available);
    }

    return GestureDetector(
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
                  selectedImages: state.selectedImages,
                  onTap: _handleImagePressed,
                ),
                if (state.selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SelectedImagesList(
                    images: state.selectedImages,
                    onRemove: _controller.removeSelectedImageAt,
                    onReorder: _controller.reorderSelectedImages,
                  ),
                ],
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
                  ticketUrlController: _ticketUrlController,
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
            onPressed: state.canSubmit ? () => _controller.submit() : null,
            child: state.status == CreateEventFormStatus.submitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : Text(MaterialLocalizations.of(context).saveButtonLabel),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return AppBar(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'Edit event',
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

class EditEventController extends ChangeNotifier {
  EditEventController({
    required EventRepository eventRepository,
    required String eventId,
  }) : _eventRepository = eventRepository,
       _eventId = eventId;

  final EventRepository _eventRepository;
  final String _eventId;

  CreateEventState _state = const CreateEventState();
  CreateEventState get state => _state;

  LatLng? _selectedLocation;
  Duration? _eventDuration;
  String? _thumbnailUrl;
  bool _didSyncCategories = false;
  Set<String> _pendingCategoryIds = {};

  Future<ExploreEvent?> loadEvent() async {
    try {
      final event = await _eventRepository.fetchEvent(_eventId);
      _hydrateFromEvent(event);
      return event;
    } catch (_) {
      return null;
    }
  }

  void syncAvailableCategories(List<Category> available) {
    if (_didSyncCategories || _pendingCategoryIds.isEmpty) {
      return;
    }
    if (available.isEmpty) {
      return;
    }

    final next = available
        .where((category) => _pendingCategoryIds.contains(category.id))
        .toList(growable: false);
    if (_sameCategoryIds(next, _state.selectedCategories)) {
      _didSyncCategories = true;
      return;
    }

    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      selectedCategories: next,
      categoriesError: () =>
          next.isEmpty ? l10n.hubCreateEventValidationCategoryRequired : null,
    );
    _didSyncCategories = true;
    notifyListeners();
  }

  void _hydrateFromEvent(ExploreEvent event) {
    final startLocal = event.startsAt.toLocal();
    final locationLabel = _resolveLocationLabel(event);
    final duration = event.endsAt == null
        ? null
        : event.endsAt!.difference(event.startsAt);

    _selectedLocation = event.location;
    _eventDuration = duration;
    _thumbnailUrl = event.thumbnailUrl;
    _pendingCategoryIds = event.categories.map((c) => c.id).toSet();
    _didSyncCategories = false;

    _state = _state.copyWith(
      title: event.title,
      titleError: () => null,
      description: event.description ?? '',
      descriptionError: () => null,
      locationLabel: locationLabel,
      locationError: () => null,
      selectedDate: () => startLocal,
      dateError: () => null,
      selectedTime: () => startLocal,
      timeError: () => null,
      selectedCategories: event.categories,
      categoriesError: () => null,
      eventStatus: event.status,
      ticketUrl: () => event.ticketUrl,
      ticketUrlError: () => null,
      slotLimit: () => event.slotLimit,
      slotLimitError: () => null,
      status: CreateEventFormStatus.idle,
    );
    notifyListeners();
  }

  String _resolveLocationLabel(ExploreEvent event) {
    final address = event.address?.trim();
    if (address != null && address.isNotEmpty) {
      return address;
    }
    return event.venue;
  }

  void updateTitle(String title) {
    final l10n = L10nService.l10n;
    String? error;
    if (title.isEmpty) {
      error = l10n.hubCreateEventValidationRequired;
    } else if (title.length < 3) {
      error = l10n.hubCreateEventValidationMinChars3;
    }

    _state = _state.copyWith(title: title, titleError: () => error);
    notifyListeners();
  }

  void updateDescription(String description) {
    final l10n = L10nService.l10n;
    String? error;
    if (description.isEmpty) {
      error = l10n.hubCreateEventValidationRequired;
    } else if (description.length < 10) {
      error = l10n.hubCreateEventValidationDescriptionMin10;
    }

    _state = _state.copyWith(
      description: description,
      descriptionError: () => error,
    );
    notifyListeners();
  }

  void updateLocation(String label, LatLng? location) {
    final l10n = L10nService.l10n;
    _selectedLocation = location;
    _state = _state.copyWith(
      locationLabel: label,
      locationError: () => location == null
          ? l10n.hubCreateEventValidationLocationRequired
          : null,
    );
    notifyListeners();
  }

  void clearLocation() {
    final l10n = L10nService.l10n;
    _selectedLocation = null;
    _state = _state.copyWith(
      locationLabel: '',
      locationError: () => l10n.hubCreateEventValidationLocationRequired,
    );
    notifyListeners();
  }

  void updateDate(DateTime? date) {
    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      selectedDate: () => date,
      dateError: () =>
          date == null ? l10n.hubCreateEventValidationDateTimeRequired : null,
    );
    notifyListeners();
  }

  void updateTime(DateTime? time) {
    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      selectedTime: () => time,
      timeError: () =>
          time == null ? l10n.hubCreateEventValidationDateTimeRequired : null,
    );
    notifyListeners();
  }

  void toggleCategory(Category category) {
    final l10n = L10nService.l10n;
    final next = [..._state.selectedCategories];
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }

    _state = _state.copyWith(
      selectedCategories: next,
      categoriesError: () =>
          next.isEmpty ? l10n.hubCreateEventValidationRequired : null,
    );
    notifyListeners();
  }

  void updateStatus(EventStatus status) {
    _state = _state.copyWith(eventStatus: status);
    notifyListeners();
  }

  void updateTicketUrl(String? url) {
    _state = _state.copyWith(ticketUrl: () => url);
    notifyListeners();
  }

  void updateSlotLimit(int? limit) {
    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      slotLimit: () => limit,
      slotLimitError: () => (limit != null && limit <= 0)
          ? l10n.hubCreateEventValidationPositiveNumber
          : null,
    );
    notifyListeners();
  }

  void addSelectedImages(List<CreateEventSelectedImage> images) {
    if (images.isEmpty) return;
    _state = _state.copyWith(
      selectedImages: [..._state.selectedImages, ...images],
    );
    notifyListeners();
  }

  void removeSelectedImageAt(int index) {
    if (index < 0 || index >= _state.selectedImages.length) return;
    final next = [..._state.selectedImages]..removeAt(index);
    _state = _state.copyWith(selectedImages: next);
    notifyListeners();
  }

  void reorderSelectedImages(int oldIndex, int newIndex) {
    final images = [..._state.selectedImages];
    if (oldIndex < 0 || oldIndex >= images.length) return;
    if (newIndex < 0 || newIndex > images.length) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final moved = images.removeAt(oldIndex);
    images.insert(newIndex, moved);
    _state = _state.copyWith(selectedImages: images);
    notifyListeners();
  }

  Future<void> submit() async {
    if (_state.status == CreateEventFormStatus.submitting) return;

    final l10n = L10nService.l10n;
    String? titleError;
    if (_state.title.isEmpty) {
      titleError = l10n.hubCreateEventValidationRequired;
    } else if (_state.title.length < 3) {
      titleError = l10n.hubCreateEventValidationMinChars3;
    }

    String? descError;
    if (_state.description.isEmpty) {
      descError = l10n.hubCreateEventValidationRequired;
    } else if (_state.description.length < 10) {
      descError = l10n.hubCreateEventValidationDescriptionMin10;
    }

    _state = _state.copyWith(
      titleError: () => titleError,
      descriptionError: () => descError,
      categoriesError: () => _state.selectedCategories.isEmpty
          ? l10n.hubCreateEventValidationCategoryRequired
          : null,
      locationError: () => _selectedLocation == null
          ? l10n.hubCreateEventValidationLocationRequired
          : null,
      dateError: () => _state.selectedDate == null
          ? l10n.hubCreateEventValidationDateTimeRequired
          : null,
      timeError: () => _state.selectedTime == null
          ? l10n.hubCreateEventValidationDateTimeRequired
          : null,
    );
    notifyListeners();

    if (!state.canSubmit) return;

    _state = _state.copyWith(status: CreateEventFormStatus.submitting);
    notifyListeners();

    try {
      final startAt = _combineDateAndTime(
        _state.selectedDate!,
        _state.selectedTime!,
      );
      final endAt = _eventDuration == null
          ? null
          : startAt.add(_eventDuration!);

      final request = EventRequest(
        name: _state.title,
        description: _state.description,
        startAt: startAt,
        endAt: endAt,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        address: _state.locationLabel,
        categoryIds: _state.selectedCategories.map((c) => c.id).toList(),
        status: _state.eventStatus,
        ticketUrl: _state.ticketUrl,
        slotLimit: _state.slotLimit,
        thumbnailUrl: _thumbnailUrl,
      );

      final updatedEvent = await _eventRepository.updateEvent(
        _eventId,
        request,
      );
      final selectedImages = _state.selectedImages;
      if (selectedImages.isNotEmpty) {
        try {
          final uploadedMedia = <EventMedia>[];
          for (final image in selectedImages) {
            final media = await _eventRepository.uploadEventMedia(
              updatedEvent.id,
              image.bytes,
              image.fileName,
            );
            uploadedMedia.add(media);
          }
          final firstMediaId = uploadedMedia.firstOrNull?.id;
          if (firstMediaId != null && firstMediaId.isNotEmpty) {
            await _eventRepository.setEventThumbnail(
              updatedEvent.id,
              firstMediaId,
            );
          }
        } catch (error, stackTrace) {
          debugPrint('EditEventController image upload failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
      _state = _state.copyWith(status: CreateEventFormStatus.success);
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(status: CreateEventFormStatus.error);
      notifyListeners();
    }
  }

  DateTime _combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool _sameCategoryIds(List<Category> left, List<Category> right) {
    if (left.length != right.length) {
      return false;
    }
    final leftIds = left.map((c) => c.id).toSet();
    final rightIds = right.map((c) => c.id).toSet();
    return leftIds.length == rightIds.length &&
        leftIds.difference(rightIds).isEmpty;
  }
}

class _SelectedImagesList extends StatelessWidget {
  const _SelectedImagesList({
    required this.images,
    required this.onRemove,
    required this.onReorder,
  });

  final List<CreateEventSelectedImage> images;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ReorderableListView.builder(
        key: const Key('edit-event-image-list'),
        shrinkWrap: true,
        buildDefaultDragHandles: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final image = images[index];
          final isPrimary = index == 0;

          return Container(
            key: ValueKey('${image.fileName}-$index'),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isPrimary
                    ? scheme.primary.withValues(alpha: 0.35)
                    : scheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(image.bytes),
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                image.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                isPrimary
                    ? l10n.hubCreateEventPrimaryPhotoHint
                    : l10n.hubCreateEventSecondaryPhotoHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPrimary ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_handle_rounded),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
