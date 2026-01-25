import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reference.dart';
import '../repositories/security_repository.dart';

class UpdateReference implements UseCase<Reference, UpdateReferenceParams> {
  final SecurityRepository repository;
  UpdateReference(this.repository);

  @override
  Future<Either<Failure, Reference>> call(UpdateReferenceParams params) {
    return repository.updateReference(reference: params.reference);
  }
}

class UpdateReferenceParams extends Equatable {
  final Reference reference;
  const UpdateReferenceParams({required this.reference});

  @override
  List<Object?> get props => [reference];
}