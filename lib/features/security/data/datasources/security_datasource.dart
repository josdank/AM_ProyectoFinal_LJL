import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_block_model.dart';
import '../models/user_report_model.dart';
import '../models/verification_model.dart';

abstract class SecurityDatasource {
  Future<VerificationModel?> getVerificationStatus({required String userId});
  Future<VerificationModel> submitVerification({required String userId, required String type});
  Future<UserReportModel> reportUser({
    required String reporterId,
    required String reportedId,
    required String reason,
    String? details,
  });
  Future<UserBlockModel> blockUser({required String blockerId, required String blockedId});
  Future<List<UserBlockModel>> getBlockedUsers({required String blockerId});
}

class SecurityDatasourceImpl implements SecurityDatasource {
  final SupabaseClient client;
  SecurityDatasourceImpl({required this.client});

  static const _verifications = 'verifications';
  static const _reports = 'reports';
  static const _blocks = 'blocks';

  @override
  Future<VerificationModel?> getVerificationStatus({required String userId}) async {
    try {
      final res = await client.from(_verifications).select().eq('user_id', userId).maybeSingle();
      if (res == null) return null;
      return VerificationModel.fromJson(Map<String, dynamic>.from(res));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VerificationModel> submitVerification({required String userId, required String type}) async {
    try {
      final inserted = await client.from(_verifications).upsert({
        'user_id': userId,
        'type': type,
        'status': 'pending',
      }).select().single();
      return VerificationModel.fromJson(Map<String, dynamic>.from(inserted));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserReportModel> reportUser({
    required String reporterId,
    required String reportedId,
    required String reason,
    String? details,
  }) async {
    try {
      final inserted = await client.from(_reports).insert({
        'reporter_id': reporterId,
        'reported_id': reportedId,
        'reason': reason,
        'details': details,
      }).select().single();
      return UserReportModel.fromJson(Map<String, dynamic>.from(inserted));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserBlockModel> blockUser({required String blockerId, required String blockedId}) async {
    try {
      final inserted = await client.from(_blocks).upsert({
        'blocker_id': blockerId,
        'blocked_id': blockedId,
      }).select().single();
      return UserBlockModel.fromJson(Map<String, dynamic>.from(inserted));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserBlockModel>> getBlockedUsers({required String blockerId}) async {
    try {
      final rows = await client.from(_blocks).select().eq('blocker_id', blockerId).order('created_at', ascending: false);
      return (rows as List).map((e) => UserBlockModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}
