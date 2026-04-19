import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:locario/l10n/app_localizations.dart';

import 'locale/locale_controller.dart';
import 'locale/locale_scope.dart';
import 'router.dart';
import 'settings/app_settings_store.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_scope.dart';
import '../shared/services/feedback_service.dart';
import '../shared/services/l10n_service.dart';
import '../shared/events/event_repository.dart';
import '../shared/events/category_controller.dart';
import '../shared/events/category_scope.dart';

class LocarioApp extends StatefulWidget {
  const LocarioApp({super.key});

  @override
  State<LocarioApp> createState() => _LocarioAppState();
}

class _LocarioAppState extends State<LocarioApp> {
  late final LocaleController _localeController;
  late final ThemeController _themeController;
  late final CategoryController _categoryController;
  late final AppSettingsStore _settingsStore;
  late final EventRepository _eventRepository;

  @override
  void initState() {
    super.initState();
    _settingsStore = const SharedPreferencesAppSettingsStore();
    _eventRepository = HttpEventRepository();
    _localeController = LocaleController(settingsStore: _settingsStore);
    _themeController = ThemeController(settingsStore: _settingsStore);
    _categoryController = CategoryController(eventRepository: _eventRepository);

    _localeController.load();
    _themeController.load();
    _categoryController.loadCategories();
  }

  @override
  void dispose() {
    _localeController.dispose();
    _themeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScope(
      controller: _categoryController,
      child: LocaleScope(
        controller: _localeController,
        child: ThemeScope(
          controller: _themeController,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _localeController,
              _themeController,
              _categoryController,
            ]),
            builder: (context, _) {
              return MaterialApp.router(
                scaffoldMessengerKey: rootScaffoldMessengerKey,
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
                builder: (context, child) {
                  // Initialize the L10nService so it can be used without BuildContext.
                  final l10n = AppLocalizations.of(context);
                  if (l10n != null) {
                    L10nService.update(l10n);
                  }
                  return child!;
                },
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
      ),
    );
  }
}
