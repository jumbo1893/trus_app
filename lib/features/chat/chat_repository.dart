import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:trus_app/common/repository/header/cookies/header_provider.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'chat_image_cache.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(ref));

class ChatRoom {
  final String kind, title;
  final int unread;
  final bool pushEnabled;
  ChatRoom.fromJson(Map<String, dynamic> json)
    : kind = json['kind'] as String,
      title = json['title'] as String,
      unread = (json['unread'] as num).toInt(),
      pushEnabled = json['pushEnabled'] as bool? ?? false;

  ChatRoom.withPushEnabled(ChatRoom room, this.pushEnabled)
    : kind = room.kind,
      title = room.title,
      unread = room.unread;
}

class ChatMessage {
  final int id, authorId;
  final String author;
  final String? text;
  final DateTime createdAt;
  final bool image, bot;
  final List<ChatReaction> reactions;
  final ChatReply? replyTo;
  String? get displayText {
    if (!bot || text == null) return text;
    return text!
        .replaceFirst(
          RegExp(
            r'^\s*(?:\*\*)?TrusBot(?:\*\*)?\s*[:：]\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  ChatMessage.fromJson(Map<String, dynamic> json)
    : id = (json['id'] as num).toInt(),
      authorId = (json['authorId'] as num).toInt(),
      author = json['author'] as String,
      text = json['text'] as String?,
      createdAt = DateTime.parse(json['createdAt'] as String).toLocal(),
      image = json['image'] as bool? ?? false,
      bot = json['bot'] as bool? ?? false,
      replyTo = json['replyTo'] == null
          ? null
          : ChatReply.fromJson(json['replyTo'] as Map<String, dynamic>),
      reactions = (json['reactions'] as List? ?? const [])
          .map((item) => ChatReaction.fromJson(item as Map<String, dynamic>))
          .toList();

  ChatMessage.withReactions(ChatMessage message, this.reactions)
    : id = message.id,
      authorId = message.authorId,
      author = message.author,
      text = message.text,
      createdAt = message.createdAt,
      image = message.image,
      bot = message.bot,
      replyTo = message.replyTo;
}

class ChatReply {
  final int id;
  final String author;
  final String? text;
  final bool image;
  ChatReply.fromJson(Map<String, dynamic> json)
    : id = (json['id'] as num).toInt(),
      author = json['author'] as String,
      text = json['text'] as String?,
      image = json['image'] as bool? ?? false;
}

class ChatReaction {
  final int userId;
  final String name, emoji;
  ChatReaction.fromJson(Map<String, dynamic> json)
    : userId = (json['userId'] as num).toInt(),
      name = json['name'] as String,
      emoji = json['emoji'] as String;
}

class ChatReactionUpdate {
  final int messageId;
  final List<ChatReaction> reactions;
  ChatReactionUpdate.fromJson(Map<String, dynamic> json)
    : messageId = (json['messageId'] as num).toInt(),
      reactions = (json['reactions'] as List)
          .map((item) => ChatReaction.fromJson(item as Map<String, dynamic>))
          .toList();
}

class ChatReceipt {
  final int userId;
  final String name;
  final int? lastMessageId;
  ChatReceipt.fromJson(Map<String, dynamic> json)
    : userId = (json['userId'] as num).toInt(),
      name = json['name'] as String,
      lastMessageId = (json['lastMessageId'] as num?)?.toInt();
}

class ChatDetail {
  final List<ChatMessage> messages;
  final List<ChatReceipt> receipts;
  const ChatDetail(this.messages, this.receipts);
  ChatDetail.fromJson(Map<String, dynamic> json)
    : messages = (json['messages'] as List)
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
      receipts = (json['receipts'] as List)
          .map((item) => ChatReceipt.fromJson(item as Map<String, dynamic>))
          .toList();
}

class ChatRepository extends RequestExecutor {
  ChatRepository(super.ref);
  final ChatImageCache _images = ChatImageCache();

  Future<List<ChatRoom>> rooms() => executeGetRequest(
    Uri.parse('$serverUrl/chat/rooms'),
    (json) => (json as List)
        .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
        .toList(),
    null,
  );

  Future<ChatDetail> detail(String kind, {int? before}) => executeGetRequest(
    Uri.parse('$serverUrl/chat/$kind'),
    (json) => ChatDetail.fromJson(json as Map<String, dynamic>),
    before == null ? null : {'before': '$before'},
  );

  Future<ChatDetail> around(String kind, int id) => executeGetRequest(
    Uri.parse('$serverUrl/chat/$kind/around/$id'),
    (json) => ChatDetail.fromJson(json as Map<String, dynamic>),
    null,
  );

  Future<bool> setPushEnabled(String kind, bool enabled) => executePutRequest(
    Uri.parse('$serverUrl/chat/$kind/push'),
    (json) => (json as Map<String, dynamic>)['pushEnabled'] as bool,
    jsonEncode({'enabled': enabled}),
    queueOnFailure: false,
  );

  Future<ChatMessage> send(String kind, String text, {int? replyToId}) =>
      executePostRequest(
        Uri.parse('$serverUrl/chat/$kind'),
        (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
        jsonEncode({
          'text': text,
          if (replyToId != null) 'replyToId': replyToId,
        }),
        queueOnFailure: false,
      );

  Future<ChatReceipt> markRead(String kind, int id) => executePostRequest(
    Uri.parse('$serverUrl/chat/$kind/read/$id'),
    (json) => ChatReceipt.fromJson(json as Map<String, dynamic>),
    '{}',
    queueOnFailure: false,
  );

  Future<ChatReactionUpdate> setReaction(String kind, int id, String? emoji) =>
      executePutRequest(
        Uri.parse('$serverUrl/chat/$kind/reactions/$id'),
        (json) => ChatReactionUpdate.fromJson(json as Map<String, dynamic>),
        jsonEncode({'emoji': emoji}),
        queueOnFailure: false,
      );

  Future<ChatMessage> sendImage(
    String kind,
    Uint8List bytes,
    String text, {
    int? replyToId,
  }) async {
    final client = getClient();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/chat/$kind/image'),
      );
      request.headers.addAll(
        await HeaderProvider(ref).getHeaders()
          ..remove('Content-Type'),
      );
      request.fields['text'] = text;
      if (replyToId != null) request.fields['replyToId'] = '$replyToId';
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'chat.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) throw Exception(response.body);
      final message = ChatMessage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      final accountId = FirebaseAuth.instance.currentUser?.uid;
      final teamId = ref.read(globalVariablesControllerProvider).appTeam?.id;
      if (accountId != null && teamId != null) {
        try {
          await _images.load(
            accountId: accountId,
            teamId: teamId,
            room: kind,
            messageId: message.id,
            fetch: () async => bytes,
          );
        } catch (_) {
          // The server accepted the image. A cache failure cannot undo it.
        }
      }
      return message;
    } finally {
      client.close();
    }
  }

  Future<Uint8List> image(String kind, int id) async {
    final accountId = FirebaseAuth.instance.currentUser?.uid;
    final teamId = ref.read(globalVariablesControllerProvider).appTeam?.id;
    if (accountId == null || teamId == null) {
      throw StateError('Chat image needs an authenticated team');
    }
    return _images.load(
      accountId: accountId,
      teamId: teamId,
      room: kind,
      messageId: id,
      fetch: () => _downloadImage(kind, id),
    );
  }

  Future<Uint8List> _downloadImage(String kind, int id) async {
    final client = getClient();
    try {
      final response = await client.get(
        Uri.parse('$serverUrl/chat/$kind/image/$id'),
        headers: await HeaderProvider(ref).getHeaders(),
      );
      if (response.statusCode != 200) throw Exception('Obrázek nelze načíst');
      return response.bodyBytes;
    } finally {
      client.close();
    }
  }
}
