import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.bio,
    super.photoUrl,
    super.birthDate,
    super.gender,
    super.occupation,
    super.university,
    super.phoneNumber,
    required super.isProfileComplete,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      occupation: json['occupation'] as String?,
      university: json['university'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'bio': bio,
      'photo_url': photoUrl,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'occupation': occupation,
      'university': university,
      'phone_number': phoneNumber,
      'is_profile_complete': isProfileComplete,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile toEntity() => Profile(
        id: id,
        userId: userId,
        fullName: fullName,
        bio: bio,
        photoUrl: photoUrl,
        birthDate: birthDate,
        gender: gender,
        occupation: occupation,
        university: university,
        phoneNumber: phoneNumber,
        isProfileComplete: isProfileComplete,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}