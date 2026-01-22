import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile(String userId);
  Future<Either<Failure, Profile>> createProfile(Profile profile);
  Future<Either<Failure, Profile>> updateProfile(Profile profile);
  Future<Either<Failure, String>> uploadProfilePhoto(XFile photo, String userId);
  Future<Either<Failure, void>> deleteProfilePhoto(String userId);
}