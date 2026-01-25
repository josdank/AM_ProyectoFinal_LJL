import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/geolocation_repository.dart';
import '../datasources/location_datasource.dart';
import '../models/place_model.dart';

class GeolocationRepositoryImpl implements GeolocationRepository {
  final LocationDatasource datasource;

  GeolocationRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, LocationPoint>> getCurrentLocation() async {
    try {
      final location = await datasource.getCurrentLocation();
      return Right(location.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await datasource.requestPermission();
      return Right(granted);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasLocationPermission() async {
    try {
      final granted = await datasource.checkPermission();
      return Right(granted);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getUserPlaces(String userId) async {
    try {
      final places = await datasource.getUserPlaces(userId);
      return Right(places.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Place>> savePlace(Place place) async {
    try {
      final placeModel = PlaceModel(
        id: place.id,
        name: place.name,
        type: place.type,
        location: place.location,
        description: place.description,
        address: place.address,
        userId: place.userId,
      );

      final saved = await datasource.savePlace(placeModel);
      return Right(saved.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlace(String placeId) async {
    try {
      await datasource.deletePlace(placeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> searchNearbyPlaces({
    required LocationPoint center,
    required double radiusMeters,
    String? type,
  }) async {
    try {
      final places = await datasource.searchNearbyPlaces(
        latitude: center.latitude,
        longitude: center.longitude,
        radiusMeters: radiusMeters,
        type: type,
      );

      return Right(places.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  double calculateDistance(LocationPoint from, LocationPoint to) {
    return from.distanceTo(to);
  }

  @override
  Stream<LocationPoint> getLocationStream() {
    return datasource.getLocationStream().map((location) => location.toEntity());
  }
}