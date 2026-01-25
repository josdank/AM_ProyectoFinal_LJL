import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/security_repository.dart';

class SendVerificationCode implements UseCase<String, SendVerificationCodeParams> {
  final SecurityRepository repository;
  SendVerificationCode(this.repository);

  @override
  Future<Either<Failure, String>> call(SendVerificationCodeParams params) {
    return repository.sendVerificationCode(
      referenceId: params.referenceId,
      refereeEmail: params.refereeEmail,
    );
  }
}

class SendVerificationCodeParams extends Equatable {
  final String referenceId;
  final String refereeEmail;

  const SendVerificationCodeParams({
    required this.referenceId,
    required this.refereeEmail,
  });

  @override
  List<Object?> get props => [referenceId, refereeEmail];
}