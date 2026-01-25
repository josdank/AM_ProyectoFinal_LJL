import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location_point.dart';
import '../repositories/geolocation_repository.dart';

class CalculateDistance implements UseCase<double, CalculateDistanceParams> {
  final GeolocationRepository repository;

  CalculateDistance(this.repository);

  @override
  Future<Either<Failure, double>> call(CalculateDistanceParams params) async {
    try {
      final distance = repository.calculateDistance(params.from, params.to);
      return Right(distance);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al calcular distancia: $e'));
    }
  }
}

class CalculateDistanceParams extends Equatable {
  final LocationPoint from;
  final LocationPoint to;

  const CalculateDistanceParams({
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [from, to];
}