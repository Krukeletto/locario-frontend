import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

Widget buildLocalizedTestApp({required Widget home}) {
  return MaterialApp(
    locale: const Locale('pl'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}
