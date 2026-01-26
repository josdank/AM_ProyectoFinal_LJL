import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_property.dart';
import '../repositories/user_property_repository.dart';

class UpdateProperty implements UseCase<UserProperty, UpdatePropertyParams> {
  final UserPropertyRepository repository;

  UpdateProperty(this.repository);

  @override
  Future<Either<Failure, UserProperty>> call(UpdatePropertyParams params) async {
    return await repository.updateProperty(params.property);
  }
}

class UpdatePropertyParams extends Equatable {
  final UserProperty property;

  const UpdatePropertyParams({required this.property});

  @override
  List<Object?> get props => [property];
}

