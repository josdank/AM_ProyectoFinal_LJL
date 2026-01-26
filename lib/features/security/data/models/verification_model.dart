import '../../domain/entities/verification.dart';

class VerificationModel extends Verification {
  const VerificationModel({
    required super.userId,
    required super.type,
    required super.status,
    required super.createdAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      userId: json['user_id'] as String,
      type: (json['verification_type'] as String?) ?? 'estudiante',
      status: (json['status'] as String?) ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'verification_type': type,
        'status': status,
      };
}