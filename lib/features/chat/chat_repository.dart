import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../../shared/config/api_config.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessage,
    required this.updatedAt,
    this.groupName,
    this.isGroup = false,
  });

  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? updatedAt;
  final String? groupName;
  final bool isGroup;

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
      groupName: data['groupName'] as String?,
      isGroup: data['isGroup'] as bool? ?? false,
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
      lastMessage: _messagePreview(data),
      updatedAt:
          _date(data['timestamp']) ??
          _date(data['createdAt']) ??
          _date(data['sentAt']),
      groupName: data['groupName'] as String?,
      isGroup: data['isGroup'] as bool? ?? false,
    );
  }

  String titleFor(String currentUserId) {
    if (isGroup && groupName?.trim().isNotEmpty == true) {
      return groupName!.trim();
    }

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
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.imageUrl,
  });

  final String id;
  final String senderId;
  final String senderAppUserId;
  final String senderName;
  final String content;
  final DateTime? timestamp;
  final String? imageUrl;

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
      senderName: data['senderName'] as String? ?? '',
      content:
          data['content'] as String? ??
          data['text'] as String? ??
          data['body'] as String? ??
          data['message'] as String? ??
          '',
      imageUrl: data['imageUrl'] as String? ?? data['mediaUrl'] as String?,
      timestamp:
          _date(data['timestamp']) ??
          _date(data['createdAt']) ??
          _date(data['sentAt']),
    );
  }
}

class ChatImageAttachment {
  const ChatImageAttachment({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class FirestoreChatRepository {
  FirestoreChatRepository({
    FirebaseFirestore? firestore,
    http.Client? client,
    String? baseUrl,
  }) : _firestore = firestore,
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final FirebaseFirestore? _firestore;
  final http.Client _client;
  final String _baseUrl;

  static String directChatId(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return 'dm_${ids[0]}_${ids[1]}';
  }

  static String groupChatId(String groupId) => 'group_$groupId';

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
      groupName: data['groupName'] as String?,
      isGroup: data['isGroup'] as bool? ?? false,
    );
  }

  Future<void> sendDirectMessage({
    required String chatId,
    required String senderAppUserId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String content,
    ChatImageAttachment? image,
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final db = _db;
    if (db == null) {
      throw const ChatSendException('Firebase nie został zainicjalizowany.');
    }
    if (content.trim().isEmpty && image == null) {
      return;
    }

    final firebaseSenderId = await _resolveFirebaseSenderId(senderAppUserId);
    final chatRef = db.collection('chats').doc(chatId);
    final participantIds = [senderAppUserId, recipientId]..sort();
    final now = FieldValue.serverTimestamp();
    final imageUrl = image == null
        ? null
        : await _uploadChatImage(
            chatId: chatId,
            image: image,
            accessToken: accessToken,
            tokenType: tokenType,
          );
    final preview = content.trim().isNotEmpty ? content.trim() : 'Zdjęcie';

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
        if (content.trim().isNotEmpty) 'content': content.trim(),
        'imageUrl': ?imageUrl,
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
        'lastMessage': preview,
        'updatedAt': now,
        'createdAt': now,
      }, SetOptions(merge: true));
    } on FirebaseException {
      return;
    }
  }

  Future<void> sendGroupMessage({
    required String chatId,
    required String senderAppUserId,
    required String senderName,
    required String groupName,
    required List<String> participantIds,
    required String content,
    ChatImageAttachment? image,
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final db = _db;
    if (db == null) {
      throw const ChatSendException('Firebase nie został zainicjalizowany.');
    }
    if (content.trim().isEmpty && image == null) {
      return;
    }

    final firebaseSenderId = await _resolveFirebaseSenderId(senderAppUserId);
    final chatRef = db.collection('chats').doc(chatId);
    final resolvedParticipantIds = {
      ...participantIds.where((id) => id.trim().isNotEmpty),
      senderAppUserId,
    }.toList()..sort();
    final now = FieldValue.serverTimestamp();
    final imageUrl = image == null
        ? null
        : await _uploadChatImage(
            chatId: chatId,
            image: image,
            accessToken: accessToken,
            tokenType: tokenType,
          );
    final preview = content.trim().isNotEmpty ? content.trim() : 'Zdjęcie';

    try {
      await chatRef.collection('messages').add({
        'senderId': firebaseSenderId,
        'senderAppUserId': senderAppUserId,
        'senderName': senderName,
        'participantAppUserIds': resolvedParticipantIds,
        'participantNames': {senderAppUserId: senderName},
        if (content.trim().isNotEmpty) 'content': content.trim(),
        'imageUrl': ?imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'chatId': chatId,
        'groupName': groupName,
        'isGroup': true,
      });
    } on FirebaseException catch (error) {
      throw ChatSendException.fromFirebase(error);
    }

    try {
      await chatRef.set({
        'participantIds': resolvedParticipantIds,
        'participantNames': {senderAppUserId: senderName},
        'groupName': groupName,
        'isGroup': true,
        'lastMessage': preview,
        'updatedAt': now,
        'createdAt': now,
      }, SetOptions(merge: true));
    } on FirebaseException {
      return;
    }
  }

  Future<String> _uploadChatImage({
    required String chatId,
    required ChatImageAttachment image,
    required String? accessToken,
    required String tokenType,
  }) async {
    if (accessToken == null || accessToken.isEmpty) {
      throw const ChatSendException(
        'Zaloguj się ponownie, żeby wysłać zdjęcie.',
      );
    }
    if (image.bytes.length > 10 * 1024 * 1024) {
      throw const ChatSendException('Zdjęcie może mieć maksymalnie 10 MB.');
    }

    final contentType = _resolveImageMimeType(image.fileName);
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/media/presigned-upload-url'),
      headers: {
        'Authorization': '$tokenType $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'entityType': 'CHAT_MEDIA',
        'entityId': chatId,
        'fileName': image.fileName,
        'contentType': contentType,
        'fileSize': image.bytes.length,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw const ChatSendException(
        'Nie udało się przygotować uploadu zdjęcia.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ChatSendException('Nieprawidłowa odpowiedź uploadu zdjęcia.');
    }

    final uploadUrl = decoded['uploadUrl'] as String?;
    final publicUrl = decoded['publicUrl'] as String?;
    if (uploadUrl == null || publicUrl == null) {
      throw const ChatSendException('Brak adresu uploadu zdjęcia.');
    }

    final uploadResponse = await _client.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: image.bytes,
    );
    if (uploadResponse.statusCode != 200) {
      throw const ChatSendException('Nie udało się wysłać zdjęcia.');
    }

    return publicUrl;
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

String _messagePreview(Map<String, dynamic> data) {
  final content =
      data['content'] as String? ??
      data['text'] as String? ??
      data['body'] as String? ??
      data['message'] as String? ??
      '';
  if (content.trim().isNotEmpty) {
    return content;
  }

  final imageUrl = data['imageUrl'] as String? ?? data['mediaUrl'] as String?;
  if (imageUrl != null && imageUrl.trim().isNotEmpty) {
    return 'Zdjęcie';
  }

  return '';
}

String _resolveImageMimeType(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  return switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'jpg' || 'jpeg' => 'image/jpeg',
    _ => 'image/jpeg',
  };
}
