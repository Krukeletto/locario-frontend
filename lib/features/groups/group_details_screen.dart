import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../features/explore/models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/events/event_repository.dart';
import '../../shared/groups/group_models.dart';
import '../../shared/groups/group_repository.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    GroupRepository? groupRepository,
    EventRepository? eventRepository,
  }) : _groupRepository = groupRepository,
       _eventRepository = eventRepository;

  final String groupId;
  final GroupRepository? _groupRepository;
  final EventRepository? _eventRepository;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late final GroupRepository _groupRepository;
  late final EventRepository _eventRepository;
  final TextEditingController _postController = TextEditingController();

  Group? _group;
  List<GroupMember> _members = const [];
  List<GroupMember> _joinRequests = const [];
  List<GroupFeedItem> _feed = const [];
  List<ExploreEvent> _events = const [];
  List<GroupReport> _reports = const [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSubmittingPost = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _groupRepository = widget._groupRepository ?? HttpGroupRepository();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _load({bool refreshOnly = false}) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;

    if (!mounted) {
      return;
    }
    setState(() {
      if (refreshOnly) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });

    try {
      final group = await _groupRepository.fetchGroup(
        widget.groupId,
        accessToken: tokens?.accessToken,
        tokenType: tokens?.tokenType ?? 'Bearer',
      );
      final canModerate = _canModerate(
        group,
        session.profile?.id,
        session.profile?.admin == true,
      );

      final membersFuture = _groupRepository.fetchMembers(
        widget.groupId,
        accessToken: tokens?.accessToken,
        tokenType: tokens?.tokenType ?? 'Bearer',
      );
      final feedFuture = _groupRepository.fetchFeed(
        widget.groupId,
        accessToken: tokens?.accessToken,
        tokenType: tokens?.tokenType ?? 'Bearer',
      );
      final eventsFuture = _groupRepository.fetchGroupEvents(
        widget.groupId,
        accessToken: tokens?.accessToken,
        tokenType: tokens?.tokenType ?? 'Bearer',
      );
      final joinRequestsFuture = canModerate && tokens != null
          ? _groupRepository.fetchJoinRequests(
              widget.groupId,
              accessToken: tokens.accessToken,
              tokenType: tokens.tokenType,
            )
          : Future.value(const <GroupMember>[]);
      final reportsFuture = canModerate && tokens != null
          ? _groupRepository.fetchReports(
              widget.groupId,
              accessToken: tokens.accessToken,
              tokenType: tokens.tokenType,
            )
          : Future.value(const <GroupReport>[]);

      final results = await Future.wait([
        membersFuture,
        feedFuture,
        eventsFuture,
        joinRequestsFuture,
        reportsFuture,
      ]);

      if (!mounted) {
        return;
      }
      setState(() {
        _group = group;
        _members = results[0] as List<GroupMember>;
        _feed = results[1] as List<GroupFeedItem>;
        _events = results[2] as List<ExploreEvent>;
        _joinRequests = results[3] as List<GroupMember>;
        _reports = results[4] as List<GroupReport>;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  bool _canModerate(Group group, String? userId, bool isGlobalAdmin) {
    return isGlobalAdmin ||
        group.ownerUserId == userId ||
        group.currentUserRole == GroupRole.admin;
  }

  bool _canCreateGroupsEvents(Group group) {
    final session = AuthScope.of(context);
    final profile = session.profile;
    if (session.tokens == null || profile == null) {
      return false;
    }
    return profile.admin ||
        group.ownerUserId == profile.id ||
        group.currentUserRole == GroupRole.admin ||
        group.currentUserMembership == GroupMembershipStatus.active;
  }

  Future<void> _handleJoinOrLeave() async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final group = _group;
    final l10n = AppLocalizations.of(context);
    if (group == null) {
      return;
    }
    if (tokens == null) {
      await context.push(
        '/auth/login?from=${Uri.encodeComponent('/groups/${group.id}')}&target=${Uri.encodeComponent('/groups/${group.id}')}',
      );
      return;
    }

    try {
      if (group.isMember || group.isPending) {
        await _groupRepository.leaveGroup(
          group.id,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else {
        await _groupRepository.joinGroup(
          group.id,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      }
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleCreatePost({GroupPost? editingPost}) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final group = _group;
    if (tokens == null || group == null) {
      return;
    }

    final controller = TextEditingController(text: editingPost?.content ?? '');
    final l10n = AppLocalizations.of(context);
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          editingPost == null
              ? l10n.groupsPostCreateTitle
              : l10n.groupsPostEditTitle,
        ),
        content: TextField(
          controller: controller,
          maxLines: 6,
          maxLength: 10000,
          decoration: InputDecoration(
            hintText: l10n.groupsPostHint,
            counterText: null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.profileBecomeOrganizerDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(
              editingPost == null
                  ? l10n.groupsPostPublish
                  : l10n.groupsSaveChanges,
            ),
          ),
        ],
      ),
    );
    controller.dispose();

    if (content == null || content.isEmpty) {
      return;
    }

    setState(() {
      _isSubmittingPost = true;
    });

    try {
      if (editingPost == null) {
        await _groupRepository.createPost(
          group.id,
          GroupPostRequest(content: content),
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else {
        await _groupRepository.updatePost(
          group.id,
          editingPost.id,
          GroupPostRequest(content: content),
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmittingPost = false;
      });
      _postController.clear();
      await _load(refreshOnly: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmittingPost = false;
      });
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleDeletePost(GroupFeedItem item) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final group = _group;
    final l10n = AppLocalizations.of(context);
    if (tokens == null || group == null) {
      return;
    }

    final confirmed = await _confirm(
      title: l10n.groupsDeletePostTitle,
      body: l10n.groupsDeletePostBody,
    );
    if (!confirmed) {
      return;
    }

    try {
      await _groupRepository.deletePost(
        group.id,
        item.id,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleHidePost(GroupFeedItem item) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final group = _group;
    final l10n = AppLocalizations.of(context);
    if (tokens == null || group == null) {
      return;
    }

    try {
      await _groupRepository.hidePost(
        group.id,
        item.id,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleApproveRequest(GroupMember member) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final l10n = AppLocalizations.of(context);
    if (tokens == null) {
      return;
    }

    try {
      await _groupRepository.approveJoinRequest(
        widget.groupId,
        member.userId,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleRejectRequest(GroupMember member) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final l10n = AppLocalizations.of(context);
    if (tokens == null) {
      return;
    }

    try {
      await _groupRepository.rejectJoinRequest(
        widget.groupId,
        member.userId,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleMemberAction(
    GroupMember member,
    _MemberAction action,
  ) async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final l10n = AppLocalizations.of(context);
    if (tokens == null) {
      return;
    }

    try {
      if (action == _MemberAction.makeAdmin) {
        await _groupRepository.changeRole(
          widget.groupId,
          member.userId,
          GroupRole.admin,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else if (action == _MemberAction.makeMember) {
        await _groupRepository.changeRole(
          widget.groupId,
          member.userId,
          GroupRole.member,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else if (action == _MemberAction.ban) {
        await _groupRepository.banMember(
          widget.groupId,
          member.userId,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else if (action == _MemberAction.unban) {
        await _groupRepository.unbanMember(
          widget.groupId,
          member.userId,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else if (action == _MemberAction.remove) {
        await _groupRepository.removeMember(
          widget.groupId,
          member.userId,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } else if (action == _MemberAction.transferOwnership) {
        await _groupRepository.transferOwnership(
          widget.groupId,
          member.userId,
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      }
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleCreateEventForGroup() async {
    final group = _group;
    if (group == null) {
      return;
    }
    await context.push(
      '/hub/create-event?groupId=${Uri.encodeQueryComponent(group.id)}',
    );
    if (!mounted) {
      return;
    }
    await _load(refreshOnly: true);
  }

  Future<void> _handleLinkExistingEvent() async {
    final group = _group;
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final l10n = AppLocalizations.of(context);
    if (group == null || tokens == null) {
      return;
    }

    try {
      final events = await _eventRepository.fetchOrganizerEvents(
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
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
      if (selected == null) {
        return;
      }
      await _groupRepository.linkEvent(
        group.id,
        selected.id,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleUnlinkEvent(ExploreEvent event) async {
    final group = _group;
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final l10n = AppLocalizations.of(context);
    if (group == null || tokens == null) {
      return;
    }

    try {
      await _groupRepository.unlinkEvent(
        group.id,
        event.id,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _showReportDialog({
    required String title,
    required Future<GroupReport> Function(String reason, String? description)
    submit,
  }) async {
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();

    final payload = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: l10n.groupsReportReasonLabel,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
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
                reasonController.text.trim(),
                descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              ));
            },
            child: Text(l10n.groupsReportSubmit),
          ),
        ],
      ),
    );
    reasonController.dispose();
    descriptionController.dispose();

    if (payload == null || payload.$1.isEmpty) {
      return;
    }

    try {
      await submit(payload.$1, payload.$2);
      if (!mounted) {
        return;
      }
      await _load(refreshOnly: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(l10n.groupsActionFailed);
    }
  }

  Future<void> _handleDeleteGroup() async {
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final group = _group;
    final l10n = AppLocalizations.of(context);
    if (tokens == null || group == null) {
      return;
    }

    final confirmed = await _confirm(
      title: l10n.groupsDeleteGroupTitle,
      body: l10n.groupsDeleteGroupBody,
    );
    if (!confirmed) {
      return;
    }

    try {
      await _groupRepository.deleteGroup(
        group.id,
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) {
        return;
      }
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(child: CircularProgressIndicator(color: scheme.primary)),
      );
    }

    if (_error != null || _group == null) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.groupsErrorSubtitle, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final group = _group!;
    final session = AuthScope.of(context);
    final tokens = session.tokens;
    final profile = session.profile;
    final canModerate = _canModerate(
      group,
      profile?.id,
      profile?.admin == true,
    );
    final canCreateEvents = _canCreateGroupsEvents(group);
    const canLinkEvents = false;
    final tabCount = canModerate ? 4 : 3;

    return DefaultTabController(
      length: tabCount,
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
                  if (tokens == null) {
                    return;
                  }
                  await _showReportDialog(
                    title: l10n.groupsReportGroupTitle,
                    submit: (reason, description) =>
                        _groupRepository.reportGroup(
                          group.id,
                          GroupReportRequest(
                            targetType: 'group',
                            targetId: group.id,
                            reason: reason,
                            description: description,
                            groupId: group.id,
                          ),
                          accessToken: tokens.accessToken,
                          tokenType: tokens.tokenType,
                        ),
                  );
                } else if (value == 'edit') {
                  await context.push('/groups/${group.id}/edit');
                  if (!mounted) {
                    return;
                  }
                  await _load(refreshOnly: true);
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
                if (canModerate)
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(l10n.groupsDeleteAction),
                  ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.groupsTabFeed),
              Tab(text: l10n.groupsTabMembers),
              Tab(text: l10n.groupsTabEvents),
              if (canModerate) Tab(text: l10n.groupsTabManage),
            ],
          ),
        ),
        body: Column(
          children: [
            _GroupHeader(
              group: group,
              onJoinOrLeave: _handleJoinOrLeave,
              canJoinOrLeave: tokens != null && !group.isBanned,
            ),
            if (_isRefreshing) const LinearProgressIndicator(),
            Expanded(
              child: TabBarView(
                children: [
                  _FeedTab(
                    group: group,
                    canPost: group.isMember,
                    currentUserId: profile?.id,
                    isSubmittingPost: _isSubmittingPost,
                    items: _feed,
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
                      if (tokens == null) {
                        return;
                      }
                      await _showReportDialog(
                        title: l10n.groupsReportPostTitle,
                        submit: (reason, description) =>
                            _groupRepository.reportPost(
                              group.id,
                              item.id,
                              GroupReportRequest(
                                targetType: 'post',
                                targetId: item.id,
                                reason: reason,
                                description: description,
                                groupId: group.id,
                              ),
                              accessToken: tokens.accessToken,
                              tokenType: tokens.tokenType,
                            ),
                      );
                    },
                    onReportEvent: (item) async {
                      if (tokens == null || item.eventId == null) {
                        return;
                      }
                      await _showReportDialog(
                        title: l10n.groupsReportEventTitle,
                        submit: (reason, description) =>
                            _groupRepository.reportEvent(
                              group.id,
                              item.eventId!,
                              GroupReportRequest(
                                targetType: 'group_event',
                                targetId: item.eventId!,
                                reason: reason,
                                description: description,
                                groupId: group.id,
                              ),
                              accessToken: tokens.accessToken,
                              tokenType: tokens.tokenType,
                            ),
                      );
                    },
                  ),
                  _MembersTab(
                    members: _members,
                    joinRequests: _joinRequests,
                    canModerate: canModerate,
                    ownerUserId: group.ownerUserId,
                    currentUserId: profile?.id,
                    onApproveRequest: _handleApproveRequest,
                    onRejectRequest: _handleRejectRequest,
                    onMemberAction: _handleMemberAction,
                  ),
                  _EventsTab(
                    events: _events,
                    canCreateEvents: canCreateEvents,
                    canLinkEvents: canLinkEvents,
                    canUnlinkEvents: canModerate,
                    onCreateEvent: _handleCreateEventForGroup,
                    onLinkEvent: _handleLinkExistingEvent,
                    onUnlinkEvent: _handleUnlinkEvent,
                    onOpenEvent: (event) => context.push('/events/${event.id}'),
                    onReportEvent: (event) async {
                      if (tokens == null) {
                        return;
                      }
                      await _showReportDialog(
                        title: l10n.groupsReportEventTitle,
                        submit: (reason, description) =>
                            _groupRepository.reportEvent(
                              group.id,
                              event.id,
                              GroupReportRequest(
                                targetType: 'group_event',
                                targetId: event.id,
                                reason: reason,
                                description: description,
                                groupId: group.id,
                              ),
                              accessToken: tokens.accessToken,
                              tokenType: tokens.tokenType,
                            ),
                      );
                    },
                  ),
                  _ManageTab(
                    canModerate: canModerate,
                    reports: _reports,
                    onResolveReport: (report) async {
                      if (tokens == null) {
                        return;
                      }
                      await _groupRepository.resolveReport(
                        group.id,
                        report.id,
                        accessToken: tokens.accessToken,
                        tokenType: tokens.tokenType,
                      );
                      if (!mounted) {
                        return;
                      }
                      await _load(refreshOnly: true);
                    },
                    onRejectReport: (report) async {
                      if (tokens == null) {
                        return;
                      }
                      await _groupRepository.rejectReport(
                        group.id,
                        report.id,
                        accessToken: tokens.accessToken,
                        tokenType: tokens.tokenType,
                      );
                      if (!mounted) {
                        return;
                      }
                      await _load(refreshOnly: true);
                    },
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.18)),
        ),
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
              _HeaderChip(label: l10n.groupsMembersCount(group.memberCount)),
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

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.group,
    required this.canPost,
    required this.currentUserId,
    required this.isSubmittingPost,
    required this.items,
    required this.onCreatePost,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onHidePost,
    required this.onOpenEvent,
    required this.onReportPost,
    required this.onReportEvent,
  });

  final Group group;
  final bool canPost;
  final String? currentUserId;
  final bool isSubmittingPost;
  final List<GroupFeedItem> items;
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

    return ListView(
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
      ],
    );
  }
}

class _FeedItemCard extends StatelessWidget {
  const _FeedItemCard({
    required this.item,
    required this.currentUserId,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onHidePost,
    required this.onOpenEvent,
    required this.onReportPost,
    required this.onReportEvent,
  });

  final GroupFeedItem item;
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
    required this.joinRequests,
    required this.canModerate,
    required this.ownerUserId,
    required this.currentUserId,
    required this.onApproveRequest,
    required this.onRejectRequest,
    required this.onMemberAction,
  });

  final List<GroupMember> members;
  final List<GroupMember> joinRequests;
  final bool canModerate;
  final String? ownerUserId;
  final String? currentUserId;
  final ValueChanged<GroupMember> onApproveRequest;
  final ValueChanged<GroupMember> onRejectRequest;
  final Future<void> Function(GroupMember member, _MemberAction action)
  onMemberAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
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
    required this.onActionSelected,
  });

  final GroupMember member;
  final bool isOwner;
  final bool isCurrentUser;
  final bool canModerate;
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
    required this.canCreateEvents,
    required this.canLinkEvents,
    required this.canUnlinkEvents,
    required this.onCreateEvent,
    required this.onLinkEvent,
    required this.onUnlinkEvent,
    required this.onOpenEvent,
    required this.onReportEvent,
  });

  final List<ExploreEvent> events;
  final bool canCreateEvents;
  final bool canLinkEvents;
  final bool canUnlinkEvents;
  final VoidCallback onCreateEvent;
  final VoidCallback onLinkEvent;
  final ValueChanged<ExploreEvent> onUnlinkEvent;
  final ValueChanged<ExploreEvent> onOpenEvent;
  final ValueChanged<ExploreEvent> onReportEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        if (events.isEmpty)
          _InfoCard(
            title: l10n.groupsEventsEmptyTitle,
            subtitle: l10n.groupsEventsEmptySubtitle,
          )
        else
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventCard(
                event: event,
                canUnlink: canUnlinkEvents,
                onOpen: () => onOpenEvent(event),
                onUnlink: () => onUnlinkEvent(event),
                onReport: () => onReportEvent(event),
              ),
            ),
          ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.canUnlink,
    required this.onOpen,
    required this.onUnlink,
    required this.onReport,
  });

  final ExploreEvent event;
  final bool canUnlink;
  final VoidCallback onOpen;
  final VoidCallback onUnlink;
  final VoidCallback onReport;

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
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'unlink') {
                    onUnlink();
                  } else if (value == 'report') {
                    onReport();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text(l10n.groupsReportAction),
                  ),
                  if (canUnlink)
                    PopupMenuItem<String>(
                      value: 'unlink',
                      child: Text(l10n.groupsUnlinkEventAction),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            event.timeLabel(l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
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

class _ManageTab extends StatelessWidget {
  const _ManageTab({
    required this.canModerate,
    required this.reports,
    required this.onResolveReport,
    required this.onRejectReport,
  });

  final bool canModerate;
  final List<GroupReport> reports;
  final ValueChanged<GroupReport> onResolveReport;
  final ValueChanged<GroupReport> onRejectReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!canModerate) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            title: l10n.groupsManageRestrictedTitle,
            subtitle: l10n.groupsManageRestrictedSubtitle,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (reports.isEmpty)
          _InfoCard(
            title: l10n.groupsReportsEmptyTitle,
            subtitle: l10n.groupsReportsEmptySubtitle,
          )
        else
          ...reports.map(
            (report) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReportCard(
                report: report,
                onResolve: () => onResolveReport(report),
                onReject: () => onRejectReport(report),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onResolve,
    required this.onReject,
  });

  final GroupReport report;
  final VoidCallback onResolve;
  final VoidCallback onReject;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.reason ?? '-',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if ((report.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(report.description!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onReject,
                  child: Text(AppLocalizations.of(context).groupsRejectAction),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onResolve,
                  child: Text(AppLocalizations.of(context).groupsResolveAction),
                ),
              ),
            ],
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

enum _MemberAction {
  makeAdmin,
  makeMember,
  ban,
  unban,
  remove,
  transferOwnership,
}
