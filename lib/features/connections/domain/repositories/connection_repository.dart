import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/connection_request.dart';
import '../entities/match.dart';

abstract class ConnectionRepository {
  Future<Either<Failure, ConnectionRequest>> sendInterest({
    required String fromUserId,
    required String toUserId,
    String? listingId,
  });

  Future<Either<Failure, ConnectionRequest>> acceptInterest({
    required String requestId,
  });

  Future<Either<Failure, ConnectionRequest>> rejectInterest({
    required String requestId,
  });

  Future<Either<Failure, List<ConnectionRequest>>> getIncoming({
    required String userId,
  });

  Future<Either<Failure, List<ConnectionRequest>>> getOutgoing({
    required String userId,
  });

  Future<Either<Failure, List<Match>>> getMatches({
    required String userId,
  });
}
