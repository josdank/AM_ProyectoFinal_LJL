part of 'visit_bloc.dart';

abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar visitas del usuario
class VisitsLoadRequested extends VisitEvent {
  final String userId;
  final bool asOwner; // true = visitas a mis propiedades, false = mis visitas

  const VisitsLoadRequested({
    required this.userId,
    this.asOwner = false,
  });

  @override
  List<Object?> get props => [userId, asOwner];
}

/// Agendar una nueva visita
class VisitScheduleRequested extends VisitEvent {
  final Visit visit;

  const VisitScheduleRequested({required this.visit});

  @override
  List<Object?> get props => [visit];
}

/// Confirmar una visita (solo el dueño)
class VisitConfirmRequested extends VisitEvent {
  final String visitId;

  const VisitConfirmRequested({required this.visitId});

  @override
  List<Object?> get props => [visitId];
}

/// Cancelar una visita
class VisitCancelRequested extends VisitEvent {
  final String visitId;

  const VisitCancelRequested({required this.visitId});

  @override
  List<Object?> get props => [visitId];
}

/// Marcar visita como completada
class VisitCompleteRequested extends VisitEvent {
  final String visitId;

  const VisitCompleteRequested({required this.visitId});

  @override
  List<Object?> get props => [visitId];
}