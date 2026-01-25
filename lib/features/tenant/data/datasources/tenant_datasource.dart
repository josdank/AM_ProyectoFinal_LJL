import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../models/application_model.dart';
import '../models/favorite_model.dart';

abstract class TenantDataSource {  // CAMBIAR de TenantDatasource a TenantDataSource
  Future<List<FavoriteModel>> getFavorites(String userId);
  Future<void> addFavorite(String userId, String listingId);
  Future<void> removeFavorite(String userId, String listingId);
  Future<bool> isFavorite(String userId, String listingId);
  
  Future<List<ApplicationModel>> getApplications(String tenantId);
  Future<ApplicationModel> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  });
  Future<void> cancelApplication(String applicationId);
}

class TenantDataSourceImpl implements TenantDataSource {
  final SupabaseClient supabaseClient;

  TenantDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    try {
      final response = await supabaseClient
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response != null && response is List) {
        return response
            .map<FavoriteModel>((item) => FavoriteModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw DatabaseFailure(message: 'Error obteniendo favoritos: $e');
    }
  }

  @override
  Future<void> addFavorite(String userId, String listingId) async {
    try {
      await supabaseClient.from('favorites').insert({
        'user_id': userId,
        'listing_id': listingId,
      });
    } catch (e) {
      throw DatabaseFailure(message: 'Error agregando favorito: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String listingId) async {
    try {
      await supabaseClient
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } catch (e) {
      throw DatabaseFailure(message: 'Error eliminando favorito: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String listingId) async {
    try {
      final response = await supabaseClient
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      return response != null && response is List && response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ApplicationModel>> getApplications(String tenantId) async {
    try {
      final response = await supabaseClient
          .from('applications')
          .select()
          .eq('tenant_id', tenantId)
          .order('applied_at', ascending: false);

      if (response != null && response is List) {
        return response
            .map<ApplicationModel>((item) => ApplicationModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw DatabaseFailure(message: 'Error obteniendo aplicaciones: $e');
    }
  }

  @override
  Future<ApplicationModel> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  }) async {
    try {
      final response = await supabaseClient
          .from('applications')
          .insert({
            'tenant_id': tenantId,
            'listing_id': listingId,
            'message': message,
            'status': 'pending',
          })
          .select()
          .single();

      return ApplicationModel.fromJson(response);
    } catch (e) {
      throw DatabaseFailure(message: 'Error creando aplicación: $e');
    }
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    try {
      await supabaseClient
          .from('applications')
          .update({'status': 'canceled'})
          .eq('id', applicationId);
    } catch (e) {
      throw DatabaseFailure(message: 'Error cancelando aplicación: $e');
    }
  }
}