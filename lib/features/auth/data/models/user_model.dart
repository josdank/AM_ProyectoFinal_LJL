import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    required super.emailConfirmed,
    super.createdAt,
    super.roles = const ['user'], // AGREGAR
  });

  factory UserModel.fromSupabaseUser(supabase.User user) {
    // Obtener roles de user_metadata
    final metadata = user.userMetadata ?? {};
    final roles = List<String>.from(metadata['roles'] ?? ['user']);
    
    return UserModel(
      id: user.id,
      email: user.email!,
      fullName: metadata['full_name'] as String?,
      emailConfirmed: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt!),
      roles: roles, // AGREGAR
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      emailConfirmed: json['email_confirmed'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      roles: List<String>.from(json['roles'] ?? ['user']), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'email_confirmed': emailConfirmed,
      'created_at': createdAt?.toIso8601String(),
      'roles': roles, 
    };
  }

  User toEntity() => User(
    id: id,
    email: email,
    fullName: fullName,
    emailConfirmed: emailConfirmed,
    createdAt: createdAt,
    roles: roles, 
  );
}