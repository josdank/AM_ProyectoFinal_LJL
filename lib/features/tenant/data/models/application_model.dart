import 'package:equatable/equatable.dart';
import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.tenantId,
    required super.listingId,
    super.status = 'pending',
    super.message,
    required super.appliedAt,
    super.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      listingId: json['listing_id'] as String,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'listing_id': listingId,
      'status': status,
      'message': message,
      'applied_at': appliedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Application toEntity() => Application(
    id: id,
    tenantId: tenantId,
    listingId: listingId,
    status: status,
    message: message,
    appliedAt: appliedAt,
    updatedAt: updatedAt,
  );
}