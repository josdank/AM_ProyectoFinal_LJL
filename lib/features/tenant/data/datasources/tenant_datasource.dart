import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/application_model.dart';
import '../models/favorite_model.dart';

abstract class TenantDatasource {
  Future<void> toggleFavorite({
    required String userId,
    required String listingId,
  });

  Future<bool> isFavorite({
    required String userId,
    required String listingId,
  });

  Future<List<FavoriteModel>> getFavorites({
    required String userId,
  });

  Future<ApplicationModel> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  });

  Future<List<ApplicationModel>> getMyApplications({
    required String tenantId,
  });

  Future<void> cancelApplication({required String applicationId});
}

class TenantDatasourceImpl implements TenantDatasource {
  final SupabaseClient client;

  TenantDatasourceImpl(this.client);

  static const _fav = 'favorites';
  static const _apps = 'applications';

  @override
  Future<void> toggleFavorite({required String userId, required String listingId}) async {
    try {
      final existing = await client
          .from(_fav)
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .maybeSingle();

      if (existing != null) {
        await client.from(_fav).delete().eq('id', existing['id']);
      } else {
        await client.from(_fav).insert({'user_id': userId, 'listing_id': listingId});
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> isFavorite({required String userId, required String listingId}) async {
    try {
      final row = await client
          .from(_fav)
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .maybeSingle();
      return row != null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<FavoriteModel>> getFavorites({required String userId}) async {
    try {
      final rows = await client.from(_fav).select().eq('user_id', userId).order('created_at', ascending: false);
      return (rows as List).map((e) => FavoriteModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ApplicationModel> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  }) async {
    try {
      final row = await client
          .from(_apps)
          .insert({
            'tenant_id': tenantId,
            'listing_id': listingId,
            'message': message,
            'status': 'pending',
          })
          .select()
          .single();

      return ApplicationModel.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ApplicationModel>> getMyApplications({required String tenantId}) async {
    try {
      final rows = await client.from(_apps).select().eq('tenant_id', tenantId).order('created_at', ascending: false);
      return (rows as List).map((e) => ApplicationModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> cancelApplication({required String applicationId}) async {
    try {
      await client.from(_apps).delete().eq('id', applicationId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}
