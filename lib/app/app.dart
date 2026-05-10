import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
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
import '../features/saved/saved_events_controller.dart';
import '../features/saved/saved_events_repository.dart';
import '../features/saved/saved_events_scope.dart';
import '../shared/auth/auth_api.dart';
import '../shared/auth/auth_repository.dart';
import '../shared/auth/auth_scope.dart';
import '../shared/auth/session_controller.dart';
import '../shared/auth/auth_storage.dart';

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
  late final SavedEventsController _savedEventsController;
  late final AuthApi _authApi;
  late final AuthRepository _authRepository;
  late final AuthStorage _authStorage;
  late final SessionController _sessionController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _settingsStore = const SharedPreferencesAppSettingsStore();
    _eventRepository = HttpEventRepository();
    _authApi = AuthApi();
    _authStorage = const AuthStorage();
    _authRepository = AuthRepository(api: _authApi, storage: _authStorage);
    _sessionController = SessionController(authRepository: _authRepository);
    _router = createAppRouter(_sessionController);
    _localeController = LocaleController(settingsStore: _settingsStore);
    _themeController = ThemeController(settingsStore: _settingsStore);
    _categoryController = CategoryController(eventRepository: _eventRepository);
    _savedEventsController = SavedEventsController(
      repository: const SharedPreferencesSavedEventsRepository(),
    );

    _localeController.load();
    _themeController.load();
    _categoryController.loadCategories();
    _savedEventsController.load();
    _sessionController.load();
  }

  @override
  void dispose() {
    _localeController.dispose();
    _themeController.dispose();
    _categoryController.dispose();
    _savedEventsController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScope(
      controller: _categoryController,
      child: AuthScope(
        controller: _sessionController,
        child: SavedEventsScope(
          controller: _savedEventsController,
          child: LocaleScope(
            controller: _localeController,
            child: ThemeScope(
              controller: _themeController,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _localeController,
                  _themeController,
                  _categoryController,
                  _savedEventsController,
                ]),
                builder: (context, _) {
                  return MaterialApp.router(
                    scaffoldMessengerKey: rootScaffoldMessengerKey,
                    onGenerateTitle: (context) =>
                        AppLocalizations.of(context).appTitle,
                    debugShowCheckedModeBanner: false,
                    theme: buildLightAppTheme(),
                    darkTheme: buildDarkAppTheme(),
                    themeMode: _themeController.themeMode,
                    routerConfig: _router,
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
                      L10nService.update(l10n);
                                          return child!;
                    },
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (locale == null) {
                        return const Locale('pl');
                      }

                      for (final supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            locale.languageCode) {
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
        ),
      ),
    );
  }
}
