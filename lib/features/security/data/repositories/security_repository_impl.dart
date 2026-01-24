import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_block.dart';
import '../../domain/entities/user_report.dart';
import '../../domain/entities/verification.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_datasource.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityDatasource datasource;
  SecurityRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, Verification?>> getVerificationStatus({required String userId}) async {
    try {
      final res = await datasource.getVerificationStatus(userId: userId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verification>> submitVerification({required String userId, required String type}) async {
    try {
      final res = await datasource.submitVerification(userId: userId, type: type);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserReport>> reportUser({
    required String reporterId,
    required String reportedId,
    required String reason,
    String? details,
  }) async {
    try {
      final res = await datasource.reportUser(
        reporterId: reporterId,
        reportedId: reportedId,
        reason: reason,
        details: details,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserBlock>> blockUser({required String blockerId, required String blockedId}) async {
    try {
      final res = await datasource.blockUser(blockerId: blockerId, blockedId: blockedId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserBlock>>> getBlockedUsers({required String blockerId}) async {
    try {
      final res = await datasource.getBlockedUsers(blockerId: blockerId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
