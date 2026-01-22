import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/compatibility_calculator.dart';
import '../../domain/entities/compatibility_score.dart';
import '../../domain/entities/habits.dart';
import '../../domain/repositories/compatibility_repository.dart';
import '../datasources/questionnaire_datasource.dart';
import '../models/habits_model.dart';

class CompatibilityRepositoryImpl implements CompatibilityRepository {
  final QuestionnaireDatasource datasource;

  CompatibilityRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, Habits>> getUserHabits(String userId) async {
    try {
      final habits = await datasource.getUserHabits(userId);
      return Right(habits.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Habits>> saveHabits(Habits habits) async {
    try {
      final habitsModel = HabitsModel(
        id: habits.id,
        userId: habits.userId,
        sleepSchedule: habits.sleepSchedule,
        noiseToleranceLevel: habits.noiseToleranceLevel,
        cleanlinessLevel: habits.cleanlinessLevel,
        cleaningFrequency: habits.cleaningFrequency,
        socialPreference: habits.socialPreference,
        guestsAllowed: habits.guestsAllowed,
        guestFrequency: habits.guestFrequency,
        smoker: habits.smoker,
        drinker: habits.drinker,
        hasPets: habits.hasPets,
        petType: habits.petType,
        workSchedule: habits.workSchedule,
        worksFromHome: habits.worksFromHome,
        sharedCommonAreas: habits.sharedCommonAreas,
        sharedKitchenware: habits.sharedKitchenware,
        temperaturePreference: habits.temperaturePreference,
        hobbies: habits.hobbies,
        musicVolume: habits.musicVolume,
        createdAt: habits.createdAt,
        updatedAt: habits.updatedAt,
      );

      final result = await datasource.saveHabits(habitsModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, CompatibilityScore>> calculateCompatibility(
    String userId1,
    String userId2,
  ) async {
    try {
      final habits1 = await datasource.getUserHabits(userId1);
      final habits2 = await datasource.getUserHabits(userId2);

      final score = CompatibilityCalculator.calculate(
        habits1.toEntity(),
        habits2.toEntity(),
      );

      return Right(score);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al calcular compatibilidad: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Habits>>> getAllHabits() async {
    try {
      final habitsList = await datasource.getAllHabits();
      return Right(habitsList.map((h) => h.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}