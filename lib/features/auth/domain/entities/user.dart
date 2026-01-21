import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final bool emailConfirmed;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.emailConfirmed,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, fullName, emailConfirmed, createdAt];
}