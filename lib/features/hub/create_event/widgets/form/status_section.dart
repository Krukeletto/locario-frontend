import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../../../explore/models.dart';
import '../../create_event_state.dart';
import '../form_primitives.dart';

class CreateEventStatusSection extends StatelessWidget {
  const CreateEventStatusSection({
    super.key,
    required this.state,
    required this.onStatusChanged,
  });

  final CreateEventState state;
  final ValueChanged<EventStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventFieldLabel(text: l10n.hubCreateEventStatusLabel),
        const SizedBox(height: 8),
        SegmentedButton<EventStatus>(
          segments: [
            ButtonSegment(
              value: EventStatus.draft,
              label: Text(l10n.eventStatusDraft),
            ),
            ButtonSegment(
              value: EventStatus.published,
              label: Text(l10n.eventStatusPublished),
            ),
          ],
          selected: {state.eventStatus},
          onSelectionChanged: (selection) {
            onStatusChanged(selection.first);
          },
        ),
      ],
    );
  }
}
