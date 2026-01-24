import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_repository.dart';

class GetIncomingInterests implements UseCase<List<ConnectionRequest>, GetIncomingInterestsParams> {
  final ConnectionRepository repository;
  GetIncomingInterests(this.repository);

  @override
  Future<Either<Failure, List<ConnectionRequest>>> call(GetIncomingInterestsParams params) {
    return repository.getIncoming(userId: params.userId);
  }
}

class GetIncomingInterestsParams extends Equatable {
  final String userId;
  const GetIncomingInterestsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
