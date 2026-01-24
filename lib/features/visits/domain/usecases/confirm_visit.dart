import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class ConfirmVisit implements UseCase<Visit, ConfirmVisitParams> {
  final VisitRepository repository;

  ConfirmVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(ConfirmVisitParams params) async {
    return await repository.confirmVisit(params.visitId);
  }
}

class ConfirmVisitParams extends Equatable {
  final String visitId;

  const ConfirmVisitParams({required this.visitId});

  @override
  List<Object?> get props => [visitId];
}