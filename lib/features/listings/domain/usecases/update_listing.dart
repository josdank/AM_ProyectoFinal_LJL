import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class UpdateListing implements UseCase<Listing, UpdateListingParams> {
  final ListingRepository repository;
  UpdateListing(this.repository);

  @override
  Future<Either<Failure, Listing>> call(UpdateListingParams params) async {
    return await repository.updateListing(params.listing);
  }
}

class UpdateListingParams extends Equatable {
  final Listing listing;

  const UpdateListingParams({required this.listing});

  @override
  List<Object?> get props => [listing];
}