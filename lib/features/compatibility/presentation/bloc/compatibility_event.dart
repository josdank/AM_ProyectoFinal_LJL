part of 'compatibility_bloc.dart';

abstract class CompatibilityEvent extends Equatable {
  const CompatibilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserHabitsRequested extends CompatibilityEvent {
  final String userId;

  const LoadUserHabitsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SaveHabitsRequested extends CompatibilityEvent {
  final Habits habits;

  const SaveHabitsRequested({required this.habits});

  @override
  List<Object?> get props => [habits];
}

class CalculateCompatibilityRequested extends CompatibilityEvent {
  final String userId1;
  final String userId2;

  const CalculateCompatibilityRequested({
    required this.userId1,
    required this.userId2,
  });

  @override
  List<Object?> get props => [userId1, userId2];
}