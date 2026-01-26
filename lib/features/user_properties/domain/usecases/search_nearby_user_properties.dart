import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../geolocation/domain/entities/location_point.dart';
import '../entities/user_property.dart';
import '../repositories/user_property_repository.dart';

class SearchNearbyUserProperties implements UseCase<List<UserProperty>, SearchNearbyUserPropertiesParams> {
  final UserPropertyRepository repository;

  SearchNearbyUserProperties(this.repository);

  @override
  Future<Either<Failure, List<UserProperty>>> call(SearchNearbyUserPropertiesParams params) async {
    return await repository.searchNearbyProperties(
      center: params.center,
      radiusMeters: params.radiusMeters,
      limit: params.limit,
    );
  }
}

class SearchNearbyUserPropertiesParams extends Equatable {
  final LocationPoint center;
  final double radiusMeters;
  final int limit;

  const SearchNearbyUserPropertiesParams({
    required this.center,
    this.radiusMeters = 5000,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [center, radiusMeters, limit];
}

