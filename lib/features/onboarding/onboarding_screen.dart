import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../app/locale/locale_scope.dart';
import '../../shared/permissions/app_permission_service.dart';
import 'onboarding_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, AppPermissionService? permissionService})
    : _permissionService = permissionService;

  final AppPermissionService? _permissionService;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final AppPermissionService _permissionService;

  int _step = 0;
  bool _isCompleting = false;
  bool _isRequestingLocation = false;
  bool _isRequestingNotifications = false;
  AppPermissionSnapshot? _permissions;

  static const _lastStep = 3;

  @override
  void initState() {
    super.initState();
    _permissionService =
        widget._permissionService ?? DeviceAppPermissionService();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final permissions = await _permissionService.loadStatus();
    if (!mounted) return;
    setState(() => _permissions = permissions);
  }

  Future<void> _requestLocation() async {
    if (_isRequestingLocation) return;
    setState(() => _isRequestingLocation = true);
    await _permissionService.requestLocation();
    await _loadPermissions();
    if (mounted) {
      setState(() => _isRequestingLocation = false);
    }
  }

  Future<void> _requestNotifications() async {
    if (_isRequestingNotifications) return;
    setState(() => _isRequestingNotifications = true);
    await _permissionService.requestNotifications();
    await _loadPermissions();
    if (mounted) {
      setState(() => _isRequestingNotifications = false);
    }
  }

  Future<void> _openSettingsAndRefresh() async {
    await _permissionService.openAppSettings();
    await _loadPermissions();
  }

  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    await OnboardingScope.of(context).complete();
    if (!mounted) return;
    context.go('/explore');
  }

  void _next() {
    if (_step == _lastStep) {
      _complete();
      return;
    }

    setState(() => _step += 1);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Row(
                children: List.generate(_lastStep + 1, (index) {
                  final active = index <= _step;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index == _lastStep ? 0 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? scheme.primary
                            : scheme.outline.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: switch (_step) {
                    0 => _WelcomeStep(l10n: l10n),
                    1 => _PermissionsInfoStep(l10n: l10n),
                    2 => _GrantPermissionsStep(
                      l10n: l10n,
                      permissions: _permissions,
                      isRequestingLocation: _isRequestingLocation,
                      isRequestingNotifications: _isRequestingNotifications,
                      onRequestLocation: _requestLocation,
                      onRequestNotifications: _requestNotifications,
                      onOpenSettings: _openSettingsAndRefresh,
                    ),
                    _ => _DoneStep(l10n: l10n),
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _isCompleting ? null : _back,
                      child: Text(l10n.onboardingBack),
                    )
                  else
                    const SizedBox(width: 88),
                  const Spacer(),
                  if (_step == 2)
                    TextButton(
                      onPressed: _isCompleting ? null : _next,
                      child: Text(l10n.onboardingSkip),
                    ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _isCompleting ? null : _next,
                    child: _isCompleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _step == _lastStep
                                ? l10n.onboardingFinish
                                : l10n.onboardingNext,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localeController = LocaleScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroIcon(icon: Icons.location_city_rounded),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingWelcomeTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingWelcomeBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 28),
        _SectionLabel(text: l10n.onboardingLanguageTitle),
        const SizedBox(height: 10),
        SegmentedButton<Locale>(
          key: const Key('onboarding-language-segmented'),
          showSelectedIcon: false,
          segments: [
            ButtonSegment<Locale>(
              value: const Locale('pl'),
              label: Text(l10n.localePolish),
            ),
            ButtonSegment<Locale>(
              value: const Locale('en'),
              label: Text(l10n.localeEnglish),
            ),
          ],
          selected: {localeController.locale},
          onSelectionChanged: (selection) {
            localeController.setLocale(selection.first);
          },
        ),
        const SizedBox(height: 28),
        _ValueTile(
          icon: Icons.map_rounded,
          title: l10n.onboardingValueMapTitle,
          subtitle: l10n.onboardingValueMapBody,
        ),
        _ValueTile(
          icon: Icons.view_list_rounded,
          title: l10n.onboardingValueListTitle,
          subtitle: l10n.onboardingValueListBody,
        ),
        _ValueTile(
          icon: Icons.bookmark_rounded,
          title: l10n.onboardingValueSavedTitle,
          subtitle: l10n.onboardingValueSavedBody,
        ),
      ],
    );
  }
}

class _PermissionsInfoStep extends StatelessWidget {
  const _PermissionsInfoStep({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroIcon(icon: Icons.privacy_tip_rounded),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingPermissionsTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingPermissionsBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        _ValueTile(
          icon: Icons.my_location_rounded,
          title: l10n.onboardingPermissionLocationTitle,
          subtitle: l10n.onboardingPermissionLocationBody,
        ),
        _ValueTile(
          icon: Icons.notifications_active_rounded,
          title: l10n.onboardingPermissionNotificationsTitle,
          subtitle: l10n.onboardingPermissionNotificationsBody,
        ),
        _ValueTile(
          icon: Icons.photo_library_rounded,
          title: l10n.onboardingPermissionPhotosTitle,
          subtitle: l10n.onboardingPermissionPhotosBody,
        ),
        _ValueTile(
          icon: Icons.calendar_month_rounded,
          title: l10n.onboardingPermissionCalendarTitle,
          subtitle: l10n.onboardingPermissionCalendarBody,
        ),
      ],
    );
  }
}

class _GrantPermissionsStep extends StatelessWidget {
  const _GrantPermissionsStep({
    required this.l10n,
    required this.permissions,
    required this.isRequestingLocation,
    required this.isRequestingNotifications,
    required this.onRequestLocation,
    required this.onRequestNotifications,
    required this.onOpenSettings,
  });

  final AppLocalizations l10n;
  final AppPermissionSnapshot? permissions;
  final bool isRequestingLocation;
  final bool isRequestingNotifications;
  final VoidCallback onRequestLocation;
  final VoidCallback onRequestNotifications;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroIcon(icon: Icons.tune_rounded),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingGrantTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingGrantBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        _PermissionActionTile(
          icon: Icons.my_location_rounded,
          title: l10n.onboardingPermissionLocationTitle,
          status: permissions?.location,
          actionLabel: l10n.onboardingGrantLocation,
          isBusy: isRequestingLocation,
          onPressed: _shouldOpenSettings(permissions?.location)
              ? onOpenSettings
              : () async => onRequestLocation(),
        ),
        const SizedBox(height: 12),
        _PermissionActionTile(
          icon: Icons.notifications_active_rounded,
          title: l10n.onboardingPermissionNotificationsTitle,
          status: permissions?.notifications,
          actionLabel: l10n.onboardingGrantNotifications,
          isBusy: isRequestingNotifications,
          onPressed: _shouldOpenSettings(permissions?.notifications)
              ? onOpenSettings
              : () async => onRequestNotifications(),
        ),
      ],
    );
  }

  bool _shouldOpenSettings(AppPermissionStatus? status) {
    return status == AppPermissionStatus.permanentlyDenied ||
        status == AppPermissionStatus.restricted;
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroIcon(icon: Icons.check_circle_rounded),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingDoneTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingDoneBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PermissionActionTile extends StatelessWidget {
  const _PermissionActionTile({
    required this.icon,
    required this.title,
    required this.status,
    required this.actionLabel,
    required this.isBusy,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final AppPermissionStatus? status;
  final String actionLabel;
  final bool isBusy;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final granted =
        status == AppPermissionStatus.granted ||
        status == AppPermissionStatus.limited;
    final needsSettings =
        status == AppPermissionStatus.permanentlyDenied ||
        status == AppPermissionStatus.restricted;
    final statusColor = granted
        ? Colors.green
        : needsSettings
        ? scheme.error
        : scheme.onSurface.withValues(alpha: 0.62);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusText(l10n, status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!granted)
            FilledButton.tonal(
              onPressed: isBusy ? null : onPressed,
              child: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(needsSettings ? l10n.permissionFix : actionLabel),
            ),
        ],
      ),
    );
  }

  String _statusText(AppLocalizations l10n, AppPermissionStatus? status) {
    return switch (status) {
      AppPermissionStatus.granted => l10n.permissionStatusGranted,
      AppPermissionStatus.limited => l10n.permissionStatusLimited,
      AppPermissionStatus.permanentlyDenied => l10n.permissionStatusBlocked,
      AppPermissionStatus.restricted => l10n.permissionStatusBlocked,
      AppPermissionStatus.unsupported => l10n.permissionStatusUnsupported,
      AppPermissionStatus.denied || null => l10n.permissionStatusMissing,
    };
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: scheme.primary, size: 34),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
