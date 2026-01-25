import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location_point.dart';
import '../entities/place.dart';

abstract class GeolocationRepository {
  /// Obtiene la ubicación actual del usuario
  Future<Either<Failure, LocationPoint>> getCurrentLocation();

  /// Verifica y solicita permisos de ubicación
  Future<Either<Failure, bool>> requestLocationPermission();

  /// Verifica si los permisos están otorgados
  Future<Either<Failure, bool>> hasLocationPermission();

  /// Obtiene lugares guardados del usuario
  Future<Either<Failure, List<Place>>> getUserPlaces(String userId);

  /// Guarda un nuevo lugar
  Future<Either<Failure, Place>> savePlace(Place place);

  /// Elimina un lugar
  Future<Either<Failure, void>> deletePlace(String placeId);

  /// Busca lugares públicos cercanos (universidades, transporte)
  Future<Either<Failure, List<Place>>> searchNearbyPlaces({
    required LocationPoint center,
    required double radiusMeters,
    String? type,
  });

  /// Calcula distancia entre dos puntos
  double calculateDistance(LocationPoint from, LocationPoint to);

  /// Stream de ubicación en tiempo real
  Stream<LocationPoint> getLocationStream();
}