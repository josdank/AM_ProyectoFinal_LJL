import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadProfilePhoto implements UseCase<String, UploadProfilePhotoParams> {
  final ProfileRepository repository;
  UploadProfilePhoto(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfilePhotoParams params) async {
    return await repository.uploadProfilePhoto(params.photo, params.userId);
  }
}

class UploadProfilePhotoParams extends Equatable {
  final XFile photo;
  final String userId;

  const UploadProfilePhotoParams({
    required this.photo,
    required this.userId,
  });

  @override
  List<Object?> get props => [photo, userId];
}