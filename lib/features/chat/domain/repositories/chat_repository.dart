import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_room.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  /// Obtiene todas las salas de chat del usuario
  Future<Either<Failure, List<ChatRoom>>> getChatRooms(String userId);
  
  /// Obtiene los mensajes de una sala de chat
  Future<Either<Failure, List<Message>>> getMessages(String chatRoomId);
  
  /// Envia un mensaje
  Future<Either<Failure, Message>> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  });
  
  /// Marca un mensaje como leido
  Future<Either<Failure, void>> markAsRead(String messageId);
  
  /// Marca todos los mensajes de un chat como leidos
  Future<Either<Failure, void>> markAllAsRead(String chatRoomId, String userId);
  
  /// Stream de mensajes en tiempo real
  Stream<Message> listenToMessages(String chatRoomId);
  
  /// Stream de actualizaciones de chat rooms
  Stream<ChatRoom> listenToChatRoomUpdates(String userId);
}