import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_property_repository.dart';

class TogglePropertyStatus implements UseCase<void, TogglePropertyStatusParams> {
  final UserPropertyRepository repository;

  TogglePropertyStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(TogglePropertyStatusParams params) async {
    return await repository.togglePropertyStatus(
      propertyId: params.propertyId,
      isActive: params.isActive,
    );
  }
}

class TogglePropertyStatusParams extends Equatable {
  final String propertyId;
  final bool isActive;

  const TogglePropertyStatusParams({
    required this.propertyId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [propertyId, isActive];
}