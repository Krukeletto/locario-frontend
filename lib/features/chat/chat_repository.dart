import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? updatedAt;

  factory ChatConversation.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return ChatConversation(
      id: snapshot.id,
      participantIds:
          (data['participantIds'] as List?)?.whereType<String>().toList() ??
          const [],
      participantNames: _stringMap(data['participantNames']),
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: _date(data['updatedAt']),
    );
  }

  factory ChatConversation.fromMessageSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final chatId =
        data['chatId'] as String? ?? snapshot.reference.parent.parent?.id ?? '';
    return ChatConversation(
      id: chatId,
      participantIds:
          (data['participantAppUserIds'] as List?)
              ?.whereType<String>()
              .toList() ??
          (data['participantIds'] as List?)?.whereType<String>().toList() ??
          const [],
      participantNames: _stringMap(data['participantNames']),
      lastMessage:
          data['content'] as String? ??
          data['text'] as String? ??
          data['body'] as String? ??
          data['message'] as String? ??
          '',
      updatedAt:
          _date(data['timestamp']) ??
          _date(data['createdAt']) ??
          _date(data['sentAt']),
    );
  }

  String titleFor(String currentUserId) {
    for (final entry in participantNames.entries) {
      if (entry.key != currentUserId && entry.value.trim().isNotEmpty) {
        return entry.value;
      }
    }

    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Chat',
    );
  }

  String? participantIdFor(String currentUserId) {
    for (final id in participantIds) {
      if (id != currentUserId) return id;
    }
    return null;
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderAppUserId,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String senderId;
  final String senderAppUserId;
  final String content;
  final DateTime? timestamp;

  factory ChatMessage.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return ChatMessage(
      id: snapshot.id,
      senderId:
          data['senderId'] as String? ??
          data['senderUid'] as String? ??
          data['authorId'] as String? ??
          data['uid'] as String? ??
          '',
      senderAppUserId: data['senderAppUserId'] as String? ?? '',
      content:
          data['content'] as String? ??
          data['text'] as String? ??
          data['body'] as String? ??
          data['message'] as String? ??
          '',
      timestamp:
          _date(data['timestamp']) ??
          _date(data['createdAt']) ??
          _date(data['sentAt']),
    );
  }
}

class FirestoreChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  static String directChatId(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return 'dm_${ids[0]}_${ids[1]}';
  }

  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    return _firestore ?? FirebaseFirestore.instance;
  }

  Stream<List<ChatConversation>> watchConversations(String userId) {
    final db = _db;
    if (db == null || userId.isEmpty) {
      return Stream.value(const []);
    }

    return db
        .collectionGroup('messages')
        .where('participantAppUserIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final byChatId = <String, ChatConversation>{};

          for (final doc in snapshot.docs) {
            final conversation = ChatConversation.fromMessageSnapshot(doc);
            if (conversation.id.isEmpty ||
                conversation.lastMessage.trim().isEmpty) {
              continue;
            }

            final existing = byChatId[conversation.id];
            final existingTime =
                existing?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final conversationTime =
                conversation.updatedAt ??
                DateTime.fromMillisecondsSinceEpoch(0);
            if (existing == null || conversationTime.isAfter(existingTime)) {
              byChatId[conversation.id] = conversation;
            }
          }

          return byChatId.values.toList()..sort((a, b) {
            final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
        });
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    final db = _db;
    if (db == null || chatId.isEmpty) {
      return Stream.value(const []);
    }

    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ChatMessage.fromSnapshot).toList(),
        );
  }

  Future<ChatConversation?> fetchConversation(String chatId) async {
    final db = _db;
    if (db == null || chatId.isEmpty) return null;

    final snapshot = await db.collection('chats').doc(chatId).get();
    final data = snapshot.data();
    if (data == null) return null;

    return ChatConversation(
      id: snapshot.id,
      participantIds:
          (data['participantIds'] as List?)?.whereType<String>().toList() ??
          const [],
      participantNames: _stringMap(data['participantNames']),
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: _date(data['updatedAt']),
    );
  }

  Future<void> sendDirectMessage({
    required String chatId,
    required String senderAppUserId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String content,
  }) async {
    final db = _db;
    if (db == null) {
      throw const ChatSendException('Firebase nie został zainicjalizowany.');
    }

    final firebaseSenderId = await _resolveFirebaseSenderId(senderAppUserId);
    final chatRef = db.collection('chats').doc(chatId);
    final participantIds = [senderAppUserId, recipientId]..sort();
    final now = FieldValue.serverTimestamp();

    try {
      await chatRef.collection('messages').add({
        'senderId': firebaseSenderId,
        'senderAppUserId': senderAppUserId,
        'senderName': senderName,
        'recipientAppUserId': recipientId,
        'recipientName': recipientName,
        'participantAppUserIds': participantIds,
        'participantNames': {
          senderAppUserId: senderName,
          recipientId: recipientName,
        },
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'chatId': chatId,
        'isGroup': false,
      });
    } on FirebaseException catch (error) {
      throw ChatSendException.fromFirebase(error);
    }

    try {
      await chatRef.set({
        'participantIds': participantIds,
        'participantNames': {
          senderAppUserId: senderName,
          recipientId: recipientName,
        },
        'isGroup': false,
        'lastMessage': content,
        'updatedAt': now,
        'createdAt': now,
      }, SetOptions(merge: true));
    } on FirebaseException {
      // The backend listens to message documents. Chat metadata is only for
      // client-side listing, so a rules failure here must not roll back send.
    }
  }

  Future<String> _resolveFirebaseSenderId(String fallbackUserId) async {
    if (Firebase.apps.isEmpty) {
      throw const ChatSendException('Firebase nie został zainicjalizowany.');
    }

    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser != null) return currentUser.uid;

    try {
      final credential = await auth.signInAnonymously();
      final uid = credential.user?.uid;
      if (uid != null && uid.isNotEmpty) return uid;
      throw const ChatSendException(
        'Nie udało się utworzyć sesji Firebase Auth.',
      );
    } on FirebaseAuthException catch (error) {
      throw ChatSendException.fromFirebaseAuth(error);
    }
  }
}

class ChatSendException implements Exception {
  const ChatSendException(this.message);

  final String message;

  factory ChatSendException.fromFirebase(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const ChatSendException(
        'Brak uprawnień Firestore do zapisu wiadomości.',
      ),
      'unavailable' => const ChatSendException(
        'Firestore jest chwilowo niedostępny. Spróbuj ponownie.',
      ),
      'failed-precondition' => const ChatSendException(
        'Firestore wymaga dodatkowej konfiguracji indeksu lub reguł.',
      ),
      _ => ChatSendException('Błąd Firestore: ${error.code}.'),
    };
  }

  factory ChatSendException.fromFirebaseAuth(FirebaseAuthException error) {
    return switch (error.code) {
      'operation-not-allowed' => const ChatSendException(
        'Włącz Anonymous Auth w Firebase albo zaloguj użytkownika do Firebase.',
      ),
      'network-request-failed' => const ChatSendException(
        'Brak połączenia z Firebase Auth.',
      ),
      _ => ChatSendException('Błąd Firebase Auth: ${error.code}.'),
    };
  }

  @override
  String toString() => message;
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const {};

  return value.map(
    (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
  );
}

DateTime? _date(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
