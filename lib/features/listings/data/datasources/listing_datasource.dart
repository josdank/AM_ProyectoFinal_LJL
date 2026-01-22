import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/listing_model.dart';

abstract class ListingDatasource {
  Future<List<ListingModel>> getListings();
  Future<List<ListingModel>> getMyListings(String userId);
  Future<ListingModel> getListing(String listingId);
  Future<ListingModel> createListing(ListingModel listing);
  Future<ListingModel> updateListing(ListingModel listing);
  Future<void> deleteListing(String listingId);
  Future<List<ListingModel>> searchListings({
    String? city,
    double? minPrice,
    double? maxPrice,
    String? roomType,
    List<String>? amenities,
    bool? petsAllowed,
    bool? smokingAllowed,
  });
  Future<List<String>> uploadListingImages(List<XFile> images, String listingId);
  Future<void> deleteListingImage(String listingId, String imageUrl);
}

class ListingDatasourceImpl implements ListingDatasource {
  final SupabaseClient client;

  ListingDatasourceImpl({required this.client});

  @override
  Future<List<ListingModel>> getListings() async {
    try {
      final response = await client
          .from('listings')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final listings = (response as List).map((json) => ListingModel.fromJson(json)).toList();

      // Cargar imágenes para cada listing
      for (var listing in listings) {
        final images = await _getListingImages(listing.id);
        listing = ListingModel.fromJson({
          ...listing.toJson(),
          'image_urls': images,
        });
      }

      return listings;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener publicaciones: $e');
    }
  }

  @override
  Future<List<ListingModel>> getMyListings(String userId) async {
    try {
      final response = await client
          .from('listings')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final listings = (response as List).map((json) => ListingModel.fromJson(json)).toList();

      for (var listing in listings) {
        final images = await _getListingImages(listing.id);
        listing = ListingModel.fromJson({
          ...listing.toJson(),
          'image_urls': images,
        });
      }

      return listings;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener mis publicaciones: $e');
    }
  }

  @override
  Future<ListingModel> getListing(String listingId) async {
    try {
      final response = await client
          .from('listings')
          .select()
          .eq('id', listingId)
          .single();

      final listing = ListingModel.fromJson(response);
      final images = await _getListingImages(listingId);

      return ListingModel.fromJson({
        ...listing.toJson(),
        'image_urls': images,
      });
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const ServerException(message: 'Publicación no encontrada');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener publicación: $e');
    }
  }

  @override
  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      final data = listing.toJson();
      data.remove('id'); // Supabase genera el ID
      data.remove('created_at');
      data.remove('updated_at');

      final response = await client
          .from('listings')
          .insert(data)
          .select()
          .single();

      return ListingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al crear publicación: $e');
    }
  }

  @override
  Future<ListingModel> updateListing(ListingModel listing) async {
    try {
      final data = listing.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();
      data.remove('created_at');

      final response = await client
          .from('listings')
          .update(data)
          .eq('id', listing.id)
          .select()
          .single();

      return ListingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar publicación: $e');
    }
  }

  @override
  Future<void> deleteListing(String listingId) async {
    try {
      // Primero eliminar las imágenes
      final images = await _getListingImages(listingId);
      for (var imageUrl in images) {
        await deleteListingImage(listingId, imageUrl);
      }

      // Luego eliminar el listing
      await client.from('listings').delete().eq('id', listingId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar publicación: $e');
    }
  }

  @override
  Future<List<ListingModel>> searchListings({
    String? city,
    double? minPrice,
    double? maxPrice,
    String? roomType,
    List<String>? amenities,
    bool? petsAllowed,
    bool? smokingAllowed,
  }) async {
    try {
      var query = client.from('listings').select().eq('is_active', true);

      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (roomType != null && roomType.isNotEmpty) {
        query = query.eq('room_type', roomType);
      }

      if (petsAllowed != null) {
        query = query.eq('pets_allowed', petsAllowed);
      }

      if (smokingAllowed != null) {
        query = query.eq('smoking_allowed', smokingAllowed);
      }

      // Nota: Filtrar por amenities requiere lógica adicional en el cliente
      final response = await query.order('created_at', ascending: false);

      var listings = (response as List).map((json) => ListingModel.fromJson(json)).toList();

      // Filtrar por amenities si es necesario
      if (amenities != null && amenities.isNotEmpty) {
        listings = listings.where((listing) {
          return amenities.every((amenity) => listing.amenities.contains(amenity));
        }).toList();
      }

      for (var listing in listings) {
        final images = await _getListingImages(listing.id);
        listing = ListingModel.fromJson({
          ...listing.toJson(),
          'image_urls': images,
        });
      }

      return listings;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al buscar publicaciones: $e');
    }
  }

  @override
  Future<List<String>> uploadListingImages(List<XFile> images, String listingId) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final bytes = await image.readAsBytes();
        final fileExt = image.name.split('.').last;
        final fileName = '$listingId/${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';

        await client.storage.from('listing-images').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );

        final publicUrl = client.storage.from('listing-images').getPublicUrl(fileName);
        uploadedUrls.add(publicUrl);

        // Guardar en la tabla listing_images
        await client.from('listing_images').insert({
          'listing_id': listingId,
          'image_url': publicUrl,
          'display_order': i,
        });
      }

      return uploadedUrls;
    } on StorageException catch (e) {
      throw ServerException(message: 'Error al subir imágenes: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al subir imágenes: $e');
    }
  }

  @override
  Future<void> deleteListingImage(String listingId, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('listing-images');

      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final path = pathSegments.skip(bucketIndex + 1).join('/');
        await client.storage.from('listing-images').remove([path]);
      }

      await client.from('listing_images').delete().eq('image_url', imageUrl);
    } on StorageException catch (e) {
      throw ServerException(message: 'Error al eliminar imagen: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  // Método auxiliar privado
  Future<List<String>> _getListingImages(String listingId) async {
    try {
      final response = await client
          .from('listing_images')
          .select('image_url')
          .eq('listing_id', listingId)
          .order('display_order', ascending: true);

      return (response as List).map((e) => e['image_url'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}