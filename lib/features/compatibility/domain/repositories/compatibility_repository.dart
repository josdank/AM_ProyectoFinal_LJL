import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/habits.dart';
import '../entities/compatibility_score.dart';

abstract class CompatibilityRepository {
  Future<Either<Failure, Habits>> getUserHabits(String userId);
  Future<Either<Failure, Habits>> saveHabits(Habits habits);
  Future<Either<Failure, CompatibilityScore>> calculateCompatibility(
    String userId1,
    String userId2,
  );
  Future<Either<Failure, List<Habits>>> getAllHabits();
}