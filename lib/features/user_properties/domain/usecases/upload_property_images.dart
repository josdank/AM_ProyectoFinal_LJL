import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_property_repository.dart';

class UploadPropertyImages implements UseCase<List<String>, UploadPropertyImagesParams> {
  final UserPropertyRepository repository;

  UploadPropertyImages(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(UploadPropertyImagesParams params) async {
    return await repository.uploadPropertyImages(
      propertyId: params.propertyId,
      ownerId: params.ownerId,
      imagePaths: params.imagePaths,
    );
  }
}

class UploadPropertyImagesParams extends Equatable {
  final String propertyId;
  final String ownerId;
  final List<String> imagePaths;

  const UploadPropertyImagesParams({
    required this.propertyId,
    required this.ownerId,
    required this.imagePaths,
  });

  @override
  List<Object?> get props => [propertyId, ownerId, imagePaths];
}

