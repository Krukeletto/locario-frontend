import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../features/explore/models.dart';
import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/events/category_scope.dart';
import '../../shared/groups/group_models.dart';
import '../../shared/groups/group_scope.dart';
import '../../shared/widgets/state_panel.dart';

class GroupDiscoverScreen extends StatefulWidget {
  const GroupDiscoverScreen({super.key});

  @override
  State<GroupDiscoverScreen> createState() => _GroupDiscoverScreenState();
}

class _GroupDiscoverScreenState extends State<GroupDiscoverScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;
  bool _initialTabSet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final controller = GroupScope.of(context);
        controller.loadDiscoverGroups();
        controller.loadMyGroups().then((_) {
          if (mounted && !_initialTabSet) {
            setState(() {
              _initialTabSet = true;
            });
            if (controller.myGroups.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _tabController.animateTo(1);
              });
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final controller = GroupScope.of(context);
    if (_initialTabSet &&
        controller.myGroups.isEmpty &&
        _tabController.index == 1) {
      _tabController.index = 0;
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        GroupScope.of(context).loadDiscoverGroups(search: value);
      }
    });
  }

  bool _canCreateGroups(UserProfile? profile) {
    if (profile == null) return false;
    return profile.organizer || profile.admin;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final session = AuthScope.of(context);
    final profile = session.profile;
    final categories = CategoryScope.maybeOf(context)?.categories ?? const [];
    final ctrl = GroupScope.of(context);
    final showMyGroupsDisabled =
        !session.isAuthenticated || ctrl.myGroups.isEmpty;
    final myGroupsDisabled = showMyGroupsDisabled && _initialTabSet;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.groupsDiscoverTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_canCreateGroups(profile))
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  await context.push('/groups/create');
                  if (!mounted) return;
                  unawaited(ctrl.loadDiscoverGroups());
                  unawaited(ctrl.loadMyGroups());
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.groupsCreateCta),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.groupsDiscoverTab),
                  Tab(
                    child: AnimatedDefaultTextStyle(
                      style: theme.textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: myGroupsDisabled
                            ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                            : null,
                      ),
                      duration: const Duration(milliseconds: 200),
                      child: Text(l10n.groupsMyGroupsTab),
                    ),
                  ),
                ],
                labelColor: scheme.primary,
                unselectedLabelColor: scheme.onSurfaceVariant,
                indicatorColor: scheme.primary,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: myGroupsDisabled ? const NeverScrollableScrollPhysics() : null,
        children: [
          _DiscoverTab(
            searchController: _searchController,
            categories: categories,
            selectedCategoryId: ctrl.discoverCategoryId,
            onCategorySelected: (categoryId) {
              ctrl.loadDiscoverGroups(categoryId: categoryId);
            },
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: () =>
                ctrl.loadDiscoverGroups(search: _searchController.text.trim()),
            isLoading: ctrl.isDiscoverLoading,
            error: ctrl.discoverError,
            groups: ctrl.discoverGroups,
            l10n: l10n,
            theme: theme,
            scheme: scheme,
            onRefresh: () async {
              await ctrl.loadDiscoverGroups(forceRefresh: true);
              await ctrl.loadMyGroups(forceRefresh: true);
            },
            onGroupTap: (groupId) async {
              await context.push('/groups/$groupId');
              if (!mounted) return;
              unawaited(ctrl.loadDiscoverGroups());
              unawaited(ctrl.loadMyGroups());
            },
          ),
          _MyGroupsTab(
            isLoading: ctrl.isMyGroupsLoading,
            isAuthenticated: session.isAuthenticated,
            groups: ctrl.myGroups,
            disabled: myGroupsDisabled,
            l10n: l10n,
            theme: theme,
            scheme: scheme,
            onRefresh: () async {
              await ctrl.loadMyGroups(forceRefresh: true);
              await ctrl.loadDiscoverGroups(forceRefresh: true);
            },
            onGroupTap: (groupId) async {
              await context.push('/groups/$groupId');
              if (!mounted) return;
              unawaited(ctrl.loadDiscoverGroups());
              unawaited(ctrl.loadMyGroups());
            },
          ),
        ],
      ),
    );
  }
}

class _MyGroupsTab extends StatelessWidget {
  const _MyGroupsTab({
    required this.isLoading,
    required this.isAuthenticated,
    required this.groups,
    required this.disabled,
    required this.l10n,
    required this.theme,
    required this.scheme,
    required this.onRefresh,
    required this.onGroupTap,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final List<Group> groups;
  final bool disabled;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme scheme;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String groupId) onGroupTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!isAuthenticated)
            _EmptyCard(
              title: l10n.groupsMyGroupsEmptyTitle,
              subtitle: l10n.groupsMyGroupsEmptySubtitle,
            )
          else if (groups.isEmpty)
            _EmptyCard(
              title: l10n.groupsMyGroupsEmptyTitle,
              subtitle: l10n.groupsMyGroupsEmptySubtitle,
            )
          else
            ...groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: disabled ? 0.5 : 1.0,
                  child: _GroupCard(
                    group: group,
                    onTap: () => onGroupTap(group.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab({
    required this.searchController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.isLoading,
    required this.error,
    required this.groups,
    required this.l10n,
    required this.theme,
    required this.scheme,
    required this.onRefresh,
    required this.onGroupTap,
  });

  final TextEditingController searchController;
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onSearchSubmitted;
  final bool isLoading;
  final Object? error;
  final List<Group> groups;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme scheme;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String groupId) onGroupTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _SearchCard(
            controller: searchController,
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: onCategorySelected,
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            SizedBox(
              height: 320,
              child: StatePanel.loading(
                title: l10n.groupsLoadingTitle,
                subtitle: l10n.groupsLoadingSubtitle,
              ),
            )
          else if (error != null)
            SizedBox(
              height: 320,
              child: StatePanel.error(
                title: l10n.groupsErrorTitle,
                subtitle: l10n.groupsErrorSubtitle,
                retryLabel: l10n.exploreRetryButton,
                onRetry: onRefresh,
              ),
            )
          else if (groups.isEmpty)
            _EmptyCard(
              title: l10n.groupsDiscoverEmptyTitle,
              subtitle: l10n.groupsDiscoverEmptySubtitle,
            )
          else
            ...groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GroupCard(
                  group: group,
                  onTap: () => onGroupTap(group.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onSubmitted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final Future<void> Function() onSubmitted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted(),
            decoration: InputDecoration(
              hintText: l10n.groupsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: onSubmitted,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l10n.groupsCategoryAll),
                    selected: selectedCategoryId == null,
                    onSelected: (_) => onCategorySelected(null),
                  ),
                ),
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: selectedCategoryId == category.id,
                      onSelected: (_) => onCategorySelected(category.id),
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_2_outlined, color: scheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onTap});

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final membershipLabel = switch (group.currentUserMembership) {
      GroupMembershipStatus.active => l10n.groupsMembershipActive,
      GroupMembershipStatus.pending => l10n.groupsMembershipPending,
      GroupMembershipStatus.banned => l10n.groupsMembershipBanned,
      _ => null,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.group_work_outlined, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((group.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      group.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: group.categoryName ?? l10n.groupsCategoryUnknown,
                      ),
                      _MetaChip(
                        label: group.isPublic
                            ? l10n.groupsVisibilityPublic
                            : l10n.groupsVisibilityPrivate,
                      ),
                      _MetaChip(
                        label: l10n.groupsMembersCount(group.memberCount),
                      ),
                      if (membershipLabel != null)
                        _MetaChip(label: membershipLabel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: scheme.onSurface.withValues(alpha: 0.38),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
