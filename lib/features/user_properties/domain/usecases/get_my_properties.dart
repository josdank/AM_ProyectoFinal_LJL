import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_property.dart';
import '../repositories/user_property_repository.dart';

class GetMyProperties implements UseCase<List<UserProperty>, GetMyPropertiesParams> {
  final UserPropertyRepository repository;

  GetMyProperties(this.repository);

  @override
  Future<Either<Failure, List<UserProperty>>> call(GetMyPropertiesParams params) async {
    return await repository.getMyProperties(params.ownerId);
  }
}

class GetMyPropertiesParams extends Equatable {
  final String ownerId;

  const GetMyPropertiesParams({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

