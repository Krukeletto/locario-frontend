import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/auth/auth_scope.dart';
import '../../../shared/events/event_repository.dart';
import '../../../shared/groups/group_models.dart';
import '../../../shared/groups/group_scope.dart';
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

class CreateEventPickedFile {
  const CreateEventPickedFile({required this.bytes, required this.fileName});

  final List<int> bytes;
  final String fileName;
}

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    EventRepository? eventRepository,
    LocationService? locationService,
    CreateEventGeocoder? geocoder,
    EventRefreshSignal? eventRefreshSignal,
    Future<List<CreateEventPickedFile>> Function()? pickImageFiles,
    this.initialGroupId,
    this.canSubmit = false,
  }) : _eventRepository = eventRepository,
       _locationService = locationService,
       _geocoder = geocoder,
       _eventRefreshSignal = eventRefreshSignal,
       _pickImageFiles = pickImageFiles;

  final EventRepository? _eventRepository;
  final LocationService? _locationService;
  final CreateEventGeocoder? _geocoder;
  final EventRefreshSignal? _eventRefreshSignal;
  final Future<List<CreateEventPickedFile>> Function()? _pickImageFiles;
  final String? initialGroupId;
  final bool canSubmit;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  CreateEventController? _controller;
  late final CreateEventLocationController _locationController;
  late final EventRefreshSignal _eventRefreshSignal;
  late final LocationService _locationService;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  bool _didInitController = false;

  @override
  void initState() {
    super.initState();
    _locationService = widget._locationService ?? GeolocatorLocationService();
    _eventRefreshSignal =
        widget._eventRefreshSignal ?? globalEventRefreshSignal;
    _locationController = CreateEventLocationController(
      locationService: _locationService,
      geocoder: widget._geocoder,
    );

    _locationController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitController) {
      return;
    }
    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;
    final canCreatePublicEvents =
        profile?.organizer == true || profile?.admin == true;
    final controller = CreateEventController(
      eventRepository: widget._eventRepository ?? HttpEventRepository(),
      sessionController: sessionController,
      canCreatePublicEvents: canCreatePublicEvents,
    );
    controller.addListener(_handleStateChanged);
    _controller = controller;
    _didInitController = true;

    final groupController = GroupScope.of(context);
    groupController.loadMyGroups();

    if (widget.initialGroupId != null) {
      void trySetInitialGroups() {
        if (!mounted) {
          groupController.removeListener(trySetInitialGroups);
          return;
        }
        final activeGroups = groupController.myGroups
            .where(
              (g) => g.currentUserMembership == GroupMembershipStatus.active,
            )
            .toList();
        final initial = activeGroups
            .where((g) => g.id == widget.initialGroupId)
            .toList();
        if (initial.isNotEmpty) {
          controller.setSelectedGroups(initial);
          groupController.removeListener(trySetInitialGroups);
        } else if (!groupController.isMyGroupsLoading) {
          groupController.removeListener(trySetInitialGroups);
        }
      }

      groupController.addListener(trySetInitialGroups);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleStateChanged);
    _controller?.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final state = controller.state;
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

  Future<void> _handleImagePressed() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _clearFocus();
    final pickedFiles =
        await (widget._pickImageFiles?.call() ?? _pickImageFiles());
    if (!mounted || pickedFiles.isEmpty) {
      return;
    }

    controller.addSelectedImages(
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

  Future<List<CreateEventPickedFile>> _pickImageFiles() async {
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
              CreateEventPickedFile(bytes: file.bytes!, fileName: file.name),
        )
        .toList();
  }

  Future<void> _pickDate() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _clearFocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: controller.state.selectedDate ?? now,
    );

    if (mounted && picked != null) {
      controller.updateDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _clearFocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        controller.state.selectedTime ?? DateTime.now(),
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
      controller.updateTime(time);
    }
  }

  Future<void> _handleLocationPressed() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
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
      controller.updateLocation(selection.label, selection.coordinates);
    } else if (mounted &&
        result != null &&
        result.status != CreateEventLocationLookupStatus.success) {
      controller.clearLocation();
      FeedbackService.showError(FeedbackMessage.networkError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final state = controller.state;
    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;
    final canCreatePublicEvents =
        profile?.organizer == true || profile?.admin == true;
    final groupController = GroupScope.of(context);
    final allGroups = groupController.myGroups;
    final activeGroups = allGroups
        .where((g) => g.currentUserMembership == GroupMembershipStatus.active)
        .toList();
    final isGroupsLoading = groupController.isMyGroupsLoading;

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
                    selectedImages: state.selectedImages,
                    onTap: _handleImagePressed,
                  ),
                  if (state.selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SelectedImagesList(
                      images: state.selectedImages,
                      onRemove: controller.removeSelectedImageAt,
                      onReorder: controller.reorderSelectedImages,
                    ),
                  ],
                  const SizedBox(height: 16),
                  CreateEventBasicInfoSection(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    titleError: state.titleError,
                    descriptionError: state.descriptionError,
                    onTitleChanged: controller.updateTitle,
                    onDescriptionChanged: controller.updateDescription,
                  ),
                  const SizedBox(height: 16),
                  CreateEventCategoriesSection(
                    state: state,
                    onCategoryToggled: controller.toggleCategory,
                  ),
                  const SizedBox(height: 16),
                  _CreateEventGroupsSection(
                    isLoading: isGroupsLoading,
                    groups: activeGroups,
                    selectedGroups: state.selectedGroups,
                    groupsError: state.groupsError,
                    canCreatePublicEvents: canCreatePublicEvents,
                    onGroupToggled: controller.toggleGroup,
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
                    onTicketUrlChanged: controller.updateTicketUrl,
                    onSlotLimitChanged: controller.updateSlotLimit,
                  ),
                  const SizedBox(height: 16),
                  CreateEventStatusSection(
                    state: state,
                    onStatusChanged: controller.updateStatus,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!widget.canSubmit)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.hubCreateEventSubmitDisabledHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            FilledButton(
              onPressed:
                  !widget.canSubmit ||
                      state.status == CreateEventFormStatus.submitting
                  ? null
                  : () => controller.submit(),
              child: state.status == CreateEventFormStatus.submitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
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

class _CreateEventGroupsSection extends StatelessWidget {
  const _CreateEventGroupsSection({
    required this.isLoading,
    required this.groups,
    required this.selectedGroups,
    required this.groupsError,
    required this.canCreatePublicEvents,
    required this.onGroupToggled,
  });

  final bool isLoading;
  final List<Group> groups;
  final List<Group> selectedGroups;
  final String? groupsError;
  final bool canCreatePublicEvents;
  final ValueChanged<Group> onGroupToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventFieldLabel(text: l10n.groupsEventGroupsLabel),
        const SizedBox(height: 8),
        Text(
          canCreatePublicEvents
              ? l10n.groupsEventGroupsOptionalHint
              : l10n.groupsEventGroupsRequiredHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (groups.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              l10n.groupsEventGroupsEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final group in groups)
                FilterChip(
                  key: Key('create-event-group-${group.id}'),
                  label: Text(group.name),
                  selected: selectedGroups.any((item) => item.id == group.id),
                  onSelected: (_) => onGroupToggled(group),
                ),
            ],
          ),
        if (groupsError != null) ...[
          const SizedBox(height: 8),
          Text(
            groupsError!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
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
        key: const Key('create-event-image-list'),
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
