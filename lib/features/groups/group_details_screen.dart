import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../features/explore/models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/groups/group_models.dart';
import '../../shared/groups/group_scope.dart';
import '../../shared/widgets/state_panel.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final TextEditingController _postController = TextEditingController();
  final ScrollController _feedScrollController = ScrollController();

  bool _isSubmittingPost = false;

  @override
  void initState() {
    super.initState();
    _feedScrollController.addListener(_onFeedScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        GroupScope.of(context).loadGroupDetail(widget.groupId);
      }
    });
  }

  @override
  void dispose() {
    _feedScrollController.removeListener(_onFeedScroll);
    _feedScrollController.dispose();
    _postController.dispose();
    super.dispose();
  }

  bool _canModerate(Group group, String? userId, bool isGlobalAdmin) {
    if (isGlobalAdmin) return true;
    return group.ownerUserId == userId ||
        group.currentUserRole == GroupRole.admin;
  }

  bool _canDeleteGroup(Group group, String? userId) {
    return group.ownerUserId == userId;
  }

  bool _canTransferOwnership(Group group, String? userId) {
    return group.ownerUserId == userId;
  }

  bool _canCreateGroupsEvents(Group group) {
    final session = AuthScope.of(context);
    final profile = session.profile;
    if (session.tokens == null || profile == null) return false;
    return profile.admin ||
        group.ownerUserId == profile.id ||
        group.currentUserRole == GroupRole.admin ||
        group.currentUserMembership == GroupMembershipStatus.active;
  }

  Future<void> _handleJoinOrLeave() async {
    final ctrl = GroupScope.of(context);
    final group = ctrl.detailGroup;
    final l10n = AppLocalizations.of(context);
    if (group == null) return;

    final session = AuthScope.of(context);
    if (session.tokens == null) {
      await context.push(
        '/auth/login?from=${Uri.encodeComponent('/groups/${group.id}')}&target=${Uri.encodeComponent('/groups/${group.id}')}',
      );
      return;
    }

    try {
      if (group.isMember || group.isPending) {
        await ctrl.leaveGroup(group.id);
      } else {
        await ctrl.joinGroup(group.id);
      }
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleCreatePost({GroupPost? editingPost}) async {
    final ctrl = GroupScope.of(context);
    final group = ctrl.detailGroup;
    if (group == null) return;

    final session = AuthScope.of(context);
    if (session.tokens == null) return;

    final l10n = AppLocalizations.of(context);
    final content = await showDialog<String>(
      context: context,
      builder: (context) => _PostComposerDialog(
        title: editingPost == null
            ? l10n.groupsPostCreateTitle
            : l10n.groupsPostEditTitle,
        hintText: l10n.groupsPostHint,
        initialValue: editingPost?.content ?? '',
        cancelLabel: l10n.profileBecomeOrganizerDialogCancel,
        confirmLabel: editingPost == null
            ? l10n.groupsPostPublish
            : l10n.groupsSaveChanges,
      ),
    );

    if (content == null || content.isEmpty) return;

    setState(() {
      _isSubmittingPost = true;
    });

    try {
      if (editingPost == null) {
        await ctrl.createPost(group.id, content);
      } else {
        await ctrl.updatePost(group.id, editingPost.id, content);
      }
      if (!mounted) return;
      _postController.clear();
      await ctrl.loadGroupFeed(group.id, page: 0);
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.groupsActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingPost = false;
        });
      }
    }
  }

  Future<void> _handleDeletePost(GroupFeedItem item) async {
    final ctrl = GroupScope.of(context);
    final group = ctrl.detailGroup;
    final l10n = AppLocalizations.of(context);
    if (group == null) return;

    final confirmed = await _confirm(
      title: l10n.groupsDeletePostTitle,
      body: l10n.groupsDeletePostBody,
    );
    if (!confirmed) return;

    try {
      await ctrl.deletePost(group.id, item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.groupsPostDeleteSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleHidePost(GroupFeedItem item) async {
    final ctrl = GroupScope.of(context);
    final group = ctrl.detailGroup;
    final l10n = AppLocalizations.of(context);
    if (group == null) return;

    try {
      await ctrl.hidePost(group.id, item.id);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleApproveRequest(GroupMember member) async {
    final ctrl = GroupScope.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      await ctrl.approveJoinRequest(widget.groupId, member.userId);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleRejectRequest(GroupMember member) async {
    final ctrl = GroupScope.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      await ctrl.rejectJoinRequest(widget.groupId, member.userId);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleMemberAction(
    GroupMember member,
    _MemberAction action,
  ) async {
    final ctrl = GroupScope.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      switch (action) {
        case _MemberAction.makeAdmin:
          await ctrl.changeRole(widget.groupId, member.userId, GroupRole.admin);
        case _MemberAction.makeMember:
          await ctrl.changeRole(
            widget.groupId,
            member.userId,
            GroupRole.member,
          );
        case _MemberAction.ban:
          await ctrl.banMember(widget.groupId, member.userId);
        case _MemberAction.unban:
          await ctrl.unbanMember(widget.groupId, member.userId);
        case _MemberAction.remove:
          await ctrl.removeMember(widget.groupId, member.userId);
        case _MemberAction.transferOwnership:
          await ctrl.transferOwnership(widget.groupId, member.userId);
      }
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleCreateEventForGroup() async {
    final group = GroupScope.of(context).detailGroup;
    if (group == null) return;

    await context.push(
      '/hub/create-event?groupId=${Uri.encodeQueryComponent(group.id)}',
    );
    if (!mounted) return;
    unawaited(GroupScope.of(context).loadGroupEvents(group.id));
  }

  Future<void> _handleLinkExistingEvent() async {
    final ctrl = GroupScope.of(context);
    final group = ctrl.detailGroup;
    final l10n = AppLocalizations.of(context);
    if (group == null) return;

    try {
      final events = await ctrl.fetchOrganizerEvents();
      if (!mounted) return;
      final selected = await showModalBottomSheet<ExploreEvent>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final event in events)
                ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.timeLabel(l10n)),
                  onTap: () => Navigator.of(context).pop(event),
                ),
            ],
          ),
        ),
      );
      if (selected == null) return;
      await ctrl.linkEvent(group.id, selected.id);
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.groupsActionFailed);
    }
  }

  void _onFeedScroll() {
    final ctrl = GroupScope.of(context);
    if (!_feedScrollController.hasClients ||
        !ctrl.hasMoreFeed ||
        ctrl.isLoadingMoreFeed) {
      return;
    }
    if (_feedScrollController.position.pixels >=
        _feedScrollController.position.maxScrollExtent - 200) {
      ctrl.loadMoreGroupFeed(widget.groupId);
    }
  }

  Future<void> _showReportDialog({
    required String title,
    required Future<GroupReport> Function(String reason, String? description)
    submit,
  }) async {
    final l10n = AppLocalizations.of(context);
    final payload = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => _GroupReportDialog(title: title),
    );

    if (payload == null || payload.$1.isEmpty) return;

    try {
      await submit(payload.$1, payload.$2);
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleDeleteGroup() async {
    final ctrl = GroupScope.of(context);
    final group = ctrl.detailGroup;
    final l10n = AppLocalizations.of(context);
    if (group == null) return;

    final confirmed = await _confirm(
      title: l10n.groupsDeleteGroupTitle,
      body: l10n.groupsDeleteGroupBody,
    );
    if (!confirmed) return;

    try {
      await ctrl.deleteGroup(group.id);
      if (!mounted) return;
      context.go('/hub/community');
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.profileBecomeOrganizerDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.groupsConfirmAction),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final ctrl = GroupScope.of(context);

    if (ctrl.isDetailLoading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(child: CircularProgressIndicator(color: scheme.primary)),
      );
    }

    if (ctrl.detailError != null || ctrl.detailGroup == null) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.groupsErrorSubtitle, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ctrl.loadGroupDetail(widget.groupId),
                  child: Text(l10n.exploreRetryButton),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final group = ctrl.detailGroup!;
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final profile = session.profile;
    final canModerate = _canModerate(
      group,
      profile?.id,
      profile?.admin == true,
    );
    final canDeleteGroup = _canDeleteGroup(group, profile?.id);
    final canTransferOwnership = _canTransferOwnership(group, profile?.id);
    final canCreateEvents = _canCreateGroupsEvents(group);
    final canLinkEvents = canCreateEvents;

    return DefaultTabController(
      initialIndex: group.isMember ? 0 : 3,
      length: 4,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            group.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'report') {
                  if (tokens == null) return;
                  await _showReportDialog(
                    title: l10n.groupsReportGroupTitle,
                    submit: (reason, description) => ctrl.reportGroup(
                      group.id,
                      GroupReportRequest(
                        targetType: 'group',
                        targetId: group.id,
                        reason: reason,
                        description: description,
                        groupId: group.id,
                      ),
                    ),
                  );
                } else if (value == 'edit') {
                  await context.push('/groups/${group.id}/edit');
                  if (!mounted) return;
                  unawaited(
                    ctrl.loadGroupDetail(widget.groupId, refreshOnly: true),
                  );
                } else if (value == 'delete') {
                  await _handleDeleteGroup();
                }
              },
              itemBuilder: (context) => [
                if (tokens != null)
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text(l10n.groupsReportGroupAction),
                  ),
                if (canModerate)
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text(l10n.groupsEditAction),
                  ),
                if (canDeleteGroup)
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(l10n.groupsDeleteAction),
                  ),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: l10n.groupsTabFeed),
              Tab(text: l10n.groupsTabEvents),
              Tab(text: l10n.groupsTabMembers),
              Tab(text: l10n.groupsTabInfo),
            ],
          ),
        ),
        body: Column(
          children: [
            if (ctrl.isDetailRefreshing) const LinearProgressIndicator(),
            Expanded(
              child: TabBarView(
                children: [
                  _FeedTab(
                    canPost: group.isMember,
                    currentUserId: profile?.id,
                    isSubmittingPost: _isSubmittingPost,
                    isLoading: false,
                    error: null,
                    isLoadingMore: ctrl.isLoadingMoreFeed,
                    scrollController: _feedScrollController,
                    items: ctrl.detailFeed,
                    events: ctrl.detailEvents,
                    onRetry: () => ctrl.loadGroupFeed(widget.groupId, page: 0),
                    onCreatePost: () => _handleCreatePost(),
                    onEditPost: (item) => _handleCreatePost(
                      editingPost: GroupPost(
                        id: item.id,
                        content: item.content,
                      ),
                    ),
                    onDeletePost: _handleDeletePost,
                    onHidePost: _handleHidePost,
                    onOpenEvent: (eventId) => context.push('/events/$eventId'),
                    onReportPost: (item) async {
                      if (tokens == null) return;
                      await _showReportDialog(
                        title: l10n.groupsReportPostTitle,
                        submit: (reason, description) => ctrl.reportPost(
                          group.id,
                          item.id,
                          GroupReportRequest(
                            targetType: 'post',
                            targetId: item.id,
                            reason: reason,
                            description: description,
                            groupId: group.id,
                          ),
                        ),
                      );
                    },
                    onReportEvent: (item) async {
                      if (tokens == null || item.eventId == null) return;
                      await _showReportDialog(
                        title: l10n.groupsReportEventTitle,
                        submit: (reason, description) => ctrl.reportEvent(
                          group.id,
                          item.eventId!,
                          GroupReportRequest(
                            targetType: 'group_event',
                            targetId: item.eventId!,
                            reason: reason,
                            description: description,
                            groupId: group.id,
                          ),
                        ),
                      );
                    },
                  ),
                  _EventsTab(
                    events: ctrl.detailEvents,
                    isLoading: false,
                    error: null,
                    canCreateEvents: canCreateEvents,
                    canLinkEvents: canLinkEvents,
                    onRetry: () => ctrl.loadGroupEvents(widget.groupId),
                    onCreateEvent: _handleCreateEventForGroup,
                    onLinkEvent: _handleLinkExistingEvent,
                    onOpenEvent: (event) => context.push('/events/${event.id}'),
                  ),
                  _MembersTab(
                    members: ctrl.detailMembers,
                    isLoadingMembers: false,
                    membersError: null,
                    joinRequests: ctrl.detailJoinRequests,
                    isLoadingJoinRequests: false,
                    joinRequestsError: null,
                    canModerate: canModerate,
                    ownerUserId: group.ownerUserId,
                    currentUserId: profile?.id,
                    onRetryMembers: () => ctrl.loadGroupMembers(widget.groupId),
                    onRetryJoinRequests: () =>
                        ctrl.loadGroupJoinRequests(widget.groupId),
                    onApproveRequest: _handleApproveRequest,
                    onRejectRequest: _handleRejectRequest,
                    onMemberAction: _handleMemberAction,
                    canTransferOwnership: canTransferOwnership,
                  ),
                  _InfoTab(
                    group: group,
                    onJoinOrLeave: _handleJoinOrLeave,
                    canJoinOrLeave: tokens != null && !group.isBanned,
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PostComposerDialog extends StatefulWidget {
  const _PostComposerDialog({
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final String title;
  final String hintText;
  final String initialValue;
  final String cancelLabel;
  final String confirmLabel;

  @override
  State<_PostComposerDialog> createState() => _PostComposerDialogState();
}

class _PostComposerDialogState extends State<_PostComposerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLines: 6,
        maxLength: 10000,
        decoration: InputDecoration(
          hintText: widget.hintText,
          counterText: null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _GroupReportDialog extends StatefulWidget {
  const _GroupReportDialog({required this.title});

  final String title;

  @override
  State<_GroupReportDialog> createState() => _GroupReportDialogState();
}

class _GroupReportDialogState extends State<_GroupReportDialog> {
  late final TextEditingController _reasonController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.groupsReportReasonLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.groupsReportDescriptionLabel,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.profileBecomeOrganizerDialogCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop((
              _reasonController.text.trim(),
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
            ));
          },
          child: Text(l10n.groupsReportSubmit),
        ),
      ],
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.canPost,
    required this.currentUserId,
    required this.isSubmittingPost,
    required this.isLoading,
    required this.error,
    required this.isLoadingMore,
    required this.scrollController,
    required this.items,
    required this.events,
    required this.onRetry,
    required this.onCreatePost,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onHidePost,
    required this.onOpenEvent,
    required this.onReportPost,
    required this.onReportEvent,
  });

  final bool canPost;
  final String? currentUserId;
  final bool isSubmittingPost;
  final bool isLoading;
  final Object? error;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final List<GroupFeedItem> items;
  final List<ExploreEvent> events;
  final Future<void> Function() onRetry;
  final VoidCallback onCreatePost;
  final ValueChanged<GroupFeedItem> onEditPost;
  final ValueChanged<GroupFeedItem> onDeletePost;
  final ValueChanged<GroupFeedItem> onHidePost;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<GroupFeedItem> onReportPost;
  final ValueChanged<GroupFeedItem> onReportEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final eventsById = {for (final event in events) event.id: event};

    if (isLoading && items.isEmpty) {
      return StatePanel.loading(
        title: l10n.groupsTabFeed,
        subtitle: l10n.groupsLoadingSubtitle,
      );
    }

    if (error != null && items.isEmpty) {
      return StatePanel.error(
        title: l10n.groupsTabFeed,
        subtitle: l10n.groupsErrorSubtitle,
        retryLabel: l10n.exploreRetryButton,
        onRetry: onRetry,
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (canPost) ...[
          FilledButton.icon(
            onPressed: isSubmittingPost ? null : onCreatePost,
            icon: const Icon(Icons.edit_rounded),
            label: Text(l10n.groupsPostCreateAction),
          ),
          const SizedBox(height: 16),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionNotice(
              title: l10n.groupsTabFeed,
              subtitle: l10n.groupsActionFailed,
              actionLabel: l10n.exploreRetryButton,
              onAction: onRetry,
            ),
          ),
        if (items.isEmpty)
          _InfoCard(
            title: l10n.groupsFeedEmptyTitle,
            subtitle: l10n.groupsFeedEmptySubtitle,
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FeedItemCard(
                item: item,
                linkedEvent: item.type == GroupFeedItemType.event
                    ? eventsById[item.eventId]
                    : null,
                currentUserId: currentUserId,
                onEditPost: onEditPost,
                onDeletePost: onDeletePost,
                onHidePost: onHidePost,
                onOpenEvent: onOpenEvent,
                onReportPost: onReportPost,
                onReportEvent: onReportEvent,
              ),
            ),
          ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _FeedItemCard extends StatelessWidget {
  const _FeedItemCard({
    required this.item,
    required this.linkedEvent,
    required this.currentUserId,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onHidePost,
    required this.onOpenEvent,
    required this.onReportPost,
    required this.onReportEvent,
  });

  final GroupFeedItem item;
  final ExploreEvent? linkedEvent;
  final String? currentUserId;
  final ValueChanged<GroupFeedItem> onEditPost;
  final ValueChanged<GroupFeedItem> onDeletePost;
  final ValueChanged<GroupFeedItem> onHidePost;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<GroupFeedItem> onReportPost;
  final ValueChanged<GroupFeedItem> onReportEvent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAuthor =
        item.type == GroupFeedItemType.post &&
        currentUserId != null &&
        item.authorId == currentUserId;
    final canDelete = isAuthor || item.canModerate;
    final canEdit = isAuthor;
    final canHide = item.canModerate && item.type == GroupFeedItemType.post;
    const canReport = true;
    final showMenu =
        canEdit ||
        canDelete ||
        canHide ||
        (canReport &&
            (item.type == GroupFeedItemType.post ||
                item.type == GroupFeedItemType.event));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type == GroupFeedItemType.post
                          ? (item.authorUsername ??
                                l10n.groupsFeedPostFallbackAuthor)
                          : (item.eventName ??
                                l10n.groupsFeedEventFallbackTitle),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.type == GroupFeedItemType.post
                          ? l10n.groupsFeedPostLabel
                          : l10n.groupsFeedEventLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.type == GroupFeedItemType.post ||
                        item.type == GroupFeedItemType.event) ...[
                      const SizedBox(height: 6),
                      if ((item.authorUsername ??
                              linkedEvent?.organizerUsername) !=
                          null)
                        _CardMetaLine(
                          icon: Icons.person_outline_rounded,
                          label:
                              item.authorUsername ??
                              linkedEvent!.organizerUsername!,
                        ),
                      if (item.createdAt != null) ...[
                        if ((item.authorUsername ??
                                linkedEvent?.organizerUsername) !=
                            null)
                          const SizedBox(height: 4),
                        _CardMetaLine(
                          icon: Icons.schedule_rounded,
                          label: _formatCardTimestamp(item.createdAt!),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (showMenu)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEditPost(item);
                    } else if (value == 'delete') {
                      onDeletePost(item);
                    } else if (value == 'hide') {
                      onHidePost(item);
                    } else if (value == 'report-post') {
                      onReportPost(item);
                    } else if (value == 'report-event') {
                      onReportEvent(item);
                    }
                  },
                  itemBuilder: (context) => [
                    if (canEdit)
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.groupsEditAction),
                      ),
                    if (canDelete)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(l10n.groupsDeleteAction),
                      ),
                    if (canHide)
                      PopupMenuItem<String>(
                        value: 'hide',
                        child: Text(l10n.groupsHideAction),
                      ),
                    PopupMenuItem<String>(
                      value: item.type == GroupFeedItemType.post
                          ? 'report-post'
                          : 'report-event',
                      child: Text(l10n.groupsReportAction),
                    ),
                  ],
                ),
            ],
          ),
          if ((item.content ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.content!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ],
          if (item.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _FeedMediaGallery(mediaUrls: item.mediaUrls),
          ],
          if (item.type == GroupFeedItemType.event && item.eventId != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => onOpenEvent(item.eventId!),
              child: Text(l10n.groupsOpenEventAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({
    required this.members,
    required this.isLoadingMembers,
    required this.membersError,
    required this.joinRequests,
    required this.isLoadingJoinRequests,
    required this.joinRequestsError,
    required this.canModerate,
    required this.ownerUserId,
    required this.currentUserId,
    required this.onRetryMembers,
    required this.onRetryJoinRequests,
    required this.onApproveRequest,
    required this.onRejectRequest,
    required this.onMemberAction,
    required this.canTransferOwnership,
  });

  final List<GroupMember> members;
  final bool isLoadingMembers;
  final Object? membersError;
  final List<GroupMember> joinRequests;
  final bool isLoadingJoinRequests;
  final Object? joinRequestsError;
  final bool canModerate;
  final String? ownerUserId;
  final String? currentUserId;
  final Future<void> Function() onRetryMembers;
  final Future<void> Function() onRetryJoinRequests;
  final ValueChanged<GroupMember> onApproveRequest;
  final ValueChanged<GroupMember> onRejectRequest;
  final Future<void> Function(GroupMember member, _MemberAction action)
  onMemberAction;
  final bool canTransferOwnership;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final isInitialLoading =
        (isLoadingMembers && members.isEmpty) ||
        (canModerate &&
            isLoadingJoinRequests &&
            joinRequests.isEmpty &&
            members.isEmpty);
    if (isInitialLoading) {
      return StatePanel.loading(
        title: l10n.groupsTabMembers,
        subtitle: l10n.groupsLoadingSubtitle,
      );
    }

    if (membersError != null && members.isEmpty) {
      return StatePanel.error(
        title: l10n.groupsTabMembers,
        subtitle: l10n.groupsErrorSubtitle,
        retryLabel: l10n.exploreRetryButton,
        onRetry: onRetryMembers,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (canModerate && joinRequestsError != null && joinRequests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionNotice(
              title: l10n.groupsJoinRequestsTitle,
              subtitle: l10n.groupsActionFailed,
              actionLabel: l10n.exploreRetryButton,
              onAction: onRetryJoinRequests,
            ),
          ),
        if (canModerate && isLoadingJoinRequests && joinRequests.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (canModerate && joinRequestsError != null && joinRequests.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StatePanel.error(
              title: l10n.groupsJoinRequestsTitle,
              subtitle: l10n.groupsErrorSubtitle,
              retryLabel: l10n.exploreRetryButton,
              onRetry: onRetryJoinRequests,
            ),
          ),
        if (canModerate && joinRequests.isNotEmpty) ...[
          Text(
            l10n.groupsJoinRequestsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...joinRequests.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingRequestCard(
                member: member,
                onApprove: () => onApproveRequest(member),
                onReject: () => onRejectRequest(member),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (membersError != null && members.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionNotice(
              title: l10n.groupsTabMembers,
              subtitle: l10n.groupsActionFailed,
              actionLabel: l10n.exploreRetryButton,
              onAction: onRetryMembers,
            ),
          ),
        if (members.isEmpty)
          _InfoCard(
            title: l10n.groupsMembersEmptyTitle,
            subtitle: l10n.groupsMembersEmptySubtitle,
          )
        else
          ...members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MemberCard(
                member: member,
                isOwner: ownerUserId == member.userId,
                isCurrentUser: currentUserId == member.userId,
                canModerate: canModerate,
                canTransferOwnership: canTransferOwnership,
                onActionSelected: (action) => onMemberAction(member, action),
              ),
            ),
          ),
      ],
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.member,
    required this.onApprove,
    required this.onReject,
  });

  final GroupMember member;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              member.username,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: onReject,
            child: Text(AppLocalizations.of(context).groupsRejectAction),
          ),
          FilledButton(
            onPressed: onApprove,
            child: Text(AppLocalizations.of(context).groupsApproveAction),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.isOwner,
    required this.isCurrentUser,
    required this.canModerate,
    required this.canTransferOwnership,
    required this.onActionSelected,
  });

  final GroupMember member;
  final bool isOwner;
  final bool isCurrentUser;
  final bool canModerate;
  final bool canTransferOwnership;
  final ValueChanged<_MemberAction> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            child: Text(
              member.username.isEmpty
                  ? '?'
                  : member.username.characters.first.toUpperCase(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (isOwner) l10n.groupsMemberOwner,
                    if (!isOwner && member.role == GroupRole.admin)
                      l10n.groupsMemberAdmin,
                    if (!isOwner && member.role == GroupRole.member)
                      l10n.groupsMemberRegular,
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (canModerate && !isOwner && !isCurrentUser)
            PopupMenuButton<_MemberAction>(
              onSelected: onActionSelected,
              itemBuilder: (context) => [
                if (member.role == GroupRole.member)
                  PopupMenuItem(
                    value: _MemberAction.makeAdmin,
                    child: Text(l10n.groupsMakeAdminAction),
                  ),
                if (member.role == GroupRole.admin)
                  PopupMenuItem(
                    value: _MemberAction.makeMember,
                    child: Text(l10n.groupsMakeMemberAction),
                  ),
                if (canTransferOwnership)
                  PopupMenuItem(
                    value: _MemberAction.transferOwnership,
                    child: Text(l10n.groupsTransferOwnershipAction),
                  ),
                if (member.status == GroupMembershipStatus.banned)
                  PopupMenuItem(
                    value: _MemberAction.unban,
                    child: Text(l10n.groupsUnbanAction),
                  )
                else ...[
                  PopupMenuItem(
                    value: _MemberAction.ban,
                    child: Text(l10n.groupsBanAction),
                  ),
                  PopupMenuItem(
                    value: _MemberAction.remove,
                    child: Text(l10n.groupsRemoveMemberAction),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({
    required this.events,
    required this.isLoading,
    required this.error,
    required this.canCreateEvents,
    required this.canLinkEvents,
    required this.onRetry,
    required this.onCreateEvent,
    required this.onLinkEvent,
    required this.onOpenEvent,
  });

  final List<ExploreEvent> events;
  final bool isLoading;
  final Object? error;
  final bool canCreateEvents;
  final bool canLinkEvents;
  final Future<void> Function() onRetry;
  final VoidCallback onCreateEvent;
  final VoidCallback onLinkEvent;
  final ValueChanged<ExploreEvent> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading && events.isEmpty) {
      return StatePanel.loading(
        title: l10n.groupsTabEvents,
        subtitle: l10n.groupsLoadingSubtitle,
      );
    }

    if (error != null && events.isEmpty) {
      return StatePanel.error(
        title: l10n.groupsTabEvents,
        subtitle: l10n.groupsErrorSubtitle,
        retryLabel: l10n.exploreRetryButton,
        onRetry: onRetry,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        if (canCreateEvents) ...[
          FilledButton.icon(
            onPressed: onCreateEvent,
            icon: const Icon(Icons.add_box_outlined),
            label: Text(l10n.groupsCreateEventAction),
          ),
          const SizedBox(height: 12),
        ],
        if (canLinkEvents) ...[
          FilledButton.tonalIcon(
            onPressed: onLinkEvent,
            icon: const Icon(Icons.link_rounded),
            label: Text(l10n.groupsLinkExistingEventAction),
          ),
          const SizedBox(height: 16),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionNotice(
              title: l10n.groupsTabEvents,
              subtitle: l10n.groupsActionFailed,
              actionLabel: l10n.exploreRetryButton,
              onAction: onRetry,
            ),
          ),
        if (events.isEmpty)
          _InfoCard(
            title: l10n.groupsEventsEmptyTitle,
            subtitle: l10n.groupsEventsEmptySubtitle,
          )
        else
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventCard(event: event, onOpen: () => onOpenEvent(event)),
            ),
          ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onOpen});

  final ExploreEvent event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (event.organizerUsername != null) ...[
            const SizedBox(height: 6),
            _CardMetaLine(
              icon: Icons.person_outline_rounded,
              label: event.organizerUsername!,
            ),
          ],
          const SizedBox(height: 4),
          _CardMetaLine(
            icon: Icons.schedule_rounded,
            label: event.timeLabel(l10n),
          ),
          if (event.createdAt != null) ...[
            const SizedBox(height: 4),
            _CardMetaLine(
              icon: Icons.access_time_rounded,
              label: _formatCardTimestamp(event.createdAt!),
              color: scheme.onSurface.withValues(alpha: 0.56),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onOpen,
            child: Text(l10n.groupsOpenEventAction),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

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
        border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, color: scheme.primary),
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

String _formatCardTimestamp(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.$year, $hour:$minute';
}

class _CardMetaLine extends StatelessWidget {
  const _CardMetaLine({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final resolvedColor = color ?? scheme.onSurface.withValues(alpha: 0.68);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VisualMetadataRow extends StatelessWidget {
  const _VisualMetadataRow({
    required this.label,
    required this.value,
    required this.fallbackIcon,
    this.imageUrl,
  });

  final String label;
  final String value;
  final IconData fallbackIcon;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 56,
                    height: 56,
                    color: scheme.surfaceContainerHighest,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 56,
                    height: 56,
                    color: scheme.surfaceContainerHighest,
                    child: Icon(fallbackIcon, color: scheme.primary),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: scheme.surfaceContainerHighest,
                  child: Icon(fallbackIcon, color: scheme.primary),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedMediaGallery extends StatelessWidget {
  const _FeedMediaGallery({required this.mediaUrls});

  final List<String> mediaUrls;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final mediaUrl in mediaUrls.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: CachedNetworkImage(
                  imageUrl: mediaUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: scheme.surfaceContainerHighest,
                    child: Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionNotice extends StatelessWidget {
  const _SectionNotice({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.group,
    required this.onJoinOrLeave,
    required this.canJoinOrLeave,
  });

  final Group group;
  final VoidCallback onJoinOrLeave;
  final bool canJoinOrLeave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final actionLabel = group.isMember
        ? l10n.groupsLeaveAction
        : group.isPending
        ? l10n.groupsPendingAction
        : l10n.groupsJoinAction;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderChip(
                    label: group.categoryName ?? l10n.groupsCategoryUnknown,
                  ),
                  _HeaderChip(
                    label: group.isPublic
                        ? l10n.groupsVisibilityPublic
                        : l10n.groupsVisibilityPrivate,
                  ),
                  _HeaderChip(
                    label: l10n.groupsMembersCount(group.memberCount),
                  ),
                ],
              ),
              if ((group.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  group.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: canJoinOrLeave ? onJoinOrLeave : null,
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
        if ((group.avatarUrl ?? '').isNotEmpty ||
            (group.iconUrl ?? '').isNotEmpty ||
            (group.mapPinIconUrl ?? '').isNotEmpty ||
            (group.mapPinStyle ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.groupsAdvancedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if ((group.avatarUrl ?? '').isNotEmpty) ...[
                  _VisualMetadataRow(
                    label: l10n.groupsFieldAvatarUrl,
                    value: group.avatarUrl!,
                    imageUrl: group.avatarUrl,
                    fallbackIcon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),
                ],
                if ((group.iconUrl ?? '').isNotEmpty) ...[
                  _VisualMetadataRow(
                    label: l10n.groupsFieldIconUrl,
                    value: group.iconUrl!,
                    imageUrl: group.iconUrl,
                    fallbackIcon: Icons.emoji_events_outlined,
                  ),
                  const SizedBox(height: 12),
                ],
                if ((group.mapPinIconUrl ?? '').isNotEmpty) ...[
                  _VisualMetadataRow(
                    label: l10n.groupsFieldMapPinIconUrl,
                    value: group.mapPinIconUrl!,
                    imageUrl: group.mapPinIconUrl,
                    fallbackIcon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 12),
                ],
                if ((group.mapPinStyle ?? '').isNotEmpty)
                  _VisualMetadataRow(
                    label: l10n.groupsFieldMapPinStyle,
                    value: group.mapPinStyle!,
                    fallbackIcon: Icons.tune_rounded,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum _MemberAction {
  makeAdmin,
  makeMember,
  ban,
  unban,
  remove,
  transferOwnership,
}
