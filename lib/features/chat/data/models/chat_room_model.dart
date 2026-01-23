import '../../domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.connectionId,
    required super.user1Id,
    required super.user2Id,
    super.lastMessageContent,
    super.lastMessageAt,
    super.unreadCount,
    required super.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      connectionId: json['connection_id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      lastMessageContent: json['last_message_content'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connection_id': connectionId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message_content': lastMessageContent,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatRoom toEntity() => ChatRoom(
        id: id,
        connectionId: connectionId,
        user1Id: user1Id,
        user2Id: user2Id,
        lastMessageContent: lastMessageContent,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
        createdAt: createdAt,
      );
}