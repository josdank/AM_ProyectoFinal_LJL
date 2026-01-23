import 'package:equatable/equatable.dart';

/// Entidad que representa una sala de chat entre dos usuarios
class ChatRoom extends Equatable {
  final String id;
  final String connectionId; // FK a connections
  final String user1Id;
  final String user2Id;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final int unreadCount; // Mensajes no leídos
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.connectionId,
    required this.user1Id,
    required this.user2Id,
    this.lastMessageContent,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
  });

  /// Retorna el ID del otro usuario en el chat
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  @override
  List<Object?> get props => [
        id,
        connectionId,
        user1Id,
        user2Id,
        lastMessageContent,
        lastMessageAt,
        unreadCount,
        createdAt,
      ];
}