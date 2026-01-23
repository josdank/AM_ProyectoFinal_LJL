import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification.dart';
import '../repositories/security_repository.dart';

class SubmitVerification implements UseCase<Verification, SubmitVerificationParams> {
  final SecurityRepository repository;
  SubmitVerification(this.repository);

  @override
  Future<Either<Failure, Verification>> call(SubmitVerificationParams params) {
    return repository.submitVerification(userId: params.userId, type: params.type);
  }
}

class SubmitVerificationParams extends Equatable {
  final String userId;
  final String type;
  const SubmitVerificationParams({required this.userId, required this.type});

  @override
  List<Object?> get props => [userId, type];
}
