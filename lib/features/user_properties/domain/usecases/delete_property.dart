import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_property_repository.dart';

class DeleteProperty implements UseCase<void, DeletePropertyParams> {
  final UserPropertyRepository repository;

  DeleteProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePropertyParams params) async {
    return await repository.deleteProperty(params.propertyId);
  }
}

class DeletePropertyParams extends Equatable {
  final String propertyId;

  const DeletePropertyParams({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

