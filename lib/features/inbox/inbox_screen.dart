import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/notifications/notification_entry.dart';
import 'package:locario/shared/notifications/notification_scope.dart';
import 'package:locario/shared/notifications/notification_type.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final controller = NotificationScope.of(context);
      if (controller.hasMoreHistoryPages) {
        controller.loadMoreHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final controller = NotificationScope.of(context);

    final allHistory = controller.history;
    final unread = allHistory.where((e) => !e.isRead).toList();
    final read = allHistory.where((e) => e.isRead).toList();
    final showLoader = controller.hasMoreHistoryPages;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          titleSpacing: 8,
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.18),
                ),
              ),
              child: IconButton(
                onPressed: () async {
                  if (!await Navigator.of(context).maybePop()) {
                    if (context.mounted) context.go('/explore');
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: scheme.primary,
                  size: 18,
                ),
              ),
            ),
          ),
          title: Text(
            l10n.tabInbox,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          bottom: allHistory.isNotEmpty
              ? TabBar(
                  tabs: [
                    Tab(text: 'Unread (${unread.length})'),
                    Tab(text: 'All (${allHistory.length})'),
                  ],
                  labelColor: scheme.primary,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  indicatorColor: scheme.primary,
                )
              : null,
          actions: [
            if (controller.unreadCount > 0)
              TextButton(
                onPressed: () => controller.markAllAsRead(),
                child: Text(l10n.inboxMarkAllRead),
              ),
          ],
        ),
        body: allHistory.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 64,
                        color: scheme.onSurface.withValues(alpha: 0.24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.inboxEmpty,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.48),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : TabBarView(
                children: [
                  _buildUnreadTab(unread: unread, scheme: scheme, theme: theme),
                  _buildAllTab(
                    unread: unread,
                    read: read,
                    scheme: scheme,
                    theme: theme,
                    showLoader: showLoader,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUnreadTab({
    required List<NotificationEntry> unread,
    required ColorScheme scheme,
    required ThemeData theme,
  }) {
    if (unread.isEmpty) {
      return Center(
        child: Text(
          'No unread notifications',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.48),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
      itemCount: unread.length,
      itemBuilder: (context, index) => _NotificationTile(
        entry: unread[index],
        onTap: () => _onNotificationTap(unread[index]),
      ),
    );
  }

  Widget _buildAllTab({
    required List<NotificationEntry> unread,
    required List<NotificationEntry> read,
    required ColorScheme scheme,
    required ThemeData theme,
    required bool showLoader,
  }) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (unread.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Unread (${unread.length})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _NotificationTile(
                entry: unread[index],
                onTap: () => _onNotificationTap(unread[index]),
              ),
              childCount: unread.length,
            ),
          ),
        ],
        if (read.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Read (${read.length})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Opacity(
                opacity: 0.72,
                child: _NotificationTile(
                  entry: read[index],
                  onTap: () => _onNotificationTap(read[index]),
                ),
              ),
              childCount: read.length,
            ),
          ),
        ],
        if (showLoader)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  void _onNotificationTap(NotificationEntry entry) {
    final controller = NotificationScope.of(context);
    controller.markAsRead(entry.id);
    final route = entry.route;
    if (route != null && route.isNotEmpty) {
      context.go(route);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.entry, required this.onTap});

  final NotificationEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: entry.isRead
                ? scheme.surfaceContainerLow.withValues(alpha: 0.6)
                : scheme.primaryContainer.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: entry.isRead
                  ? scheme.outline.withValues(alpha: 0.16)
                  : scheme.primary.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: entry.isRead
                      ? scheme.surfaceContainerHigh
                      : scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.type.icon,
                  color: entry.isRead
                      ? scheme.onSurface.withValues(alpha: 0.48)
                      : scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: entry.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!entry.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.64),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(entry.timestamp, l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return l10n.relativeTimeNow;
    if (diff.inMinutes < 60) {
      return l10n.relativeTimeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) return l10n.relativeTimeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.relativeTimeDaysAgo(diff.inDays);

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
