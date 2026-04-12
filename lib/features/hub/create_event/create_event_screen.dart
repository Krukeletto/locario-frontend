import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ticketsCountController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final Set<String> _selectedCategories = {'music'};
  bool _hasTicketing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _ticketsCountController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate ?? now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _categoryLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'music':
        return l10n.filterMusic;
      case 'art':
        return l10n.filterArt;
      case 'workshops':
        return l10n.filterWorkshops;
      case 'food':
        return l10n.filterFood;
      default:
        return l10n.filterAll;
    }
  }

  InputDecoration _fieldDecoration(
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

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.hubCreateEventValidationDateTimeRequired),
          ),
        );
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.hubCreateEventValidationCategoryRequired),
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.hubCreateEventCreatedSuccess)),
      );

    Navigator.of(context).maybePop();
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
      body: Form(
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
                        'music',
                        'art',
                        'workshops',
                        'food',
                      ])
                        FilterChip(
                          selected: _selectedCategories.contains(category),
                          showCheckmark: false,
                          label: Text(_categoryLabel(l10n, category)),
                          labelStyle: theme.textTheme.labelMedium?.copyWith(
                            color: _selectedCategories.contains(category)
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
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(text: l10n.hubCreateEventLocationLabel),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _locationController,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      context,
                      hintText: l10n.hubCreateEventLocationHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.hubCreateEventValidationRequired;
                      }
                      return null;
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
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
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
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
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
              activeColor: scheme.primary,
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
                  decoration: InputDecoration(
                    hintText: countLabel,
                    hintStyle: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                    filled: true,
                    fillColor: scheme.surface.withValues(alpha: 0.72),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: scheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
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
                  decoration: InputDecoration(
                    hintText: priceLabel,
                    hintStyle: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                    filled: true,
                    fillColor: scheme.surface.withValues(alpha: 0.72),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: scheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
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
