import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/visit.dart';

abstract class VisitRepository {
  /// Obtiene todas las visitas del usuario (como visitante)
  Future<Either<Failure, List<Visit>>> getMyVisits(String userId);

  /// Obtiene visitas a mis propiedades (como dueño)
  Future<Either<Failure, List<Visit>>> getVisitsToMyListings(String ownerId);

  /// Obtiene una visita por ID
  Future<Either<Failure, Visit>> getVisit(String visitId);

  /// Crea una nueva visita
  Future<Either<Failure, Visit>> scheduleVisit(Visit visit);

  /// Confirma una visita (solo el dueño)
  Future<Either<Failure, Visit>> confirmVisit(String visitId);

  /// Cancela una visita
  Future<Either<Failure, Visit>> cancelVisit(String visitId);

  /// Marca una visita como completada
  Future<Either<Failure, Visit>> completeVisit(String visitId);

  /// Obtiene visitas por listing
  Future<Either<Failure, List<Visit>>> getVisitsByListing(String listingId);

  /// Obtiene horarios disponibles para un listing
  Future<Either<Failure, List<DateTime>>> getAvailableSlots({
    required String listingId,
    required DateTime date,
    required int durationMinutes,
  });
}