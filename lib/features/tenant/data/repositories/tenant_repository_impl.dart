import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_datasource.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantDatasource datasource;

  TenantRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, void>> toggleFavorite({required String userId, required String listingId}) async {
    try {
      await datasource.toggleFavorite(userId: userId, listingId: listingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<Favorite>>> getFavorites({required String userId}) async {
    try {
      final list = await datasource.getFavorites(userId: userId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Application>> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  }) async {
    try {
      final app = await datasource.createApplication(tenantId: tenantId, listingId: listingId, message: message);
      return Right(app);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<Application>>> getMyApplications({required String tenantId}) async {
    try {
      final list = await datasource.getMyApplications(tenantId: tenantId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> cancelApplication({required String applicationId}) async {
    try {
      await datasource.cancelApplication(applicationId: applicationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
