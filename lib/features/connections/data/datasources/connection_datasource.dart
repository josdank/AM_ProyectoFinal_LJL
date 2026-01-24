import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/connection_request_model.dart';
import '../models/match_model.dart';

abstract class ConnectionDatasource {
  Future<ConnectionRequestModel> sendInterest({
    required String fromUserId,
    required String toUserId,
    String? listingId,
  });

  Future<ConnectionRequestModel> acceptInterest({required String requestId});

  Future<ConnectionRequestModel> rejectInterest({required String requestId});

  Future<List<ConnectionRequestModel>> getIncoming({required String userId});

  Future<List<ConnectionRequestModel>> getOutgoing({required String userId});

  Future<List<MatchModel>> getMatches({required String userId});
}

class ConnectionDatasourceImpl implements ConnectionDatasource {
  final SupabaseClient client;
  ConnectionDatasourceImpl({required this.client});

  static const _requestsTable = 'connection_requests';
  static const _matchesTable = 'matches';

  @override
  Future<ConnectionRequestModel> sendInterest({
    required String fromUserId,
    required String toUserId,
    String? listingId,
  }) async {
    try {
      final inserted = await client.from(_requestsTable).insert({
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'listing_id': listingId,
        'status': 'pending',
      }).select().single();

      return ConnectionRequestModel.fromJson(Map<String, dynamic>.from(inserted));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ConnectionRequestModel> acceptInterest({required String requestId}) async {
    try {
      final updated = await client
          .from(_requestsTable)
          .update({'status': 'accepted'})
          .eq('id', requestId)
          .select()
          .single();

      // Crear/asegurar match (user_a_id, user_b_id ordenados para evitar duplicados)
      final req = ConnectionRequestModel.fromJson(Map<String, dynamic>.from(updated));
      final a = req.fromUserId.compareTo(req.toUserId) <= 0 ? req.fromUserId : req.toUserId;
      final b = req.fromUserId.compareTo(req.toUserId) <= 0 ? req.toUserId : req.fromUserId;

      // upsert match (si tu tabla tiene constraint único por user_a_id,user_b_id,listing_id)
      await client.from(_matchesTable).upsert({
        'user_a_id': a,
        'user_b_id': b,
        'listing_id': req.listingId,
      });

      return req;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ConnectionRequestModel> rejectInterest({required String requestId}) async {
    try {
      final updated = await client
          .from(_requestsTable)
          .update({'status': 'rejected'})
          .eq('id', requestId)
          .select()
          .single();

      return ConnectionRequestModel.fromJson(Map<String, dynamic>.from(updated));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ConnectionRequestModel>> getIncoming({required String userId}) async {
    try {
      final rows = await client
          .from(_requestsTable)
          .select()
          .eq('to_user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((e) => ConnectionRequestModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ConnectionRequestModel>> getOutgoing({required String userId}) async {
    try {
      final rows = await client
          .from(_requestsTable)
          .select()
          .eq('from_user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((e) => ConnectionRequestModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MatchModel>> getMatches({required String userId}) async {
    try {
      // Match si userId está en user_a_id o user_b_id
      final rows = await client
          .from(_matchesTable)
          .select()
          .or('user_a_id.eq.$userId,user_b_id.eq.$userId')
          .order('created_at', ascending: false);

      return (rows as List)
          .map((e) => MatchModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}
