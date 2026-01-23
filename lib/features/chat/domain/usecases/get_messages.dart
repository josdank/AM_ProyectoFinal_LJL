import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages implements UseCase<List<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessages(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(params.chatRoomId);
  }
}

class GetMessagesParams extends Equatable {
  final String chatRoomId;

  const GetMessagesParams({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}