import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification.dart';
import '../repositories/security_repository.dart';

class GetVerificationStatus implements UseCase<Verification?, GetVerificationStatusParams> {
  final SecurityRepository repository;
  GetVerificationStatus(this.repository);

  @override
  Future<Either<Failure, Verification?>> call(GetVerificationStatusParams params) {
    return repository.getVerificationStatus(userId: params.userId);
  }
}

class GetVerificationStatusParams extends Equatable {
  final String userId;
  const GetVerificationStatusParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
