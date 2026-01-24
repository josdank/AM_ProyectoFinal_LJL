import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class ScheduleVisit implements UseCase<Visit, ScheduleVisitParams> {
  final VisitRepository repository;

  ScheduleVisit(this.repository);

  @override
  Future<Either<Failure, Visit>> call(ScheduleVisitParams params) async {
    return await repository.scheduleVisit(params.visit);
  }
}

class ScheduleVisitParams extends Equatable {
  final Visit visit;

  const ScheduleVisitParams({required this.visit});

  @override
  List<Object?> get props => [visit];
}