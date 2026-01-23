import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileDatasource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> createProfile(ProfileModel profile);
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<String> uploadProfilePhoto(XFile photo, String userId);
  Future<void> deleteProfilePhoto(String userId);
}

class ProfileDatasourceImpl implements ProfileDatasource {
  final SupabaseClient client;

  ProfileDatasourceImpl({required this.client});

  @override
  @override
Future<ProfileModel> getProfile(String userId) async {
  try {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ProfileModel.fromJson(response);
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      throw const ServerException(message: 'Perfil no encontrado');
    }
    throw ServerException(message: e.message);
  } catch (e) {
    throw ServerException(message: 'Error al obtener perfil: $e');
  }
}


  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      final data = profile.toJson();
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('profiles')
          .insert(data)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al crear perfil: $e');
    }
  }

  @override
  @override
Future<ProfileModel> updateProfile(ProfileModel profile) async {
  try {
    final data = profile.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await client
        .from('profiles')
        .update(data)
        .eq('id', profile.id)
        .select()
        .single();

    return ProfileModel.fromJson(response);
  } on PostgrestException catch (e) {
    throw ServerException(message: e.message);
  } catch (e) {
    throw ServerException(message: 'Error al actualizar perfil: $e');
  }
}


  @override
  Future<String> uploadProfilePhoto(XFile photo, String userId) async {
    try {
      final bytes = await photo.readAsBytes();
      final fileExt = photo.name.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;  // Simplificado

      // CORRECCIÓN: Usar 'profile-photos' en lugar de 'profiles'
      await client.storage.from('profile-photos').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from('profile-photos').getPublicUrl(filePath);

      // Actualizar la URL en el perfil
      await client
          .from('profiles')
          .update({
            'photo_url': publicUrl,  // Usar photo_url
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', userId);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(message: 'Error al subir foto: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al subir foto: $e');
    }
  }

  @override
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      // Obtener la URL actual
      final profile = await getProfile(userId);
      
      if (profile.photoUrl != null) {
        // Extraer el path del archivo de la URL
        final uri = Uri.parse(profile.photoUrl!);
        final pathSegments = uri.pathSegments;
        
        // Buscar el índice de 'profile-photos' en los segmentos
        final bucketIndex = pathSegments.indexOf('profile-photos');
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final path = pathSegments.skip(bucketIndex + 1).join('/');
          
          // Eliminar de storage
          await client.storage.from('profile-photos').remove([path]);
        }
        
        // Actualizar perfil
        await client
            .from('profiles')
            .update({
              'photo_url': null,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('id', userId);
      }
    } on StorageException catch (e) {
      throw ServerException(message: 'Error al eliminar foto: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }
}