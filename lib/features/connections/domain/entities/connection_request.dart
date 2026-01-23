import 'package:equatable/equatable.dart';

class ConnectionRequest extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String? listingId;
  final String status; // pending | accepted | rejected
  final DateTime createdAt;

  const ConnectionRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.listingId,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fromUserId, toUserId, listingId, status, createdAt];
}
