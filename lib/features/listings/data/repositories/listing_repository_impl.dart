import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_datasource.dart';
import '../models/listing_model.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ListingDatasource datasource;

  ListingRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<Listing>>> getListings() async {
    try {
      final listings = await datasource.getListings();
      return Right(listings.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> getMyListings(String userId) async {
    try {
      final listings = await datasource.getMyListings(userId);
      return Right(listings.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Listing>> getListing(String listingId) async {
    try {
      final listing = await datasource.getListing(listingId);
      return Right(listing.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Listing>> createListing(Listing listing) async {
    try {
      final listingModel = ListingModel(
        id: listing.id,
        ownerId: listing.ownerId,
        title: listing.title,
        description: listing.description,
        price: listing.price,
        currency: listing.currency,
        address: listing.address,
        city: listing.city,
        state: listing.state,
        country: listing.country,
        latitude: listing.latitude,
        longitude: listing.longitude,
        roomType: listing.roomType,
        bathroomsCount: listing.bathroomsCount,
        maxOccupants: listing.maxOccupants,
        availableFrom: listing.availableFrom,
        leaseDuration: listing.leaseDuration,
        utilitiesIncluded: listing.utilitiesIncluded,
        wifiIncluded: listing.wifiIncluded,
        parkingIncluded: listing.parkingIncluded,
        furnished: listing.furnished,
        amenities: listing.amenities,
        petsAllowed: listing.petsAllowed,
        smokingAllowed: listing.smokingAllowed,
        guestsAllowed: listing.guestsAllowed,
        isActive: listing.isActive,
        isFeatured: listing.isFeatured,
        imageUrls: listing.imageUrls,
        createdAt: listing.createdAt,
        updatedAt: listing.updatedAt,
      );

      final result = await datasource.createListing(listingModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Listing>> updateListing(Listing listing) async {
    try {
      final listingModel = ListingModel(
        id: listing.id,
        ownerId: listing.ownerId,
        title: listing.title,
        description: listing.description,
        price: listing.price,
        currency: listing.currency,
        address: listing.address,
        city: listing.city,
        state: listing.state,
        country: listing.country,
        latitude: listing.latitude,
        longitude: listing.longitude,
        roomType: listing.roomType,
        bathroomsCount: listing.bathroomsCount,
        maxOccupants: listing.maxOccupants,
        availableFrom: listing.availableFrom,
        leaseDuration: listing.leaseDuration,
        utilitiesIncluded: listing.utilitiesIncluded,
        wifiIncluded: listing.wifiIncluded,
        parkingIncluded: listing.parkingIncluded,
        furnished: listing.furnished,
        amenities: listing.amenities,
        petsAllowed: listing.petsAllowed,
        smokingAllowed: listing.smokingAllowed,
        guestsAllowed: listing.guestsAllowed,
        isActive: listing.isActive,
        isFeatured: listing.isFeatured,
        imageUrls: listing.imageUrls,
        createdAt: listing.createdAt,
        updatedAt: listing.updatedAt,
      );

      final result = await datasource.updateListing(listingModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String listingId) async {
    try {
      await datasource.deleteListing(listingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> searchListings({
    String? city,
    double? minPrice,
    double? maxPrice,
    String? roomType,
    List<String>? amenities,
    bool? petsAllowed,
    bool? smokingAllowed,
  }) async {
    try {
      final listings = await datasource.searchListings(
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        roomType: roomType,
        amenities: amenities,
        petsAllowed: petsAllowed,
        smokingAllowed: smokingAllowed,
      );
      return Right(listings.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadListingImages(
    List<XFile> images,
    String listingId,
  ) async {
    try {
      final urls = await datasource.uploadListingImages(images, listingId);
      return Right(urls);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListingImage(
    String listingId,
    String imageUrl,
  ) async {
    try {
      await datasource.deleteListingImage(listingId, imageUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}