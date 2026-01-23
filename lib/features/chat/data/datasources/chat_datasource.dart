import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

abstract class ChatDatasource {
  /// Obtiene todas las salas de chat del usuario actual
  Future<List<ChatRoomModel>> getChatRooms(String userId);
  
  /// Obtiene los mensajes de una sala de chat
  Future<List<MessageModel>> getMessages(String chatRoomId);
  
  /// Envia un mensaje
  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  });
  
  /// Marca un mensaje como leido
  Future<void> markAsRead(String messageId);
  
  /// Marca todos los mensajes de un chat como leidos
  Future<void> markAllAsRead(String chatRoomId, String userId);
  
  /// Stream de mensajes en tiempo real
  Stream<MessageModel> listenToMessages(String chatRoomId);
  
  /// Stream de actualizaciones de chat rooms
  Stream<ChatRoomModel> listenToChatRoomUpdates(String userId);
}

class ChatDatasourceImpl implements ChatDatasource {
  final SupabaseClient client;

  ChatDatasourceImpl({required this.client});

  @override
  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    try {
      final response = await client
          .from('chat_rooms')
          .select('''
            *,
            connections!inner(
              requester_id,
              receiver_id,
              status
            )
          ''')
          .or('requester_id.eq.$userId,receiver_id.eq.$userId', 
              referencedTable: 'connections')
          .eq('connections.status', 'accepted')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => ChatRoomModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al cargar chats: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String chatRoomId) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al cargar mensajes: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    try {
      // 1. Insertar mensaje
      final messageResponse = await client
          .from('messages')
          .insert({
            'chat_room_id': chatRoomId,
            'sender_id': senderId,
            'content': content,
            'is_read': false,
          })
          .select()
          .single();

      // 2. Actualizar chat_room con último mensaje
      await client
          .from('chat_rooms')
          .update({
            'last_message_content': content,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chatRoomId);

      return MessageModel.fromJson(messageResponse);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al enviar mensaje: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await client
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al marcar como leído: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String chatRoomId, String userId) async {
    try {
      await client
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId) // Solo mensajes del otro usuario
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al marcar mensajes: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Stream<MessageModel> listenToMessages(String chatRoomId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', chatRoomId)
        .order('created_at')
        .map((data) => MessageModel.fromJson(data.last));
  }

  @override
  Stream<ChatRoomModel> listenToChatRoomUpdates(String userId) {
    return client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((data) {
          final chatRooms = data
              .map((json) => ChatRoomModel.fromJson(json))
              .where((room) => 
                  room.user1Id == userId || room.user2Id == userId)
              .toList();
          
          return chatRooms.isNotEmpty 
              ? chatRooms.first 
              : throw const ServerException(message: 'No hay chat rooms');
        });
  }
}