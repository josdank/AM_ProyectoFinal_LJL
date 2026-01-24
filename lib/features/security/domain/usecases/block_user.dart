import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_block.dart';
import '../repositories/security_repository.dart';

class BlockUser implements UseCase<UserBlock, BlockUserParams> {
  final SecurityRepository repository;
  BlockUser(this.repository);

  @override
  Future<Either<Failure, UserBlock>> call(BlockUserParams params) {
    return repository.blockUser(blockerId: params.blockerId, blockedId: params.blockedId);
  }
}

class BlockUserParams extends Equatable {
  final String blockerId;
  final String blockedId;

  const BlockUserParams({
    required this.blockerId,
    required this.blockedId,
  });

  @override
  List<Object?> get props => [blockerId, blockedId];
}
