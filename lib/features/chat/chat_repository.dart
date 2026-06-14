import 'package:cloud_firestore/cloud_firestore.dart';
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
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String senderId;
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
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final conversations =
              snapshot.docs
                  .map(ChatConversation.fromSnapshot)
                  .where((chat) => chat.lastMessage.trim().isNotEmpty)
                  .toList()
                ..sort((a, b) {
                  final aTime =
                      a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bTime =
                      b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return bTime.compareTo(aTime);
                });
          return conversations;
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
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String content,
  }) async {
    final db = _db;
    if (db == null) {
      throw StateError('Firebase is not initialized.');
    }

    final chatRef = db.collection('chats').doc(chatId);
    final participantIds = [senderId, recipientId]..sort();
    final now = FieldValue.serverTimestamp();

    await chatRef.set({
      'participantIds': participantIds,
      'participantNames': {senderId: senderName, recipientId: recipientName},
      'isGroup': false,
      'lastMessage': content,
      'updatedAt': now,
      'createdAt': now,
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'chatId': chatId,
      'isGroup': false,
    });
  }
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
