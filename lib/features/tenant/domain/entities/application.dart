import 'package:equatable/equatable.dart';

class Application extends Equatable {
  final String id;
  final String tenantId;
  final String listingId;
  final String status; // pending/accepted/rejected
  final String? message;
  final DateTime createdAt;

  const Application({
    required this.id,
    required this.tenantId,
    required this.listingId,
    required this.status,
    this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, tenantId, listingId, status, message, createdAt];
}
