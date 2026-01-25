import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reference.dart';
import '../repositories/security_repository.dart';

class AddReference implements UseCase<Reference, AddReferenceParams> {
  final SecurityRepository repository;
  AddReference(this.repository);

  @override
  Future<Either<Failure, Reference>> call(AddReferenceParams params) {
    return repository.addReference(
      userId: params.userId,
      refereeName: params.refereeName,
      refereeEmail: params.refereeEmail,
      refereePhone: params.refereePhone,
      relationship: params.relationship,
      comments: params.comments,
      rating: params.rating,
    );
  }
}

class AddReferenceParams extends Equatable {
  final String userId;
  final String refereeName;
  final String refereeEmail;
  final String refereePhone;
  final String relationship;
  final String? comments;
  final int? rating;

  const AddReferenceParams({
    required this.userId,
    required this.refereeName,
    required this.refereeEmail,
    required this.refereePhone,
    required this.relationship,
    this.comments,
    this.rating,
  });

  @override
  List<Object?> get props => [
        userId,
        refereeName,
        refereeEmail,
        refereePhone,
        relationship,
        comments,
        rating,
      ];
}