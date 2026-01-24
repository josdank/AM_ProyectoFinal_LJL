import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/connection_request.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/connection_repository.dart';
import '../datasources/connection_datasource.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionDatasource datasource;
  ConnectionRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, ConnectionRequest>> sendInterest({
    required String fromUserId,
    required String toUserId,
    String? listingId,
  }) async {
    try {
      final res = await datasource.sendInterest(
        fromUserId: fromUserId,
        toUserId: toUserId,
        listingId: listingId,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectionRequest>> acceptInterest({required String requestId}) async {
    try {
      final res = await datasource.acceptInterest(requestId: requestId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectionRequest>> rejectInterest({required String requestId}) async {
    try {
      final res = await datasource.rejectInterest(requestId: requestId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConnectionRequest>>> getIncoming({required String userId}) async {
    try {
      final res = await datasource.getIncoming(userId: userId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConnectionRequest>>> getOutgoing({required String userId}) async {
    try {
      final res = await datasource.getOutgoing(userId: userId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Match>>> getMatches({required String userId}) async {
    try {
      final res = await datasource.getMatches(userId: userId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
