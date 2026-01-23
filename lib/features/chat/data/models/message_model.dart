import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.chatRoomId,
    required super.senderId,
    required super.content,
    super.isRead,
    super.readAt,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Message toEntity() => Message(
        id: id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        content: content,
        isRead: isRead,
        readAt: readAt,
        createdAt: createdAt,
      );
}