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
import '../shared/events/event_detail_controller.dart';
import '../shared/events/event_detail_scope.dart';
import '../shared/events/category_controller.dart';
import '../shared/events/category_scope.dart';
import '../shared/cache/cache_scope.dart';
import '../shared/cache/cache_service.dart';
import '../shared/groups/group_controller.dart';
import '../shared/groups/group_scope.dart';
import '../shared/groups/group_repository.dart';
import '../shared/reviews/review_controller.dart';
import '../shared/reviews/review_scope.dart';
import '../shared/reviews/review_repository.dart';
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
import '../shared/notifications/api_notification_history_repository.dart';
import '../shared/notifications/notification_controller.dart';
import '../shared/notifications/notification_scope.dart';
import '../shared/notifications/notification_service.dart';
import '../shared/notifications/notifications_api.dart';
import '../shared/notifications/shared_prefs_notification_history_repository.dart';
import '../shared/notifications/shared_prefs_notification_preferences_store.dart';
import '../features/legals/legal_controller.dart';
import '../features/legals/legal_scope.dart';
import '../features/legals/shared_prefs_legal_acceptance_store.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/onboarding_scope.dart';

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
  late final EventRegistrationApi _eventRegistrationApi;
  late final GroupRepository _groupRepository;
  late final ReviewRepository _reviewRepository;
  late final CacheService _cacheService;
  late final GroupController _groupController;
  late final EventDetailController _eventDetailController;
  late final ReviewController _reviewController;
  late final SavedEventsController _savedEventsController;
  late final SavedFiltersController _savedFiltersController;
  late final AuthApi _authApi;
  late final AuthRepository _authRepository;
  late final AuthStorage _authStorage;
  late final FavoritesApi _favoritesApi;
  late final JoinedEventsController _joinedEventsController;
  late final SessionController _sessionController;
  late final LegalController _legalController;
  late final OnboardingController _onboardingController;
  late final GoRouter _router;
  late final NotificationsApi _notificationsApi;
  late final NotificationController _notificationController;
  bool _hasInitializedNotifications = false;

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
    _groupRepository = HttpGroupRepository();
    _reviewRepository = HttpReviewRepository();
    _cacheService = CacheService();
    _cacheService.init();
    _groupController = GroupController(
      groupRepository: _groupRepository,
      eventRepository: _eventRepository,
      cacheService: _cacheService,
      sessionController: _sessionController,
    );
    _eventDetailController = EventDetailController(
      eventRepository: _eventRepository,
      registrationApi: _eventRegistrationApi,
      cacheService: _cacheService,
      sessionController: _sessionController,
    );
    _reviewController = ReviewController(
      reviewRepository: _reviewRepository,
      cacheService: _cacheService,
      sessionController: _sessionController,
    );
    _joinedEventsController = JoinedEventsController(
      registrationApi: _eventRegistrationApi,
      sessionController: _sessionController,
    );
    _legalController = LegalController(
      store: const SharedPrefsLegalAcceptanceStore(),
      sessionController: _sessionController,
    );
    _onboardingController = OnboardingController(settingsStore: _settingsStore);
    _router = createAppRouter(
      sessionController: _sessionController,
      legalController: _legalController,
      onboardingController: _onboardingController,
    );
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
    _notificationsApi = NotificationsApi();
    _notificationController = NotificationController(
      historyRepository: ApiNotificationHistoryRepository(
        api: _notificationsApi,
        tokenProvider: () => _sessionController.tokens?.accessToken,
        localCache: const SharedPrefsNotificationHistoryRepository(),
      ),
      preferencesStore: const SharedPrefsNotificationPreferencesStore(),
      api: _notificationsApi,
      sessionController: _sessionController,
    );
    NotificationService.cancelAllLocalNotifications();

    _localeController.load();
    _themeController.load();
    _categoryController.loadCategories();
    _savedEventsController.load();
    _savedFiltersController.loadFilters();
    _joinedEventsController.load();
    _sessionController.load();
    _sessionController.addListener(_onSessionChanged);
    _onboardingController.addListener(_onOnboardingChanged);
    _legalController.load();
    _onboardingController.load().then((_) {
      if (!mounted) return;
      _initNotificationsIfAllowed();
    });
    _notificationController.loadHistory();
    _notificationController.loadPreferences();
  }

  void _onSessionChanged() {
    if (_sessionController.isAuthenticated &&
        _sessionController.tokens != null) {
      _groupController.loadMyGroups();
      _notificationController.retryDeviceRegistrationIfNeeded();
    } else {
      _cacheService.invalidateByPrefix('my_groups');
      _groupController.loadMyGroups(forceRefresh: true);
    }
  }

  void _onOnboardingChanged() {
    _initNotificationsIfAllowed();
  }

  void _initNotificationsIfAllowed() {
    if (_hasInitializedNotifications || !_onboardingController.isCompleted) {
      return;
    }

    _hasInitializedNotifications = true;
    NotificationService.init(
      controller: _notificationController,
      router: _router,
    );
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    _onboardingController.removeListener(_onOnboardingChanged);
    _localeController.dispose();
    _themeController.dispose();
    _categoryController.dispose();
    _groupController.dispose();
    _eventDetailController.dispose();
    _reviewController.dispose();
    _savedEventsController.dispose();
    _savedFiltersController.dispose();
    _joinedEventsController.dispose();
    _legalController.dispose();
    _onboardingController.dispose();
    _sessionController.dispose();
    _notificationController.dispose();
    _cacheService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScope(
      controller: _categoryController,
      child: CacheScope(
        cacheService: _cacheService,
        child: AuthScope(
          controller: _sessionController,
          child: GroupScope(
            controller: _groupController,
            child: EventDetailScope(
              controller: _eventDetailController,
              child: ReviewScope(
                controller: _reviewController,
                child: LegalScope(
                  controller: _legalController,
                  child: OnboardingScope(
                    controller: _onboardingController,
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
                                      scaffoldMessengerKey:
                                          rootScaffoldMessengerKey,
                                      onGenerateTitle: (context) =>
                                          AppLocalizations.of(context).appTitle,
                                      debugShowCheckedModeBanner: false,
                                      theme: buildLightAppTheme(),
                                      darkTheme: buildDarkAppTheme(),
                                      themeMode: _themeController.themeMode,
                                      routerConfig: _router,
                                      locale: _localeController.locale,
                                      supportedLocales:
                                          AppLocalizations.supportedLocales,
                                      localizationsDelegates: const [
                                        AppLocalizations.delegate,
                                        GlobalMaterialLocalizations.delegate,
                                        GlobalWidgetsLocalizations.delegate,
                                        GlobalCupertinoLocalizations.delegate,
                                      ],
                                      builder: (context, child) {
                                        final l10n = AppLocalizations.of(
                                          context,
                                        );
                                        L10nService.update(l10n);
                                        return child!;
                                      },
                                      localeResolutionCallback:
                                          (locale, supportedLocales) {
                                            if (locale == null) {
                                              return const Locale('pl');
                                            }

                                            for (final supportedLocale
                                                in supportedLocales) {
                                              if (supportedLocale
                                                      .languageCode ==
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
