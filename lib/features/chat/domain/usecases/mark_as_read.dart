import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class MarkAsRead implements UseCase<void, MarkAsReadParams> {
  final ChatRepository repository;

  MarkAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    if (params.messageId != null) {
      return await repository.markAsRead(params.messageId!);
    } else if (params.chatRoomId != null && params.userId != null) {
      return await repository.markAllAsRead(
        params.chatRoomId!,
        params.userId!,
      );
    }
    return Left(ServerFailure(message: 'Parámetros inválidos'));
  }
}

class MarkAsReadParams extends Equatable {
  final String? messageId; // Para marcar un mensaje específico
  final String? chatRoomId; // Para marcar todos los mensajes
  final String? userId;

  const MarkAsReadParams({
    this.messageId,
    this.chatRoomId,
    this.userId,
  });

  const MarkAsReadParams.single(String messageId)
      : messageId = messageId,
        chatRoomId = null,
        userId = null;

  const MarkAsReadParams.all({
    required String chatRoomId,
    required String userId,
  })  : chatRoomId = chatRoomId,
        userId = userId,
        messageId = null;

  @override
  List<Object?> get props => [messageId, chatRoomId, userId];
}