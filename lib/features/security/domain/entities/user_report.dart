import 'package:equatable/equatable.dart';

class UserReport extends Equatable {
  final String id;
  final String reporterId;
  final String reportedId;
  final String reason;
  final String? details;
  final DateTime createdAt;

  const UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    required this.details,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, reporterId, reportedId, reason, details, createdAt];
}
