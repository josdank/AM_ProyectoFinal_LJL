import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_block_model.dart';
import '../models/user_report_model.dart';
import '../models/verification_model.dart';
import '../models/reference_model.dart';

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

  // ===== REFERENCIAS =====
  Future<List<ReferenceModel>> getUserReferences({required String userId});
  Future<ReferenceModel> addReference({required ReferenceModel reference});
  Future<ReferenceModel> updateReference({required ReferenceModel reference});
  Future<void> deleteReference({required String referenceId});
  Future<String> sendVerificationCode({
    required String referenceId,
    required String refereeEmail,
  });
  Future<ReferenceModel> verifyReference({
    required String referenceId,
    required String code,
  });
}

class SecurityDatasourceImpl implements SecurityDatasource {
  final SupabaseClient client;
  SecurityDatasourceImpl({required this.client});

  static const _verifications = 'verifications';
  static const _reports = 'reports';
  static const _blocks = 'user_blocks'; // 🔥 CAMBIADO: 'blocks' → 'user_blocks'
  static const _references = 'references';

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
        'verification_type': type, // 🔥 CAMBIADO: 'type' → 'verification_type'
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
        'reporter': reporterId,     // 🔥 CAMBIADO: 'reporter_id' → 'reporter'
        'reported': reportedId,     // 🔥 CAMBIADO: 'reported_id' → 'reported'
        'category': reason,         // 🔥 CAMBIADO: 'reason' → 'category'
        'description': details,     // 🔥 CAMBIADO: 'details' → 'description'
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

  // ===== REFERENCIAS =====

  @override
  Future<List<ReferenceModel>> getUserReferences({required String userId}) async {
    try {
      final rows = await client
          .from(_references)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (rows as List)
          .map((e) => ReferenceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReferenceModel> addReference({required ReferenceModel reference}) async {
    try {
      final inserted = await client
          .from(_references)
          .insert(reference.toInsertJson())
          .select()
          .single();
      
      return ReferenceModel.fromJson(Map<String, dynamic>.from(inserted));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReferenceModel> updateReference({required ReferenceModel reference}) async {
    try {
      final updated = await client
          .from(_references)
          .update(reference.toUpdateJson())
          .eq('id', reference.id)
          .select()
          .single();
      
      return ReferenceModel.fromJson(Map<String, dynamic>.from(updated));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteReference({required String referenceId}) async {
    try {
      await client.from(_references).delete().eq('id', referenceId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> sendVerificationCode({
    required String referenceId,
    required String refereeEmail,
  }) async {
    try {
      // Llamar a la función de Supabase que genera y envía el código
      final response = await client.rpc(
        'send_verification_code',
        params: {
          'p_reference_id': referenceId,
        },
      );
      
      return response as String;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: 'Error al enviar código: $e');
    }
  }

  @override
  Future<ReferenceModel> verifyReference({
    required String referenceId,
    required String code,
  }) async {
    try {
      // Obtener la referencia
      final reference = await client
          .from(_references)
          .select()
          .eq('id', referenceId)
          .single();
      
      final ref = ReferenceModel.fromJson(Map<String, dynamic>.from(reference));
      
      // Validar código
      if (ref.verificationCode != code) {
        throw const ServerException(message: 'Código de verificación incorrecto');
      }
      
      if (ref.isCodeExpired) {
        throw const ServerException(message: 'El código ha expirado');
      }
      
      // Marcar como verificado
      final updated = await client
          .from(_references)
          .update({
            'verified': true,
            'verified_at': DateTime.now().toIso8601String(), // 🔥 AGREGADO
            'verification_code': null,
          })
          .eq('id', referenceId)
          .select()
          .single();
      
      return ReferenceModel.fromJson(Map<String, dynamic>.from(updated));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error al verificar: $e');
    }
  }

  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}