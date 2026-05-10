import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import 'form_primitives.dart';

class CreateEventBasicInfoSection extends StatelessWidget {
  const CreateEventBasicInfoSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleError,
    this.descriptionError,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? titleError;
  final String? descriptionError;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventFieldLabel(text: l10n.hubCreateEventNameLabel),
        const SizedBox(height: 6),
        TextFormField(
          controller: titleController,
          onChanged: onTitleChanged,
          decoration: createEventFieldDecoration(
            context,
            hintText: l10n.hubCreateEventNameHint,
            errorText: titleError,
          ),
        ),
        const SizedBox(height: 16),
        CreateEventFieldLabel(text: l10n.hubCreateEventDescriptionLabel),
        const SizedBox(height: 6),
        TextFormField(
          controller: descriptionController,
          onChanged: onDescriptionChanged,
          maxLines: 3,
          decoration: createEventFieldDecoration(
            context,
            hintText: l10n.hubCreateEventDescriptionHint,
            errorText: descriptionError,
          ),
        ),
      ],
    );
  }
}
