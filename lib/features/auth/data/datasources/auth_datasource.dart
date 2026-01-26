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
      // 1. Crear usuario en auth.users
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

      // 2. ❌ ELIMINAR este bloque que causaba el error:
      // await client.from('users').upsert({...});

      // ✅ El trigger 'on_auth_user_created_users' se encarga automáticamente
      // de crear el registro en public.users

      return UserModel.fromSupabaseUser(response.user!);
    } on sb.AuthApiException catch (e) {
      throw AuthException(message: _parseError(e.message), code: e.code);
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
  Stream<UserModel?> get authStateChanges => 
      _auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return UserModel.fromSupabaseUser(user);
      });

  String _parseError(String message) => message;
  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}