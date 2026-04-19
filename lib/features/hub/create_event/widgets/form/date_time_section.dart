import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../create_event_state.dart';
import '../form_primitives.dart';

class CreateEventDateTimeSection extends StatelessWidget {
  const CreateEventDateTimeSection({
    super.key,
    required this.state,
    required this.onPickDate,
    required this.onPickTime,
  });

  final CreateEventState state;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreateEventFieldLabel(text: l10n.hubCreateEventDateLabel),
              const SizedBox(height: 6),
              CreateEventPickerTile(
                key: const Key('create-event-date-picker'),
                value: state.selectedDate == null
                    ? l10n.hubCreateEventDateHint
                    : '${state.selectedDate!.day.toString().padLeft(2, '0')}.${state.selectedDate!.month.toString().padLeft(2, '0')}.${state.selectedDate!.year}',
                isPlaceholder: state.selectedDate == null,
                onTap: onPickDate,
                errorText: state.dateError,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreateEventFieldLabel(text: l10n.hubCreateEventTimeLabel),
              const SizedBox(height: 6),
              CreateEventPickerTile(
                key: const Key('create-event-time-picker'),
                value: state.selectedTime == null
                    ? l10n.hubCreateEventTimeHint
                    : '${state.selectedTime!.hour.toString().padLeft(2, '0')}:${state.selectedTime!.minute.toString().padLeft(2, '0')}',
                isPlaceholder: state.selectedTime == null,
                onTap: onPickTime,
                errorText: state.timeError,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
