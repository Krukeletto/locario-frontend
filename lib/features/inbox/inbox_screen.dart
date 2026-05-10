import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/notifications/notification_entry.dart';
import 'package:locario/shared/notifications/notification_controller.dart';
import 'package:locario/shared/notifications/notification_scope.dart';
import 'package:locario/shared/notifications/notification_type.dart';

enum _InboxFilter { unread, all }

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _scrollController = ScrollController();
  _InboxFilter _filter = _InboxFilter.unread;
  bool _showRead = false;

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

    return Scaffold(
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
              border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
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
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: _FilterBar(
                      filter: _filter,
                      unreadCount: unread.length,
                      allCount: allHistory.length,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                  ),
                ),
                if (_filter == _InboxFilter.unread) ...[
                  if (unread.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Text(
                            'No unread notifications',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.48),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _NotificationTile(
                          entry: unread[index],
                          onTap: () =>
                              _onNotificationTap(controller, unread[index]),
                        ),
                        childCount: unread.length,
                      ),
                    ),
                  if (showLoader)
                    SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  if (read.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _filter = _InboxFilter.all),
                          icon: const Icon(Icons.expand_more_rounded, size: 18),
                          label: Text('Show read (${read.length})'),
                        ),
                      ),
                    ),
                ] else ...[
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
                          onTap: () =>
                              _onNotificationTap(controller, unread[index]),
                        ),
                        childCount: unread.length,
                      ),
                    ),
                  ],
                  if (read.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() => _showRead = !_showRead),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Read (${read.length})',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 200),
                                  turns: _showRead ? 0.5 : 0,
                                  child: Icon(
                                    Icons.expand_more_rounded,
                                    size: 20,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_showRead)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Opacity(
                            opacity: 0.72,
                            child: _NotificationTile(
                              entry: read[index],
                              onTap: () =>
                                  _onNotificationTap(controller, read[index]),
                            ),
                          ),
                          childCount: read.length,
                        ),
                      ),
                  ],
                  if (showLoader)
                    SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _filter = _InboxFilter.unread),
                        icon: const Icon(Icons.expand_less_rounded, size: 18),
                        label: const Text('Show unread only'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  void _onNotificationTap(
    NotificationController controller,
    NotificationEntry entry,
  ) {
    controller.markAsRead(entry.id);
    final route = entry.route;
    if (route != null && route.isNotEmpty) {
      context.go(route);
    }
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.unreadCount,
    required this.allCount,
    required this.onChanged,
  });

  final _InboxFilter filter;
  final int unreadCount;
  final int allCount;
  final ValueChanged<_InboxFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_InboxFilter>(
      segments: [
        ButtonSegment(
          value: _InboxFilter.unread,
          label: Text('Unread ($unreadCount)'),
          icon: const Icon(Icons.mark_email_unread_rounded, size: 18),
        ),
        ButtonSegment(
          value: _InboxFilter.all,
          label: Text('All ($allCount)'),
          icon: const Icon(Icons.inbox_rounded, size: 18),
        ),
      ],
      selected: {filter},
      onSelectionChanged: (v) => onChanged(v.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
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
                      _formatTimestamp(entry.timestamp),
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

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
