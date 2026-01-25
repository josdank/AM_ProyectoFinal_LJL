import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as app_user;
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabaseClient;

  AuthRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, app_user.User>> signUp({
    required String email,
    required String password,
    String? fullName,
    List<String> roles = const ['user'],
  }) async {
    try {
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'roles': roles,
        },
      );

      if (authResponse.user == null) {
        return Left(ServerFailure(message: 'No se pudo crear el usuario'));
      }

      // Crear registro en la tabla public.users
      await supabaseClient.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'roles': roles,
        'email_confirmed': authResponse.user!.emailConfirmedAt != null,
      }); 
      final user = UserModel.fromSupabaseUser(authResponse.user!);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, app_user.User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = UserModel.fromSupabaseUser(authResponse.user!);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, app_user.User?>> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        return const Right(null);
      }

      final user = session.user;
      if (user == null) {
        return const Right(null);
      }

      // Obtener datos completos de la tabla users
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      if (response == null) { 
        return const Right(null);
      }

      final userModel = UserModel.fromJson(response);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error obteniendo usuario: ${e.toString()}'));
    }
  }

  @override
  Stream<app_user.User?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user).toEntity();
    });
  }
}