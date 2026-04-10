import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:locario/l10n/app_localizations.dart';

import 'locale/locale_controller.dart';
import 'locale/locale_scope.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_scope.dart';

class LocarioApp extends StatefulWidget {
  const LocarioApp({super.key});

  @override
  State<LocarioApp> createState() => _LocarioAppState();
}

class _LocarioAppState extends State<LocarioApp> {
  late final LocaleController _localeController;
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _localeController = LocaleController();
    _themeController = ThemeController();
  }

  @override
  void dispose() {
    _localeController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: ThemeScope(
        controller: _themeController,
        child: AnimatedBuilder(
          animation: Listenable.merge([_localeController, _themeController]),
          builder: (context, _) {
            return MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              debugShowCheckedModeBanner: false,
              theme: buildLightAppTheme(),
              darkTheme: buildDarkAppTheme(),
              themeMode: _themeController.themeMode,
              routerConfig: appRouter,
              locale: _localeController.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) {
                  return const Locale('pl');
                }

                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }

                return const Locale('pl');
              },
            );
          },
        ),
      ),
    );
  }
}
