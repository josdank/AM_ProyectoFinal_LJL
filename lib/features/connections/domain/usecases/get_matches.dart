import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/match.dart';
import '../repositories/connection_repository.dart';

class GetMatches implements UseCase<List<Match>, GetMatchesParams> {
  final ConnectionRepository repository;
  GetMatches(this.repository);

  @override
  Future<Either<Failure, List<Match>>> call(GetMatchesParams params) {
    return repository.getMatches(userId: params.userId);
  }
}

class GetMatchesParams extends Equatable {
  final String userId;
  const GetMatchesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
