import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_chat_rooms.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/listen_to_messages.dart';
import '../../domain/usecases/mark_as_read.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRooms getChatRooms;
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final ListenToMessages listenToMessages;
  final MarkAsRead markAsRead;

  StreamSubscription? _messagesSubscription;

  ChatBloc({
    required this.getChatRooms,
    required this.getMessages,
    required this.sendMessage,
    required this.listenToMessages,
    required this.markAsRead,
  }) : super(const ChatInitial()) {
    on<ChatRoomsLoadRequested>(_onLoadChatRooms);
    on<ChatMessagesLoadRequested>(_onLoadMessages);
    on<ChatMessageSendRequested>(_onSendMessage);
    on<ChatMessagesListenStarted>(_onStartListening);
    on<ChatMessagesListenStopped>(_onStopListening);
    on<ChatMessageReceived>(_onMessageReceived);
    on<ChatMarkAsReadRequested>(_onMarkAsRead);
  }

  Future<void> _onLoadChatRooms(
    ChatRoomsLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatRoomsLoading());

    final result = await getChatRooms(
      GetChatRoomsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (chatRooms) => emit(ChatRoomsLoaded(chatRooms: chatRooms)),
    );
  }

  Future<void> _onLoadMessages(
    ChatMessagesLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatMessagesLoading());

    final result = await getMessages(
      GetMessagesParams(chatRoomId: event.chatRoomId),
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(ChatMessagesLoaded(
        chatRoomId: event.chatRoomId,
        messages: messages,
      )),
    );
  }

  Future<void> _onSendMessage(
    ChatMessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatMessagesLoaded) return;

    final currentState = state as ChatMessagesLoaded;
    emit(currentState.copyWith(isSending: true));

    final result = await sendMessage(
      SendMessageParams(
        chatRoomId: event.chatRoomId,
        senderId: event.senderId,
        content: event.content,
      ),
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isSending: false));
        emit(ChatError(message: failure.message));
      },
      (message) {
        // El mensaje nuevo llegará por el stream
        emit(currentState.copyWith(isSending: false));
      },
    );
  }

  Future<void> _onStartListening(
    ChatMessagesListenStarted event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();

    _messagesSubscription = listenToMessages(
      ListenToMessagesParams(chatRoomId: event.chatRoomId),
    ).listen((message) {
      add(ChatMessageReceived(message: message));
    });
  }

  Future<void> _onStopListening(
    ChatMessagesListenStopped event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  void _onMessageReceived(
    ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      
      // Verificar si el mensaje ya existe
      final existingIndex = currentState.messages
          .indexWhere((m) => m.id == event.message.id);
      
      List<Message> updatedMessages;
      
      if (existingIndex != -1) {
        // Actualizar mensaje existente
        updatedMessages = List.from(currentState.messages);
        updatedMessages[existingIndex] = event.message;
      } else {
        // Agregar nuevo mensaje
        updatedMessages = [...currentState.messages, event.message];
      }

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  Future<void> _onMarkAsRead(
    ChatMarkAsReadRequested event,
    Emitter<ChatState> emit,
  ) async {
    await markAsRead(
      MarkAsReadParams.all(
        chatRoomId: event.chatRoomId,
        userId: event.userId,
      ),
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}