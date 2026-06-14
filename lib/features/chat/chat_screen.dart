import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';
import 'chat_repository.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.repository});

  final FirestoreChatRepository? repository;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatConversation> _lastConversations = const [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currentUserId = _currentUserId(context);
    final chatRepository = widget.repository ?? FirestoreChatRepository();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () async {
            if (!await Navigator.of(context).maybePop() && context.mounted) {
              context.go('/explore');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(
          l10n.hubMessagesTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: chatRepository.watchConversations(currentUserId),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Chat conversations stream failed: ${snapshot.error}');
          }

          final freshConversations = snapshot.hasError
              ? const <ChatConversation>[]
              : snapshot.data ?? const <ChatConversation>[];
          if (freshConversations.isNotEmpty) {
            _lastConversations = freshConversations;
          }

          final conversations = freshConversations.isNotEmpty
              ? freshConversations
              : _lastConversations;
          if (conversations.isEmpty) {
            return Center(
              child: Text(
                'Brak Wiadomości',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.52),
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final recipientId = conversation.participantIdFor(currentUserId);
              final recipientName = conversation.titleFor(currentUserId);
              return _ConversationTile(
                conversation: conversation,
                currentUserId: currentUserId,
                onTap: () => context.push(
                  Uri(
                    path: '/chat/${conversation.id}',
                    queryParameters: {
                      'recipientId': ?recipientId,
                      'recipientName': recipientName,
                    },
                  ).toString(),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemCount: conversations.length,
          );
        },
      ),
    );
  }
}

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.chatId,
    this.recipientId,
    this.recipientName,
    this.repository,
  });

  final String chatId;
  final String? recipientId;
  final String? recipientName;
  final FirestoreChatRepository? repository;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _controller = TextEditingController();
  late final FirestoreChatRepository _repository;
  List<ChatMessage> _lastMessages = const [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FirestoreChatRepository();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final profile = AuthScope.of(context).profile;
    final senderId = _currentUserId(context);
    var recipientId = widget.recipientId;
    var recipientName = widget.recipientName;

    if (text.isEmpty || senderId.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      if (recipientId == null) {
        final conversation = await _repository.fetchConversation(widget.chatId);
        recipientId = conversation?.participantIdFor(senderId);
        recipientName = conversation?.titleFor(senderId);
      }
      if (recipientId == null) return;

      await _repository.sendDirectMessage(
        chatId: widget.chatId,
        senderAppUserId: senderId,
        senderName: profile?.username ?? 'User',
        recipientId: recipientId,
        recipientName: recipientName ?? recipientId,
        content: text,
      );
      _controller.clear();
    } catch (error) {
      if (!mounted) return;
      debugPrint('Chat send failed: $error');
      if (error is ChatSendException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie udało się wysłać wiadomości.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentUserId = _currentUserId(context);
    final title = widget.recipientName?.trim().isNotEmpty == true
        ? widget.recipientName!.trim()
        : 'Chat';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _repository.watchMessages(widget.chatId),
              initialData: const [],
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Chat messages stream failed: ${snapshot.error}');
                }

                final freshMessages = snapshot.hasError
                    ? const <ChatMessage>[]
                    : snapshot.data ?? const <ChatMessage>[];
                if (freshMessages.isNotEmpty) {
                  _lastMessages = freshMessages;
                }

                final messages = freshMessages.isNotEmpty
                    ? freshMessages
                    : _lastMessages;
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Brak Wiadomości',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.52),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      isMine:
                          message.senderAppUserId == currentUserId ||
                          message.senderId == currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !_isSending,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Wiadomość',
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = conversation.titleFor(currentUserId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
              foregroundColor: scheme.primary,
              child: Text(
                title.isEmpty ? '?' : title.characters.first.toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatTimestamp(conversation.updatedAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final background = isMine ? scheme.primary : scheme.surfaceContainerHigh;
    final foreground = isMine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _currentUserId(BuildContext context) {
  final profileId = AuthScope.of(context).profile?.id;
  if (profileId != null && profileId.isNotEmpty) return profileId;

  final firebaseUid = Firebase.apps.isEmpty
      ? null
      : FirebaseAuth.instance.currentUser?.uid;
  return firebaseUid ?? '';
}

String _formatTimestamp(DateTime? date) {
  if (date == null) return '';

  final local = date.toLocal();
  final now = DateTime.now();
  if (local.year == now.year &&
      local.month == now.month &&
      local.day == now.day) {
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}';
}
