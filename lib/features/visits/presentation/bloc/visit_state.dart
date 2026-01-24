part of 'visit_bloc.dart';

abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {
  const VisitInitial();
}

class VisitsLoading extends VisitState {
  const VisitsLoading();
}

class VisitsLoaded extends VisitState {
  final List<Visit> visits;

  const VisitsLoaded({required this.visits});

  /// Visitas pendientes
  List<Visit> get pendingVisits =>
      visits.where((v) => v.isPending).toList();

  /// Visitas confirmadas
  List<Visit> get confirmedVisits =>
      visits.where((v) => v.isConfirmed).toList();

  /// Visitas próximas (confirmadas y no pasadas)
  List<Visit> get upcomingVisits =>
      visits.where((v) => v.isConfirmed && !v.isPast).toList();

  /// Visitas pasadas
  List<Visit> get pastVisits =>
      visits.where((v) => v.isPast).toList();

  @override
  List<Object?> get props => [visits];
}

class VisitScheduling extends VisitState {
  const VisitScheduling();
}

class VisitScheduled extends VisitState {
  final Visit visit;

  const VisitScheduled({required this.visit});

  @override
  List<Object?> get props => [visit];
}

class VisitUpdating extends VisitState {
  const VisitUpdating();
}

class VisitConfirmed extends VisitState {
  final Visit visit;

  const VisitConfirmed({required this.visit});

  @override
  List<Object?> get props => [visit];
}

class VisitCancelled extends VisitState {
  final Visit visit;

  const VisitCancelled({required this.visit});

  @override
  List<Object?> get props => [visit];
}

class VisitCompleted extends VisitState {
  final Visit visit;

  const VisitCompleted({required this.visit});

  @override
  List<Object?> get props => [visit];
}

class VisitError extends VisitState {
  final String message;

  const VisitError({required this.message});

  @override
  List<Object?> get props => [message];
}