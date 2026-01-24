import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class CancelVisit implements UseCase<Visit, CancelVisitParams> {
  final VisitRepository repository;

  CancelVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(CancelVisitParams params) async {
    return await repository.cancelVisit(params.visitId);
  }
}

class CancelVisitParams extends Equatable {
  final String visitId;

  const CancelVisitParams({required this.visitId});

  @override
  List<Object?> get props => [visitId];
}