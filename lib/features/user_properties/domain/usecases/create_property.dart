import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_property.dart';
import '../repositories/user_property_repository.dart';

class CreateProperty implements UseCase<UserProperty, CreatePropertyParams> {
  final UserPropertyRepository repository;

  CreateProperty(this.repository);

  @override
  Future<Either<Failure, UserProperty>> call(CreatePropertyParams params) async {
    return await repository.createProperty(params.property);
  }
}

class CreatePropertyParams extends Equatable {
  final UserProperty property;

  const CreatePropertyParams({required this.property});

  @override
  List<Object?> get props => [property];
}

