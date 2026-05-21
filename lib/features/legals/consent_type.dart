import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

enum ConsentType {
  marketingEmails,
  dataProcessing,
  locationData;

  String label(AppLocalizations l10n) {
    return switch (this) {
      ConsentType.marketingEmails => l10n.consentTypeMarketingEmails,
      ConsentType.dataProcessing => l10n.consentTypeDataProcessing,
      ConsentType.locationData => l10n.consentTypeLocationData,
    };
  }

  String description(AppLocalizations l10n) {
    return switch (this) {
      ConsentType.marketingEmails => l10n.consentTypeMarketingEmailsDesc,
      ConsentType.dataProcessing => l10n.consentTypeDataProcessingDesc,
      ConsentType.locationData => l10n.consentTypeLocationDataDesc,
    };
  }

  IconData get icon {
    return switch (this) {
      ConsentType.marketingEmails => Icons.email_rounded,
      ConsentType.dataProcessing => Icons.analytics_rounded,
      ConsentType.locationData => Icons.location_on_rounded,
    };
  }

  String get prefsKey => 'consents.$name';
}
