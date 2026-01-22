import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/listing_repository.dart';

class DeleteListing implements UseCase<void, DeleteListingParams> {
  final ListingRepository repository;
  DeleteListing(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteListingParams params) async {
    return await repository.deleteListing(params.listingId);
  }
}

class DeleteListingParams extends Equatable {
  final String listingId;

  const DeleteListingParams({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}