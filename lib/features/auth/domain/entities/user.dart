import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final bool emailConfirmed;
  final DateTime? createdAt;
  final List<String> roles; // AGREGAR

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.emailConfirmed,
    this.createdAt,
    this.roles = const ['user'], // VALOR POR DEFECTO
  });

  // Helper methods para roles
  bool isTenant() => roles.contains('tenant');
  bool isLandlord() => roles.contains('landlord');
  bool isAdmin() => roles.contains('admin');
  bool hasAnyRole(List<String> checkRoles) {
    return roles.any((role) => checkRoles.contains(role));
  }

  @override
  List<Object?> get props => [
    id, 
    email, 
    fullName, 
    emailConfirmed, 
    createdAt,
    roles, // AGREGAR
  ];
}