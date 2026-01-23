import 'package:equatable/equatable.dart';

class Verification extends Equatable {
  final String userId;
  final String type; // estudiante | trabajador
  final String status; // pending | verified | rejected
  final DateTime createdAt;

  const Verification({
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, type, status, createdAt];
}
