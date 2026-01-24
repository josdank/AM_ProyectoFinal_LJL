import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_repository.dart';

class RejectInterest implements UseCase<ConnectionRequest, RejectInterestParams> {
  final ConnectionRepository repository;
  RejectInterest(this.repository);

  @override
  Future<Either<Failure, ConnectionRequest>> call(RejectInterestParams params) {
    return repository.rejectInterest(requestId: params.requestId);
  }
}

class RejectInterestParams extends Equatable {
  final String requestId;
  const RejectInterestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
