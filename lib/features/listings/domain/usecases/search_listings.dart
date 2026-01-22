import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class SearchListings implements UseCase<List<Listing>, SearchListingsParams> {
  final ListingRepository repository;
  SearchListings(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(SearchListingsParams params) async {
    return await repository.searchListings(
      city: params.city,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      roomType: params.roomType,
      amenities: params.amenities,
      petsAllowed: params.petsAllowed,
      smokingAllowed: params.smokingAllowed,
    );
  }
}

class SearchListingsParams extends Equatable {
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String? roomType;
  final List<String>? amenities;
  final bool? petsAllowed;
  final bool? smokingAllowed;

  const SearchListingsParams({
    this.city,
    this.minPrice,
    this.maxPrice,
    this.roomType,
    this.amenities,
    this.petsAllowed,
    this.smokingAllowed,
  });

  @override
  List<Object?> get props => [
        city,
        minPrice,
        maxPrice,
        roomType,
        amenities,
        petsAllowed,
        smokingAllowed,
      ];
}