import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habits.dart';
import '../repositories/compatibility_repository.dart';

class GetUserHabits implements UseCase<Habits, GetUserHabitsParams> {
  final CompatibilityRepository repository;
  GetUserHabits(this.repository);

  @override
  Future<Either<Failure, Habits>> call(GetUserHabitsParams params) async {
    return await repository.getUserHabits(params.userId);
  }
}

class GetUserHabitsParams extends Equatable {
  final String userId;

  const GetUserHabitsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}