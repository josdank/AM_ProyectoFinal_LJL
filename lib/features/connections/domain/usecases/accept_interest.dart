import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_repository.dart';

class AcceptInterest implements UseCase<ConnectionRequest, AcceptInterestParams> {
  final ConnectionRepository repository;
  AcceptInterest(this.repository);

  @override
  Future<Either<Failure, ConnectionRequest>> call(AcceptInterestParams params) {
    return repository.acceptInterest(requestId: params.requestId);
  }
}

class AcceptInterestParams extends Equatable {
  final String requestId;
  const AcceptInterestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
