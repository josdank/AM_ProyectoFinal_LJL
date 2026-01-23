import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_block.dart';
import '../repositories/security_repository.dart';

class GetBlockedUsers implements UseCase<List<UserBlock>, GetBlockedUsersParams> {
  final SecurityRepository repository;
  GetBlockedUsers(this.repository);

  @override
  Future<Either<Failure, List<UserBlock>>> call(GetBlockedUsersParams params) {
    return repository.getBlockedUsers(blockerId: params.blockerId);
  }
}

class GetBlockedUsersParams extends Equatable {
  final String blockerId;
  const GetBlockedUsersParams({required this.blockerId});

  @override
  List<Object?> get props => [blockerId];
}
