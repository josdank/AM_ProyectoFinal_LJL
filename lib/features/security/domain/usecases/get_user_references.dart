import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reference.dart';
import '../repositories/security_repository.dart';

class GetUserReferences implements UseCase<List<Reference>, GetUserReferencesParams> {
  final SecurityRepository repository;
  GetUserReferences(this.repository);

  @override
  Future<Either<Failure, List<Reference>>> call(GetUserReferencesParams params) {
    return repository.getUserReferences(userId: params.userId);
  }
}

class GetUserReferencesParams extends Equatable {
  final String userId;
  const GetUserReferencesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}