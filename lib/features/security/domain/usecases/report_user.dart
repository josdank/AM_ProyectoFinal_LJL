import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_report.dart';
import '../repositories/security_repository.dart';

class ReportUser implements UseCase<UserReport, ReportUserParams> {
  final SecurityRepository repository;
  ReportUser(this.repository);

  @override
  Future<Either<Failure, UserReport>> call(ReportUserParams params) {
    return repository.reportUser(
      reporterId: params.reporterId,
      reportedId: params.reportedId,
      reason: params.reason,
      details: params.details,
    );
  }
}

class ReportUserParams extends Equatable {
  final String reporterId;
  final String reportedId;
  final String reason;
  final String? details;

  const ReportUserParams({
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [reporterId, reportedId, reason, details];
}
