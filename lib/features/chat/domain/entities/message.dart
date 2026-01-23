import 'package:equatable/equatable.dart';

/// Entidad que representa un mensaje individual en el chat
class Message extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  /// Copia el mensaje marcándolo como leido
  Message copyWithRead() {
    return Message(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      content: content,
      isRead: true,
      readAt: DateTime.now(),
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatRoomId,
        senderId,
        content,
        isRead,
        readAt,
        createdAt,
      ];
}