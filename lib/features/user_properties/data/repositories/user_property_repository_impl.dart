import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../geolocation/domain/entities/location_point.dart';
import '../../domain/entities/user_property.dart';
import '../../domain/repositories/user_property_repository.dart';
import '../datasources/user_property_datasource.dart';
import '../models/user_property_model.dart';

class UserPropertyRepositoryImpl implements UserPropertyRepository {
  final UserPropertyDatasource datasource;

  UserPropertyRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<UserProperty>>> getMyProperties(
      String ownerId) async {
    try {
      final properties = await datasource.getMyProperties(ownerId);
      return Right(properties.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProperty>> getPropertyById(
      String propertyId) async {
    try {
      final property = await datasource.getPropertyById(propertyId);
      return Right(property.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProperty>> createProperty(
      UserProperty property) async {
    try {
      final model = UserPropertyModel.fromEntity(property);
      final created = await datasource.createProperty(model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProperty>> updateProperty(
      UserProperty property) async {
    try {
      final model = UserPropertyModel.fromEntity(property);
      final updated = await datasource.updateProperty(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String propertyId) async {
    try {
      await datasource.deleteProperty(propertyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserProperty>>> searchNearbyProperties({
    required LocationPoint center,
    required double radiusMeters,
    int limit = 50,
  }) async {
    try {
      final properties = await datasource.searchNearbyProperties(
        latitude: center.latitude,
        longitude: center.longitude,
        radiusMeters: radiusMeters,
        limit: limit,
      );
      return Right(properties.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadPropertyImages({
    required String propertyId,
    required String ownerId,
    required List<String> imagePaths,
  }) async {
    try {
      final urls = await datasource.uploadPropertyImages(
        propertyId: propertyId,
        ownerId: ownerId,
        imagePaths: imagePaths,
      );
      return Right(urls);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> togglePropertyStatus({
    required String propertyId,
    required bool isActive,
  }) async {
    try {
      await datasource.togglePropertyStatus(
        propertyId: propertyId,
        isActive: isActive,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}