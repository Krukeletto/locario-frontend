import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/events/event_repository.dart';
import '../../../shared/events/event_refresh_signal.dart';
import '../../../shared/location/location_service.dart';
import '../../explore/models.dart';
import '../../explore/widgets/area_picker.dart';
import 'create_event_location_controller.dart';
import 'event_map_picker_screen.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ticketsCountController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();

  late final EventRepository _eventRepository;
  late final LocationService _locationService;
  late final CreateEventLocationController _locationController;
  late final EventRefreshSignal _eventRefreshSignal;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<ExploreCategory> _selectedCategories = [];
  bool _hasTicketing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
    _locationService = widget._locationService ?? GeolocatorLocationService();
    _eventRefreshSignal =
        widget._eventRefreshSignal ?? globalEventRefreshSignal;
    _locationController = CreateEventLocationController(
      locationService: _locationService,
      geocoder: widget._geocoder,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ticketsCountController.dispose();
    _ticketPriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _clearInteractionFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _pickDate() async {
    _clearInteractionFocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate ?? now,
    );

    if (!mounted) {
      return;
    }

    _clearInteractionFocus();
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    _clearInteractionFocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (!mounted) {
      return;
    }

    _clearInteractionFocus();
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _categoryLabel(AppLocalizations l10n, ExploreCategory value) {
    return switch (value) {
      ExploreCategory.music => l10n.filterMusic,
      ExploreCategory.art => l10n.filterArt,
      ExploreCategory.workshops => l10n.filterWorkshops,
      ExploreCategory.food => l10n.filterFood,
      ExploreCategory.all => l10n.filterAll,
    };
  }

  bool _isCategorySelected(ExploreCategory category) {
    return _selectedCategories.contains(category);
  }

  void _toggleCategory(ExploreCategory category, bool selected) {
    setState(() {
      _selectedCategories.remove(category);
      if (selected) {
        _selectedCategories.add(category);
      }
    });
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hintText,
    IconData? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return _buildFieldDecoration(
      context,
      hintText: hintText,
      prefixIcon: prefixIcon,
      alignLabelWithHint: alignLabelWithHint,
    );
  }

  Future<void> _handleLocationPressed() async {
    final l10n = AppLocalizations.of(context)!;
    _clearInteractionFocus();
    final action = await showModalBottomSheet<ExploreAreaSelectionAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => ExploreAreaSelectionSheet(
        title: l10n.areaPickerTitle,
        subtitle: l10n.areaPickerSubtitle,
        onActionSelected: (action) => Navigator.of(context).pop(action),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case ExploreAreaSelectionAction.currentLocation:
        final result = await _locationController.useCurrentLocation(l10n);
        if (!mounted) {
          return;
        }
        _clearInteractionFocus();
        _handleLocationResult(result);
        return;
      case ExploreAreaSelectionAction.enterAddress:
        final address = await showDialog<String>(
          context: context,
          builder: (context) => const ExploreAddressInputDialog(),
        );
        if (!mounted || address == null || address.isEmpty) {
          return;
        }
        final result = await _locationController.selectAddress(l10n, address);
        if (!mounted) {
          return;
        }
        _clearInteractionFocus();
        _handleLocationResult(result);
        return;
      case ExploreAreaSelectionAction.pickOnMap:
        final center = await Navigator.of(context).push<LatLng>(
          MaterialPageRoute(
            builder: (_) =>
                EventMapPickerScreen(locationService: _locationService),
          ),
        );
        if (!mounted || center == null) {
          return;
        }
        _clearInteractionFocus();
        _locationController.selectPinnedLocation(l10n, center);
        return;
    }
  }

  void _handleLocationResult(CreateEventLocationLookupResult result) {
    final l10n = AppLocalizations.of(context)!;
    switch (result.status) {
      case CreateEventLocationLookupStatus.success:
        return;
      case CreateEventLocationLookupStatus.notFound:
      case CreateEventLocationLookupStatus.error:
        _showSnackBar(l10n.hubCreateEventLocationLookupFailed);
        return;
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showSnackBar(l10n.hubCreateEventValidationDateTimeRequired);
      return;
    }

    if (_selectedCategories.isEmpty) {
      _showSnackBar(l10n.hubCreateEventValidationCategoryRequired);
      return;
    }

    final primaryCategory = primaryCategoryForSubmission(_selectedCategories);
    if (primaryCategory == null) {
      _showSnackBar(l10n.hubCreateEventValidationCategoryRequired);
      return;
    }

    final locationSelection = _locationController.selection;
    if (locationSelection == null) {
      _showSnackBar(l10n.hubCreateEventValidationLocationRequired);
      return;
    }

    final startDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _eventRepository.createEvent(
        CreateEventInput(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: locationSelection.coordinates,
          startDate: startDate,
          address: locationSelection.address,
          categoryId: backendCategoryIdFor(primaryCategory),
        ),
        l10n,
      );
      if (!mounted) {
        return;
      }

      _eventRefreshSignal.notifyChanged();
      _showSnackBar(l10n.hubCreateEventCreatedSuccess);
      Navigator.of(context).maybePop();
    } on EventRepositoryException {
      if (mounted) {
        _showSnackBar(l10n.hubCreateEventCreateFailed);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar(l10n.hubCreateEventCreateFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.close_rounded, color: scheme.primary, size: 22),
            ),
          ),
        ),
        title: Text(
          l10n.hubCreateEventTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _clearInteractionFocus,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _Section(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImagePickerTile(
                      label: l10n.hubCreateEventMainPhotoLabel,
                      subtitle: l10n.hubCreateEventMainPhotoSizeHint,
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(text: l10n.hubCreateEventNameLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        context,
                        hintText: l10n.hubCreateEventNameHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return l10n.hubCreateEventValidationMinChars3;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: l10n.hubCreateEventDateLabel),
                              const SizedBox(height: 6),
                              _PickerTile(
                                value: _selectedDate == null
                                    ? l10n.hubCreateEventDateHint
                                    : '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}',
                                isPlaceholder: _selectedDate == null,
                                onTap: _pickDate,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: l10n.hubCreateEventTimeLabel),
                              const SizedBox(height: 6),
                              _PickerTile(
                                value: _selectedTime == null
                                    ? l10n.hubCreateEventTimeHint
                                    : _selectedTime!.format(context),
                                isPlaceholder: _selectedTime == null,
                                onTap: _pickTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.hubCreateEventCategoryLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final category in const [
                          ExploreCategory.music,
                          ExploreCategory.art,
                          ExploreCategory.workshops,
                          ExploreCategory.food,
                        ])
                          FilterChip(
                            selected: _isCategorySelected(category),
                            showCheckmark: false,
                            label: Text(_categoryLabel(l10n, category)),
                            labelStyle: theme.textTheme.labelMedium?.copyWith(
                              color: _isCategorySelected(category)
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: scheme.surface,
                            selectedColor: scheme.primary,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            onSelected: (selected) =>
                                _toggleCategory(category, selected),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(text: l10n.hubCreateEventLocationLabel),
                    const SizedBox(height: 6),
                    AnimatedBuilder(
                      animation: _locationController,
                      builder: (context, _) {
                        return _LocationSelectionTile(
                          selection: _locationController.selection,
                          isLoading: _locationController.isResolvingSelection,
                          placeholder: l10n.hubCreateEventLocationHint,
                          loadingLabel: l10n.hubCreateEventLocationLoadingLabel,
                          loadingDescription:
                              l10n.hubCreateEventLocationLoadingDescription,
                          onTap: _handleLocationPressed,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(text: l10n.hubCreateEventDescriptionLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: _fieldDecoration(
                        context,
                        hintText: l10n.hubCreateEventDescriptionHint,
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return l10n.hubCreateEventValidationDescriptionMin10;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _TicketingSection(
                      hasTicketing: _hasTicketing,
                      title: l10n.hubCreateEventTicketingTitle,
                      countLabel: l10n.hubCreateEventTicketSeatsLabel,
                      priceLabel: l10n.hubCreateEventTicketPriceLabel,
                      switchLabel: l10n.hubCreateEventTicketingSwitchLabel,
                      countController: _ticketsCountController,
                      priceController: _ticketPriceController,
                      requiredValidationMessage:
                          l10n.hubCreateEventValidationRequired,
                      invalidNumberMessage:
                          l10n.hubCreateEventValidationPositiveNumber,
                      onTicketingChanged: (value) {
                        setState(() {
                          _hasTicketing = value;
                          if (!value) {
                            _ticketsCountController.clear();
                            _ticketPriceController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(l10n.hubCreateEventSubmitButton),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSelectionTile extends StatelessWidget {
  const _LocationSelectionTile({
    required this.selection,
    required this.isLoading,
    required this.placeholder,
    required this.loadingLabel,
    required this.loadingDescription,
    required this.onTap,
  });

  final CreateEventLocationSelection? selection;
  final bool isLoading;
  final String placeholder;
  final String loadingLabel;
  final String loadingDescription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selection = this.selection;

    return InkWell(
      key: const Key('create-event-location-button'),
      borderRadius: BorderRadius.circular(16),
      canRequestFocus: false,
      onTap: isLoading ? null : onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              )
            else
              Icon(
                selection?.icon ?? Icons.place_outlined,
                color: scheme.primary,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading ? loadingLabel : selection?.label ?? placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(
                        alpha: selection == null && !isLoading ? 0.55 : 1,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 4),
                    Text(
                      loadingDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ] else if (selection != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      selection.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, color: scheme.secondary),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      canRequestFocus: false,
      onTap: () {},
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: scheme.outline.withValues(alpha: 0.42),
          radius: 16,
          strokeWidth: 1.4,
          dashWidth: 7,
          dashSpace: 5,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.add_a_photo_outlined, color: scheme.primary, size: 36),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth > metric.length
            ? metric.length
            : distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

class _TicketingSection extends StatelessWidget {
  const _TicketingSection({
    required this.hasTicketing,
    required this.title,
    required this.switchLabel,
    required this.countLabel,
    required this.priceLabel,
    required this.countController,
    required this.priceController,
    required this.requiredValidationMessage,
    required this.invalidNumberMessage,
    required this.onTicketingChanged,
  });

  final bool hasTicketing;
  final String title;
  final String switchLabel;
  final String countLabel;
  final String priceLabel;
  final TextEditingController countController;
  final TextEditingController priceController;
  final String requiredValidationMessage;
  final String invalidNumberMessage;
  final ValueChanged<bool> onTicketingChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: Text(switchLabel)),
            Switch.adaptive(
              value: hasTicketing,
              activeThumbColor: scheme.primary,
              activeTrackColor: scheme.primary.withValues(alpha: 0.4),
              onChanged: onTicketingChanged,
            ),
          ],
        ),
        if (hasTicketing) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: countController,
                  keyboardType: TextInputType.number,
                  decoration: _buildFieldDecoration(
                    context,
                    hintText: countLabel,
                  ),
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) {
                      return requiredValidationMessage;
                    }

                    final parsed = int.tryParse(raw);
                    if (parsed == null || parsed <= 0) {
                      return invalidNumberMessage;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _buildFieldDecoration(
                    context,
                    hintText: priceLabel,
                  ),
                  validator: (value) {
                    final raw = (value ?? '').trim().replaceAll(',', '.');
                    if (raw.isEmpty) {
                      return requiredValidationMessage;
                    }

                    final parsed = double.tryParse(raw);
                    if (parsed == null || parsed < 0) {
                      return invalidNumberMessage;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

InputDecoration _buildFieldDecoration(
  BuildContext context, {
  required String hintText,
  IconData? prefixIcon,
  bool alignLabelWithHint = false,
}) {
  final scheme = Theme.of(context).colorScheme;

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.55)),
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    fillColor: scheme.surface.withValues(alpha: 0.72),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.18)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.18)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
  });

  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      canRequestFocus: false,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
        ),
        child: Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: isPlaceholder ? 0.55 : 1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.68),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
