import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_repository.dart';

class GetOutgoingInterests implements UseCase<List<ConnectionRequest>, GetOutgoingInterestsParams> {
  final ConnectionRepository repository;
  GetOutgoingInterests(this.repository);

  @override
  Future<Either<Failure, List<ConnectionRequest>>> call(GetOutgoingInterestsParams params) {
    return repository.getOutgoing(userId: params.userId);
  }
}

class GetOutgoingInterestsParams extends Equatable {
  final String userId;
  const GetOutgoingInterestsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
