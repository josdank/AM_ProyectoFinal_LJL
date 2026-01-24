import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class CompleteVisit implements UseCase<Visit, CompleteVisitParams> {
  final VisitRepository repository;

  CompleteVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(CompleteVisitParams params) async {
    return await repository.completeVisit(params.visitId);
  }
}

class CompleteVisitParams extends Equatable {
  final String visitId;

  const CompleteVisitParams({required this.visitId});

  @override
  List<Object?> get props => [visitId];
}