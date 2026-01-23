import '../../domain/entities/user_block.dart';

class UserBlockModel extends UserBlock {
  const UserBlockModel({
    required super.id,
    required super.blockerId,
    required super.blockedId,
    required super.createdAt,
  });

  factory UserBlockModel.fromJson(Map<String, dynamic> json) {
    return UserBlockModel(
      id: json['id'].toString(),
      blockerId: json['blocker_id'] as String,
      blockedId: json['blocked_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
