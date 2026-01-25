import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reference.dart';
import '../repositories/security_repository.dart';

class VerifyReference implements UseCase<Reference, VerifyReferenceParams> {
  final SecurityRepository repository;
  VerifyReference(this.repository);

  @override
  Future<Either<Failure, Reference>> call(VerifyReferenceParams params) {
    return repository.verifyReference(
      referenceId: params.referenceId,
      code: params.code,
    );
  }
}

class VerifyReferenceParams extends Equatable {
  final String referenceId;
  final String code;

  const VerifyReferenceParams({
    required this.referenceId,
    required this.code,
  });

  @override
  List<Object?> get props => [referenceId, code];
}