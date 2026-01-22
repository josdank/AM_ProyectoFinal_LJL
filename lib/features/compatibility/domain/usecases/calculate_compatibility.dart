import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/compatibility_score.dart';
import '../repositories/compatibility_repository.dart';

class CalculateCompatibility implements UseCase<CompatibilityScore, CalculateCompatibilityParams> {
  final CompatibilityRepository repository;
  CalculateCompatibility(this.repository);

  @override
  Future<Either<Failure, CompatibilityScore>> call(CalculateCompatibilityParams params) async {
    return await repository.calculateCompatibility(params.userId1, params.userId2);
  }
}

class CalculateCompatibilityParams extends Equatable {
  final String userId1;
  final String userId2;

  const CalculateCompatibilityParams({
    required this.userId1,
    required this.userId2,
  });

  @override
  List<Object?> get props => [userId1, userId2];
}