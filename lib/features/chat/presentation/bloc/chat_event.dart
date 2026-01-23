part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de chat rooms del usuario
class ChatRoomsLoadRequested extends ChatEvent {
  final String userId;

  const ChatRoomsLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Cargar mensajes de un chat específico
class ChatMessagesLoadRequested extends ChatEvent {
  final String chatRoomId;

  const ChatMessagesLoadRequested({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}

/// Enviar un mensaje
class ChatMessageSendRequested extends ChatEvent {
  final String chatRoomId;
  final String senderId;
  final String content;

  const ChatMessageSendRequested({
    required this.chatRoomId,
    required this.senderId,
    required this.content,
  });

  @override
  List<Object?> get props => [chatRoomId, senderId, content];
}

/// Iniciar escucha de mensajes en tiempo real
class ChatMessagesListenStarted extends ChatEvent {
  final String chatRoomId;

  const ChatMessagesListenStarted({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}

/// Detener escucha de mensajes
class ChatMessagesListenStopped extends ChatEvent {
  const ChatMessagesListenStopped();
}

/// Evento interno cuando se recibe un mensaje del stream
class ChatMessageReceived extends ChatEvent {
  final Message message;

  const ChatMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Marcar mensajes como leídos
class ChatMarkAsReadRequested extends ChatEvent {
  final String chatRoomId;
  final String userId;

  const ChatMarkAsReadRequested({
    required this.chatRoomId,
    required this.userId,
  });

  @override
  List<Object?> get props => [chatRoomId, userId];
}