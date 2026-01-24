import '../../domain/entities/user_report.dart';

class UserReportModel extends UserReport {
  const UserReportModel({
    required super.id,
    required super.reporterId,
    required super.reportedId,
    required super.reason,
    required super.details,
    required super.createdAt,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
      id: json['id'].toString(),
      reporterId: json['reporter_id'] as String,
      reportedId: json['reported_id'] as String,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
