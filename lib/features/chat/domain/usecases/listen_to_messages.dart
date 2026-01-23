import 'package:equatable/equatable.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// Use case para escuchar mensajes en tiempo real
/// No usa Either porque es un Stream
class ListenToMessages {
  final ChatRepository repository;

  ListenToMessages(this.repository);

  Stream<Message> call(ListenToMessagesParams params) {
    return repository.listenToMessages(params.chatRoomId);
  }
}

class ListenToMessagesParams extends Equatable {
  final String chatRoomId;

  const ListenToMessagesParams({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}