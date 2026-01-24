import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_datasource.dart';
import '../models/visit_model.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitDatasource datasource;

  VisitRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<Visit>>> getMyVisits(String userId) async {
    try {
      final visits = await datasource.getMyVisits(userId);
      return Right(visits.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Visit>>> getVisitsToMyListings(
      String ownerId) async {
    try {
      final visits = await datasource.getVisitsToMyListings(ownerId);
      return Right(visits.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisit(String visitId) async {
    try {
      final visit = await datasource.getVisit(visitId);
      return Right(visit.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit>> scheduleVisit(Visit visit) async {
    try {
      final visitModel = VisitModel(
        id: visit.id,
        listingId: visit.listingId,
        visitorId: visit.visitorId,
        scheduledAt: visit.scheduledAt,
        durationMinutes: visit.durationMinutes,
        status: visit.status,
        notes: visit.notes,
        createdAt: visit.createdAt,
        updatedAt: visit.updatedAt,
      );

      final result = await datasource.scheduleVisit(visitModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit>> confirmVisit(String visitId) async {
    try {
      final visit = await datasource.confirmVisit(visitId);
      return Right(visit.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit>> cancelVisit(String visitId) async {
    try {
      final visit = await datasource.cancelVisit(visitId);
      return Right(visit.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Visit>> completeVisit(String visitId) async {
    try {
      final visit = await datasource.completeVisit(visitId);
      return Right(visit.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Visit>>> getVisitsByListing(
      String listingId) async {
    try {
      final visits = await datasource.getVisitsByListing(listingId);
      return Right(visits.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getAvailableSlots({
    required String listingId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      final slots = await datasource.getAvailableSlots(
        listingId: listingId,
        date: date,
        durationMinutes: durationMinutes,
      );
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}