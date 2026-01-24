import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthDatasource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    required String role, // ← agregado aquí
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
  final SupabaseClient client;

  AuthDatasourceImpl({required this.client});

  GoTrueClient get _auth => client.auth;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    required String role, // ← agregado aquí también
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          'role': role,
        },
      );

      if (response.user == null) {
        throw const AuthException(message: 'Error al crear cuenta');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthApiException catch (e) {
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
    } on AuthApiException catch (e) {
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
      return user != null ? UserModel.fromSupabaseUser(user) : null;
    } catch (e) {
      throw AuthException(message: 'Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final redirectUrl = dotenv.env['RESET_PASSWORD_URL'] ??
                         'http://localhost:3000/reset-password';
      await _auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
    } on AuthApiException catch (e) {
      throw AuthException(message: _parseError(e.message));
    } catch (e) {
      throw AuthException(message: 'Error al enviar email: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.onAuthStateChange.map((event) => event.session?.user != null
          ? UserModel.fromSupabaseUser(event.session!.user)
          : null);

  /// Método auxiliar para parsear errores de Supabase
  String _parseError(String message) {
    // Aquí puedes mapear mensajes de Supabase a algo más amigable
    return message;
  }
}
