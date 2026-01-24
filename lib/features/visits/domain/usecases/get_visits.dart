import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class GetVisits implements UseCase<List<Visit>, GetVisitsParams> {
  final VisitRepository repository;

  GetVisits(this.repository);

  @override
  Future<Either<Failure, List<Visit>>> call(GetVisitsParams params) async {
    if (params.asOwner) {
      return await repository.getVisitsToMyListings(params.userId);
    } else {
      return await repository.getMyVisits(params.userId);
    }
  }
}

class GetVisitsParams extends Equatable {
  final String userId;
  final bool asOwner; // true = visitas a mis propiedades, false = mis visitas

  const GetVisitsParams({
    required this.userId,
    this.asOwner = false,
  });

  @override
  List<Object?> get props => [userId, asOwner];
}