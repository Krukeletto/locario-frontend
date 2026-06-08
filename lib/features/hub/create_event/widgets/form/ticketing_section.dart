import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../create_event_state.dart';
import '../form_primitives.dart';

class CreateEventTicketingSection extends StatelessWidget {
  const CreateEventTicketingSection({
    super.key,
    required this.state,
    required this.ticketUrlController,
    required this.seatsController,
    required this.onTicketUrlChanged,
    required this.onSlotLimitChanged,
  });

  final CreateEventState state;
  final TextEditingController ticketUrlController;
  final TextEditingController seatsController;
  final ValueChanged<String> onTicketUrlChanged;
  final ValueChanged<int?> onSlotLimitChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventFieldLabel(text: l10n.hubCreateEventTicketingLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: ticketUrlController,
          onChanged: onTicketUrlChanged,
          decoration: createEventFieldDecoration(
            context,
            hintText: l10n.hubCreateEventTicketUrlHint,
            errorText: state.ticketUrlError,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: seatsController,
          keyboardType: TextInputType.number,
          onChanged: (v) => onSlotLimitChanged(int.tryParse(v)),
          decoration: createEventFieldDecoration(
            context,
            hintText: l10n.hubCreateEventTicketSeatsLabel,
            errorText: state.slotLimitError,
          ),
        ),
      ],
    );
  }
}
