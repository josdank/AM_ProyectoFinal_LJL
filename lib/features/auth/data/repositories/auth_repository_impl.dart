import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/user.dart' as app_user;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, app_user.User>> signUp({
    required String email,
    required String password,
    String? fullName,
    List<String> roles = const ['user'],
  }) async {
    try {
      final userModel = await datasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        roles: roles,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));

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
      final userModel = await datasource.signIn(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, app_user.User?>> getCurrentUser() async {
    try {
      final userModel = await datasource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error obteniendo usuario: ${e.toString()}'));
    }
  }

  @override
  Stream<app_user.User?> get authStateChanges {
    return datasource.authStateChanges.map((u) => u?.toEntity());
  }
}
