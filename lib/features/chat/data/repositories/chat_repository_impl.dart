import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDatasource datasource;

  ChatRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<ChatRoom>>> getChatRooms(String userId) async {
    try {
      final chatRooms = await datasource.getChatRooms(userId);
      return Right(chatRooms.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String chatRoomId) async {
    try {
      final messages = await datasource.getMessages(chatRoomId);
      return Right(messages.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final message = await datasource.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        content: content,
      );
      return Right(message.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String messageId) async {
    try {
      await datasource.markAsRead(messageId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(
      String chatRoomId, String userId) async {
    try {
      await datasource.markAllAsRead(chatRoomId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Stream<Message> listenToMessages(String chatRoomId) {
    return datasource
        .listenToMessages(chatRoomId)
        .map((model) => model.toEntity());
  }

  @override
  Stream<ChatRoom> listenToChatRoomUpdates(String userId) {
    return datasource
        .listenToChatRoomUpdates(userId)
        .map((model) => model.toEntity());
  }
}