import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class GetListings implements UseCase<List<Listing>, NoParams> {
  final ListingRepository repository;
  GetListings(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(NoParams params) async {
    return await repository.getListings();
  }
}