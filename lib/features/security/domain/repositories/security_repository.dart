import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/reference_model.dart';
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

  // ===== REFERENCIAS =====
  Future<List<ReferenceModel>> getUserReferences({required String userId});
  Future<ReferenceModel> addReference({required ReferenceModel reference});
  Future<ReferenceModel> updateReference({required ReferenceModel reference});
  Future<void> deleteReference({required String referenceId});
  Future<String> sendVerificationCode({
    required String referenceId,
    required String refereeEmail,
  });
  Future<ReferenceModel> verifyReference({
    required String referenceId,
    required String code,
  });
  
}
