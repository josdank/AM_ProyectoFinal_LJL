import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class CreateListing implements UseCase<Listing, CreateListingParams> {
  final ListingRepository repository;
  CreateListing(this.repository);

  @override
  Future<Either<Failure, Listing>> call(CreateListingParams params) async {
    return await repository.createListing(params.listing);
  }
}

class CreateListingParams extends Equatable {
  final Listing listing;

  const CreateListingParams({required this.listing});

  @override
  List<Object?> get props => [listing];
}