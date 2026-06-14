import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/chat/chat_repository.dart';
import 'package:locario/features/chat/chat_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows conversations from repository', (tester) async {
    final repository = _FakeChatRepository(
      conversations: [
        ChatConversation(
          id: 'dm_user-1_user-2',
          participantIds: const ['user-1', 'user-2'],
          participantNames: const {'user-1': 'Tester', 'user-2': 'Anna'},
          lastMessage: 'Cześć!',
          updatedAt: DateTime(2026, 6, 14, 12, 30),
        ),
      ],
    );

    await _pumpWithAuth(tester, ChatListScreen(repository: repository));

    await tester.pump();

    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Cześć!'), findsOneWidget);
  });

  testWidgets('keeps last conversations when stream emits empty list', (
    tester,
  ) async {
    final controller = StreamController<List<ChatConversation>>();
    final repository = _FakeChatRepository(
      conversationStream: controller.stream,
    );

    await _pumpWithAuth(tester, ChatListScreen(repository: repository));

    controller.add([
      ChatConversation(
        id: 'dm_user-1_user-2',
        participantIds: const ['user-1', 'user-2'],
        participantNames: const {'user-1': 'Tester', 'user-2': 'Anna'},
        lastMessage: 'Pierwsza wiadomość',
        updatedAt: DateTime(2026, 6, 14, 12, 30),
      ),
    ]);
    await tester.pump();

    expect(find.text('Anna'), findsOneWidget);

    controller.add(const []);
    await tester.pump();

    expect(find.text('Anna'), findsOneWidget);
    await controller.close();
  });

  testWidgets('renders own and other messages with sender names', (
    tester,
  ) async {
    final repository = _FakeChatRepository(
      messages: [
        ChatMessage(
          id: 'msg-1',
          senderId: 'firebase-2',
          senderAppUserId: 'user-2',
          senderName: 'Anna',
          content: 'Hej',
          timestamp: DateTime(2026, 6, 14, 12, 30),
        ),
        ChatMessage(
          id: 'msg-2',
          senderId: 'firebase-1',
          senderAppUserId: 'user-1',
          senderName: 'Tester',
          content: 'Cześć',
          timestamp: DateTime(2026, 6, 14, 12, 31),
        ),
      ],
    );

    await _pumpWithAuth(
      tester,
      ChatThreadScreen(chatId: 'dm_user-1_user-2', repository: repository),
    );

    await tester.pump();

    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('Hej'), findsOneWidget);
    expect(find.text('Cześć'), findsOneWidget);

    final otherBubble = tester.widget<Align>(
      find.ancestor(of: find.text('Hej'), matching: find.byType(Align)).first,
    );
    final ownBubble = tester.widget<Align>(
      find.ancestor(of: find.text('Cześć'), matching: find.byType(Align)).first,
    );

    expect(otherBubble.alignment, Alignment.centerLeft);
    expect(ownBubble.alignment, Alignment.centerRight);
  });

  testWidgets('sends direct messages through repository', (tester) async {
    final repository = _FakeChatRepository();

    await _pumpWithAuth(
      tester,
      ChatThreadScreen(
        chatId: 'dm_user-1_user-2',
        recipientId: 'user-2',
        recipientName: 'Anna',
        repository: repository,
      ),
    );

    await tester.enterText(find.byType(TextField), 'Nowa wiadomość');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(repository.sentDirectMessages, ['Nowa wiadomość']);
    expect(repository.sentGroupMessages, isEmpty);
  });

  testWidgets('sends group messages through repository', (tester) async {
    final repository = _FakeChatRepository();

    await _pumpWithAuth(
      tester,
      ChatThreadScreen(
        chatId: 'group_group-1',
        groupName: 'Climbing Club',
        isGroup: true,
        participantIds: const ['user-1', 'user-2'],
        repository: repository,
      ),
    );

    await tester.enterText(find.byType(TextField), 'Hej grupa');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(repository.sentGroupMessages, ['Hej grupa']);
    expect(repository.lastGroupName, 'Climbing Club');
    expect(repository.lastParticipantIds, containsAll(['user-1', 'user-2']));
    expect(repository.sentDirectMessages, isEmpty);
  });
}

Future<void> _pumpWithAuth(WidgetTester tester, Widget child) async {
  final sessionController = await _createAuthenticatedSessionController();

  await tester.pumpWidget(
    buildLocalizedTestApp(
      home: AuthScope(controller: sessionController, child: child),
    ),
  );
}

Future<SessionController> _createAuthenticatedSessionController() async {
  final storage = _MemoryAuthStorage()
    ..stored = AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.now().add(const Duration(days: 1)),
    );
  final controller = SessionController(
    authRepository: AuthRepository(
      api: _FakeAuthApi(
        profile: UserProfile(
          id: 'user-1',
          username: 'Tester',
          email: 'tester@example.com',
          hasPassword: true,
          avatarUrl: null,
          bio: null,
          websiteUrl: null,
          instagramUrl: null,
          facebookUrl: null,
          createdAt: DateTime.utc(2026, 6, 1),
          eventRegistrations: const [],
        ),
      ),
      storage: storage,
    ),
  );
  await controller.load();
  return controller;
}

class _FakeChatRepository extends FirestoreChatRepository {
  _FakeChatRepository({
    List<ChatConversation> conversations = const [],
    List<ChatMessage> messages = const [],
    Stream<List<ChatConversation>>? conversationStream,
  }) : _conversations = conversations,
       _messages = messages,
       _conversationStream = conversationStream;

  final List<ChatConversation> _conversations;
  final List<ChatMessage> _messages;
  final Stream<List<ChatConversation>>? _conversationStream;
  final List<String> sentDirectMessages = [];
  final List<String> sentGroupMessages = [];
  List<String> lastParticipantIds = const [];
  String? lastGroupName;

  @override
  Stream<List<ChatConversation>> watchConversations(String userId) {
    return _conversationStream ?? Stream.value(_conversations);
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return Stream.value(_messages);
  }

  @override
  Future<void> sendDirectMessage({
    required String chatId,
    required String senderAppUserId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String content,
  }) async {
    sentDirectMessages.add(content);
  }

  @override
  Future<void> sendGroupMessage({
    required String chatId,
    required String senderAppUserId,
    required String senderName,
    required String groupName,
    required List<String> participantIds,
    required String content,
  }) async {
    sentGroupMessages.add(content);
    lastGroupName = groupName;
    lastParticipantIds = participantIds;
  }
}

class _MemoryAuthStorage implements AuthTokenStorage {
  AuthTokens? stored;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    stored = tokens;
  }

  @override
  Future<AuthTokens?> readTokens() async => stored;

  @override
  Future<void> clear() async {
    stored = null;
  }
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({required this.profile}) : super();

  final UserProfile profile;

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    return profile;
  }

  @override
  Future<AuthResponse> login(LoginRequest request) {
    throw StateError('login not configured');
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    throw StateError('register not configured');
  }

  @override
  Future<AuthResponse> refresh(String refreshToken) {
    throw StateError('refresh not configured');
  }

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) {
    throw StateError('loginWithGoogle not configured');
  }

  @override
  Future<void> logout({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {}
}
