import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/security_repository.dart';

class DeleteReference implements UseCase<void, DeleteReferenceParams> {
  final SecurityRepository repository;
  DeleteReference(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReferenceParams params) {
    return repository.deleteReference(referenceId: params.referenceId);
  }
}

class DeleteReferenceParams extends Equatable {
  final String referenceId;
  const DeleteReferenceParams({required this.referenceId});

  @override
  List<Object?> get props => [referenceId];
}