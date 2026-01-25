import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reference.dart'; 
import '../entities/user_block.dart';
import '../entities/user_report.dart';
import '../entities/verification.dart';

abstract class SecurityRepository {
  Future<Either<Failure, Verification?>> getVerificationStatus({required String userId});

  Future<Either<Failure, Verification>> submitVerification({
    required String userId,
    required String type,
  });

  Future<Either<Failure, UserReport>> reportUser({
    required String reporterId,
    required String reportedId,
    required String reason,
    String? details,
  });

  Future<Either<Failure, UserBlock>> blockUser({
    required String blockerId,
    required String blockedId,
  });

  Future<Either<Failure, List<UserBlock>>> getBlockedUsers({required String blockerId});

  // ===== REFERENCIAS ===== ✅ CORREGIDO
  Future<Either<Failure, List<Reference>>> getUserReferences({
    required String userId,
  });
  
  Future<Either<Failure, Reference>> addReference({
    required String userId,
    required String refereeName,
    required String refereeEmail,
    required String refereePhone,
    required String relationship,
    String? comments,
    int? rating,
  });
  
  Future<Either<Failure, Reference>> updateReference({
    required Reference reference,
  });
  
  Future<Either<Failure, void>> deleteReference({
    required String referenceId,
  });
  
  Future<Either<Failure, String>> sendVerificationCode({
    required String referenceId,
    required String refereeEmail,
  });
  
  Future<Either<Failure, Reference>> verifyReference({
    required String referenceId,
    required String code,
  });
}