part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatRoomsLoading extends ChatState {
  const ChatRoomsLoading();
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> chatRooms;

  const ChatRoomsLoaded({required this.chatRooms});

  @override
  List<Object?> get props => [chatRooms];
}

class ChatMessagesLoading extends ChatState {
  const ChatMessagesLoading();
}

class ChatMessagesLoaded extends ChatState {
  final String chatRoomId;
  final List<Message> messages;
  final bool isSending;

  const ChatMessagesLoaded({
    required this.chatRoomId,
    required this.messages,
    this.isSending = false,
  });

  ChatMessagesLoaded copyWith({
    List<Message>? messages,
    bool? isSending,
  }) {
    return ChatMessagesLoaded(
      chatRoomId: chatRoomId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [chatRoomId, messages, isSending];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}