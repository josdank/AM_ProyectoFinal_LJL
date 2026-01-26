import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_block.dart';
import '../../domain/entities/user_report.dart';
import '../../domain/entities/verification.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_datasource.dart';
import '../models/reference_model.dart';
import '../../domain/entities/reference.dart';

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

  // ===== REFERENCIAS =====
  @override
  Future<Either<Failure, List<Reference>>> getUserReferences({
    required String userId,
  }) async {
    try {
      final res = await datasource.getUserReferences(userId: userId);
      return Right(res.cast<Reference>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reference>> addReference({
    required String userId,
    required String refereeName,
    required String refereeEmail,
    required String refereePhone,
    required String relationship,
    String? comments,
    int? rating,
  }) async {
    try {
      final reference = ReferenceModel(
        id: '', // Supabase lo genera
        userId: userId,
        refereeName: refereeName,
        refereeEmail: refereeEmail,
        refereePhone: refereePhone,
        relationship: relationship,
        comment: comments,
        rating: rating,
        verified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final res = await datasource.addReference(reference: reference);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reference>> updateReference({
    required Reference reference,
  }) async {
    try {
      final model = ReferenceModel(
        id: reference.id,
        userId: reference.userId,
        refereeName: reference.refereeName,
        refereeEmail: reference.refereeEmail,
        refereePhone: reference.refereePhone,
        relationship: reference.relationship,
        comment: reference.comment,
        rating: reference.rating,
        verified: reference.verified,
        verificationCode: reference.verificationCode,
        codeExpiresAt: reference.codeExpiresAt,
        createdAt: reference.createdAt,
        updatedAt: DateTime.now(),
      );

      final res = await datasource.updateReference(reference: model);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReference({
    required String referenceId,
  }) async {
    try {
      await datasource.deleteReference(referenceId: referenceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendVerificationCode({
    required String referenceId,
    required String refereeEmail,
  }) async {
    try {
      final code = await datasource.sendVerificationCode(
        referenceId: referenceId,
        refereeEmail: refereeEmail,
      );
      return Right(code);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reference>> verifyReference({
    required String referenceId,
    required String code,
  }) async {
    try {
      final res = await datasource.verifyReference(
        referenceId: referenceId,
        code: code,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
