import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/get_visits.dart';
import '../../domain/usecases/schedule_visit.dart';
import '../../domain/usecases/confirm_visit.dart';
import '../../domain/usecases/cancel_visit.dart';
import '../../domain/usecases/complete_visit.dart';

part 'visit_event.dart';
part 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final GetVisits getVisits;
  final ScheduleVisit scheduleVisit;
  final ConfirmVisit confirmVisit;
  final CancelVisit cancelVisit;
  final CompleteVisit completeVisit;

  VisitBloc({
    required this.getVisits,
    required this.scheduleVisit,
    required this.confirmVisit,
    required this.cancelVisit,
    required this.completeVisit,
  }) : super(const VisitInitial()) {
    on<VisitsLoadRequested>(_onLoadVisits);
    on<VisitScheduleRequested>(_onScheduleVisit);
    on<VisitConfirmRequested>(_onConfirmVisit);
    on<VisitCancelRequested>(_onCancelVisit);
    on<VisitCompleteRequested>(_onCompleteVisit);
  }

  Future<void> _onLoadVisits(
    VisitsLoadRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitsLoading());

    final result = await getVisits(
      GetVisitsParams(
        userId: event.userId,
        asOwner: event.asOwner,
      ),
    );

    result.fold(
      (failure) => emit(VisitError(message: failure.message)),
      (visits) => emit(VisitsLoaded(visits: visits)),
    );
  }

  Future<void> _onScheduleVisit(
    VisitScheduleRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitScheduling());

    final result = await scheduleVisit(
      ScheduleVisitParams(visit: event.visit),
    );

    result.fold(
      (failure) => emit(VisitError(message: failure.message)),
      (visit) => emit(VisitScheduled(visit: visit)),
    );
  }

  Future<void> _onConfirmVisit(
    VisitConfirmRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitUpdating());

    final result = await confirmVisit(
      ConfirmVisitParams(visitId: event.visitId),
    );

    result.fold(
      (failure) => emit(VisitError(message: failure.message)),
      (visit) => emit(VisitConfirmed(visit: visit)),
    );
  }

  Future<void> _onCancelVisit(
    VisitCancelRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitUpdating());

    final result = await cancelVisit(
      CancelVisitParams(visitId: event.visitId),
    );

    result.fold(
      (failure) => emit(VisitError(message: failure.message)),
      (visit) => emit(VisitCancelled(visit: visit)),
    );
  }

  Future<void> _onCompleteVisit(
    VisitCompleteRequested event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitUpdating());

    final result = await completeVisit(
      CompleteVisitParams(visitId: event.visitId),
    );

    result.fold(
      (failure) => emit(VisitError(message: failure.message)),
      (visit) => emit(VisitCompleted(visit: visit)),
    );
  }
}