import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource datasource;

  ProfileRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, Profile>> getProfile(String userId) async {
    try {
      final profile = await datasource.getProfile(userId);
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Profile>> createProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        bio: profile.bio,
        photoUrl: profile.photoUrl,
        birthDate: profile.birthDate,
        gender: profile.gender,
        occupation: profile.occupation,
        university: profile.university,
        phoneNumber: profile.phoneNumber,
        isProfileComplete: profile.isProfileComplete,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      );

      final result = await datasource.createProfile(profileModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        bio: profile.bio,
        photoUrl: profile.photoUrl,
        birthDate: profile.birthDate,
        gender: profile.gender,
        occupation: profile.occupation,
        university: profile.university,
        phoneNumber: profile.phoneNumber,
        isProfileComplete: profile.isProfileComplete,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      );

      final result = await datasource.updateProfile(profileModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto(
      XFile photo, String userId) async {
    try {
      final url = await datasource.uploadProfilePhoto(photo, userId);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePhoto(String userId) async {
    try {
      await datasource.deleteProfilePhoto(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}