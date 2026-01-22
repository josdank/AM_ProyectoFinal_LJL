part of 'compatibility_bloc.dart';

abstract class CompatibilityState extends Equatable {
  const CompatibilityState();

  @override
  List<Object?> get props => [];
}

class CompatibilityInitial extends CompatibilityState {
  const CompatibilityInitial();
}

class CompatibilityLoading extends CompatibilityState {
  const CompatibilityLoading();
}

class CompatibilitySaving extends CompatibilityState {
  const CompatibilitySaving();
}

class CompatibilityCalculating extends CompatibilityState {
  const CompatibilityCalculating();
}

class HabitsLoaded extends CompatibilityState {
  final Habits habits;

  const HabitsLoaded({required this.habits});

  @override
  List<Object?> get props => [habits];
}

class HabitsSaved extends CompatibilityState {
  final Habits habits;

  const HabitsSaved({required this.habits});

  @override
  List<Object?> get props => [habits];
}

class CompatibilityCalculated extends CompatibilityState {
  final CompatibilityScore score;

  const CompatibilityCalculated({required this.score});

  @override
  List<Object?> get props => [score];
}

class CompatibilityError extends CompatibilityState {
  final String message;

  const CompatibilityError({required this.message});

  @override
  List<Object?> get props => [message];
}