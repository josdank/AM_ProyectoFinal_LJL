import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.tenantId,
    required super.listingId,
    required super.status,
    super.message,
    required super.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'].toString(),
      listingId: json['listing_id'].toString(),
      status: (json['status'] ?? 'pending').toString(),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
