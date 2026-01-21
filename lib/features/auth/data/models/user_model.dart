import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    required super.emailConfirmed,
    super.createdAt,
  });

  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'] as String?,
      emailConfirmed: user.emailConfirmedAt != null,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'email_confirmed': emailConfirmed,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User toEntity() => User(
    id: id,
    email: email,
    fullName: fullName,
    emailConfirmed: emailConfirmed,
    createdAt: createdAt,
  );
}