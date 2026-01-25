import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location_point.dart';
import '../entities/place.dart';
import '../repositories/geolocation_repository.dart';

class SearchNearbyPlaces implements UseCase<List<Place>, SearchNearbyPlacesParams> {
  final GeolocationRepository repository;

  SearchNearbyPlaces(this.repository);

  @override
  Future<Either<Failure, List<Place>>> call(SearchNearbyPlacesParams params) async {
    return await repository.searchNearbyPlaces(
      center: params.center,
      radiusMeters: params.radiusMeters,
      type: params.type,
    );
  }
}

class SearchNearbyPlacesParams extends Equatable {
  final LocationPoint center;
  final double radiusMeters;
  final String? type;

  const SearchNearbyPlacesParams({
    required this.center,
    this.radiusMeters = 5000, // 5 km por defecto
    this.type,
  });

  @override
  List<Object?> get props => [center, radiusMeters, type];
}