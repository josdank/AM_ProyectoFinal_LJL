import 'package:equatable/equatable.dart';

/// Perfil de usuario en la app.
/// 
/// Nota: para mantener compatibilidad con datos existentes, [role] tiene
/// valor por defecto 'tenant' cuando no viene desde la BD.
class Profile extends Equatable {
  final String id;
  final String fullName;
  final String role; // tenant | owner | admin (extensible)
  final String? bio;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? gender;
  final String? occupation;
  final String? university;
  final String? phoneNumber;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.role = 'tenant',
    this.bio,
    this.photoUrl,
    this.birthDate,
    this.gender,
    this.occupation,
    this.university,
    this.phoneNumber,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  bool get isTenant => role == 'tenant';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [
        id,
        fullName,
        role,
        bio,
        photoUrl,
        birthDate,
        gender,
        occupation,
        university,
        phoneNumber,
        isProfileComplete,
        createdAt,
        updatedAt,
      ];
}
