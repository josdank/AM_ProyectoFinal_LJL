import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/compatibility_score.dart';
import '../../domain/entities/habits.dart';
import '../../domain/usecases/calculate_compatibility.dart';
import '../../domain/usecases/get_user_habits.dart';
import '../../domain/usecases/save_questionnaire.dart';

part 'compatibility_event.dart';
part 'compatibility_state.dart';

class CompatibilityBloc extends Bloc<CompatibilityEvent, CompatibilityState> {
  final GetUserHabits getUserHabits;
  final SaveQuestionnaire saveQuestionnaire;
  final CalculateCompatibility calculateCompatibility;

  CompatibilityBloc({
    required this.getUserHabits,
    required this.saveQuestionnaire,
    required this.calculateCompatibility,
  }) : super(const CompatibilityInitial()) {
    on<LoadUserHabitsRequested>(_onLoadUserHabitsRequested);
    on<SaveHabitsRequested>(_onSaveHabitsRequested);
    on<CalculateCompatibilityRequested>(_onCalculateCompatibilityRequested);
  }

  Future<void> _onLoadUserHabitsRequested(
    LoadUserHabitsRequested event,
    Emitter<CompatibilityState> emit,
  ) async {
    emit(const CompatibilityLoading());

    final result = await getUserHabits(
      GetUserHabitsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(CompatibilityError(message: failure.message)),
      (habits) => emit(HabitsLoaded(habits: habits)),
    );
  }

  Future<void> _onSaveHabitsRequested(
    SaveHabitsRequested event,
    Emitter<CompatibilityState> emit,
  ) async {
    emit(const CompatibilitySaving());

    final result = await saveQuestionnaire(
      SaveQuestionnaireParams(habits: event.habits),
    );

    result.fold(
      (failure) => emit(CompatibilityError(message: failure.message)),
      (habits) => emit(HabitsSaved(habits: habits)),
    );
  }

  Future<void> _onCalculateCompatibilityRequested(
    CalculateCompatibilityRequested event,
    Emitter<CompatibilityState> emit,
  ) async {
    emit(const CompatibilityCalculating());

    final result = await calculateCompatibility(
      CalculateCompatibilityParams(
        userId1: event.userId1,
        userId2: event.userId2,
      ),
    );

    result.fold(
      (failure) => emit(CompatibilityError(message: failure.message)),
      (score) => emit(CompatibilityCalculated(score: score)),
    );
  }
}