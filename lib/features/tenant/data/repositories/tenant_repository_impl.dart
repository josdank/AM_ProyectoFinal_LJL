import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_datasource.dart';
import '../models/application_model.dart';
import '../models/favorite_model.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantDataSource dataSource;

  TenantRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<Favorite>>> getFavorites({required String userId}) async {
    try {
      final favorites = await dataSource.getFavorites(userId);
      return Right(favorites.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Error obteniendo favoritos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite({
    required String userId,
    required String listingId,
  }) async {
    try {
      await dataSource.addFavorite(userId, listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error agregando favorito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required String userId,
    required String listingId,
  }) async {
    try {
      await dataSource.removeFavorite(userId, listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error eliminando favorito: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite({
    required String userId,
    required String listingId,
  }) async {
    try {
      final isFav = await dataSource.isFavorite(userId, listingId);
      return Right(isFav);
    } catch (e) {
      return Left(ServerFailure(message: 'Error verificando favorito: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Application>>> getApplications({
    required String tenantId,
  }) async {
    try {
      final applications = await dataSource.getApplications(tenantId);
      return Right(applications.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Error obteniendo aplicaciones: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Application>>> getMyApplications({
    required String tenantId,
  }) async {
    return getApplications(tenantId: tenantId);
  }

  @override
  Future<Either<Failure, Application>> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  }) async {
    try {
      final application = await dataSource.createApplication(
        tenantId: tenantId,
        listingId: listingId,
        message: message,
      );
      return Right(application.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error creando aplicación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelApplication({
    required String applicationId,
  }) async {
    try {
      await dataSource.cancelApplication(applicationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error cancelando aplicación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required String listingId,
    required bool isCurrentlyFavorite,
  }) async {
    try {
      if (isCurrentlyFavorite) {
        await dataSource.removeFavorite(userId, listingId);
      } else {
        await dataSource.addFavorite(userId, listingId);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error alternando favorito: $e'));
    }
  }
}