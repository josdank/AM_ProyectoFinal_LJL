import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing.dart';

abstract class ListingRepository {
  /// Obtener todas las publicaciones activas
  Future<Either<Failure, List<Listing>>> getListings();
  
  /// Obtener publicaciones del usuario actual
  Future<Either<Failure, List<Listing>>> getMyListings(String userId);
  
  /// Obtener una publicación por ID
  Future<Either<Failure, Listing>> getListing(String listingId);
  
  /// Crear nueva publicación
  Future<Either<Failure, Listing>> createListing(Listing listing);
  
  /// Actualizar publicación existente
  Future<Either<Failure, Listing>> updateListing(Listing listing);
  
  /// Eliminar publicación
  Future<Either<Failure, void>> deleteListing(String listingId);
  
  /// Buscar publicaciones con filtros
  Future<Either<Failure, List<Listing>>> searchListings({
    String? city,
    double? minPrice,
    double? maxPrice,
    String? roomType,
    List<String>? amenities,
    bool? petsAllowed,
    bool? smokingAllowed,
  });
  
  /// Subir imágenes de la publicación
  Future<Either<Failure, List<String>>> uploadListingImages(
    List<XFile> images,
    String listingId,
  );
  
  /// Eliminar imagen de la publicación
  Future<Either<Failure, void>> deleteListingImage(
    String listingId,
    String imageUrl,
  );
}