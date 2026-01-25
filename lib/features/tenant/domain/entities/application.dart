import 'package:equatable/equatable.dart';

class Application extends Equatable {
  final String id;
  final String tenantId;
  final String listingId;
  final String status;
  final String? message;
  final DateTime appliedAt;
  final DateTime? updatedAt;

  const Application({
    required this.id,
    required this.tenantId,
    required this.listingId,
    this.status = 'pending',
    this.message,
    required this.appliedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, tenantId, listingId, status, 
    message, appliedAt, updatedAt
  ];
}