import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/services/feedback_service.dart';
import 'package:locario/shared/services/l10n_service.dart';

Widget buildLocalizedTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    scaffoldMessengerKey: rootScaffoldMessengerKey,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
    builder: (context, child) {
      final l10n = AppLocalizations.of(context)!;
      L10nService.init(l10n);
      return child!;
    },
  );
}
