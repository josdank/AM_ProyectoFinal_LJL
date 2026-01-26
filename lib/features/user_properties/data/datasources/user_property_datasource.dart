import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_property_model.dart';

abstract class UserPropertyDatasource {
  Future<List<UserPropertyModel>> getMyProperties(String ownerId);
  Future<UserPropertyModel> getPropertyById(String propertyId);
  Future<UserPropertyModel> createProperty(UserPropertyModel property);
  Future<UserPropertyModel> updateProperty(UserPropertyModel property);
  Future<void> deleteProperty(String propertyId);
  Future<List<UserPropertyModel>> searchNearbyProperties({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    int limit = 50,
  });
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required String ownerId,
    required List<String> imagePaths,
  });
  Future<void> togglePropertyStatus({
    required String propertyId,
    required bool isActive,
  });
}

class UserPropertyDatasourceImpl implements UserPropertyDatasource {
  final SupabaseClient client;

  UserPropertyDatasourceImpl({required this.client});

  @override
  Future<List<UserPropertyModel>> getMyProperties(String ownerId) async {
    try {
      final response = await client
          .from('user_properties')
          .select('*, user_property_images(*)')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserPropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al cargar propiedades: $e');
    }
  }

  @override
  Future<UserPropertyModel> getPropertyById(String propertyId) async {
    try {
      final response = await client
          .from('user_properties')
          .select('*, user_property_images(*)')
          .eq('id', propertyId)
          .single();

      return UserPropertyModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al cargar propiedad: $e');
    }
  }

  @override
  Future<UserPropertyModel> createProperty(UserPropertyModel property) async {
    try {
      final data = property.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('user_property_images');

      final response = await client
          .from('user_properties')
          .insert(data)
          .select()
          .single();

      return UserPropertyModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al crear propiedad: $e');
    }
  }

  @override
  Future<UserPropertyModel> updateProperty(UserPropertyModel property) async {
    try {
      final data = property.toJson();
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('user_property_images');

      final response = await client
          .from('user_properties')
          .update(data)
          .eq('id', property.id)
          .select('*, user_property_images(*)')
          .single();

      return UserPropertyModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar propiedad: $e');
    }
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    try {
      await client.from('user_properties').delete().eq('id', propertyId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar propiedad: $e');
    }
  }

  @override
  Future<List<UserPropertyModel>> searchNearbyProperties({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    int limit = 50,
  }) async {
    try {
      final response = await client.rpc(
        'search_nearby_user_properties',
        params: {
          'p_latitude': latitude,
          'p_longitude': longitude,
          'p_radius_meters': radiusMeters,
          'p_limit': limit,
        },
      );

      if (response == null) return [];

      return (response as List)
          .map((json) => UserPropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error buscando propiedades: $e');
    }
  }

  @override
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required String ownerId,
    required List<String> imagePaths,
  }) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
        final file = File(imagePath);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storagePath = '$ownerId/$propertyId/$fileName';

        // Subir a Storage
        await client.storage
            .from('user-property-images')
            .upload(storagePath, file);

        // Obtener URL pública
        final publicUrl = client.storage
            .from('user-property-images')
            .getPublicUrl(storagePath);

        uploadedUrls.add(publicUrl);

        // Guardar en tabla user_property_images
        await client.from('user_property_images').insert({
          'property_id': propertyId,
          'image_url': publicUrl,
          'display_order': i,
          'is_primary': i == 0,
        });
      }

      return uploadedUrls;
    } on StorageException catch (e) {
      throw ServerException(message: 'Error subiendo imágenes: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error subiendo imágenes: $e');
    }
  }

  @override
  Future<void> togglePropertyStatus({
    required String propertyId,
    required bool isActive,
  }) async {
    try {
      await client
          .from('user_properties')
          .update({'is_active': isActive})
          .eq('id', propertyId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error cambiando estado: $e');
    }
  }
}