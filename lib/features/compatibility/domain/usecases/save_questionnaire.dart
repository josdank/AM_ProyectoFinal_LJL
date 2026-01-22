import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habits.dart';
import '../repositories/compatibility_repository.dart';

class SaveQuestionnaire implements UseCase<Habits, SaveQuestionnaireParams> {
  final CompatibilityRepository repository;
  SaveQuestionnaire(this.repository);

  @override
  Future<Either<Failure, Habits>> call(SaveQuestionnaireParams params) async {
    return await repository.saveHabits(params.habits);
  }
}

class SaveQuestionnaireParams extends Equatable {
  final Habits habits;

  const SaveQuestionnaireParams({required this.habits});

  @override
  List<Object?> get props => [habits];
}