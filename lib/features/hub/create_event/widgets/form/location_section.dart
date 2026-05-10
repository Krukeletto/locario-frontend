import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../create_event_location_controller.dart';
import '../../create_event_state.dart';
import '../form_primitives.dart';

class CreateEventLocationSection extends StatelessWidget {
  const CreateEventLocationSection({
    super.key,
    required this.state,
    required this.locationController,
    required this.onLocationPressed,
  });

  final CreateEventState state;
  final CreateEventLocationController locationController;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locationSelection = locationController.selection;
    final isLoading = locationController.isResolvingSelection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventFieldLabel(text: l10n.hubCreateEventLocationLabel),
        const SizedBox(height: 6),
        CreateEventLocationPickerTile(
          key: const Key('create-event-location-button'),
          selection: locationSelection,
          isLoading: isLoading,
          placeholder: l10n.hubCreateEventLocationHint,
          loadingLabel: l10n.hubCreateEventLocationLoadingLabel,
          loadingDescription: l10n.hubCreateEventLocationLoadingDescription,
          onTap: onLocationPressed,
          errorText: state.locationError,
        ),
      ],
    );
  }
}
