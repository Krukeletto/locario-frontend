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
import '../shared/events/event_registration_api.dart';
import '../shared/events/category_controller.dart';
import '../shared/events/category_scope.dart';
import '../features/events/joined_events_controller.dart';
import '../features/events/joined_events_scope.dart';
import '../features/saved/saved_events_controller.dart';
import '../features/saved/saved_events_repository.dart';
import '../features/saved/saved_events_scope.dart';
import '../features/saved/saved_filters_controller.dart';
import '../features/saved/saved_filters_repository.dart';
import '../features/saved/saved_filters_scope.dart';
import '../shared/auth/auth_api.dart';
import '../shared/auth/auth_repository.dart';
import '../shared/auth/auth_scope.dart';
import '../shared/auth/favorites_api.dart';
import '../shared/auth/session_controller.dart';
import '../shared/auth/auth_storage.dart';
import '../shared/notifications/notification_controller.dart';
import '../shared/notifications/notification_scope.dart';
import '../shared/notifications/notification_service.dart';
import '../shared/notifications/shared_prefs_notification_history_repository.dart';
import '../shared/notifications/shared_prefs_notification_preferences_store.dart';

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
  late final SavedFiltersController _savedFiltersController;
  late final AuthApi _authApi;
  late final AuthRepository _authRepository;
  late final AuthStorage _authStorage;
  late final FavoritesApi _favoritesApi;
  late final EventRegistrationApi _eventRegistrationApi;
  late final JoinedEventsController _joinedEventsController;
  late final SessionController _sessionController;
  late final GoRouter _router;
  late final NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _settingsStore = const SharedPreferencesAppSettingsStore();
    _eventRepository = HttpEventRepository();
    _authApi = AuthApi();
    _authStorage = const AuthStorage();
    _authRepository = AuthRepository(api: _authApi, storage: _authStorage);
    _sessionController = SessionController(authRepository: _authRepository);
    _favoritesApi = FavoritesApi();
    _eventRegistrationApi = EventRegistrationApi();
    _joinedEventsController = JoinedEventsController(
      registrationApi: _eventRegistrationApi,
      sessionController: _sessionController,
    );
    _router = createAppRouter(_sessionController);
    _localeController = LocaleController(settingsStore: _settingsStore);
    _themeController = ThemeController(settingsStore: _settingsStore);
    _categoryController = CategoryController(eventRepository: _eventRepository);
    _savedEventsController = SavedEventsController(
      repository: const SharedPreferencesSavedEventsRepository(),
      favoritesApi: _favoritesApi,
      sessionController: _sessionController,
      eventRepository: _eventRepository,
    );
    _savedFiltersController = SavedFiltersController(
      repository: const SharedPreferencesSavedFiltersRepository(),
    );
    _notificationController = NotificationController(
      historyRepository: const SharedPrefsNotificationHistoryRepository(),
      preferencesStore: const SharedPrefsNotificationPreferencesStore(),
    );

    _localeController.load();
    _themeController.load();
    _categoryController.loadCategories();
    _savedEventsController.load();
    _savedFiltersController.loadFilters();
    _joinedEventsController.load();
    _sessionController.load();
    _notificationController.loadHistory();
    _notificationController.loadPreferences();

    NotificationService.init(
      controller: _notificationController,
      router: _router,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncReminders();
      _savedEventsController.addListener(_syncReminders);
      _joinedEventsController.addListener(_syncReminders);
    });
  }

  void _syncReminders() {
    final joinedIds = _joinedEventsController.joinedEventIds;

    final profile = _sessionController.profile;
    if (profile != null) {
      final registrations = profile.eventRegistrations
          .map((r) => (id: r.eventId, title: r.name, startsAt: r.startAt))
          .toList();
      _notificationController.scheduleRemindersForJoinedEvents(registrations);
    }

    final savedEvents = _savedEventsController.events;
    if (savedEvents.isNotEmpty) {
      _notificationController.scheduleRemindersForSavedEvents(
        savedEvents
            .map((e) => (id: e.id, title: e.title, startsAt: e.startsAt))
            .toList(),
        excludeEventIds: joinedIds,
      );
    }
  }

  @override
  void dispose() {
    _savedEventsController.removeListener(_syncReminders);
    _joinedEventsController.removeListener(_syncReminders);
    _localeController.dispose();
    _themeController.dispose();
    _categoryController.dispose();
    _savedEventsController.dispose();
    _savedFiltersController.dispose();
    _joinedEventsController.dispose();
    _sessionController.dispose();
    _notificationController.dispose();
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
          child: SavedFiltersScope(
            controller: _savedFiltersController,
            child: JoinedEventsScope(
              controller: _joinedEventsController,
              child: NotificationScope(
                controller: _notificationController,
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
                        _notificationController,
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
          ),
        ),
      ),
    );
  }
}
