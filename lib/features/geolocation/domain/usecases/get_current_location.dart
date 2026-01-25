import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location_point.dart';
import '../repositories/geolocation_repository.dart';

class GetCurrentLocation implements UseCase<LocationPoint, NoParams> {
  final GeolocationRepository repository;

  GetCurrentLocation(this.repository);

  @override
  Future<Either<Failure, LocationPoint>> call(NoParams params) async {
    // Primero verificar permisos
    final permissionResult = await repository.hasLocationPermission();

    final hasPermission = permissionResult.fold(
      (failure) => false,
      (granted) => granted,
    );

    if (!hasPermission) {
      // Solicitar permisos
      final requestResult = await repository.requestLocationPermission();

      final granted = requestResult.fold(
        (failure) => false,
        (g) => g,
      );

      if (!granted) {
        return const Left(
          ServerFailure(
            message: 'Permiso de ubicación denegado. Por favor, habilítalo en la configuración.',
          ),
        );
      }
    }

    // Obtener ubicación
    return await repository.getCurrentLocation();
  }
}