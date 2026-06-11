import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/groups/group_models.dart';
import 'package:locario/shared/groups/group_scope.dart';

class GroupPostCommentsScreen extends StatefulWidget {
  const GroupPostCommentsScreen({
    super.key,
    required this.groupId,
    required this.postId,
  });

  final String groupId;
  final String postId;

  @override
  State<GroupPostCommentsScreen> createState() =>
      _GroupPostCommentsScreenState();
}

class _GroupPostCommentsScreenState extends State<GroupPostCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<GroupPostComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadComments());
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final ctrl = GroupScope.of(context);
    final items = await ctrl.fetchComments(
      widget.groupId,
      widget.postId,
      page: 0,
    );
    if (!mounted) return;
    setState(() {
      _comments = items;
      _isLoading = false;
    });
  }

  Future<void> _handleSend() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    final session = AuthScope.of(context);
    if (session.tokens == null) return;

    setState(() => _isSending = true);

    final ctrl = GroupScope.of(context);
    GroupPostComment? comment;

    if (_editingCommentId != null) {
      comment = await ctrl.updateComment(
        widget.groupId,
        widget.postId,
        _editingCommentId!,
        text,
      );
    } else {
      comment = await ctrl.createComment(widget.groupId, widget.postId, text);
    }

    if (!mounted) return;

    if (comment != null) {
      setState(() {
        if (_editingCommentId != null) {
          final idx = _comments.indexWhere((c) => c.id == _editingCommentId);
          if (idx >= 0) {
            _comments[idx] = comment!;
          }
        } else {
          _comments.insert(0, comment!);
        }
        _editingCommentId = null;
      });
      _commentController.clear();
    }

    setState(() => _isSending = false);
  }

  void _startEdit(GroupPostComment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _commentController.text = comment.content;
    });
  }

  Future<void> _handleDelete(GroupPostComment comment) async {
    final ctrl = GroupScope.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.groupsCommentDelete),
        content: Text(l10n.groupsCommentDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.profileBecomeOrganizerDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.groupsDeleteAction),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final success = await ctrl.deleteComment(
      widget.groupId,
      widget.postId,
      comment.id,
    );
    if (!mounted) return;
    if (success) {
      setState(() => _comments.removeWhere((c) => c.id == comment.id));
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.groupsCommentsTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.groupsCommentsEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return _CommentCard(
                        comment: _comments[index],
                        currentUserId: AuthScope.of(context).profile?.id,
                        canModerate: false,
                        onEdit: _startEdit,
                        onDelete: _handleDelete,
                      );
                    },
                  ),
          ),
          if (_editingCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.groupsCommentEdit,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _cancelEdit,
                    child: Text(l10n.profileBecomeOrganizerDialogCancel),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                top: BorderSide(color: scheme.outline.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: l10n.groupsCommentHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _handleSend,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _editingCommentId != null
                              ? Icons.check_rounded
                              : Icons.send_rounded,
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

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.currentUserId,
    required this.canModerate,
    required this.onEdit,
    required this.onDelete,
  });

  final GroupPostComment comment;
  final String? currentUserId;
  final bool canModerate;
  final ValueChanged<GroupPostComment> onEdit;
  final ValueChanged<GroupPostComment> onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isOwn = currentUserId != null && comment.authorId == currentUserId;
    final showMenu = isOwn || canModerate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    (comment.authorUsername ?? '?').characters.first
                        .toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              comment.authorUsername ?? '',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (comment.createdAt != null)
                            Text(
                              _formatShortTime(comment.createdAt!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          if (comment.updatedAt != null &&
                              comment.updatedAt != comment.createdAt)
                            Text(
                              l10n.groupsCommentEdited,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.content, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (showMenu)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onSelected: (value) {
                      if (value == 'edit') onEdit(comment);
                      if (value == 'delete') onDelete(comment);
                    },
                    itemBuilder: (context) => [
                      if (isOwn)
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.groupsEditAction),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.groupsDeleteAction),
                      ),
                    ],
                  ),
              ],
            ),
            if (comment.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: comment.mediaUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        comment.mediaUrls[index],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 120,
                          height: 120,
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatShortTime(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);

  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}';
}
