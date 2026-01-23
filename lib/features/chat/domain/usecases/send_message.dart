import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage implements UseCase<Message, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      chatRoomId: params.chatRoomId,
      senderId: params.senderId,
      content: params.content,
    );
  }
}

class SendMessageParams extends Equatable {
  final String chatRoomId;
  final String senderId;
  final String content;

  const SendMessageParams({
    required this.chatRoomId,
    required this.senderId,
    required this.content,
  });

  @override
  List<Object?> get props => [chatRoomId, senderId, content];
}