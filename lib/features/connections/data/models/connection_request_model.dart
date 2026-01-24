import '../../domain/entities/connection_request.dart';

class ConnectionRequestModel extends ConnectionRequest {
  const ConnectionRequestModel({
    required super.id,
    required super.fromUserId,
    required super.toUserId,
    required super.listingId,
    required super.status,
    required super.createdAt,
  });

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestModel(
      id: json['id'].toString(),
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      listingId: json['listing_id'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'listing_id': listingId,
      'status': status,
    };
  }
}
