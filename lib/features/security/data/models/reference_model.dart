import '../../domain/entities/reference.dart';

class ReferenceModel extends Reference {
  const ReferenceModel({
    required super.id,
    required super.userId,
    required super.refereeName,
    required super.refereeEmail,
    required super.refereePhone,
    required super.relationship,
    super.comment,
    super.rating,
    super.verified,
    super.verificationCode,
    super.codeExpiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReferenceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceModel(
      id: json['id'].toString(),
      userId: json['user_id'] as String,
      refereeName: json['referee_name'] as String,
      refereeEmail: json['referee_email'] as String,
      refereePhone: json['referee_phone'] as String,
      relationship: json['relationship'] as String,
      comment: json['comment'] as String?, // ✅ CORREGIDO
      rating: json['rating'] as int?,
      verified: (json['verified'] as bool?) ?? false,
      verificationCode: json['verification_code'] as String?,
      codeExpiresAt: json['code_expires_at'] != null
          ? DateTime.parse(json['code_expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'referee_name': refereeName,
      'referee_email': refereeEmail,
      'referee_phone': refereePhone,
      'relationship': relationship,
      'comment': comment, // ✅ CORREGIDO
      'rating': rating,
      'verified': verified,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'referee_name': refereeName,
      'referee_email': refereeEmail,
      'referee_phone': refereePhone,
      'relationship': relationship,
      'comment': comment, // ✅ CORREGIDO
      'rating': rating,
    };
  }
}
