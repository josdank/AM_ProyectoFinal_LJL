import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';


abstract class AuthDatasource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    required List<String> roles,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserModel?> get authStateChanges;
}

class AuthDatasourceImpl implements AuthDatasource {
  final sb.SupabaseClient client;

  AuthDatasourceImpl({required this.client});

  sb.GoTrueClient get _auth => client.auth;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    required List<String> roles,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          'roles': roles,
        },
      );

      if (response.user == null) {
        throw const AuthException(message: 'Error al crear cuenta');
      }

      //Insertar/Upsert en tabla public.users para que quede persistente
      // (Esto evita depender solo de user_metadata)
      await client.from('users').upsert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'roles': roles,
        'email_confirmed': response.user!.emailConfirmedAt != null,
      });

      return UserModel.fromSupabaseUser(response.user!);
    } on sb.AuthApiException catch (e) {
      throw AuthException(message: _parseError(e.message), code: e.code);
    } on sb.PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: _tryInt(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(message: 'Credenciales inválidas');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on sb.AuthApiException catch (e) {
      throw AuthException(message: _parseError(e.message), code: e.code);
    } catch (e) {
      throw AuthException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      //Traer roles reales desde public.users si existe
      try {
        final row = await client.from('users').select().eq('id', user.id).maybeSingle();
        if (row != null) {
          return UserModel.fromJson(Map<String, dynamic>.from(row));
        }
      } catch (_) {
        // si falla, caemos a metadata
      }

      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw AuthException(message: 'Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final redirectUrl = dotenv.env['RESET_PASSWORD_URL'] ??
          'https://ljl-colive.netlify.app/reset/';
      await _auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
    } on sb.AuthApiException catch (e) {
      throw AuthException(message: _parseError(e.message));
    } catch (e) {
      throw AuthException(message: 'Error al enviar email: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _auth.onAuthStateChange.asyncMap((event) async {
        final user = event.session?.user;
        if (user == null) return null;

        //intentar traer desde public.users
        try {
          final row = await client.from('users').select().eq('id', user.id).maybeSingle();
          if (row != null) {
            return UserModel.fromJson(Map<String, dynamic>.from(row));
          }
        } catch (_) {}

        return UserModel.fromSupabaseUser(user);
      });

  String _parseError(String message) => message;

  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}
