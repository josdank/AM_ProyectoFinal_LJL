import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_repository.dart';

class SendInterest implements UseCase<ConnectionRequest, SendInterestParams> {
  final ConnectionRepository repository;
  SendInterest(this.repository);

  @override
  Future<Either<Failure, ConnectionRequest>> call(SendInterestParams params) {
    return repository.sendInterest(
      fromUserId: params.fromUserId,
      toUserId: params.toUserId,
      listingId: params.listingId,
    );
  }
}

class SendInterestParams extends Equatable {
  final String fromUserId;
  final String toUserId;
  final String? listingId;

  const SendInterestParams({
    required this.fromUserId,
    required this.toUserId,
    this.listingId,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, listingId];
}
